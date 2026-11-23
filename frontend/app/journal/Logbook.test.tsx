import { MockedProvider, type MockedResponse } from "@apollo/client/testing";
import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { Logbook } from "~/journal/Logbook";
import { CURRENT_JOURNEY, ENTRIES } from "~/journal/operations";
import { testJourney } from "~/journey/testJourney";

function renderLogbook(currentJourney: ReturnType<typeof testJourney> | null) {
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
    renderLogbook(testJourney());

    const sendButton = await screen.findByRole("button", { name: "Send entry" });
    expect(sendButton).toBeDisabled();

    fireEvent.change(screen.getByLabelText("Your entry"), { target: { value: "Je va au parc." } });
    expect(sendButton).toBeEnabled();
  });

  it("names the next point of interest above the prompt", async () => {
    renderLogbook(testJourney({ nextPointOfInterestIndex: 2 }));

    expect(await screen.findByRole("heading", { name: "Bourges" })).toBeInTheDocument();
    expect(
      screen.getByText("Write about today's stop. Three sentences is enough."),
    ).toBeInTheDocument();
  });

  it("gives the encounter's prompt while an encounter waits for an entry", async () => {
    renderLogbook(
      testJourney({
        nextPointOfInterestIndex: 1,
        openEncounter: {
          __typename: "Encounter",
          id: "7",
          prompt: "Mon dieu, a dragon is asleep on the bridge!",
        },
      }),
    );

    expect(
      await screen.findByRole("heading", { name: "On the road to Troyes" }),
    ).toBeInTheDocument();
    expect(screen.getByText("Mon dieu, a dragon is asleep on the bridge!")).toBeInTheDocument();
  });

  it("ends the journey at the last point of interest and offers the next one", async () => {
    renderLogbook(testJourney({ nextPointOfInterestIndex: null }));

    expect(
      await screen.findByText(
        "You reached La Rochelle, the end of this journey. Start a journey to keep writing.",
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Start a journey" })).toBeInTheDocument();
    expect(screen.queryByLabelText("Your entry")).not.toBeInTheDocument();
  });
});
