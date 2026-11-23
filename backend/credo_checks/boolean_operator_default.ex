defmodule Backend.CredoChecks.BooleanOperatorDefault do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      `||` and `&&` treat `false` and `nil` alike, so they hide which one arrived.

          name = payload["guest_name"] || "A guest"
          user && user.active

      Match the shape instead:

          defp guest_name(%{"guest_name" => name}) when is_binary(name), do: name
          defp guest_name(_payload), do: "A guest"
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
