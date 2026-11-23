defmodule Backend.Journal.AiProvider.StubTest do
  use ExUnit.Case, async: true

  alias Backend.Journal.AiProvider.Stub
  alias Backend.Journal.CorrectionParser

  test "returns corrections the parser locates, in body order" do
    body = "Hier, j'ai allé à le marché. Je va voir le maison."

    {:ok, response} = Stub.correct_entry(body, "fr", "A1")
    {:ok, corrections} = CorrectionParser.parse(body, response)

    assert Enum.map(corrections, &{&1.original, &1.category}) == [
             {"j'ai allé", :verb_tense},
             {"à le", :preposition},
             {"Je va", :verb_agreement},
             {"le maison", :gender}
           ]
  end

  test "returns no corrections for text it has no canned correction for" do
    assert Stub.correct_entry("Bonjour.", "fr", "A1") == {:ok, %{"corrections" => []}}
  end
end
