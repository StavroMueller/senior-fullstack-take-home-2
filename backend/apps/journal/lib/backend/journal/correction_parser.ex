defmodule Backend.Journal.CorrectionParser do
  @moduledoc "Validates the AI provider's response and locates each correction in the entry body by code point."

  require Logger

  alias Backend.Database.Schema.Correction

  @categories_by_name Map.new(Ecto.Enum.mappings(Correction, :category), fn {category, name} ->
                        {name, category}
                      end)

  @longest_teacher_reaction 200

  @doc "Returns the teacher's reaction from the response when it is one short line and every correction in the response was kept, or nil."
  def parse_teacher_reaction(
        %{"teacher_reaction" => reaction, "corrections" => items},
        kept_corrections
      )
      when is_binary(reaction) and length(items) == length(kept_corrections) do
    trimmed_reaction = String.trim(reaction)

    if trimmed_reaction != "" and String.length(trimmed_reaction) <= @longest_teacher_reaction,
      do: trimmed_reaction
  end

  def parse_teacher_reaction(_response, _kept_corrections), do: nil

  @doc "Returns the valid corrections found in the body, in body order, with code point spans."
  def parse(body, %{"corrections" => items}) when is_list(items) do
    {corrections, _byte_cursor} = Enum.flat_map_reduce(items, 0, &locate(body, &1, &2))
    {:ok, corrections}
  end

  def parse(_body, _response), do: {:error, :malformed_response}

  defp locate(body, item, byte_cursor) do
    with {:ok, fields} <- validate(item),
         {:ok, byte_start, byte_length} <- find(body, fields.original, byte_cursor) do
      byte_end = byte_start + byte_length

      correction =
        Map.merge(fields, %{
          original: binary_part(body, byte_start, byte_length),
          span_start: code_points_before(body, byte_start),
          span_end: code_points_before(body, byte_end)
        })

      {[correction], byte_end}
    else
      {:error, reason} ->
        Logger.warning(
          "Dropped a correction from the AI provider: #{reason}, category #{logged_category_name(item)}"
        )

        {[], byte_cursor}
    end
  end

  defp validate(%{"original" => unchanged_text, "fix" => unchanged_text}),
    do: {:error, :fix_changes_nothing}

  defp validate(%{
         "original" => original,
         "fix" => fix,
         "explanation" => explanation,
         "category" => category_name
       })
       when is_binary(original) and original != "" and is_binary(fix) and
              is_binary(explanation) and is_binary(category_name) do
    case Map.fetch(@categories_by_name, category_name) do
      {:ok, category} ->
        {:ok,
         %{
           original: :unicode.characters_to_nfc_binary(original),
           fix: :unicode.characters_to_nfc_binary(fix),
           explanation: explanation,
           category: category
         }}

      :error ->
        {:error, :unknown_category}
    end
  end

  defp validate(_item), do: {:error, :malformed_correction}

  defp find(body, original, byte_cursor) do
    pattern =
      Regex.compile!(
        "(?<![\\p{L}\\p{N}])" <> Regex.escape(original) <> "(?![\\p{L}\\p{N}])",
        "iu"
      )

    case Regex.run(pattern, body, offset: byte_cursor, return: :index) do
      [{byte_start, byte_length}] -> {:ok, byte_start, byte_length}
      nil -> {:error, :not_found_after_previous_correction}
    end
  end

  defp logged_category_name(%{"category" => category_name}), do: inspect(category_name)
  defp logged_category_name(_item), do: "missing"

  defp code_points_before(body, byte_offset) do
    body |> binary_part(0, byte_offset) |> String.codepoints() |> length()
  end
end
