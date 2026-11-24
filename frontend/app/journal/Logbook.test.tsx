import { MockedProvider, type MockedResponse } from "@apollo/client/testing";
import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { Logbook } from "~/journal/Logbook";
import { CURRENT_JOURNEY, ENTRIES, LANGUAGES } from "~/journal/operations";
import { testJourney } from "~/journey/testJourney";

function renderLogbook(currentJourney: ReturnType<typeof testJourney> | null) {
  const mocks: MockedResponse[] = [
    { request: { query: CURRENT_JOURNEY }, result: { data: { currentJourney } } },
    { request: { query: ENTRIES }, result: { data: { entries: [] } } },
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
    expect(
      await screen.findByRole("button", { name: "Start a journey in France" }),
    ).toBeInTheDocument();
  });

  it("enables sending only once the entry has text", async () => {
    renderLogbook(testJourney());

    const sendButton = await screen.findByRole("button", { name: "Send entry" });
    expect(sendButton).toBeDisabled();

    fireEvent.change(screen.getByLabelText("Your entry"), { target: { value: "Je va au parc." } });
    expect(sendButton).toBeEnabled();
  });

  it("names the point of interest the person is at above the prompt", async () => {
    renderLogbook(testJourney({ currentPointOfInterestIndex: 2 }));

    expect(await screen.findByRole("heading", { name: "Bourges" })).toBeInTheDocument();
    expect(
      screen.getByText("Voilà, we made it to Nancy! Tell me in French what you see first."),
    ).toBeInTheDocument();
  });

  it("gives the encounter's prompt while an encounter waits for an entry", async () => {
    renderLogbook(
      testJourney({
        currentPointOfInterestIndex: 0,
        openEncounter: { __typename: "Encounter", id: "7" },
        currentScene: "Mon dieu, a dragon is asleep on the bridge!",
      }),
    );

    expect(
      await screen.findByRole("heading", { name: "On the road to Troyes" }),
    ).toBeInTheDocument();
    expect(screen.getByText("Mon dieu, a dragon is asleep on the bridge!")).toBeInTheDocument();
  });

  it("opens a new journey on the teacher's intro alone, and the first town after Let's go", async () => {
    renderLogbook(
      testJourney({ intro: "Bon! We walk from Nancy to La Rochelle, with 3 towns in between." }),
    );

    expect(
      await screen.findByText("Bon! We walk from Nancy to La Rochelle, with 3 towns in between."),
    ).toBeInTheDocument();
    expect(screen.queryByLabelText("Your entry")).not.toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "Let's go" }));

    expect(screen.getByLabelText("Your entry")).toBeInTheDocument();
    expect(
      screen.queryByText("Bon! We walk from Nancy to La Rochelle, with 3 towns in between."),
    ).not.toBeInTheDocument();
  });

  it("drops the intro once the journey has left its first town", async () => {
    renderLogbook(
      testJourney({
        currentPointOfInterestIndex: 2,
        intro: "Bon! We walk from Nancy to La Rochelle, with 3 towns in between.",
      }),
    );

    expect(await screen.findByRole("heading", { name: "Bourges" })).toBeInTheDocument();
    expect(
      screen.queryByText("Bon! We walk from Nancy to La Rochelle, with 3 towns in between."),
    ).not.toBeInTheDocument();
  });

  it("offers to keep going only once the current route position has an entry", async () => {
    renderLogbook(testJourney({ canTravelOn: true }));

    expect(await screen.findByRole("button", { name: "Keep going" })).toBeEnabled();
  });

  it("hides keep going before the current route position has an entry", async () => {
    renderLogbook(testJourney());

    expect(await screen.findByRole("button", { name: "Send entry" })).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Keep going" })).not.toBeInTheDocument();
  });

  it("ends the journey at the last point of interest and offers the next one", async () => {
    renderLogbook(testJourney({ currentPointOfInterestIndex: null }));

    expect(
      await screen.findByText(
        "You reached La Rochelle, the end of this journey. Start a journey to keep writing.",
      ),
    ).toBeInTheDocument();
    expect(
      await screen.findByRole("button", { name: "Start a journey in France" }),
    ).toBeInTheDocument();
    expect(screen.queryByLabelText("Your entry")).not.toBeInTheDocument();
  });
});
