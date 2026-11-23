defmodule Backend.Journal.EncounterDrawTest do
  @moduledoc "Pins which encounters a seed places along its route."

  use ExUnit.Case, async: true

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.EncounterDraw
  alias Backend.Journal.Route

  defp journey(seed), do: %Journey{seed: seed, language: "fr", level: "A1"}

  defp encounters_along(journey) do
    for index <- 0..(Route.point_of_interest_count() - 1),
        do: EncounterDraw.after_point_of_interest(journey, index)
  end

  test "a seed pins the encounter after each point of interest" do
    assert encounters_along(journey(1)) == [:ghost_baker, nil, :lost_knight, :giant_snail, nil]
  end

  test "no encounter follows the last point of interest" do
    last_index = Route.point_of_interest_count() - 1

    for seed <- 1..200 do
      assert EncounterDraw.after_point_of_interest(journey(seed), last_index) == nil
    end
  end

  test "some gaps between points of interest hold an encounter and some do not" do
    drawn = Enum.flat_map(1..200, &(&1 |> journey() |> encounters_along() |> Enum.drop(-1)))

    assert Enum.any?(drawn, &is_nil/1)
    assert Enum.any?(drawn, &(&1 != nil))
  end
end
