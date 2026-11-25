defmodule Backend.Journal.AiProvider do
  @moduledoc "The contract every AI provider meets, and the calls that reach the provider set in config: corrections for an entry, the teacher's intro to a new journey, the scene the teacher sets in a town, and a learner's entry for the example journeys."

  @callback correct_entry(body :: String.t(), language :: String.t(), level :: String.t()) ::
              {:ok, map()} | {:error, term()}

  @callback describe_point_of_interest(
              town :: String.t(),
              language :: String.t(),
              level :: String.t()
            ) ::
              {:ok, String.t()} | {:error, term()}

  @callback introduce_journey(towns :: [String.t()], language :: String.t(), level :: String.t()) ::
              {:ok, String.t()} | {:error, term()}

  @callback write_example_entry(
              writing_prompt :: String.t(),
              language :: String.t(),
              level :: String.t()
            ) ::
              {:ok, String.t()} | {:error, term()}

  @doc "Asks the configured provider for corrections to an entry."
  def correct_entry(body, language, level), do: configured().correct_entry(body, language, level)

  @doc "Asks the configured provider for the scene the teacher sets in a town."
  def describe_point_of_interest(town, language, level),
    do: configured().describe_point_of_interest(town, language, level)

  @doc "Asks the configured provider for the teacher's intro to a route."
  def introduce_journey(towns, language, level),
    do: configured().introduce_journey(towns, language, level)

  @doc "Asks the configured provider for an entry a learner at the level might write for the prompt, mistakes included."
  def write_example_entry(writing_prompt, language, level),
    do: configured().write_example_entry(writing_prompt, language, level)

  defp configured, do: Application.fetch_env!(:journal, :ai_provider)
end
