defmodule Backend.ApiWeb.JourneyRouteTest do
  @moduledoc "Walks one seeded journey over GraphQL from its first point of interest, through its encounters, to its end."

  use Backend.ApiWeb.GraphqlCase, async: false

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  @journey_fields """
  id
  pointsOfInterest { name }
  encounters { afterPointOfInterestIndex prompt }
  openEncounter { id prompt }
  currentPointOfInterestIndex
  canTravelOn
  currentScene
  intro
  """

  @ghost_baker_prompt "Tiens! The bakery at the crossroads is open, but the baker is a ghost. The croissants smell real, at least. Order our breakfast in French: what do you want, and how many?"

  defp read_journey do
    %{"data" => %{"currentJourney" => journey}} =
      graphql("query { currentJourney { #{@journey_fields} } }")

    journey
  end

  defp submit_entry(journey_id, body) do
    graphql(
      """
      mutation($input: SubmitEntryInput!) {
        submitEntry(input: $input) {
          pointOfInterestIndex
          encounter { id }
        }
      }
      """,
      %{input: %{journeyId: journey_id, body: body}}
    )
  end

  defp travel_on(journey_id) do
    graphql("mutation($id: ID!) { travelOn(journeyId: $id) { id } }", %{id: journey_id})
  end

  defp written_place(journey_id) do
    %{"data" => %{"submitEntry" => entry}} = submit_entry(journey_id, "Bonjour.")

    case entry do
      %{"encounter" => %{"id" => encounter_id}} -> {:encounter, encounter_id}
      %{"pointOfInterestIndex" => index} -> {:point_of_interest, index}
    end
  end

  test "a place takes several entries, and the journey moves on only when asked" do
    %Journey{id: journey_id} = Repo.insert!(%Journey{seed: 1, language: "fr", level: "A1"})

    journey = read_journey()
    assert length(journey["pointsOfInterest"]) == 5
    assert journey["currentPointOfInterestIndex"] == 0
    assert journey["canTravelOn"] == false

    assert %{"errors" => [%{"message" => "no_entry_here"}]} = travel_on(journey_id)

    assert written_place(journey_id) == {:point_of_interest, 0}
    assert written_place(journey_id) == {:point_of_interest, 0}
    assert read_journey()["canTravelOn"] == true
  end

  test "seed 1 travels through every point of interest and its encounters to the end" do
    %Journey{id: journey_id} = Repo.insert!(%Journey{seed: 1, language: "fr", level: "A1"})

    assert written_place(journey_id) == {:point_of_interest, 0}
    travel_on(journey_id)

    %{
      "openEncounter" => %{"id" => _ghost_baker_id, "prompt" => @ghost_baker_prompt},
      "currentScene" => @ghost_baker_prompt
    } = read_journey()

    assert %{"data" => %{"submitEntry" => _entry}} = submit_entry(journey_id, "Un croissant.")
    travel_on(journey_id)
    assert read_journey()["currentScene"] =~ "Vichy"

    places =
      for _place <- 1..6 do
        place = written_place(journey_id)
        travel_on(journey_id)
        place
      end

    assert [
             {:point_of_interest, 1},
             {:point_of_interest, 2},
             {:encounter, _lost_knight_id},
             {:point_of_interest, 3},
             {:encounter, _giant_snail_id},
             {:point_of_interest, 4}
           ] = places

    finished = read_journey()
    assert finished["currentPointOfInterestIndex"] == nil
    assert finished["openEncounter"] == nil
    assert finished["canTravelOn"] == false
    assert Enum.map(finished["encounters"], & &1["afterPointOfInterestIndex"]) == [0, 2, 3]

    assert %{"errors" => [%{"message" => "journey_finished"}]} =
             submit_entry(journey_id, "Encore un mot.")

    assert %{"errors" => [%{"message" => "journey_finished"}]} = travel_on(journey_id)
  end

  test "a new journey opens on the teacher's intro to its route and the scene in its first town" do
    %{"data" => %{"startJourney" => %{"pointsOfInterest" => towns}}} =
      graphql(
        ~s|mutation { startJourney(language: "fr", level: "A1") { pointsOfInterest { name } } }|
      )

    [%{"name" => first_town} | _later_towns] = towns
    %{"name" => last_town} = List.last(towns)
    journey = read_journey()

    assert journey["intro"] =~ first_town
    assert journey["intro"] =~ last_town
    assert journey["currentScene"] =~ first_town
  end

  test "lists French A1 in France as the language a journey can start in" do
    assert %{
             "data" => %{
               "languages" => [%{"code" => "fr", "level" => "A1", "country" => "France"}]
             }
           } =
             graphql("query { languages { code level country } }")
  end

  test "a journey in a language with no data files is refused" do
    assert %{"errors" => [%{"message" => "language_not_offered"}]} =
             graphql(~s|mutation { startJourney(language: "xx", level: "A1") { id } }|)
  end

  test "an entry for a journey that does not exist is refused" do
    assert %{"errors" => [%{"message" => "journey_not_found"}]} =
             submit_entry("999999", "Bonjour.")
  end
end
