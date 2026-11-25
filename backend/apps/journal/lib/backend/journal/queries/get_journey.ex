defmodule Backend.Journal.Queries.GetJourney do
  @moduledoc "Reads one journey by id, or nil when no journey has that id."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  def run(journey_id), do: Repo.get(Journey, journey_id)
end
