require Logger

defmodule Blitzy.Coordinator do
  use GenServer

  alias Blitzy.Worker

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def run(n_workers, url) do
    GenServer.call(__MODULE__, {:run, n_workers, url})
  end

  #############
  # Callbacks #
  #############

  def init(:ok) do
    {:ok, {}}
  end

  def handle_call({:run, n_workers, url}, _from, state) when n_workers > 0 do
    result =
      1..n_workers
      |> Enum.map(fn _ -> Task.async(Worker, :start, [url]) end)
      |> Enum.map(&(Task.await(&1, :infinity)))

    {:reply, state, result}
  end

end
