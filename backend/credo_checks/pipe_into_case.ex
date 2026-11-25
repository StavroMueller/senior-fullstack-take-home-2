defmodule Backend.CredoChecks.PipeIntoCase do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      A pipe never ends in `case`. Bind the result to a name, then `case` on that name.

          Multi.new()
          |> Multi.insert(:entry, changeset)
          |> Repo.transaction()
          |> case do

      Write instead:

          multi =
            Multi.new()
            |> Multi.insert(:entry, changeset)

          case Repo.transaction(multi) do
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    context = Context.build(source_file, params, __MODULE__)
    walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

    walked_context.issues
  end

  defp walk({:|>, _pipe_meta, [_piped_value, {:case, case_meta, _clauses}]} = ast, context) do
    issue =
      format_issue(context,
        message: "Bind the piped result to a name, then `case` on that name.",
        trigger: "case",
        line_no: case_meta[:line]
      )

    {ast, put_issue(context, issue)}
  end

  defp walk(ast, context), do: {ast, context}
end
