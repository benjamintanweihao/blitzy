require Logger

defmodule Blitzy.CLI do

  alias Blitzy.Coordinator
  alias Blitzy.Worker

  def main(args) do
    # Start master node
    Application.get_env(:blitz, :master_node) |> Node.start

    # Start slave nodes
    slave_nodes = Application.get_env(:blitz, :slave_nodes) |> Enum.filter(&Node.connect(&1))

    args |> parse_args |> process_options([node|slave_nodes])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests], strict: [requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(url, n, nodes)
      _ -> do_help
    end
  end

  defp do_requests(url, n_requests, nodes) do
    Logger.info "Pummelling #{url} with #{n_requests} requests"

    total_nodes = Enum.count(nodes)
    requests_per_node = div(n_requests, total_nodes)
    
    tasks = nodes |> Enum.map(fn node -> 
      Task.Supervisor.async({:coord_tasks_sup, node}, Coordinator, :start, [requests_per_node])
    end)

    # this function needs to run on all the nodes.
    Enum.each(nodes, fn node -> 
      Enum.each(1..requests_per_node, fn i -> 
        Node.spawn(node, Worker, :start, [url, i])         
      end)
    end)

    # Await for all the coordinator tasks
    tasks |> Enum.map(fn task ->
      Task.await(task, :infinity) |> parse_results
    end)

  end

  defp do_help do
    IO.puts """
      Usage:
        blitzy -n [requests] [url]

      Options:
        -n, [--requests]      # Number of requests

      Example:
        ./blitzy -n 100 http://www.example.com
    """
    System.halt(0)
  end

  defp parse_results(%{n_fail: n_fail, n_succeed: n_succeed, total_time_elapsed: total_time_elapsed}) do
    average_time = total_time_elapsed / n_succeed

    IO.puts """
      Succeeded         : #{n_succeed}
      Failures          : #{n_fail}
      Total time (msecs): #{total_time_elapsed}
      Avg time   (msecs): #{average_time}
    """
  end

end
