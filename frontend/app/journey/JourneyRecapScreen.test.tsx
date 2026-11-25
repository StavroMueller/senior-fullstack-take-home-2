import { MockedProvider } from "@apollo/client/testing";
import { render, screen, within } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router";
import { JOURNEY_RECAP } from "~/journal/operations";
import { JourneyLayout } from "~/journey/JourneyLayout";
import { JourneyRecapScreen } from "~/journey/JourneyRecapScreen";

vi.mock("~/journey/JourneyMap", () => ({ JourneyMap: () => null }));

const towns = [
  { name: "Amiens", longitude: 2.3, latitude: 49.89 },
  { name: "Bayonne", longitude: -1.47, latitude: 43.49 },
].map((town) => ({ __typename: "PointOfInterest", ...town }));

function correction(id: string, original: string, fix: string, category: string) {
  return { __typename: "Correction", id, original, fix, category };
}

const recap = {
  __typename: "Journey",
  id: "1",
  country: "France",
  pointsOfInterest: towns,
  encounters: [],
  currentPointOfInterestIndex: null,
  entries: [
    {
      __typename: "Entry",
      id: "10",
      corrections: [
        correction("100", "le maison", "la maison", "GENDER"),
        correction("101", "je va", "je vais", "VERB_AGREEMENT"),
      ],
    },
    {
      __typename: "Entry",
      id: "11",
      corrections: [correction("102", "le cathédrale", "la cathédrale", "GENDER")],
    },
  ],
  categoryTrends: {
    __typename: "CategoryTrends",
    olderEntryCount: 1,
    recentEntryCount: 1,
    categories: [
      { __typename: "CategoryTrend", category: "GENDER", count: 2, trend: "STEADY" },
      {
        __typename: "CategoryTrend",
        category: "VERB_AGREEMENT",
        count: 1,
        trend: "GONE_LATELY",
      },
    ],
  },
};

describe("JourneyRecapScreen", () => {
  it("marks the journey finished and groups every correction under its mistake category", async () => {
    render(
      <MockedProvider
        mocks={[
          {
            request: { query: JOURNEY_RECAP, variables: { id: "1" } },
            result: { data: { journey: recap } },
          },
        ]}
      >
        <MemoryRouter initialEntries={["/journeys/1/recap"]}>
          <Routes>
            <Route element={<JourneyLayout />}>
              <Route path="journeys/1/recap" element={<JourneyRecapScreen journeyId="1" />} />
            </Route>
          </Routes>
        </MemoryRouter>
      </MockedProvider>,
    );

    expect(await screen.findByRole("heading", { name: "Amiens to Bayonne" })).toBeInTheDocument();
    expect(screen.getByText("Finished")).toBeInTheDocument();
    expect(screen.getByText("France. 2 entries, 3 corrections.")).toBeInTheDocument();

    const everyCorrection = screen.getByRole("heading", { name: "Every correction" }).parentElement;
    if (!everyCorrection) throw new Error("Every correction section is missing");
    const genderCard = within(everyCorrection).getByText("Gender").parentElement;
    if (!genderCard) throw new Error("Gender card is missing");
    expect(within(genderCard).getByText("le maison")).toBeInTheDocument();
    expect(within(genderCard).getByText("le cathédrale")).toBeInTheDocument();
    expect(within(genderCard).queryByText("je va")).not.toBeInTheDocument();
  });
});
