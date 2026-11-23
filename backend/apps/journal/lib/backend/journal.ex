defmodule Backend.Journal do
  @moduledoc "The journal's public API: commands and queries over entries, corrections and journeys."

  alias Backend.Journal.AnalysisEvents
  alias Backend.Journal.Commands
  alias Backend.Journal.Queries

  defdelegate start_journey, to: Commands.StartJourney, as: :execute
  defdelegate submit_entry(attributes), to: Commands.SubmitEntry, as: :execute
  defdelegate get_current_journey, to: Queries.GetCurrentJourney, as: :run
  defdelegate get_entry(entry_id), to: Queries.GetEntry, as: :run
  defdelegate list_entries, to: Queries.ListEntries, as: :run
  defdelegate get_data_source, to: Queries.GetDataSource, as: :run
  defdelegate subscribe_to_analysis(entry_id), to: AnalysisEvents, as: :subscribe
end
