defmodule Backend.Journal.Queries.GetEncounterPrompt do
  @moduledoc "Reads the writing prompt for an encounter in its journey's language and level."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Encounter
  alias Backend.Journal.EncounterPrompt

  def run(%Encounter{} = encounter) do
    %Encounter{journey: journey} = Repo.preload(encounter, :journey)
    EncounterPrompt.for_encounter(encounter, journey)
  end
end
