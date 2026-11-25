defmodule Backend.ApiWeb.JourneyListTest do
  @moduledoc "Lists every journey over GraphQL, with the country its route crosses and its entries."

  use Backend.ApiWeb.GraphqlCase, async: false

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  test "lists journeys, the one started most recently first, each with its country" do
    older =
      Repo.insert!(%Journey{
        seed: 1,
        language: "fr",
        level: "A1",
        inserted_at: ~U[2026-11-01 09:00:00Z]
      })

    newer =
      Repo.insert!(%Journey{
        seed: 2,
        language: "fr",
        level: "A1",
        inserted_at: ~U[2026-11-20 09:00:00Z]
      })

    assert %{"data" => %{"journeys" => journeys}} =
             graphql("query { journeys { id country entries { id } } }")

    assert journeys == [
             %{"id" => Integer.to_string(newer.id), "country" => "France", "entries" => []},
             %{"id" => Integer.to_string(older.id), "country" => "France", "entries" => []}
           ]
  end

  test "reads null for a journey id that does not exist" do
    assert %{"data" => %{"journey" => nil}} =
             graphql("query { journey(id: \"999999\") { id } }")
  end
end
