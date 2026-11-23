defmodule Backend.Journal.TeacherReaction do
  @moduledoc "Picks the teacher's hand-written reaction to an analyzed entry from the strings file for its language and level."

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey

  @doc "Returns the teacher's reaction for an analyzed entry; one journey seed and entry id always pick the same reaction."
  def for_entry(%Entry{id: entry_id}, %Journey{} = journey, corrections) do
    strings = read_strings(journey.language, journey.level)
    reactions = strings[reaction_group(corrections)]

    reactions
    |> Enum.at(:erlang.phash2({journey.seed, entry_id}, length(reactions)))
    |> fill_in(strings, corrections)
  end

  defp reaction_group([]), do: "no_corrections"
  defp reaction_group([_correction]), do: "one_correction"
  defp reaction_group(_corrections), do: "several_corrections"

  defp fill_in(reaction, _strings, []), do: reaction

  defp fill_in(reaction, strings, corrections) do
    category_name = strings["category_names"][Atom.to_string(most_common_category(corrections))]

    reaction
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
    |> Application.app_dir("priv/teacher_reactions/#{language}-#{level}.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
