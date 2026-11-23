import { MockedProvider } from "@apollo/client/testing";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { vi } from "vitest";
import { CURRENT_JOURNEY, ENTRIES } from "~/journal/operations";
import { JourneyScreen } from "~/journey/JourneyScreen";

vi.mock("maplibre-gl", () => ({
  Map: vi.fn(function FakeMap() {
    return { remove: vi.fn() };
  }),
}));

const mocks = [
  { request: { query: CURRENT_JOURNEY }, result: { data: { currentJourney: { id: "1" } } } },
  { request: { query: ENTRIES }, result: { data: { entries: [] } } },
];

describe("JourneyScreen", () => {
  it("shows the map beside the writing prompt", async () => {
    render(
      <MockedProvider mocks={mocks}>
        <MemoryRouter>
          <JourneyScreen />
        </MemoryRouter>
      </MockedProvider>,
    );

    expect(screen.getByRole("region", { name: "Journey map" })).toBeInTheDocument();
    expect(
      await screen.findByText("Write about today's stop. Three sentences is enough."),
    ).toBeInTheDocument();
    expect(screen.getByLabelText("Your entry")).toBeInTheDocument();
  });
});
