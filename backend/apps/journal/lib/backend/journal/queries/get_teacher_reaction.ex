defmodule Backend.Journal.Queries.GetTeacherReaction do
  @moduledoc "Reads the teacher's reaction to an entry, or nil until its analysis finishes."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.TeacherReaction

  def run(%Entry{analysis_status: :analyzed} = entry) do
    %Entry{journey: journey, corrections: corrections} =
      Repo.preload(entry, [:journey, :corrections])

    TeacherReaction.for_entry(entry, journey, corrections)
  end

  def run(%Entry{}), do: nil
end
