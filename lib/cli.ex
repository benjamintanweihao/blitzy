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

    coord_task = Task.async(Coordinator, :start, [n_requests])
    Process.register(coord_task.pid, Coordinator)
  
    Enum.map(1..n_requests, fn i -> 
      spawn(Worker, :start, [url, i])         
    end)

    Task.await(coord_task, :infinity) |> parse_results
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
