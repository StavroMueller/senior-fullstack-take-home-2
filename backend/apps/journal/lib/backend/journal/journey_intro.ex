defmodule Backend.Journal.JourneyIntro do
  @moduledoc "Writes the teacher's intro to a new journey from its route: the AI's, when usable, or a hand-written intro from the strings file."

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.AiProvider
  alias Backend.Journal.PlaceScene
  alias Backend.Journal.Route

  @doc "Returns the teacher's intro naming the journey's start, end and the towns between."
  def for_journey(%Journey{} = journey) do
    towns = journey |> Route.points_of_interest() |> Enum.map(& &1.name)

    ai_intro = AiProvider.introduce_journey(towns, journey.language, journey.level)

    case PlaceScene.usable(ai_intro) do
      nil -> hand_written(journey, towns)
      intro -> intro
    end
  end

  defp hand_written(journey, towns) do
    intros =
      :journal
      |> Application.app_dir("priv/journey_intros/#{journey.language}-#{journey.level}.json")
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("intros")

    intros
    |> Enum.at(:erlang.phash2(journey.seed, length(intros)))
    |> String.replace("%{start}", List.first(towns))
    |> String.replace("%{finish}", List.last(towns))
    |> String.replace("%{stops}", Integer.to_string(length(towns) - 2))
  end
end
