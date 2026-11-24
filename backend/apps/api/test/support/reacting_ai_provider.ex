defmodule Backend.ApiWeb.Test.ReactingAiProvider do
  @moduledoc "An AI provider that returns the stub's corrections with a teacher reaction, for testing the stored reaction path."

  @behaviour Backend.Journal.AiProvider

  alias Backend.Journal.AiProvider.Stub

  @teacher_reaction "Zut! Two slips. Fix the verb first."

  def teacher_reaction, do: @teacher_reaction

  @impl true
  def correct_entry(body, language, level) do
    {:ok, response} = Stub.correct_entry(body, language, level)
    {:ok, Map.put(response, "teacher_reaction", @teacher_reaction)}
  end
end
