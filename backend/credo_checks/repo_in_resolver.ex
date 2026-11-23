defmodule Backend.CredoChecks.RepoInResolver do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Resolvers check authorization and map arguments. Reads and writes go
      through the domain app's queries and commands, never `Repo` directly.
      """
    ]

  @resolver_directory "apps/graphql/lib/backend/graphql/resolvers/"

  @impl true
  def run(%SourceFile{} = source_file, params) do
    if String.contains?(source_file.filename, @resolver_directory) do
      context = Context.build(source_file, params, __MODULE__)
      walked_context = Credo.Code.prewalk(source_file, &walk/2, context)

      walked_context.issues
    else
      []
    end
  end

  defp walk(
         {{:., _dot_meta, [{:__aliases__, _alias_meta, module_parts}, function_name]}, meta,
          _arguments} = ast,
         context
       ) do
    if List.last(module_parts) == :Repo do
      issue =
        format_issue(context,
          message: "Move `Repo.#{function_name}` into a domain query or command.",
          trigger: "Repo",
          line_no: meta[:line]
        )

      {ast, put_issue(context, issue)}
    else
      {ast, context}
    end
  end

  defp walk(ast, context), do: {ast, context}
end
