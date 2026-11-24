defmodule Backend.Journal.TeacherText do
  @moduledoc "Decides whether what the AI wrote for the teacher, a town scene or a journey intro, can be shown as is."

  @longest_teacher_text 600

  @doc "Returns `{:ok, trimmed}` when the provider's text is not blank and fits the longest teacher text, or `:error`."
  def usable({:ok, teacher_text}) when is_binary(teacher_text) do
    trimmed = String.trim(teacher_text)
    fits? = trimmed != "" and String.length(trimmed) <= @longest_teacher_text

    if fits?, do: {:ok, trimmed}, else: :error
  end

  def usable(_failure), do: :error
end
