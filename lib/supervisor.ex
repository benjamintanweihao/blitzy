defmodule Blitzy.Supervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Blitzy.Coordinator, [])
    ]

    opts = [strategy: :one_for_one]

    supervise(children, opts)
  end

end
