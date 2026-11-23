defmodule Backend.Journal.RouteTest do
  @moduledoc "Checks that every seed draws five real towns, far apart at the ends and close to the line between."

  use ExUnit.Case, async: true

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  @earth_radius_km 6_371

  defp journey(seed), do: %Journey{seed: seed, language: "fr", level: "A1"}

  defp great_circle_km(town, other_town) do
    [latitude, other_latitude] = Enum.map([town.latitude, other_town.latitude], &radians/1)
    latitude_change = other_latitude - latitude
    longitude_change = radians(other_town.longitude - town.longitude)

    haversine =
      :math.pow(:math.sin(latitude_change / 2), 2) +
        :math.cos(latitude) * :math.cos(other_latitude) *
          :math.pow(:math.sin(longitude_change / 2), 2)

    2 * @earth_radius_km * :math.asin(:math.sqrt(haversine))
  end

  defp radians(degrees), do: degrees * :math.pi() / 180

  test "a seed pins its route" do
    names = journey(42) |> Route.points_of_interest() |> Enum.map(& &1.name)

    assert names == ["Nancy", "Troyes", "Bourges", "Tours", "La Rochelle"]
  end

  test "every seed draws five different towns with the ends at least 400 km apart" do
    for seed <- 1..200 do
      points_of_interest = Route.points_of_interest(journey(seed))
      start = List.first(points_of_interest)
      finish = List.last(points_of_interest)

      assert length(points_of_interest) == Route.point_of_interest_count()
      assert points_of_interest |> Enum.uniq() |> length() == Route.point_of_interest_count()
      assert great_circle_km(start, finish) >= 400
    end
  end

  test "every seed puts each town farther from the start than the one before" do
    for seed <- 1..200 do
      points_of_interest = Route.points_of_interest(journey(seed))
      start = List.first(points_of_interest)
      distances_from_start = Enum.map(points_of_interest, &great_circle_km(start, &1))

      assert distances_from_start == Enum.sort(distances_from_start)
    end
  end
end
