defmodule Backend.Api.Application do
  @moduledoc "Starts Oban and the endpoint."

  use Application

  alias Backend.ApiWeb.Endpoint

  @impl true
  def start(_type, _arguments) do
    children = [
      {Oban, Application.fetch_env!(:api, Oban)},
      Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Backend.Api.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
