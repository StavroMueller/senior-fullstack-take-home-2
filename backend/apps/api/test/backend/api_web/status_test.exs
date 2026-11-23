defmodule Backend.ApiWeb.StatusTest do
  @moduledoc "The GraphQL endpoint answers through Phoenix and Absinthe."

  use Backend.ApiWeb.GraphqlCase, async: true

  test "the status query answers ok" do
    assert graphql("query { status }") == %{"data" => %{"status" => "ok"}}
  end
end
