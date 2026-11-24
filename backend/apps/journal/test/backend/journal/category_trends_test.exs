defmodule Backend.Journal.CategoryTrendsTest do
  use ExUnit.Case, async: true

  alias Backend.Journal.CategoryTrends

  defp row_for(%{categories: categories}, category),
    do: Enum.find(categories, &(&1.category == category))

  test "no analyzed entries give no categories" do
    assert CategoryTrends.from_entries([]) == %{
             analyzed_entry_count: 0,
             older_entry_count: 0,
             recent_entry_count: 0,
             categories: []
           }
  end

  test "one analyzed entry gives counts and no trend" do
    trends = CategoryTrends.from_entries([[:gender, :gender]])

    assert trends.older_entry_count == 0
    assert trends.recent_entry_count == 1
    assert trends.categories == [%{category: :gender, count: 2, trend: nil}]
  end

  test "each category compares the older half of the entries with the recent half" do
    trends =
      CategoryTrends.from_entries([
        [:verb_tense, :verb_tense, :article, :spelling],
        [:verb_tense, :spelling],
        [:verb_tense, :gender, :spelling],
        [:gender, :spelling]
      ])

    assert row_for(trends, :verb_tense) == %{
             category: :verb_tense,
             count: 4,
             trend: :fewer_lately
           }

    assert row_for(trends, :gender) == %{category: :gender, count: 2, trend: :more_lately}
    assert row_for(trends, :spelling) == %{category: :spelling, count: 4, trend: :steady}
    assert row_for(trends, :article) == %{category: :article, count: 1, trend: :gone_lately}
  end

  test "with an odd count the recent half holds the extra entry and halves compare per entry" do
    trends = CategoryTrends.from_entries([[:article], [:article], [:article]])

    assert trends.older_entry_count == 1
    assert trends.recent_entry_count == 2
    assert row_for(trends, :article).trend == :steady
  end

  test "an entry with no corrections still counts toward its half" do
    trends = CategoryTrends.from_entries([[:preposition], [], [:preposition], []])

    assert row_for(trends, :preposition).trend == :steady
  end

  test "categories come most frequent first, then by name" do
    trends = CategoryTrends.from_entries([[:word_choice, :article], [:spelling, :spelling]])

    assert Enum.map(trends.categories, & &1.category) == [:spelling, :article, :word_choice]
  end
end
