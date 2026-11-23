defmodule Backend.Journal.Application do
  @moduledoc "Starts the PubSub server that announces when an analysis ends."

  use Application

  @impl true
  def start(_type, _arguments) do
    children = [{Phoenix.PubSub, name: Backend.Journal.PubSub}]
    Supervisor.start_link(children, strategy: :one_for_one, name: Backend.Journal.Supervisor)
  end
end
