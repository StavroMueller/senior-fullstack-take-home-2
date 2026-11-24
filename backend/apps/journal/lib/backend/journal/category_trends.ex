defmodule Backend.Journal.CategoryTrends do
  @moduledoc "Counts each mistake category over the analyzed entries and compares the older half of those entries with the recent half."

  @trends [:fewer_lately, :more_lately, :steady, :gone_lately]

  @doc "The trends a mistake category can show."
  def trends, do: @trends

  @doc "Takes the correction categories of each analyzed entry, oldest entry first, and returns the size of each half and one row per category, most frequent first."
  def from_entries(categories_per_entry) do
    older_entry_count = div(length(categories_per_entry), 2)
    {older_entries, recent_entries} = Enum.split(categories_per_entry, older_entry_count)
    recent_entry_count = length(recent_entries)
    older_counts = older_entries |> List.flatten() |> Enum.frequencies()
    recent_counts = recent_entries |> List.flatten() |> Enum.frequencies()

    categories =
      (Map.keys(older_counts) ++ Map.keys(recent_counts))
      |> Enum.uniq()
      |> Enum.map(fn category ->
        older_count = Map.get(older_counts, category, 0)
        recent_count = Map.get(recent_counts, category, 0)

        %{
          category: category,
          count: older_count + recent_count,
          trend:
            trend(
              older_entry_count,
              older_count * recent_entry_count,
              recent_count * older_entry_count
            )
        }
      end)
      |> Enum.sort_by(fn row -> {-row.count, Atom.to_string(row.category)} end)

    %{
      analyzed_entry_count: length(categories_per_entry),
      older_entry_count: older_entry_count,
      recent_entry_count: recent_entry_count,
      categories: categories
    }
  end

  defp trend(0 = _older_entry_count, _older_rate, _recent_rate), do: nil
  defp trend(_older_entry_count, older_rate, 0) when older_rate > 0, do: :gone_lately

  defp trend(_older_entry_count, older_rate, recent_rate) when recent_rate < older_rate,
    do: :fewer_lately

  defp trend(_older_entry_count, older_rate, recent_rate) when recent_rate > older_rate,
    do: :more_lately

  defp trend(_older_entry_count, _older_rate, _recent_rate), do: :steady
end
