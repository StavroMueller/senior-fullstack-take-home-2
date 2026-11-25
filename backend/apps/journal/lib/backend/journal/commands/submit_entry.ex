defmodule Backend.Journal.Commands.SubmitEntry do
  @moduledoc "Saves an entry at the journey's current route position and enqueues its analysis in one transaction, leaving the journey where it is."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Jobs.AnalyzeEntry
  alias Backend.Journal.Queries.GetJourneyProgress
  alias Ecto.Multi

  def execute(%{journey_id: journey_id, body: body}) do
    case Repo.get(Journey, journey_id) do
      %Journey{} = journey -> write_at_current_place(journey, body)
      nil -> {:error, :journey_not_found}
    end
  end

  defp write_at_current_place(journey, body) do
    case GetJourneyProgress.run(journey) do
      %{open_encounter: %Encounter{} = encounter} ->
        journey |> entry_changeset(body, %{encounter_id: encounter.id}) |> save()

      %{current_point_of_interest_index: nil} ->
        {:error, :journey_finished}

      %{current_point_of_interest_index: point_of_interest_index} ->
        journey
        |> entry_changeset(body, %{point_of_interest_index: point_of_interest_index})
        |> save()
    end
  end

  defp save(entry_changeset) do
    Multi.new()
    |> Multi.insert(:entry, entry_changeset)
    |> Oban.insert(:analysis_job, fn %{entry: entry} ->
      AnalyzeEntry.new(%{entry_id: entry.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry}} -> {:ok, entry}
      {:error, :entry, changeset, _changes} -> {:error, changeset}
    end
  end

  defp entry_changeset(journey, body, route_position) do
    Entry.submission_changeset(
      %Entry{analysis_status: :analyzing, journey_id: journey.id},
      Map.put(route_position, :body, body)
    )
  end
end
