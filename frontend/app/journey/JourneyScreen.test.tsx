import { MockedProvider } from "@apollo/client/testing";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { vi } from "vitest";
import { CURRENT_JOURNEY, ENTRIES } from "~/journal/operations";
import { JourneyScreen } from "~/journey/JourneyScreen";
import { testJourney } from "~/journey/testJourney";

const { placedMarkers } = vi.hoisted(() => ({ placedMarkers: [] as HTMLElement[] }));

vi.mock("maplibre-gl", () => ({
  Map: vi.fn(function FakeMap() {
    return {
      remove: vi.fn(),
      once: (_event: string, listener: () => void) => listener(),
      getSource: () => undefined,
      addSource: vi.fn(),
      addLayer: vi.fn(),
      fitBounds: vi.fn(),
    };
  }),
  Marker: vi.fn(function FakeMarker({ element }: { element: HTMLElement }) {
    const marker = {
      setLngLat: () => marker,
      addTo: () => {
        placedMarkers.push(element);
        return marker;
      },
      remove: vi.fn(),
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
    request: { query: CURRENT_JOURNEY },
    result: {
      data: {
        currentJourney: testJourney({
          encounters: [encounter],
          currentPointOfInterestIndex: 1,
        }),
      },
    },
  },
  { request: { query: ENTRIES }, result: { data: { entries: [] } } },
];

describe("JourneyScreen", () => {
  it("shows the map with a marker for each point of interest and encounter beside the prompt", async () => {
    render(
      <MockedProvider mocks={mocks}>
        <MemoryRouter>
          <JourneyScreen />
        </MemoryRouter>
      </MockedProvider>,
    );

    expect(screen.getByRole("region", { name: "Journey map" })).toBeInTheDocument();
    expect(
      await screen.findByText("Voilà, we made it to Nancy! Tell me in French what you see first."),
    ).toBeInTheDocument();
    expect(screen.getByLabelText("Your entry")).toBeInTheDocument();

    const labels = placedMarkers.map((marker) => marker.getAttribute("aria-label"));
    expect(labels).toEqual([
      "Nancy",
      "Troyes",
      "Bourges",
      "Tours",
      "La Rochelle",
      "Encounter after Nancy",
      "You are here: Troyes",
    ]);
  });
});
