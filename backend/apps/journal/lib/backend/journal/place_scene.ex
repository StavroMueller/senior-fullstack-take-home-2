defmodule Backend.Journal.PlaceScene do
  @moduledoc "Sets the scene the teacher gives on reaching a town: the AI's, when it returns a usable one, or a hand-written scene from the strings file."

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  @longest_scene 600

  @doc "Returns the teacher's scene for the journey's point of interest at the index."
  def for_arrival(%Journey{} = journey, point_of_interest_index) do
    town = Enum.at(Route.points_of_interest(journey), point_of_interest_index).name

    town
    |> provider().describe_place(journey.language, journey.level)
    |> usable_scene()
    |> case do
      nil -> hand_written(journey, point_of_interest_index, town)
      scene -> scene
    end
  end

  defp usable_scene({:ok, scene}) when is_binary(scene) do
    trimmed_scene = String.trim(scene)
    if trimmed_scene != "" and String.length(trimmed_scene) <= @longest_scene, do: trimmed_scene
  end

  defp usable_scene(_failure), do: nil

  defp hand_written(journey, point_of_interest_index, town) do
    scenes =
      :journal
      |> Application.app_dir("priv/place_scenes/#{journey.language}-#{journey.level}.json")
      |> File.read!()
      |> Jason.decode!()
      |> Map.fetch!("scenes")

    scenes
    |> Enum.at(:erlang.phash2({journey.seed, point_of_interest_index}, length(scenes)))
    |> String.replace("%{town}", town)
  end

  defp provider, do: Application.fetch_env!(:journal, :ai_provider)
end
