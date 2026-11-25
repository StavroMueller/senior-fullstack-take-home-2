defmodule Mix.Tasks.Api.RecordExampleJourneys do
  @moduledoc "Plays the example journeys through the real commands and the OpenRouter provider on a scratch database, then writes them to the file that seeds.exs loads."
  @shortdoc "Records the example journeys with the OpenRouter provider"

  use Mix.Task

  alias Backend.Database.Commands.EmptyJournalTables
  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal
  alias Backend.Journal.AiProvider
  alias Backend.Journal.AiProvider.OpenRouter

  @recording_database "wayword_example_journeys"
  @minutes_per_day 24 * 60
  @minutes_from_arrival_to_entry 120
  @minutes_from_last_entry_to_finish 60

  @example_journeys [
    %{started_days_ago: 24, route_positions_written: :all},
    %{started_days_ago: 12, route_positions_written: 3},
    %{started_days_ago: 1, route_positions_written: 1}
  ]

  @impl Mix.Task
  def run(_arguments) do
    Mix.Task.run("app.config")
    refuse_unless_open_router(Application.fetch_env!(:journal, :ai_provider))
    point_at_recording_database()

    {:ok, _migrated, _apps} =
      Ecto.Migrator.with_repo(Repo, &Ecto.Migrator.run(&1, :up, all: true))

    {:ok, _started} = Application.ensure_all_started(:api)

    EmptyJournalTables.execute()

    [language | _other_languages] = Journal.list_languages()
    example_journeys = Enum.map(@example_journeys, &record_journey(&1, language))

    example_journeys_path =
      Path.join(Mix.Project.deps_paths()[:database], "priv/repo/example_journeys.json")

    File.write!(example_journeys_path, Jason.encode!(%{journeys: example_journeys}, pretty: true))

    Mix.shell().info(
      "Wrote #{length(example_journeys)} example journeys to #{example_journeys_path}"
    )
  end

  defp refuse_unless_open_router(OpenRouter), do: :ok

  defp refuse_unless_open_router(provider) do
    Mix.raise(
      "The example journeys are recorded with OpenRouter, but the provider is #{inspect(provider)}. Set OPENROUTER_API_KEY and run again."
    )
  end

  defp point_at_recording_database do
    repo_config =
      :database |> Application.fetch_env!(Repo) |> Keyword.put(:database, @recording_database)

    oban_config = :api |> Application.fetch_env!(Oban) |> Keyword.put(:testing, :manual)

    Application.put_env(:database, Repo, repo_config)
    Application.put_env(:api, Oban, oban_config)

    case Repo.__adapter__().storage_up(repo_config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
    end
  end

  defp record_journey(
         %{started_days_ago: started_days_ago, route_positions_written: written},
         language
       ) do
    {:ok, journey} = Journal.start_journey(%{language: language.code, level: language.level})
    write_and_travel_on(journey.id, written)
    Mix.shell().info("Recorded journey #{journey.id}")
    journey.id |> Journal.get_journey() |> to_recorded_journey(started_days_ago)
  end

  defp write_and_travel_on(journey_id, :all) do
    write_example_entry(journey_id)
    {:ok, journey} = Journal.travel_on(journey_id)
    if is_nil(journey.finished_at), do: write_and_travel_on(journey_id, :all)
  end

  defp write_and_travel_on(journey_id, 1), do: write_example_entry(journey_id)

  defp write_and_travel_on(journey_id, route_positions_left) do
    write_example_entry(journey_id)
    {:ok, _journey} = Journal.travel_on(journey_id)
    write_and_travel_on(journey_id, route_positions_left - 1)
  end

  defp write_example_entry(journey_id) do
    journey = Journal.get_journey(journey_id)
    %{current_scene: writing_prompt} = Journal.get_journey_progress(journey)
    {:ok, body} = AiProvider.write_example_entry(writing_prompt, journey.language, journey.level)
    {:ok, entry} = Journal.submit_entry(%{journey_id: journey_id, body: body})
    Oban.drain_queue(queue: :analysis, with_recursion: true, with_scheduled: true)
    refuse_unless_analyzed(Repo.get!(Entry, entry.id))
  end

  defp refuse_unless_analyzed(%Entry{analysis_status: :analyzed}), do: :ok

  defp refuse_unless_analyzed(%Entry{} = entry),
    do: Mix.raise("The analysis of entry #{entry.id} ended #{entry.analysis_status}. Run again.")

  defp to_recorded_journey(%Journey{} = journey, started_days_ago) do
    journey =
      Repo.preload(journey, [:current_encounter, :encounters, entries: [:encounter, :corrections]])

    started_minutes_ago = started_days_ago * @minutes_per_day

    entries =
      journey.entries
      |> Enum.sort_by(& &1.id)
      |> Enum.with_index()
      |> Enum.map(fn {entry, days_in} ->
        to_recorded_entry(
          entry,
          started_minutes_ago - days_in * @minutes_per_day - @minutes_from_arrival_to_entry
        )
      end)

    %{
      seed: journey.seed,
      language: journey.language,
      level: journey.level,
      intro: journey.intro,
      current_point_of_interest_index: journey.current_point_of_interest_index,
      current_point_of_interest_scene: journey.current_point_of_interest_scene,
      current_encounter_after_point_of_interest_index:
        after_point_of_interest_index(journey.current_encounter),
      minutes_ago: started_minutes_ago,
      finished_minutes_ago: finished_minutes_ago(journey, List.last(entries)),
      encounters: Enum.map(journey.encounters, &to_recorded_encounter/1),
      entries: entries
    }
  end

  defp to_recorded_encounter(%Encounter{} = encounter),
    do: %{
      after_point_of_interest_index: encounter.after_point_of_interest_index,
      kind: encounter.kind
    }

  defp to_recorded_entry(%Entry{} = entry, minutes_ago) do
    %{
      body: entry.body,
      analysis_status: entry.analysis_status,
      point_of_interest_index: entry.point_of_interest_index,
      encounter_after_point_of_interest_index: after_point_of_interest_index(entry.encounter),
      teacher_reaction: entry.teacher_reaction,
      minutes_ago: minutes_ago,
      corrections:
        entry.corrections
        |> Enum.sort_by(& &1.span_start)
        |> Enum.map(
          &Map.take(&1, [:span_start, :span_end, :original, :fix, :explanation, :category])
        )
    }
  end

  defp after_point_of_interest_index(%Encounter{} = encounter),
    do: encounter.after_point_of_interest_index

  defp after_point_of_interest_index(nil), do: nil

  defp finished_minutes_ago(%Journey{finished_at: nil}, _last_entry), do: nil

  defp finished_minutes_ago(%Journey{}, last_entry),
    do: last_entry.minutes_ago - @minutes_from_last_entry_to_finish
end
