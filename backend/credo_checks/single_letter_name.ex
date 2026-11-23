defmodule Backend.CredoChecks.SingleLetterName do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Variables are named for what they hold, never a single letter.

          from(c in Correction, where: c.entry_id == ^entry_id)
          Enum.sort_by(entries, fn e -> e.inserted_at end)

      should read:

          from(correction in Correction, where: correction.entry_id == ^entry_id)
          Enum.sort_by(entries, fn entry -> entry.inserted_at end)
      """
    ]

  @binding_operators [:=, :->, :<-, :in]
  @definition_keywords [:def, :defp, :defmacro, :defmacrop]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    context =
      source_file
      |> Context.build(params, __MODULE__)
      |> Map.put(:reported, MapSet.new())

    walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

    walked_context.issues
  end

  defp walk({operator, _meta, [pattern, _right_side]} = ast, context)
       when operator in @binding_operators do
    {ast, report_single_letter_variables(pattern, context)}
  end

  defp walk({keyword, _meta, [function_head | _body]} = ast, context)
       when keyword in @definition_keywords do
    {ast, report_single_letter_variables(function_head, context)}
  end

  defp walk(ast, context), do: {ast, context}

  defp report_single_letter_variables({:@, _meta, _attribute}, context), do: context

  defp report_single_letter_variables({:^, _meta, _pinned}, context), do: context

  defp report_single_letter_variables({name, meta, variable_context} = variable, context)
       when is_atom(name) and is_atom(variable_context) do
    if single_letter?(name) do
      report(variable, meta, context)
    else
      context
    end
  end

  defp report_single_letter_variables({_name, _meta, children}, context) when is_list(children) do
    Enum.reduce(children, context, &report_single_letter_variables/2)
  end

  defp report_single_letter_variables(children, context) when is_list(children) do
    Enum.reduce(children, context, &report_single_letter_variables/2)
  end

  defp report_single_letter_variables(tuple, context) when is_tuple(tuple) do
    elements = Tuple.to_list(tuple)

    Enum.reduce(elements, context, &report_single_letter_variables/2)
  end

  defp report_single_letter_variables(_literal, context), do: context

  defp single_letter?(name) do
    name_without_underscore =
      name
      |> Atom.to_string()
      |> String.trim_leading("_")

    String.length(name_without_underscore) == 1
  end

  defp report({name, _meta, _variable_context}, meta, context) do
    line_number = meta[:line]
    report_key = {name, line_number}

    if MapSet.member?(context.reported, report_key) do
      context
    else
      issue =
        format_issue(context,
          message: "Name `#{name}` for what it holds, not a single letter.",
          trigger: Atom.to_string(name),
          line_no: line_number
        )

      reported = MapSet.put(context.reported, report_key)

      context
      |> put_issue(issue)
      |> Map.put(:reported, reported)
    end
  end
end
