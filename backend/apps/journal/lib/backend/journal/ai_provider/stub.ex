defmodule Backend.Journal.AiProvider.Stub do
  @moduledoc "An AI provider that returns canned French A1 corrections for the phrases it knows and no scenes or intros, with no network call."

  @behaviour Backend.Journal.AiProvider

  @known_corrections [
    %{
      "original" => "je va",
      "fix" => "je vais",
      "explanation" => "With je, aller becomes vais.",
      "category" => "verb_agreement"
    },
    %{
      "original" => "j'ai allé",
      "fix" => "je suis allé",
      "explanation" => "Aller takes être in the passé composé.",
      "category" => "verb_tense"
    },
    %{
      "original" => "le maison",
      "fix" => "la maison",
      "explanation" => "Maison is feminine, so it takes la.",
      "category" => "gender"
    },
    %{
      "original" => "à le",
      "fix" => "au",
      "explanation" => "À and le join to make au.",
      "category" => "preposition"
    }
  ]

  @impl true
  def describe_point_of_interest(_town, _language, _level), do: {:error, :stub_writes_no_scenes}

  @impl true
  def introduce_journey(_towns, _language, _level), do: {:error, :stub_writes_no_intros}

  @impl true
  def correct_entry(body, _language, _level) do
    lowercase_body = String.downcase(body)

    corrections =
      @known_corrections
      |> Enum.flat_map(&with_first_position(&1, lowercase_body))
      |> Enum.sort_by(fn {position, _correction} -> position end)
      |> Enum.map(fn {_position, correction} -> correction end)

    {:ok, %{"corrections" => corrections}}
  end

  defp with_first_position(%{"original" => original} = correction, lowercase_body) do
    case :binary.match(lowercase_body, original) do
      {position, _length} -> [{position, correction}]
      :nomatch -> []
    end
  end
end
