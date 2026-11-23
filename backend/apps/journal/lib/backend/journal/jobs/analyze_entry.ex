defmodule Backend.Journal.Jobs.AnalyzeEntry do
  @moduledoc "Runs the AI provider over one entry, then stores the corrections or the failure."

  use Oban.Worker, queue: :analysis, max_attempts: 3

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.AnalysisEvents
  alias Backend.Journal.Commands.FailAnalysis
  alias Backend.Journal.Commands.FinishAnalysis
  alias Backend.Journal.CorrectionParser

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"entry_id" => entry_id}} = job) do
    entry = Entry |> Repo.get!(entry_id) |> Repo.preload(:journey)

    with {:ok, response} <-
           provider().correct_entry(entry.body, entry.journey.language, entry.journey.level),
         {:ok, corrections} <- CorrectionParser.parse(entry.body, response),
         {:ok, entry} <- FinishAnalysis.execute(entry, corrections) do
      AnalysisEvents.broadcast_analysis_ended(entry.id, entry.analysis_status)
    else
      {:error, reason} -> record_failure(entry, job, reason)
    end
  end

  defp record_failure(_entry, %Oban.Job{attempt: attempt, max_attempts: max_attempts}, reason)
       when attempt < max_attempts do
    {:error, reason}
  end

  defp record_failure(entry, _final_attempt, reason) do
    {:ok, entry} = FailAnalysis.execute(entry)
    AnalysisEvents.broadcast_analysis_ended(entry.id, entry.analysis_status)
    {:cancel, reason}
  end

  defp provider, do: Application.fetch_env!(:journal, :ai_provider)
end
