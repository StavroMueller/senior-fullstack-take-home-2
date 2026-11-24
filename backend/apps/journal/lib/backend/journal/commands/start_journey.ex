defmodule Backend.Journal.Commands.StartJourney do
  @moduledoc "Starts a new journey from a random seed in one of the offered languages and levels, with the teacher's intro and the scene in its first town, both written at once."

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.JourneyIntro
  alias Backend.Journal.PointOfInterestScene
  alias Backend.Journal.Queries.ListLanguages

  @largest_seed 2_147_483_647
  @longest_wait_for_the_teacher 30_000

  def execute(%{language: language, level: level}) do
    if Enum.any?(ListLanguages.run(), &(&1.code == language and &1.level == level)),
      do: start(language, level),
      else: {:error, :language_not_offered}
  end

  defp start(language, level) do
    journey = %Journey{seed: :rand.uniform(@largest_seed), language: language, level: level}

    [intro, first_scene] =
      Task.await_many(
        [
          Task.async(fn -> JourneyIntro.for_journey(journey) end),
          Task.async(fn -> PointOfInterestScene.for_arrival(journey, 0) end)
        ],
        @longest_wait_for_the_teacher
      )

    Repo.insert(%Journey{journey | intro: intro, current_point_of_interest_scene: first_scene})
  end
end
