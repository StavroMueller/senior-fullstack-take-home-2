defmodule Backend.ApiWeb.ExampleJourneysTest do
  @moduledoc "Loads the recorded example journeys and reads them back over GraphQL."

  use Backend.ApiWeb.GraphqlCase, async: false

  alias Backend.Database.Commands.LoadExampleJourneys

  @now ~U[2026-11-24 12:00:00Z]

  @journeys_query """
  query {
    journeys {
      currentPointOfInterestIndex
      canTravelOn
      openEncounter { id }
      intro
      currentScene
      entries {
        body
        analysisStatus
        teacherReaction
        corrections { spanStart spanEnd original }
      }
    }
  }
  """

  setup do
    LoadExampleJourneys.execute(@now)
  end

  test "loads a finished journey, one partway along its route and one just started" do
    %{"data" => %{"journeys" => [just_started, partway, finished]}} = graphql(@journeys_query)

    assert finished["currentPointOfInterestIndex"] == nil
    assert just_started["currentPointOfInterestIndex"] == 0
    assert partway["currentPointOfInterestIndex"] > 0
    assert just_started["canTravelOn"] == true

    for journey <- [just_started, partway, finished] do
      assert journey["intro"] != nil
      assert journey["entries"] != []
    end
  end

  test "every example entry is analyzed, and each correction covers its original in the body" do
    %{"data" => %{"journeys" => journeys}} = graphql(@journeys_query)

    for journey <- journeys, entry <- journey["entries"] do
      assert entry["analysisStatus"] == "ANALYZED"
      assert entry["teacherReaction"] != nil

      for correction <- entry["corrections"] do
        covered =
          entry["body"]
          |> String.codepoints()
          |> Enum.slice(correction["spanStart"]..(correction["spanEnd"] - 1)//1)
          |> Enum.join()

        assert covered == correction["original"]
      end
    end
  end

  test "dates the entries before now, so the usual suspects show a trend" do
    %{"data" => %{"categoryTrends" => trends}} =
      graphql(
        "query { categoryTrends { olderEntryCount recentEntryCount categories { trend } } }"
      )

    assert trends["olderEntryCount"] > 0
    assert trends["recentEntryCount"] > 0
    assert Enum.any?(trends["categories"], &(&1["trend"] != nil))
  end
end
