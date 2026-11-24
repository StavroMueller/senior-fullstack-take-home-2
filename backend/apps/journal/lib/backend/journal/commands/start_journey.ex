defmodule Backend.Journal.Commands.StartJourney do
  @moduledoc "Starts a new journey from a random seed, in the configured language and level, with the teacher's scene for its first town."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.PlaceScene

  @largest_seed 2_147_483_647

  def execute do
    [language: language, level: level] = Application.fetch_env!(:journal, :new_journey)
    journey = %Journey{seed: :rand.uniform(@largest_seed), language: language, level: level}
    Repo.insert(%Journey{journey | current_place_scene: PlaceScene.for_arrival(journey, 0)})
  end
end
