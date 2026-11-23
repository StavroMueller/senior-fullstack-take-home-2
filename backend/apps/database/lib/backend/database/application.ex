defmodule Backend.Database.Application do
  @moduledoc "Starts the repo."

  use Application

  @impl true
  def start(_type, _arguments) do
    Supervisor.start_link([Backend.Database.Repo],
      strategy: :one_for_one,
      name: Backend.Database.Supervisor
    )
  end
end
