defmodule Backend.Journal.AiProvider.OpenRouter do
  @moduledoc "An AI provider that asks a pinned model on OpenRouter for an entry's corrections as schema-checked JSON."

  @behaviour Backend.Journal.AiProvider

  alias Backend.Database.Schema.Correction

  @endpoint "https://openrouter.ai/api/v1/chat/completions"
  @max_output_tokens 2000
  @category_names Enum.map(Ecto.Enum.values(Correction, :category), &Atom.to_string/1)

  @response_format %{
    type: "json_schema",
    json_schema: %{
      name: "corrections",
      strict: true,
      schema: %{
        type: "object",
        additionalProperties: false,
        required: ["corrections"],
        properties: %{
          corrections: %{
            type: "array",
            items: %{
              type: "object",
              additionalProperties: false,
              required: ["original", "fix", "explanation", "category"],
              properties: %{
                original: %{type: "string"},
                fix: %{type: "string"},
                explanation: %{type: "string"},
                category: %{type: "string", enum: @category_names}
              }
            }
          }
        }
      }
    }
  }

  @impl true
  def correct_entry(body, language, level) do
    settings = Application.fetch_env!(:journal, __MODULE__)

    @endpoint
    |> Req.post(
      auth: {:bearer, Keyword.fetch!(settings, :api_key)},
      json: request_body(Keyword.fetch!(settings, :model), body, language, level),
      retry: false
    )
    |> read_corrections()
  end

  defp request_body(model, body, language, level) do
    %{
      model: model,
      max_tokens: @max_output_tokens,
      response_format: @response_format,
      provider: %{require_parameters: true},
      messages: [
        %{role: "system", content: correction_instructions(language, level)},
        %{role: "user", content: body}
      ]
    }
  end

  defp correction_instructions(language, level) do
    """
    You correct text written by a learner of the language with ISO 639-1 code "#{language}", at CEFR level #{level}.
    Return every error in the entry as one correction.
    "original" is the shortest span that contains the error, copied character for character from the entry.
    "original" and "fix" cover whole words. When a fix joins two words, as when "je aime" becomes "j'aime", "original" holds both words.
    "fix" is the corrected span. "explanation" is one short sentence in English.
    "category" is the kind of error.
    List corrections in the order they appear in the entry.
    Do not correct style or word choice that is already correct. If the entry has no errors, return an empty list.
    """
  end

  defp read_corrections(
         {:ok,
          %Req.Response{
            status: 200,
            body: %{
              "choices" => [%{"finish_reason" => "stop", "message" => %{"content" => content}}]
            }
          }}
       ) do
    case Jason.decode(content) do
      {:ok, corrections_response} -> {:ok, corrections_response}
      {:error, _decode_error} -> {:error, :response_not_json}
    end
  end

  defp read_corrections(
         {:ok, %Req.Response{status: 200, body: %{"choices" => [%{"finish_reason" => reason}]}}}
       ) do
    {:error, {:response_unfinished, reason}}
  end

  defp read_corrections(
         {:ok, %Req.Response{status: status, body: %{"error" => %{"message" => message}}}}
       ) do
    {:error, {:openrouter_status, status, message}}
  end

  defp read_corrections({:ok, %Req.Response{status: status}}) do
    {:error, {:openrouter_status, status}}
  end

  defp read_corrections({:error, _exception} = failure), do: failure
end
