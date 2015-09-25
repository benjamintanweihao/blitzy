require Logger

defmodule Blitzy.Worker do
  use Timex

  alias Blitzy.Coordinator

  def start(url, id) do
    {timestamp, response} = Time.measure(fn -> HTTPoison.get(url) end)
    send(Coordinator, handle_response({Time.to_msecs(timestamp), response}, id))
  end

  defp handle_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}}, id)
  when code >= 200 and code <= 304 do
    Logger.info "worker [#{node}-#{id}] completed in #{msecs} msecs"
    {:ok, msecs}
  end

  defp handle_response({_msecs, {:error, %HTTPoison.Error{reason: :connect_timeout}}}, id) do
    Logger.info "worker [#{node}-#{id}] timed out"
    {:error, :timeout}
  end

  defp handle_response({_msecs, _response}, id) do
    Logger.info "worker [#{node}-#{id}] errored out"
    {:error, :unknown}
  end

end
