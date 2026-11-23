defmodule Backend.Graphql.Schema do
  @moduledoc "The GraphQL schema the frontend talks to."

  use Absinthe.Schema

  query do
    @desc "Answers ok when the API is up."
    field :status, non_null(:string) do
      resolve(fn _parent, _arguments, _resolution -> {:ok, "ok"} end)
    end
  end
end
