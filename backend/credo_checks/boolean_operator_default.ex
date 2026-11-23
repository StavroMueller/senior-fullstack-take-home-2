defmodule Backend.CredoChecks.BooleanOperatorDefault do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      `||` and `&&` treat `false` and `nil` alike, so they hide which one arrived.

          category = correction["category"] || "other"
          entry && entry.analyzed_at

      Match the shape instead:

          defp category(%{"category" => category}) when is_binary(category), do: category
          defp category(_correction), do: "other"
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    context = Context.build(source_file, params, __MODULE__)
    walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

    walked_context.issues
  end

  defp walk({operator, meta, [_left_side, _right_side]} = ast, context)
       when operator in [:||, :&&] do
    issue =
      format_issue(context,
        message: "Replace `#{operator}` with a pattern match or `Map.get/3`.",
        trigger: Atom.to_string(operator),
        line_no: meta[:line]
      )

    {ast, put_issue(context, issue)}
  end

  defp walk(ast, context), do: {ast, context}
end
