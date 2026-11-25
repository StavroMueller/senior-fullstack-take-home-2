defmodule Backend.Journal do
  @moduledoc "The journal's public API: commands and queries over entries, corrections and journeys."

  alias Backend.Journal.AnalysisEvents
  alias Backend.Journal.Commands
  alias Backend.Journal.Queries

  defdelegate start_journey(language_and_level), to: Commands.StartJourney, as: :execute
  defdelegate submit_entry(attributes), to: Commands.SubmitEntry, as: :execute
  defdelegate retry_analysis(entry_id), to: Commands.RetryAnalysis, as: :execute
  defdelegate travel_on(journey_id), to: Commands.TravelOn, as: :execute
  defdelegate get_category_trends(scope), to: Queries.GetCategoryTrends, as: :run
  defdelegate get_country(journey), to: Queries.GetCountry, as: :run
  defdelegate get_journey(journey_id), to: Queries.GetJourney, as: :run
  defdelegate get_encounter_prompt(encounter), to: Queries.GetEncounterPrompt, as: :run
  defdelegate get_entry(entry_id), to: Queries.GetEntry, as: :run
  defdelegate get_journey_progress(journey), to: Queries.GetJourneyProgress, as: :run
  defdelegate get_points_of_interest(journey), to: Queries.GetPointsOfInterest, as: :run
  defdelegate get_teacher_reaction(entry), to: Queries.GetTeacherReaction, as: :run
  defdelegate list_journeys, to: Queries.ListJourneys, as: :run
  defdelegate list_languages, to: Queries.ListLanguages, as: :run
  defdelegate subscribe_to_analysis(entry_id), to: AnalysisEvents, as: :subscribe
end
