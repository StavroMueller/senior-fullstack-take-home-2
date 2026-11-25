defmodule Backend.Journal.Queries.GetEntry do
  @moduledoc "Reads one entry by id with its corrections, encounter and journey, or nil when no entry has that id."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.LoadedAssociations

  def run(entry_id) do
    Entry
    |> Repo.get(entry_id)
    |> Repo.preload(LoadedAssociations.entry())
  end
end
