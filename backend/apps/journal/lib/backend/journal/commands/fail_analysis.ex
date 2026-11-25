defmodule Backend.Journal.Commands.FailAnalysis do
  @moduledoc "Marks an entry's analysis failed and keeps the entry."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry

  def execute(%Entry{} = entry) do
    entry |> Entry.analysis_failed_changeset() |> Repo.update()
  end
end
