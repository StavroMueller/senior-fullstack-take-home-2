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
    |> usable()
    |> case do
      nil -> hand_written(journey, point_of_interest_index, town)
      scene -> scene
    end
  end

  @doc "Returns the teacher's line from a provider result when it is not blank and fits the longest scene, trimmed, or nil."
  def usable({:ok, line}) when is_binary(line) do
    trimmed_line = String.trim(line)
    if trimmed_line != "" and String.length(trimmed_line) <= @longest_scene, do: trimmed_line
  end

  def usable(_failure), do: nil

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
