defmodule Backend.Journal.Queries.GetCategoryTrends do
  @moduledoc "Reads the correction categories of the analyzed entries, of every journey or of one, oldest first, and returns their counts and trends."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.CategoryTrends

  def run(scope) do
    Entry
    |> where([entry], entry.analysis_status == :analyzed)
    |> written_on(scope)
    |> join(:left, [entry], correction in assoc(entry, :corrections))
    |> order_by([entry], asc: entry.inserted_at, asc: entry.id)
    |> select([entry, correction], {entry.id, correction.category})
    |> Repo.all()
    |> Enum.chunk_by(fn {entry_id, _category} -> entry_id end)
    |> Enum.map(&categories_of_entry/1)
    |> CategoryTrends.from_entries()
  end

  defp written_on(query, :every_journey), do: query

  defp written_on(query, %Journey{id: journey_id}),
    do: where(query, [entry], entry.journey_id == ^journey_id)

  defp categories_of_entry(rows_of_entry) do
    for {_entry_id, category} <- rows_of_entry, not is_nil(category), do: category
  end
end
