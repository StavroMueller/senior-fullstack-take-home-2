defmodule Backend.CredoChecks.CatchAllRescue do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      A `rescue` that binds any exception turns every crash into a log line.

          rescue
            exception -> Logger.error(...)

      Rescue only the exception you expect, or let it crash:

          rescue
            ArgumentError -> :ok
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    context = Context.build(source_file, params, __MODULE__)
    walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

    walked_context.issues
  end

  defp walk({:rescue, rescue_clauses} = ast, context) when is_list(rescue_clauses) do
    catch_all_clauses = Enum.filter(rescue_clauses, &catch_all_clause?/1)
    issues = Enum.map(catch_all_clauses, &issue_for(&1, context))

    {ast, put_issue(context, issues)}
  end

  defp walk(ast, context), do: {ast, context}

  defp catch_all_clause?({:->, _meta, [[{name, _variable_meta, variable_context}], _body]})
       when is_atom(name) and is_atom(variable_context),
       do: true

  defp catch_all_clause?(_clause), do: false

  defp issue_for({:->, meta, [[{name, _variable_meta, _variable_context}], _body]}, context) do
    format_issue(context,
      message: "Rescue a named exception type, not every exception.",
      trigger: Atom.to_string(name),
      line_no: meta[:line]
    )
  end
end
