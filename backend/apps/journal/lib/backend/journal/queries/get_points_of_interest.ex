defmodule Backend.Journal.Queries.GetPointsOfInterest do
  @moduledoc "Reads a journey's points of interest in route order, drawn from its seed."

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  def run(%Journey{} = journey), do: Route.points_of_interest(journey)
end
