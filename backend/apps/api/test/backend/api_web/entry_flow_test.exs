defmodule Backend.ApiWeb.EntryFlowTest do
  @moduledoc "Submits an entry over GraphQL, runs its analysis through Oban and reads it back."

  use Backend.ApiWeb.GraphqlCase, async: false

  import Phoenix.ChannelTest

  alias Backend.ApiWeb.EntryChannel
  alias Backend.ApiWeb.Test.FailingAiProvider
  alias Backend.ApiWeb.Test.ReactingAiProvider
  alias Backend.ApiWeb.UserSocket

  @endpoint Backend.ApiWeb.Endpoint

  @entry_fields """
  id
  body
  analysisStatus
  teacherReaction
  corrections { spanStart spanEnd original fix category }
  """

  defp start_journey do
    %{"data" => %{"startJourney" => %{"id" => journey_id}}} =
      graphql("mutation { startJourney { id language level } }")

    journey_id
  end

  defp submit_entry(journey_id, body) do
    graphql(
      "mutation($input: SubmitEntryInput!) { submitEntry(input: $input) { #{@entry_fields} } }",
      %{input: %{journeyId: journey_id, body: body}}
    )
  end

  defp read_entry(entry_id) do
    %{"data" => %{"entry" => entry}} =
      graphql("query($id: ID!) { entry(id: $id) { #{@entry_fields} } }", %{id: entry_id})

    entry
  end

  defp join_entry_channel(entry_id) do
    {:ok, socket} = connect(UserSocket, %{})
    subscribe_and_join(socket, EntryChannel, "entry:#{entry_id}")
  end

  defp run_analysis_jobs,
    do: Oban.drain_queue(queue: :analysis, with_recursion: true, with_scheduled: true)

  test "an entry is saved as analyzing, analyzed by the job and read back with its corrections" do
    journey_id = start_journey()

    %{"data" => %{"submitEntry" => submitted}} =
      submit_entry(journey_id, "  Hier, j'ai allé à le marché.  ")

    assert submitted["analysisStatus"] == "ANALYZING"
    assert submitted["body"] == "Hier, j'ai allé à le marché."
    assert submitted["corrections"] == []
    assert submitted["teacherReaction"] == nil

    {:ok, %{analysis_status: :analyzing}, _socket} = join_entry_channel(submitted["id"])

    assert %{success: 1} = run_analysis_jobs()
    assert_push "analysis_finished", %{}

    {teacher_reaction, analyzed} = Map.pop(read_entry(submitted["id"]), "teacherReaction")
    assert teacher_reaction =~ "2 corrections"
    assert teacher_reaction =~ "verb tense"

    assert analyzed == %{
             "id" => submitted["id"],
             "body" => "Hier, j'ai allé à le marché.",
             "analysisStatus" => "ANALYZED",
             "corrections" => [
               %{
                 "spanStart" => 6,
                 "spanEnd" => 15,
                 "original" => "j'ai allé",
                 "fix" => "je suis allé",
                 "category" => "VERB_TENSE"
               },
               %{
                 "spanStart" => 16,
                 "spanEnd" => 20,
                 "original" => "à le",
                 "fix" => "au",
                 "category" => "PREPOSITION"
               }
             ]
           }
  end

  test "shows the AI's teacher reaction when the provider writes one" do
    Application.put_env(:journal, :ai_provider, ReactingAiProvider)

    on_exit(fn ->
      Application.put_env(:journal, :ai_provider, Backend.Journal.AiProvider.Stub)
    end)

    journey_id = start_journey()

    %{"data" => %{"submitEntry" => submitted}} =
      submit_entry(journey_id, "J'ai allé à le marché.")

    run_analysis_jobs()

    assert read_entry(submitted["id"])["teacherReaction"] == ReactingAiProvider.teacher_reaction()
  end

  test "lists entries newest first" do
    journey_id = start_journey()
    submit_entry(journey_id, "Je va au parc.")
    submit_entry(journey_id, "Bonjour.")

    %{"data" => %{"entries" => entries}} = graphql("query { entries { body } }")

    assert Enum.map(entries, & &1["body"]) == ["Bonjour.", "Je va au parc."]
  end

  test "rejects an empty entry and saves nothing" do
    journey_id = start_journey()

    %{"errors" => [%{"message" => message}]} = submit_entry(journey_id, "   ")

    assert message == "can't be blank"
    assert %{"data" => %{"entries" => []}} = graphql("query { entries { id } }")
  end

  test "a failing provider keeps the entry and marks its analysis failed after the last attempt" do
    Application.put_env(:journal, :ai_provider, FailingAiProvider)

    on_exit(fn ->
      Application.put_env(:journal, :ai_provider, Backend.Journal.AiProvider.Stub)
    end)

    journey_id = start_journey()
    %{"data" => %{"submitEntry" => submitted}} = submit_entry(journey_id, "Je va au parc.")
    {:ok, _reply, _socket} = join_entry_channel(submitted["id"])

    assert %{cancelled: 1} = run_analysis_jobs()
    assert_push "analysis_failed", %{}

    assert %{
             "body" => "Je va au parc.",
             "analysisStatus" => "ANALYSIS_FAILED",
             "teacherReaction" => nil,
             "corrections" => []
           } =
             read_entry(submitted["id"])

    Application.put_env(:journal, :ai_provider, Backend.Journal.AiProvider.Stub)

    %{"data" => %{"retryAnalysis" => %{"analysisStatus" => "ANALYZING"}}} =
      graphql("mutation($id: ID!) { retryAnalysis(entryId: $id) { analysisStatus } }", %{
        id: submitted["id"]
      })

    assert %{success: 1} = run_analysis_jobs()
    assert_push "analysis_finished", %{}

    assert %{"analysisStatus" => "ANALYZED", "corrections" => [%{"original" => "Je va"}]} =
             read_entry(submitted["id"])
  end

  test "refuses to retry an analysis that did not fail" do
    journey_id = start_journey()
    %{"data" => %{"submitEntry" => submitted}} = submit_entry(journey_id, "Bonjour.")

    assert %{"errors" => [%{"message" => "analysis_not_failed"}]} =
             graphql("mutation($id: ID!) { retryAnalysis(entryId: $id) { id } }", %{
               id: submitted["id"]
             })
  end

  test "refuses to join the channel of an entry that does not exist" do
    {:ok, socket} = connect(UserSocket, %{})

    assert {:error, %{reason: "not_found"}} =
             subscribe_and_join(socket, EntryChannel, "entry:999999")

    assert {:error, %{reason: "not_found"}} =
             subscribe_and_join(socket, EntryChannel, "entry:abc")
  end
end
