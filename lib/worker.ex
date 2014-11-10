use Timex
require Logger

defmodule Blitzy.Worker do
  alias Blitzy.Coordinator

  def start(url, id) do
    now    = Time.now
    result = url |> HTTPoison.get |> do_request(id, now)
    send(Coordinator, result)
  end

  defp do_request({:ok, %HTTPoison.Response{status_code: code}}, id, time_start) when code >= 200 and code <= 304 do
    time_elapsed = Time.elapsed(time_start, :msecs) * -1
    Logger.info "worker [#{node}-#{id}] completed in #{time_elapsed} msecs"
    {:ok, time_elapsed}
  end

  defp do_request({:error, %HTTPoison.Error{reason: :connect_timeout}}, id, _time_start) do
    Logger.info "worker [#{node}-#{id}] timed out"
    {:error, :timeout}
  end

  defp do_request(_, id, _time_start) do
    Logger.info "worker [#{node}-#{id}] errored out"
    {:error, :unknown}
  end

end
