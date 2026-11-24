defmodule Backend.ApiWeb.CategoryTrendsTest do
  @moduledoc "Analyzes entries through Oban and reads each mistake category's count and trend over GraphQL."

  use Backend.ApiWeb.GraphqlCase, async: false

  @category_trends_query """
  query {
    categoryTrends {
      analyzedEntryCount
      olderEntryCount
      recentEntryCount
      categories { category count trend }
    }
  }
  """

  defp submit_entry(journey_id, body) do
    graphql(
      "mutation($input: SubmitEntryInput!) { submitEntry(input: $input) { id } }",
      %{input: %{journeyId: journey_id, body: body}}
    )
  end

  defp run_analysis_jobs,
    do: Oban.drain_queue(queue: :analysis, with_recursion: true, with_scheduled: true)

  test "counts the categories of analyzed entries and compares the older half with the recent half" do
    %{"data" => %{"startJourney" => %{"id" => journey_id}}} =
      graphql("mutation { startJourney { id } }")

    for body <- [
          "Hier, j'ai allé à le marché.",
          "Je va à la plage.",
          "Le maison est grande.",
          "Après, j'ai allé au parc."
        ] do
      submit_entry(journey_id, body)
      run_analysis_jobs()
    end

    submit_entry(journey_id, "Je va au cinéma.")

    %{"data" => %{"categoryTrends" => category_trends}} = graphql(@category_trends_query)

    assert category_trends == %{
             "analyzedEntryCount" => 4,
             "olderEntryCount" => 2,
             "recentEntryCount" => 2,
             "categories" => [
               %{"category" => "VERB_TENSE", "count" => 2, "trend" => "STEADY"},
               %{"category" => "GENDER", "count" => 1, "trend" => "MORE_LATELY"},
               %{"category" => "PREPOSITION", "count" => 1, "trend" => "GONE_LATELY"},
               %{"category" => "VERB_AGREEMENT", "count" => 1, "trend" => "GONE_LATELY"}
             ]
           }
  end
end
