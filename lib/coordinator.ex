defmodule Blitzy.Coordinator do

  def start(n_workers) do
    do_process_workers(n_workers, 0, empty_result)
  end

  defp do_process_workers(n_workers, n_workers, result) do
    result
  end

  defp do_process_workers(n_workers, n_processed, result) do
    receive do
      {:ok, id, time_elapsed_in_msecs} ->
        result = %{result | n_succeed: result.n_succeed + 1} 
        result = %{result | total_time_elapsed: result.total_time_elapsed + time_elapsed_in_msecs}

        do_process_workers(n_workers, n_processed + 1, result)

      {:error, id, :timeout} ->
        do_process_workers(n_workers, n_processed + 1, %{result | n_fail: result.n_fail + 1})

      {:error, id, :unknown} ->
        do_process_workers(n_workers, n_processed + 1, %{result | n_fail: result.n_fail + 1})
    end
  end

  defp empty_result do
    %{n_succeed: 0, n_fail: 0, total_time_elapsed: 0}
  end

end
