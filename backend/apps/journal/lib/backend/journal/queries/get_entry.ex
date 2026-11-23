defmodule Backend.Journal.Queries.GetEntry do
  @moduledoc "Reads one entry by id, or nil when no entry has that id."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry

  def run(entry_id), do: Repo.get(Entry, entry_id)
end
