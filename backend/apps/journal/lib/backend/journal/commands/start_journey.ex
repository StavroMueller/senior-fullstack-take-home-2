defmodule Backend.Journal.Commands.StartJourney do
  @moduledoc "Starts a new journey from a random seed, in the configured language and level."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  @largest_seed 2_147_483_647

  def execute do
    [language: language, level: level] = Application.fetch_env!(:journal, :new_journey)
    Repo.insert(%Journey{seed: :rand.uniform(@largest_seed), language: language, level: level})
  end
end
