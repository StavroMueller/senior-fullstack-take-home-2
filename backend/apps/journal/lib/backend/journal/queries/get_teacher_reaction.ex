defmodule Backend.Journal.Queries.GetTeacherReaction do
  @moduledoc "Reads the teacher's reaction to an entry: the AI's when stored, the hand-written one otherwise, or nil until analysis finishes."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.TeacherReaction

  def run(%Entry{analysis_status: :analyzed, teacher_reaction: teacher_reaction})
      when is_binary(teacher_reaction),
      do: teacher_reaction

  def run(%Entry{analysis_status: :analyzed} = entry) do
    %Entry{journey: journey, corrections: corrections} =
      Repo.preload(entry, [:journey, :corrections])

    TeacherReaction.for_entry(entry, journey, corrections)
  end

  def run(%Entry{}), do: nil
end
