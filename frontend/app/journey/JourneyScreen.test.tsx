import { render, screen } from "@testing-library/react";
import { vi } from "vitest";
import { JourneyScreen } from "~/journey/JourneyScreen";

vi.mock("maplibre-gl", () => ({
  Map: vi.fn(function FakeMap() {
    return { remove: vi.fn() };
  }),
}));

describe("JourneyScreen", () => {
  it("shows the map beside the writing prompt", () => {
    render(<JourneyScreen />);

    expect(screen.getByRole("region", { name: "Journey map" })).toBeInTheDocument();
    expect(
      screen.getByText("Write about today's stop. Three sentences is enough."),
    ).toBeInTheDocument();
    expect(screen.getByLabelText("Your entry")).toBeInTheDocument();
  });
});
