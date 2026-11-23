defmodule Backend.ApiWeb.GraphqlCase do
  @moduledoc "A test case that posts GraphQL documents through the real endpoint."

  use ExUnit.CaseTemplate

  alias Backend.ApiWeb.Endpoint
  alias Backend.Database.Test.DataCase
  alias Phoenix.ConnTest

  using do
    quote do
      import Backend.ApiWeb.GraphqlCase
    end
  end

  setup tags do
    DataCase.check_out_repo(tags)
  end

  def graphql(document, variables \\ %{}) do
    ConnTest.build_conn()
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> ConnTest.dispatch(Endpoint, :post, "/api/graphql", %{query: document, variables: variables})
    |> ConnTest.json_response(200)
  end
end
