defmodule Backend.Journal.Queries.GetJourneyProgress do
  @moduledoc "Reads where a journey's next entry goes: the open encounter, the next point of interest, or nowhere once the journey is finished."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  @doc "Returns the encounter waiting for an entry, or nil, and the index of the next point of interest, or nil when the journey is finished."
  def run(%Journey{id: journey_id}) do
    %{
      open_encounter: open_encounter(journey_id),
      next_point_of_interest_index: next_point_of_interest_index(journey_id)
    }
  end

  defp open_encounter(journey_id) do
    Encounter
    |> join(:left, [encounter], entry in assoc(encounter, :entry))
    |> where([encounter, entry], encounter.journey_id == ^journey_id and is_nil(entry.id))
    |> Repo.one()
  end

  defp next_point_of_interest_index(journey_id) do
    written =
      Entry
      |> where([entry], entry.journey_id == ^journey_id)
      |> where([entry], not is_nil(entry.point_of_interest_index))
      |> Repo.aggregate(:count)

    if written < Route.point_of_interest_count(), do: written
  end
end
