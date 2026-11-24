defmodule Backend.Journal.Commands.TravelOn do
  @moduledoc "Moves a journey from its current place to the next one, once that place has an entry, drawing any encounter on the road and setting the scene in each new town."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.EncounterDraw
  alias Backend.Journal.PlaceScene
  alias Backend.Journal.Queries.GetJourneyProgress
  alias Backend.Journal.Route
  alias Ecto.Changeset
  alias Ecto.Multi

  def execute(journey_id) do
    case Repo.get(Journey, journey_id) do
      %Journey{} = journey -> travel_on(journey, GetJourneyProgress.run(journey))
      nil -> {:error, :journey_not_found}
    end
  end

  defp travel_on(_journey, %{current_point_of_interest_index: nil}),
    do: {:error, :journey_finished}

  defp travel_on(_journey, %{can_travel_on: false}), do: {:error, :no_entry_here}

  defp travel_on(%Journey{current_encounter_id: encounter_id} = journey, _progress)
       when not is_nil(encounter_id) do
    journey
    |> Changeset.change(current_encounter_id: nil)
    |> arrive_at(journey.current_point_of_interest_index + 1)
    |> Repo.update()
  end

  defp travel_on(%Journey{current_point_of_interest_index: index} = journey, _progress) do
    if index == Route.point_of_interest_count() - 1 do
      journey |> Changeset.change(finished_at: DateTime.utc_now(:second)) |> Repo.update()
    else
      leave_point_of_interest(journey, EncounterDraw.after_point_of_interest(journey, index))
    end
  end

  defp leave_point_of_interest(journey, nil) do
    journey
    |> Changeset.change(
      current_point_of_interest_index: journey.current_point_of_interest_index + 1
    )
    |> Repo.update()
  end

  defp leave_point_of_interest(journey, encounter_kind) do
    Multi.new()
    |> Multi.insert(:encounter, %Encounter{
      journey_id: journey.id,
      after_point_of_interest_index: journey.current_point_of_interest_index,
      kind: encounter_kind
    })
    |> Multi.update(:journey, fn %{encounter: encounter} ->
      Changeset.change(journey, current_encounter_id: encounter.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{journey: journey}} -> {:ok, journey}
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end

  defp arrive_at(%Changeset{data: journey} = changeset, point_of_interest_index) do
    Changeset.change(changeset,
      current_point_of_interest_index: point_of_interest_index,
      current_place_scene: PlaceScene.for_arrival(journey, point_of_interest_index)
    )
  end
end
