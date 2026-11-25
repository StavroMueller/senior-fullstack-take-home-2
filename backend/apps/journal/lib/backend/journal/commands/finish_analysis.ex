defmodule Backend.Journal.Commands.FinishAnalysis do
  @moduledoc "Stores an entry's corrections and the AI's teacher reaction, if any, and marks its analysis analyzed."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry
  alias Ecto.Multi

  def execute(%Entry{} = entry, corrections, teacher_reaction) do
    now = DateTime.utc_now(:second)

    rows =
      Enum.map(corrections, fn correction ->
        Map.merge(correction, %{entry_id: entry.id, inserted_at: now, updated_at: now})
      end)

    Multi.new()
    |> Multi.insert_all(:corrections, Correction, rows)
    |> Multi.update(:entry, Entry.analyzed_changeset(entry, teacher_reaction))
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry}} -> {:ok, entry}
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end
end
