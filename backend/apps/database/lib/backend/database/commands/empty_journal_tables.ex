defmodule Backend.Database.Commands.EmptyJournalTables do
  @moduledoc "Deletes every journey, encounter, entry, correction and queued job, and restarts their ids."

  alias Backend.Database.Repo

  def execute do
    Repo.query!(
      "TRUNCATE journeys, encounters, entries, corrections, oban_jobs RESTART IDENTITY CASCADE"
    )
  end
end
