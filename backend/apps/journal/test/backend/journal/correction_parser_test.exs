defmodule Backend.Journal.CorrectionParserTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Backend.Journal.CorrectionParser

  @moduletag :capture_log

  defp correction(original, category \\ "verb_agreement") do
    %{
      "original" => original,
      "fix" => "fixed",
      "explanation" => "Because.",
      "category" => category
    }
  end

  defp spans(body, items) do
    {:ok, corrections} = CorrectionParser.parse(body, %{"corrections" => items})
    Enum.map(corrections, &{&1.span_start, &1.span_end})
  end

  test "counts spans in code points, so an accented letter counts once" do
    assert spans("Hier, je suis allé à le marché.", [correction("à le")]) == [{19, 23}]
  end

  test "returns the fields to store, with the category as an atom" do
    body = "Je va au parc."

    assert {:ok, [correction]} =
             CorrectionParser.parse(body, %{"corrections" => [correction("Je va")]})

    assert correction == %{
             original: "Je va",
             fix: "fixed",
             explanation: "Because.",
             category: :verb_agreement,
             span_start: 0,
             span_end: 5
           }
  end

  test "locates a repeated phrase once per correction, searching forward" do
    body = "Je va au parc. Je va au café."
    assert spans(body, [correction("Je va"), correction("Je va")]) == [{0, 5}, {15, 20}]
  end

  test "matches whole words only" do
    assert spans("Elle mange le pain.", [correction("le", "article")]) == [{11, 13}]
  end

  test "matches regardless of case and stores the text as the person wrote it" do
    body = "Je va au parc."

    {:ok, [correction]} = CorrectionParser.parse(body, %{"corrections" => [correction("je va")]})

    assert correction.original == "Je va"
  end

  test "matches an original sent in decomposed form against a composed body" do
    decomposed_original = :unicode.characters_to_nfd_binary("allé")
    assert spans("Je suis allé.", [correction(decomposed_original, "verb_tense")]) == [{8, 12}]
  end

  test "drops a correction whose text is not in the body and keeps the rest" do
    assert spans("Je va au parc.", [correction("nous sommes"), correction("Je va")]) == [{0, 5}]
  end

  test "drops a correction that appears before the previous one" do
    body = "Je va au parc avec le chien."
    assert spans(body, [correction("le chien", "article"), correction("Je va")]) == [{19, 27}]
  end

  test "drops a correction with a category outside the list" do
    assert spans("Je va au parc.", [correction("Je va", "verb tense")]) == []
  end

  test "drops a correction whose fix is the same as its original and keeps the rest" do
    unchanged = Map.put(correction("au parc"), "fix", "au parc")
    assert spans("Je va au parc.", [correction("Je va"), unchanged]) == [{0, 5}]
  end

  test "drops a correction with a missing or empty field" do
    missing_fix = Map.delete(correction("Je va"), "fix")
    assert spans("Je va au parc.", [missing_fix, correction("")]) == []
  end

  test "keeps the teacher's reaction, trimmed, when every correction was kept" do
    response = %{"corrections" => [correction("Je va")], "teacher_reaction" => " Zut! One slip. "}
    {:ok, corrections} = CorrectionParser.parse("Je va au parc.", response)

    assert CorrectionParser.parse_teacher_reaction(response, corrections) == "Zut! One slip."
  end

  test "drops the teacher's reaction when a correction was dropped, so its count cannot be wrong" do
    response = %{
      "corrections" => [correction("Je va"), correction("nous sommes")],
      "teacher_reaction" => "Zut! Two slips."
    }

    {:ok, corrections} = CorrectionParser.parse("Je va au parc.", response)

    assert CorrectionParser.parse_teacher_reaction(response, corrections) == nil
  end

  test "drops a teacher's reaction that is blank, too long or missing" do
    blank = %{"corrections" => [], "teacher_reaction" => "  "}
    too_long = %{"corrections" => [], "teacher_reaction" => String.duplicate("a", 201)}
    missing = %{"corrections" => []}

    for response <- [blank, too_long, missing] do
      assert CorrectionParser.parse_teacher_reaction(response, []) == nil
    end
  end

  test "logs why a correction was dropped and its category, with no text from the entry" do
    body = "Mon secret: je va au parc."

    log =
      capture_log(fn ->
        CorrectionParser.parse(body, %{"corrections" => [correction("je vais", "verb_tense")]})
      end)

    assert log =~ "not_found_after_previous_correction, category \"verb_tense\""
    refute log =~ "je va"
    refute log =~ "secret"
  end

  test "rejects a response without a list of corrections" do
    assert CorrectionParser.parse("Je va.", %{"text" => "Je vais."}) ==
             {:error, :malformed_response}

    assert CorrectionParser.parse("Je va.", %{"corrections" => "none"}) ==
             {:error, :malformed_response}
  end
end
