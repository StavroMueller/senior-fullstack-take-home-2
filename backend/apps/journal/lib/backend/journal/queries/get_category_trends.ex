defmodule Backend.Journal.Queries.GetCategoryTrends do
  @moduledoc "Reads the correction categories of every analyzed entry, oldest first, and returns their counts and trends."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.CategoryTrends

  def run do
    Entry
    |> where([entry], entry.analysis_status == :analyzed)
    |> join(:left, [entry], correction in assoc(entry, :corrections))
    |> order_by([entry], asc: entry.inserted_at, asc: entry.id)
    |> select([entry, correction], {entry.id, correction.category})
    |> Repo.all()
    |> Enum.chunk_by(fn {entry_id, _category} -> entry_id end)
    |> Enum.map(&categories_of_entry/1)
    |> CategoryTrends.from_entries()
  end

  defp categories_of_entry(rows_of_entry) do
    for {_entry_id, category} <- rows_of_entry, not is_nil(category), do: category
  end
end
