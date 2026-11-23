defmodule Backend.ApiWeb.Router do
  @moduledoc "Routes GraphQL requests to the Absinthe schema."

  use Phoenix.Router

  pipeline :graphql do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: Backend.Graphql.Schema
  end
end
