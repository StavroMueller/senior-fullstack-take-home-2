defmodule Backend.Journal.Commands.SubmitEntry do
  @moduledoc "Saves an entry at the journey's next place, draws any encounter that follows, and enqueues its analysis in one transaction."

  import Ecto.Changeset

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.EncounterDraw
  alias Backend.Journal.Jobs.AnalyzeEntry
  alias Backend.Journal.Queries.GetJourneyProgress
  alias Ecto.Multi

  @longest_body 2_000

  def execute(%{journey_id: journey_id, body: body}) do
    case Repo.get(Journey, journey_id) do
      %Journey{} = journey -> write_at_next_place(journey, body)
      nil -> {:error, :journey_not_found}
    end
  end

  defp write_at_next_place(journey, body) do
    case GetJourneyProgress.run(journey) do
      %{open_encounter: %Encounter{} = encounter} ->
        journey |> entry_changeset(body, %{encounter_id: encounter.id}) |> save()

      %{next_point_of_interest_index: nil} ->
        {:error, :journey_finished}

      %{next_point_of_interest_index: point_of_interest_index} ->
        journey
        |> entry_changeset(body, %{point_of_interest_index: point_of_interest_index})
        |> save(EncounterDraw.after_point_of_interest(journey, point_of_interest_index))
    end
  end

  defp save(entry_changeset, encounter_kind \\ nil) do
    Multi.new()
    |> Multi.insert(:entry, entry_changeset)
    |> insert_encounter(encounter_kind)
    |> Oban.insert(:analysis_job, fn %{entry: entry} ->
      AnalyzeEntry.new(%{entry_id: entry.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry}} -> {:ok, entry}
      {:error, :entry, changeset, _changes} -> {:error, changeset}
    end
  end

  defp insert_encounter(multi, nil), do: multi

  defp insert_encounter(multi, encounter_kind) do
    Multi.insert(multi, :encounter, fn %{entry: entry} ->
      %Encounter{
        journey_id: entry.journey_id,
        after_point_of_interest_index: entry.point_of_interest_index,
        kind: encounter_kind
      }
    end)
  end

  defp entry_changeset(journey, body, place) do
    %Entry{analysis_status: :analyzing, journey_id: journey.id}
    |> cast(Map.put(place, :body, trim_and_compose(body)), [
      :body,
      :point_of_interest_index,
      :encounter_id
    ])
    |> validate_required([:body])
    |> validate_length(:body, max: @longest_body)
    |> unique_constraint(:point_of_interest_index,
      name: :entries_journey_id_point_of_interest_index_index
    )
    |> unique_constraint(:encounter_id)
  end

  defp trim_and_compose(body), do: body |> String.trim() |> :unicode.characters_to_nfc_binary()
end
