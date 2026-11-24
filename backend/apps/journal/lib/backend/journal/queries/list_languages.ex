defmodule Backend.Journal.Queries.ListLanguages do
  @moduledoc "Lists each language and level a journey can start in: every pair whose route and level strings files all exist."

  @level_strings_folders ["teacher_reactions", "encounters", "place_scenes", "journey_intros"]

  @doc "Returns each startable language code with its level and the country its route crosses, sorted by country."
  def run do
    "teacher_reactions"
    |> strings_path("*.json")
    |> Path.wildcard()
    |> Enum.map(&code_and_level/1)
    |> Enum.filter(&every_file_exists?/1)
    |> Enum.map(fn {code, level} -> %{code: code, level: level, country: country(code)} end)
    |> Enum.sort_by(& &1.country)
  end

  defp code_and_level(path) do
    [code, level] = path |> Path.basename(".json") |> String.split("-", parts: 2)
    {code, level}
  end

  defp every_file_exists?({code, level}) do
    File.exists?(strings_path("routes", "#{code}.json")) and
      Enum.all?(@level_strings_folders, &File.exists?(strings_path(&1, "#{code}-#{level}.json")))
  end

  defp country(code) do
    "routes"
    |> strings_path("#{code}.json")
    |> File.read!()
    |> Jason.decode!()
    |> Map.fetch!("country")
  end

  defp strings_path(folder, file_name),
    do: Application.app_dir(:journal, "priv/#{folder}/#{file_name}")
end
