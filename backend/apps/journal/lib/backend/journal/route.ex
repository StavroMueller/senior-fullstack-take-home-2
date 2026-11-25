defmodule Backend.Journal.Route do
  @moduledoc "Draws a journey's points of interest from its seed: a start and an end far apart, and towns along the line between them."

  alias Backend.Database.Schema.Journey

  @shortest_route_km 400
  @earth_radius_km 6_371
  @widest_detour_km 60
  @points_of_interest_between 3
  @km_per_degree_latitude 110.57
  @km_per_degree_longitude 111.32 * :math.cos(46.5 * :math.pi() / 180)

  @doc "Returns the journey's points of interest in route order, start first; one seed always draws the same route."
  def points_of_interest(%Journey{seed: seed, language: language}) do
    towns = read_towns(language)
    draw(towns, :rand.seed_s(:exsss, seed))
  end

  @doc "Returns the country the route for a language crosses."
  def country(language), do: language |> read_route() |> Map.fetch!("country")

  @doc "Counts the points of interest on every route."
  def point_of_interest_count, do: @points_of_interest_between + 2

  defp draw(towns, random_state) do
    {start, random_state} = pick(towns, random_state)
    far_towns = Enum.filter(towns, &(great_circle_km(start, &1) >= @shortest_route_km))
    {finish, random_state} = pick(far_towns, random_state)

    case towns_between(towns, start, finish, 1, random_state) do
      {:ok, between} -> [start | between] ++ [finish]
      {:redraw, random_state} -> draw(towns, random_state)
    end
  end

  defp towns_between(_towns, _start, _finish, position, _random_state)
       when position > @points_of_interest_between,
       do: {:ok, []}

  defp towns_between(towns, start, finish, position, random_state) do
    case Enum.filter(towns, &near_line_at?(&1, start, finish, position)) do
      [] ->
        {:redraw, random_state}

      candidates ->
        {town, random_state} = pick(candidates, random_state)

        case towns_between(towns, start, finish, position + 1, random_state) do
          {:ok, later_towns} -> {:ok, [town | later_towns]}
          {:redraw, random_state} -> {:redraw, random_state}
        end
    end
  end

  defp near_line_at?(town, start, finish, position) do
    window_width = 1 / (@points_of_interest_between + 1)
    window_center = position * window_width
    {along, aside_km} = place_on_line(town, start, finish)

    abs(along - window_center) < window_width / 2 and aside_km <= @widest_detour_km
  end

  defp place_on_line(town, start, finish) do
    {start_x, start_y} = to_km(start)
    {finish_x, finish_y} = to_km(finish)
    {town_x, town_y} = to_km(town)
    {line_x, line_y} = {finish_x - start_x, finish_y - start_y}
    line_length = :math.sqrt(line_x * line_x + line_y * line_y)
    {offset_x, offset_y} = {town_x - start_x, town_y - start_y}

    along = (offset_x * line_x + offset_y * line_y) / (line_length * line_length)
    aside_km = abs(offset_x * line_y - offset_y * line_x) / line_length
    {along, aside_km}
  end

  defp great_circle_km(town, other_town) do
    latitude = radians(town.latitude)
    other_latitude = radians(other_town.latitude)
    half_latitude_change = (other_latitude - latitude) / 2
    half_longitude_change = radians(other_town.longitude - town.longitude) / 2

    haversine =
      :math.pow(:math.sin(half_latitude_change), 2) +
        :math.cos(latitude) * :math.cos(other_latitude) *
          :math.pow(:math.sin(half_longitude_change), 2)

    2 * @earth_radius_km * :math.asin(:math.sqrt(haversine))
  end

  defp radians(degrees), do: degrees * :math.pi() / 180

  defp to_km(%{longitude: longitude, latitude: latitude}),
    do: {longitude * @km_per_degree_longitude, latitude * @km_per_degree_latitude}

  defp pick(towns, random_state) do
    {position, random_state} = :rand.uniform_s(length(towns), random_state)
    {Enum.at(towns, position - 1), random_state}
  end

  defp read_route(language) do
    :journal
    |> Application.app_dir("priv/routes/#{language}.json")
    |> File.read!()
    |> Jason.decode!()
  end

  defp read_towns(language) do
    language
    |> read_route()
    |> Map.fetch!("towns")
    |> Enum.map(fn town ->
      %{name: town["name"], longitude: town["longitude"], latitude: town["latitude"]}
    end)
  end
end
