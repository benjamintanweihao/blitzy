require Logger

defmodule Blitzy.CLI do

  def main(args) do
    args |> parse_args |> process_options
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests])
  end

  defp process_options(options) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(url, n)
      _ -> do_help
    end
  end

  defp do_requests(url, requests) do
    Logger.info "Pummelling #{url} with #{requests} requests"
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

end
