defmodule Backend.Journal.Queries.GetJourneyProgress do
  @moduledoc "Reads where a journey's entries go now, whether it can travel on, and the scene the teacher sets at the current place."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.EncounterPrompt

  @doc "Returns the encounter the person is at, or nil, the index of the point of interest they are at, or nil once finished, whether the current place has an entry, and the scene the teacher sets there."
  def run(%Journey{} = journey) do
    %Journey{current_encounter: open_encounter} = Repo.preload(journey, :current_encounter)

    %{
      open_encounter: open_encounter,
      current_point_of_interest_index: current_point_of_interest_index(journey),
      can_travel_on: is_nil(journey.finished_at) and Repo.exists?(entries_here(journey)),
      current_scene: current_scene(journey, open_encounter)
    }
  end

  defp current_scene(%Journey{finished_at: nil} = journey, %Encounter{} = encounter),
    do: EncounterPrompt.for_encounter(encounter, journey)

  defp current_scene(%Journey{finished_at: nil} = journey, nil), do: journey.current_place_scene
  defp current_scene(%Journey{}, _open_encounter), do: nil

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
