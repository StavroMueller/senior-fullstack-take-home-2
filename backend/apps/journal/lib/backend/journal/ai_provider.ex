defmodule Backend.Journal.AiProvider do
  @moduledoc "The contract every AI provider meets: corrections for an entry, and the teacher's intro to a new journey, and the scene the teacher sets when the journey reaches a town."

  @callback correct_entry(body :: String.t(), language :: String.t(), level :: String.t()) ::
              {:ok, map()} | {:error, term()}

  @callback describe_place(town :: String.t(), language :: String.t(), level :: String.t()) ::
              {:ok, String.t()} | {:error, term()}

  @callback introduce_journey(towns :: [String.t()], language :: String.t(), level :: String.t()) ::
              {:ok, String.t()} | {:error, term()}
end
