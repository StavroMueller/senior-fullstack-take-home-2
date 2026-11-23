defmodule Backend.Database.NoCommentsTest do
  @moduledoc "No Elixir file in the backend holds a comment, migrations and config included."

  use ExUnit.Case, async: true

  @backend_root Path.expand("../../../../..", __DIR__)
  @generated_directories ["deps/", "_build/"]
  @tool_directive_markers ["credo:", "dialyzer"]

  test "every .ex and .exs file is free of comments" do
    comments =
      @backend_root
      |> elixir_files()
      |> Enum.flat_map(&comments_in/1)

    assert comments == []
  end

  defp elixir_files(root) do
    root
    |> Path.join("**/*.{ex,exs}")
    |> Path.wildcard(match_dot: true)
    |> Enum.map(&Path.relative_to(&1, root))
    |> Enum.reject(&String.starts_with?(&1, @generated_directories))
  end

  defp comments_in(relative_path) do
    absolute_path = Path.join(@backend_root, relative_path)
    source = File.read!(absolute_path)
    {:ok, _ast, comments} = Code.string_to_quoted_with_comments(source)

    comments
    |> Enum.reject(&String.contains?(&1.text, @tool_directive_markers))
    |> Enum.map(&"#{relative_path}:#{&1.line} #{&1.text}")
  end
end
