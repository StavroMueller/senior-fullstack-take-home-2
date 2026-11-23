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

  @one_preposition_reactions [
    "Presque! One correction, in prepositions.",
    "Pas mal! Only one slip, in prepositions. Let's fix it.",
    "Ah bon? One little slip in prepositions, and the rest holds up."
  ]

  defp correction(span_start, category),
    do: %Correction{span_start: span_start, category: category}

  test "an entry with no corrections gets a reaction from the no-corrections group" do
    reaction = TeacherReaction.for_entry(%Entry{id: 1}, @journey, [])

    assert reaction in @no_corrections_reactions
  end

  test "an entry with one correction gets a reaction from the one-correction group that names its category" do
    reactions =
      for entry_id <- 1..50,
          uniq: true,
          do:
            TeacherReaction.for_entry(%Entry{id: entry_id}, @journey, [
              correction(0, :preposition)
            ])

    assert Enum.sort(reactions) == Enum.sort(@one_preposition_reactions)
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
