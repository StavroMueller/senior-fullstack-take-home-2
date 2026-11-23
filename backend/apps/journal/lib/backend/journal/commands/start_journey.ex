defmodule Backend.Journal.Commands.StartJourney do
  @moduledoc "Starts a new French A1 journey from a random seed."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  @language "fr"
  @level "A1"
  @largest_seed 2_147_483_647

  def execute do
    Repo.insert(%Journey{seed: :rand.uniform(@largest_seed), language: @language, level: @level})
  end
end
