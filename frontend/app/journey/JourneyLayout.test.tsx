import { MockedProvider } from "@apollo/client/testing";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { Map as MapLibreMap } from "maplibre-gl";
import { MemoryRouter, Route, Routes } from "react-router";
import { vi } from "vitest";
import { UsualSuspectsScreen } from "~/journal/UsualSuspectsScreen";
import { CATEGORY_TRENDS, JOURNEY, LANGUAGES } from "~/journal/operations";
import { JourneyLayout } from "~/journey/JourneyLayout";
import { JourneyScreen } from "~/journey/JourneyScreen";
import { testJourney } from "~/journey/testJourney";

const { placedMarkers } = vi.hoisted(() => ({
  placedMarkers: [] as { element: HTMLElement; removed: boolean }[],
}));

vi.mock("maplibre-gl", () => ({
  Map: vi.fn(function FakeMap() {
    return {
      remove: vi.fn(),
      once: (_event: string, listener: () => void) => listener(),
      getSource: () => undefined,
      addSource: vi.fn(),
      addLayer: vi.fn(),
      fitBounds: vi.fn(),
      jumpTo: vi.fn(),
      easeTo: vi.fn(),
    };
  }),
  Marker: vi.fn(function FakeMarker({ element }: { element: HTMLElement }) {
    const placedMarker = { element, removed: false };
    const marker = {
      setLngLat: () => marker,
      addTo: () => {
        placedMarkers.push(placedMarker);
        return marker;
      },
      remove: () => {
        placedMarker.removed = true;
      },
    };
    return marker;
  }),
  LngLatBounds: vi.fn(function FakeBounds() {
    return { extend: vi.fn() };
  }),
}));

const encounter = { __typename: "Encounter", id: "7", afterPointOfInterestIndex: 0 };

const mocks = [
  {
    request: { query: JOURNEY, variables: { id: "1" } },
    result: {
      data: {
        journey: testJourney({
          encounters: [encounter],
          currentPointOfInterestIndex: 1,
        }),
      },
    },
  },
  { request: { query: LANGUAGES }, result: { data: { languages: [] } } },
  {
    request: { query: CATEGORY_TRENDS },
    result: {
      data: {
        categoryTrends: {
          __typename: "CategoryTrends",
          olderEntryCount: 0,
          recentEntryCount: 0,
          categories: [],
        },
      },
    },
  },
];

function renderJourney() {
  render(
    <MockedProvider mocks={mocks}>
      <MemoryRouter initialEntries={["/journeys/1"]}>
        <Routes>
          <Route element={<JourneyLayout />}>
            <Route path="journeys/1" element={<JourneyScreen journeyId="1" />} />
            <Route path="usual-suspects" element={<UsualSuspectsScreen />} />
          </Route>
        </Routes>
      </MemoryRouter>
    </MockedProvider>,
  );
}

function shownMarkerLabels() {
  return placedMarkers
    .filter((placedMarker) => !placedMarker.removed)
    .map((placedMarker) => placedMarker.element.getAttribute("aria-label"));
}

describe("JourneyLayout", () => {
  beforeEach(() => {
    placedMarkers.length = 0;
    vi.mocked(MapLibreMap).mockClear();
  });

  it("shows the map with a marker for each point of interest and encounter beside the prompt", async () => {
    renderJourney();

    expect(screen.getByRole("region", { name: "Journey map" })).toBeInTheDocument();
    expect(
      await screen.findByText("Voilà, we made it to Nancy! Tell me in French what you see first."),
    ).toBeInTheDocument();
    expect(screen.getByLabelText("Your entry")).toBeInTheDocument();
    await waitFor(() => expect(shownMarkerLabels()).toContain("Nancy"));
    expect(shownMarkerLabels()).toEqual([
      "Nancy",
      "Troyes",
      "Bourges",
      "Tours",
      "La Rochelle",
      "Encounter after Nancy",
      "You are here: Troyes",
    ]);
  });

  it("keeps the same map when the usual suspects link opens its screen", async () => {
    renderJourney();
    const journeyMap = screen.getByRole("region", { name: "Journey map" });
    await screen.findByLabelText("Your entry");

    fireEvent.click(screen.getByRole("link", { name: "Usual suspects" }));

    expect(await screen.findByRole("heading", { name: "Usual suspects" })).toBeInTheDocument();
    expect(screen.getByRole("region", { name: "Journey map" })).toBe(journeyMap);
    expect(MapLibreMap).toHaveBeenCalledTimes(1);
    expect(shownMarkerLabels()).not.toContain("You are here: Troyes");
  });
});
