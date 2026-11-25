defmodule Backend.Journal.LoadedAssociations do
  @moduledoc "Names the associations every read of a journey or an entry loads, so each GraphQL field over them resolves."

  @doc "The associations loaded with a journey."
  def journey, do: [:encounters, entries: [:corrections, :encounter]]

  @doc "The associations loaded with an entry."
  def entry, do: [:corrections, :encounter, journey: :encounters]
end
