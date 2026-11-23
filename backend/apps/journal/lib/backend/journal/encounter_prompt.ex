defmodule Backend.Journal.EncounterPrompt do
  @moduledoc "Reads the teacher's hand-written writing prompt for an encounter from the strings file for its language and level."

  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Journey

  @doc "Returns the writing prompt for the encounter, in the journey's language and level."
  def for_encounter(%Encounter{kind: kind}, %Journey{language: language, level: level}) do
    :journal
    |> Application.app_dir("priv/encounters/#{language}-#{level}.json")
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["prompts", Atom.to_string(kind)])
  end
end
