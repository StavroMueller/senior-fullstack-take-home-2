defmodule Backend.Journal.Queries.GetCountry do
  @moduledoc "Reads the country a journey's route crosses."

  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  def run(%Journey{language: language}), do: Route.country(language)
end
