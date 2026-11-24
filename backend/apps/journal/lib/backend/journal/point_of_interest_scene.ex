defmodule Backend.Journal.PointOfInterestScene do
  @moduledoc "Sets the scene the teacher gives on reaching a town: the AI's, when it returns a usable one, or a hand-written scene from the strings file."

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.AiProvider
  alias Backend.Journal.Route
  alias Backend.Journal.TeacherText

  @doc "Returns the teacher's scene for the journey's point of interest at the index."
  def for_arrival(%Journey{} = journey, point_of_interest_index) do
    town = Enum.at(Route.points_of_interest(journey), point_of_interest_index).name

    ai_scene = AiProvider.describe_point_of_interest(town, journey.language, journey.level)

    case TeacherText.usable(ai_scene) do
      {:ok, scene} -> scene
      :error -> hand_written(journey, point_of_interest_index, town)
    end
  end

  defp hand_written(journey, point_of_interest_index, town) do
    scenes =
      :journal
      |> Application.app_dir(
        "priv/point_of_interest_scenes/#{journey.language}-#{journey.level}.json"
      )
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("scenes")

    scenes
    |> Enum.at(:erlang.phash2({journey.seed, point_of_interest_index}, length(scenes)))
    |> String.replace("%{town}", town)
  end
end
