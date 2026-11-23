defmodule Backend.CredoChecks.CommentRules do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Comments follow the CLAUDE.md "Comments" rule:

        * no comments; a fact lives in a name or in a test
        * `@moduledoc` is at most two lines of text, `@doc` at most one
        * no phase, plan, decision or requirement IDs in docs, `@desc` strings
          or test names
      """
    ]

  @planning_id_pattern ~r/\bPhase \d+|\bPlan \d+|\bD-\d+\b|\bT-\d+-\d+\b|\b(?!RFC|ISO|SHA|UTF)[A-Z]{2,}-\d{2,}\b/

  @tool_directive_markers ["credo:", "dialyzer"]

  @maximum_lines_by_doc_attribute %{moduledoc: 2, doc: 1}

  @id_bearing_attributes [:moduledoc, :doc, :desc]
  @test_name_macros [:describe, :test]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    context = Context.build(source_file, params, __MODULE__)

    comment_issues = comment_issues(source_file, context)

    walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

    comment_issues ++ walked_context.issues
  end

  defp comment_issues(source_file, context) do
    source = SourceFile.source(source_file)

    case Code.string_to_quoted_with_comments(source) do
      {:ok, _ast, comments} ->
        comments
        |> Enum.reject(&tool_directive?/1)
        |> Enum.map(&comment_issue(&1, context))

      {:error, _parse_error} ->
        []
    end
  end

  defp tool_directive?(%{text: text}), do: String.contains?(text, @tool_directive_markers)

  defp comment_issue(comment, context) do
    format_issue(context,
      message: "Delete this comment; carry the fact in a name or pin it with a test.",
      trigger: "#",
      line_no: comment.line
    )
  end

  defp walk({:@, meta, [{attribute, _attribute_meta, [text]}]} = ast, context)
       when attribute in @id_bearing_attributes and is_binary(text) do
    length_issues = doc_length_issues(attribute, text, meta[:line], context)
    planning_id_issues = string_planning_id_issues(text, meta[:line], context)

    updated_context = put_issue(context, length_issues ++ planning_id_issues)

    {ast, updated_context}
  end

  defp walk({macro, meta, [name | _rest]} = ast, context)
       when macro in @test_name_macros and is_binary(name) do
    planning_id_issues = string_planning_id_issues(name, meta[:line], context)

    {ast, put_issue(context, planning_id_issues)}
  end

  defp walk(ast, context), do: {ast, context}

  defp doc_length_issues(attribute, text, line_number, context) do
    maximum_lines = Map.get(@maximum_lines_by_doc_attribute, attribute)

    text_lines =
      text
      |> String.split("\n")
      |> Enum.reject(&(String.trim(&1) == ""))

    line_count = length(text_lines)

    if maximum_lines != nil and line_count > maximum_lines do
      issue =
        format_issue(context,
          message: "`@#{attribute}` has #{line_count} lines; the limit is #{maximum_lines}.",
          trigger: "@#{attribute}",
          line_no: line_number
        )

      [issue]
    else
      []
    end
  end

  defp string_planning_id_issues(text, line_number, context) do
    if Regex.match?(@planning_id_pattern, text) do
      [planning_id_issue(text, line_number, context)]
    else
      []
    end
  end

  defp planning_id_issue(text, line_number, context) do
    [planning_id | _other_matches] = Regex.run(@planning_id_pattern, text)

    format_issue(context,
      message: "Remove the planning ID `#{planning_id}`; say what the code does instead.",
      trigger: planning_id,
      line_no: line_number
    )
  end
end
