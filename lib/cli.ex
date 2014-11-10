require Logger

defmodule Blitzy.CLI do

  alias Blitzy.Coordinator
  alias Blitzy.Worker

  def main(args) do
    args |> parse_args |> process_options
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests])
  end

  defp process_options(options) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(url, String.to_integer(n))
      _ -> do_help
    end
  end

  defp do_requests(url, n_requests) do
    Logger.info "Pummelling #{url} with #{n_requests} requests"

    Node.start(:"one@127.0.0.1")
    Node.connect(:"two@127.0.0.1")

    total_nodes = Enum.count(all_nodes)
    requests_per_node = div(n_requests, total_nodes)
    
    tasks = all_nodes |> Enum.map(fn node -> 
      Task.Supervisor.async({:coord_tasks_sup, node}, Coordinator, :start, [requests_per_node])
    end)

    # this function needs to run on all the nodes.
    Enum.each(all_nodes, fn node -> 
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

  defp all_nodes do
    [node | Node.list]
  end

end
