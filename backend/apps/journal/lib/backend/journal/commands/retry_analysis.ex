defmodule Backend.Journal.Commands.RetryAnalysis do
  @moduledoc "Sets a failed analysis back to analyzing and enqueues it again."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.Jobs.AnalyzeEntry
  alias Ecto.Multi

  def execute(entry_id) do
    case Repo.get(Entry, entry_id) do
      %Entry{analysis_status: :analysis_failed} = entry -> analyze_again(entry)
      %Entry{} -> {:error, :analysis_not_failed}
      nil -> {:error, :entry_not_found}
    end
  end

  defp analyze_again(entry) do
    Multi.new()
    |> Multi.update(:entry, Entry.analyzing_changeset(entry))
    |> Oban.insert(:analysis_job, AnalyzeEntry.new(%{entry_id: entry.id}))
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry}} -> {:ok, entry}
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end
end
