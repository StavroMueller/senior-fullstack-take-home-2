import { render, screen, within } from "@testing-library/react";
import { UsualSuspects } from "~/journal/UsualSuspects";

describe("UsualSuspects", () => {
  it("lists each mistake category with its count and trend, most frequent first", () => {
    render(
      <UsualSuspects
        categoryTrends={{
          olderEntryCount: 2,
          recentEntryCount: 2,
          categories: [
            { category: "VERB_TENSE", count: 3, trend: "FEWER_LATELY" },
            { category: "GENDER", count: 1, trend: "GONE_LATELY" },
          ],
        }}
      />,
    );

    const rows = screen.getAllByRole("listitem");
    expect(within(rows[0]).getByText("Verb tense")).toBeInTheDocument();
    expect(within(rows[0]).getByText("3 times")).toBeInTheDocument();
    expect(within(rows[0]).getByText("fewer lately")).toBeInTheDocument();
    expect(within(rows[1]).getByText("Gender")).toBeInTheDocument();
    expect(within(rows[1]).getByText("1 time")).toBeInTheDocument();
    expect(within(rows[1]).getByText("gone lately")).toBeInTheDocument();
    expect(screen.getByRole("complementary", { name: "Your teacher" })).toHaveTextContent(
      "Verb tense keeps tripping you up.",
    );
    expect(
      screen.getByText("Comparing your older 2 entries with your recent 2 entries."),
    ).toBeInTheDocument();
  });

  it("shows counts with no trend while only one entry is analyzed", () => {
    render(
      <UsualSuspects
        categoryTrends={{
          olderEntryCount: 0,
          recentEntryCount: 1,
          categories: [{ category: "ARTICLE", count: 2, trend: null }],
        }}
      />,
    );

    expect(screen.getByText("2 times")).toBeInTheDocument();
    expect(screen.queryByText(/lately|steady/)).not.toBeInTheDocument();
    expect(screen.getByText("Trends show up once two entries are analyzed.")).toBeInTheDocument();
  });

  it("says so when no entry has a correction yet", () => {
    render(
      <UsualSuspects
        categoryTrends={{
          olderEntryCount: 0,
          recentEntryCount: 0,
          categories: [],
        }}
      />,
    );

    expect(
      screen.getByText("No corrections yet. Write an entry and the usual suspects show up here."),
    ).toBeInTheDocument();
  });
});
