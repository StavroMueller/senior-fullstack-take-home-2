defmodule Backend.Database.Commands.LoadExampleJourneys do
  @moduledoc "Replaces every journey with the example journeys recorded in example_journeys.json, dated relative to now."

  alias Backend.Database.Commands.EmptyJournalTables
  alias Backend.Database.Repo
  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey

  @doc "Loads the recorded example journeys, each timestamp counted back from now."
  def execute(now) do
    EmptyJournalTables.execute()

    :database
    |> Application.app_dir("priv/repo/example_journeys.json")
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("journeys")
    |> Enum.each(&insert_journey(&1, now))
  end

  defp insert_journey(recorded_journey, now) do
    started_at = minutes_before(now, recorded_journey["minutes_ago"])

    journey =
      Repo.insert!(%Journey{
        seed: recorded_journey["seed"],
        language: recorded_journey["language"],
        level: recorded_journey["level"],
        intro: recorded_journey["intro"],
        current_point_of_interest_index: recorded_journey["current_point_of_interest_index"],
        current_point_of_interest_scene: recorded_journey["current_point_of_interest_scene"],
        finished_at: finished_at(recorded_journey["finished_minutes_ago"], now),
        inserted_at: started_at,
        updated_at: started_at
      })

    encounter_ids =
      Map.new(recorded_journey["encounters"], fn encounter ->
        %Encounter{id: encounter_id} =
          Repo.insert!(%Encounter{
            journey_id: journey.id,
            after_point_of_interest_index: encounter["after_point_of_interest_index"],
            kind: enum_value(Encounter, :kind, encounter["kind"]),
            inserted_at: started_at,
            updated_at: started_at
          })

        {encounter["after_point_of_interest_index"], encounter_id}
      end)

    Enum.each(recorded_journey["entries"], &insert_entry(&1, journey, encounter_ids, now))

    journey
    |> Ecto.Changeset.change(
      current_encounter_id:
        encounter_ids[recorded_journey["current_encounter_after_point_of_interest_index"]]
    )
    |> Repo.update!()
  end

  defp insert_entry(recorded_entry, journey, encounter_ids, now) do
    written_at = minutes_before(now, recorded_entry["minutes_ago"])

    Repo.insert!(%Entry{
      journey_id: journey.id,
      body: recorded_entry["body"],
      analysis_status: enum_value(Entry, :analysis_status, recorded_entry["analysis_status"]),
      point_of_interest_index: recorded_entry["point_of_interest_index"],
      encounter_id: encounter_ids[recorded_entry["encounter_after_point_of_interest_index"]],
      teacher_reaction: recorded_entry["teacher_reaction"],
      inserted_at: written_at,
      updated_at: written_at,
      corrections: Enum.map(recorded_entry["corrections"], &correction(&1, written_at))
    })
  end

  defp correction(recorded_correction, written_at) do
    %Correction{
      span_start: recorded_correction["span_start"],
      span_end: recorded_correction["span_end"],
      original: recorded_correction["original"],
      fix: recorded_correction["fix"],
      explanation: recorded_correction["explanation"],
      category: enum_value(Correction, :category, recorded_correction["category"]),
      inserted_at: written_at,
      updated_at: written_at
    }
  end

  defp enum_value(schema, field, stored_value) do
    schema
    |> Ecto.Enum.mappings(field)
    |> Map.new(fn {value, stored} -> {stored, value} end)
    |> Map.fetch!(stored_value)
  end

  defp finished_at(nil, _now), do: nil
  defp finished_at(minutes_ago, now), do: minutes_before(now, minutes_ago)

  defp minutes_before(now, minutes), do: DateTime.add(now, -minutes * 60)
end
