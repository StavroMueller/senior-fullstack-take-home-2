defmodule Backend.Journal.Queries.GetTeacherLine do
  @moduledoc "Reads the teacher's reaction to an entry, or nil until its analysis finishes."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.TeacherLine

  def run(%Entry{analysis_status: :analyzed} = entry) do
    %Entry{journey: journey, corrections: corrections} =
      Repo.preload(entry, [:journey, :corrections])

    TeacherLine.for_entry(entry, journey, corrections)
  end

  def run(%Entry{}), do: nil
end
