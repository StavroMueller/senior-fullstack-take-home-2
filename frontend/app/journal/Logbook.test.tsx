import { MockedProvider, type MockedResponse } from "@apollo/client/testing";
import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { Logbook } from "~/journal/Logbook";
import { CURRENT_JOURNEY, ENTRIES } from "~/journal/operations";

function renderLogbook(currentJourney: { id: string } | null) {
  const mocks: MockedResponse[] = [
    { request: { query: CURRENT_JOURNEY }, result: { data: { currentJourney } } },
    { request: { query: ENTRIES }, result: { data: { entries: [] } } },
  ];

  render(
    <MockedProvider mocks={mocks}>
      <MemoryRouter>
        <Logbook />
      </MemoryRouter>
    </MockedProvider>,
  );
}

describe("Logbook", () => {
  it("offers to start a journey before the first one", async () => {
    renderLogbook(null);

    expect(
      await screen.findByText("No entries yet. Start a journey to write your first one."),
    ).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Start a journey" })).toBeInTheDocument();
  });

  it("enables sending only once the entry has text", async () => {
    renderLogbook({ id: "1" });

    const sendButton = await screen.findByRole("button", { name: "Send entry" });
    expect(sendButton).toBeDisabled();

    fireEvent.change(screen.getByLabelText("Your entry"), { target: { value: "Je va au parc." } });
    expect(sendButton).toBeEnabled();
  });
});
