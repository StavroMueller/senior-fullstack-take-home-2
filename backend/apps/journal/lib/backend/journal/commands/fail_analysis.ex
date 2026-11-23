defmodule Backend.Journal.Commands.FailAnalysis do
  @moduledoc "Marks an entry's analysis failed and keeps the entry."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry

  def execute(%Entry{} = entry) do
    entry |> Ecto.Changeset.change(analysis_status: :analysis_failed) |> Repo.update()
  end
end
