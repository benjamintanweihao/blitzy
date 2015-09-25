defmodule Blitzy.Worker do
  use Timex

  def start(url) do
    {timestamp, response} = Time.measure(fn -> HTTPoison.get(url) end)
    handle_response({Time.to_msecs(timestamp), response})
  end

  defp handle_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}})
  when code >= 200 and code <= 304 do
    {:ok, msecs}
  end

  defp handle_response({_msecs, {:error, reason}}) do
    {:error, reason}
  end

  defp handle_response({_msecs, _}) do
    {:error, :unknown}
  end

end
