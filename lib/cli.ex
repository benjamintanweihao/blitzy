require Logger

defmodule Blitzy.CLI do

  alias Blitzy.Coordinator
  alias Blitzy.WorkerTasks

  def main(args) do
    # Start master node
    Application.get_env(:blitzy, :master_node) |> Node.start

    # Start slave nodes
    slave_nodes = Application.get_env(:blitzy, :slave_nodes)
                  |> Enum.filter(&Node.connect(&1))

    args
    |> parse_args
    |> process_options([node|slave_nodes])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests], strict: [requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(url, n, nodes)

      _ ->
        do_help

    end
  end

  defp do_requests(url, n_requests, nodes) do
    Logger.info "Pummelling #{url} with #{n_requests} requests"

    total_nodes  = Enum.count(nodes)
    req_per_node = div(n_requests, total_nodes)

    tasks = nodes |> Enum.map(fn node ->
      Task.Supervisor.async({WorkerTasks, node}, Coordinator, :run, [req_per_node, url])
    end)

    tasks
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.flatten
    |> parse_results

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

  defp parse_results(results) do
    IO.inspect results
  end

end
