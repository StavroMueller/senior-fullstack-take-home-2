import { MockedProvider, type MockedResponse } from "@apollo/client/testing";
import { render, screen } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router";
import { JOURNEYS, LANGUAGES } from "~/journal/operations";
import { JourneyLayout } from "~/journey/JourneyLayout";
import { JourneyList } from "~/journey/JourneyList";

vi.mock("~/journey/JourneyMap", () => ({ JourneyMap: () => null }));

const towns = ["Amiens", "Poitiers", "Bayonne"].map((name) => ({
  __typename: "PointOfInterest",
  name,
}));

function summary(changes: Record<string, unknown>) {
  return {
    __typename: "Journey",
    id: "1",
    country: "France",
    insertedAt: "2026-11-01T09:00:00Z",
    pointsOfInterest: towns,
    currentPointOfInterestIndex: 1,
    openEncounter: null,
    entries: [{ __typename: "Entry", id: "10" }],
    ...changes,
  };
}

function renderJourneyList(journeys: ReturnType<typeof summary>[]) {
  const mocks: MockedResponse[] = [
    { request: { query: JOURNEYS }, result: { data: { journeys } } },
    {
      request: { query: LANGUAGES },
      result: {
        data: {
          languages: [{ __typename: "Language", code: "fr", level: "A1", country: "France" }],
        },
      },
    },
  ];

  render(
    <MockedProvider mocks={mocks}>
      <MemoryRouter>
        <Routes>
          <Route element={<JourneyLayout />}>
            <Route index element={<JourneyList />} />
          </Route>
        </Routes>
      </MemoryRouter>
    </MockedProvider>,
  );
}

describe("JourneyList", () => {
  it("offers to start a journey in each country before the first one", async () => {
    renderJourneyList([]);

    expect(
      await screen.findByText("No journeys yet. Start one to write your first entry."),
    ).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Start a journey in France" })).toBeInTheDocument();
  });

  it("links each journey by its route and says where the person is", async () => {
    renderJourneyList([
      summary({ id: "2", openEncounter: { __typename: "Encounter", id: "7" } }),
      summary({ id: "1", currentPointOfInterestIndex: null, entries: [] }),
    ]);

    const links = await screen.findAllByRole("link", { name: "Amiens to Bayonne" });
    expect(links.map((link) => link.getAttribute("href"))).toEqual(["/journeys/2", "/journeys/1"]);
    expect(screen.getByText("France, started Nov 1, 1 entry.")).toBeInTheDocument();
    expect(screen.getByText("On the road to Bayonne")).toBeInTheDocument();
    expect(screen.getByText("France, started Nov 1, 0 entries.")).toBeInTheDocument();
    expect(screen.getByText("Finished in Bayonne")).toBeInTheDocument();
  });
});
