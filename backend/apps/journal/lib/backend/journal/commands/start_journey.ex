defmodule Backend.Journal.Commands.StartJourney do
  @moduledoc "Starts a new journey from a random seed, in the configured language and level, with the teacher's intro and the scene in its first town, both written at once."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.JourneyIntro
  alias Backend.Journal.PlaceScene

  @largest_seed 2_147_483_647
  @longest_wait_for_the_teacher 30_000

  def execute do
    [language: language, level: level] = Application.fetch_env!(:journal, :new_journey)
    journey = %Journey{seed: :rand.uniform(@largest_seed), language: language, level: level}

    [intro, first_scene] =
      Task.await_many(
        [
          Task.async(fn -> JourneyIntro.for_journey(journey) end),
          Task.async(fn -> PlaceScene.for_arrival(journey, 0) end)
        ],
        @longest_wait_for_the_teacher
      )

    Repo.insert(%Journey{journey | intro: intro, current_place_scene: first_scene})
  end
end
