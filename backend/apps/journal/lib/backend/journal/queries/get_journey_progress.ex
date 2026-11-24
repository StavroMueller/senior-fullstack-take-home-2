defmodule Backend.Journal.Queries.GetJourneyProgress do
  @moduledoc "Reads where a journey's entries go now: its current encounter or point of interest, or nowhere once finished, and whether it can travel on."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey

  @doc "Returns the encounter the person is at, or nil, the index of the point of interest they are at, or nil once finished, and whether the current place has an entry."
  def run(%Journey{} = journey) do
    %Journey{current_encounter: open_encounter} = Repo.preload(journey, :current_encounter)

    %{
      open_encounter: open_encounter,
      current_point_of_interest_index: current_point_of_interest_index(journey),
      can_travel_on: is_nil(journey.finished_at) and Repo.exists?(entries_here(journey))
    }
  end

  defp current_point_of_interest_index(%Journey{finished_at: nil} = journey),
    do: journey.current_point_of_interest_index

  defp current_point_of_interest_index(%Journey{}), do: nil

  defp entries_here(%Journey{current_encounter_id: nil} = journey) do
    where(
      Entry,
      [entry],
      entry.journey_id == ^journey.id and
        entry.point_of_interest_index == ^journey.current_point_of_interest_index
    )
  end

  defp entries_here(%Journey{current_encounter_id: encounter_id}),
    do: where(Entry, [entry], entry.encounter_id == ^encounter_id)
end
