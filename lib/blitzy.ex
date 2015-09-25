defmodule Blitzy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Task.Supervisor, [[name: :coord_tasks_sup]])
    ]

    Blitzy.Supervisor.start_link(:ok)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
