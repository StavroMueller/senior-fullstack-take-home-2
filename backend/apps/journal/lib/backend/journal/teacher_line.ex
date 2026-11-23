defmodule Backend.Journal.TeacherLine do
  @moduledoc "Picks the teacher's hand-written reaction to an analyzed entry from the strings file for its language and level."

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey

  @doc "Returns the teacher's line for an analyzed entry; one journey seed and entry id always pick the same line."
  def for_entry(%Entry{id: entry_id}, %Journey{} = journey, corrections) do
    strings = read_strings(journey.language, journey.level)
    lines = strings[line_group(corrections)]

    lines
    |> Enum.at(:erlang.phash2({journey.seed, entry_id}, length(lines)))
    |> fill_in(strings, corrections)
  end

  defp line_group([]), do: "no_corrections"
  defp line_group([_correction]), do: "one_correction"
  defp line_group(_corrections), do: "several_corrections"

  defp fill_in(line, _strings, []), do: line

  defp fill_in(line, strings, corrections) do
    category_name = strings["category_names"][Atom.to_string(most_common_category(corrections))]

    line
    |> String.replace("%{count}", Integer.to_string(length(corrections)))
    |> String.replace("%{category}", category_name)
  end

  defp most_common_category(corrections) do
    categories =
      corrections
      |> Enum.sort_by(fn %Correction{span_start: span_start} -> span_start end)
      |> Enum.map(fn %Correction{category: category} -> category end)

    categories
    |> Enum.uniq()
    |> Enum.max_by(fn category -> Enum.count(categories, &(&1 == category)) end)
  end

  defp read_strings(language, level) do
    :journal
    |> Application.app_dir("priv/teacher_lines/#{language}-#{level}.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
