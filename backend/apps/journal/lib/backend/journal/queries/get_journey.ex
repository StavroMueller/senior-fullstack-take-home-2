defmodule Backend.Journal.Queries.GetJourney do
  @moduledoc "Reads one journey by id with its encounters and entries, or nil when no journey has that id."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  def run(journey_id) do
    Journey
    |> Repo.get(journey_id)
    |> Repo.preload([:encounters, entries: [:corrections, :encounter]])
  end
end
