defmodule Backend.Journal.TeacherReactionTest do
  @moduledoc "Pins which French A1 teacher reaction each analyzed entry gets."

  use ExUnit.Case, async: true

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.TeacherReaction

  @journey %Journey{seed: 42, language: "fr", level: "A1"}

  @no_corrections_reactions [
    "Parfait! Not one correction. I checked twice.",
    "Incroyable! Nothing to fix. I am almost disappointed.",
    "Bravo! A clean entry. Don't let it go to your head."
  ]

  defp correction(span_start, category),
    do: %Correction{span_start: span_start, category: category}

  test "an entry with no corrections gets a reaction from the no-corrections group" do
    reaction = TeacherReaction.for_entry(%Entry{id: 1}, @journey, [])

    assert reaction in @no_corrections_reactions
  end

  test "an entry with one correction names its category" do
    reaction = TeacherReaction.for_entry(%Entry{id: 1}, @journey, [correction(0, :preposition)])

    assert reaction =~ "One"
    assert reaction =~ "prepositions"
  end

  test "an entry with several corrections gives the count and the most common category" do
    corrections = [
      correction(0, :gender),
      correction(10, :verb_tense),
      correction(20, :verb_tense)
    ]

    reaction = TeacherReaction.for_entry(%Entry{id: 1}, @journey, corrections)

    assert reaction =~ "3 corrections"
    assert reaction =~ "verb tense"
  end

  test "a tie goes to the category that appears first in the entry" do
    corrections = [correction(20, :gender), correction(0, :article)]

    reaction = TeacherReaction.for_entry(%Entry{id: 1}, @journey, corrections)

    assert reaction =~ "articles"
  end

  test "a journey seed and an entry id pin the reaction" do
    assert TeacherReaction.for_entry(%Entry{id: 7}, @journey, []) ==
             "Incroyable! Nothing to fix. I am almost disappointed."
  end

  test "different entries along one journey reach every reaction in a group" do
    reactions =
      for entry_id <- 1..50,
          uniq: true,
          do: TeacherReaction.for_entry(%Entry{id: entry_id}, @journey, [])

    assert Enum.sort(reactions) == Enum.sort(@no_corrections_reactions)
  end
end
