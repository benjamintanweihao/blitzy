require Logger

defmodule Blitzy.CLI do

  def main(args) do
    options = args |> parse_args

    do_requests(options[:url], options[:requests])
  end

  defp parse_args(args) do
    {[requests: n], [url], []} = OptionParser.parse(args, aliases: [n: :requests])
    %{url: url, requests: String.to_integer(n)}
  end

  defp do_requests(url, requests) do
    Logger.info "Pummelling #{url} with #{requests} requests"
  end

end
