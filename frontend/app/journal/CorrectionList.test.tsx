import { render, screen } from "@testing-library/react";
import { CorrectionList } from "~/journal/CorrectionList";

describe("CorrectionList", () => {
  it("shows the category label, the original, the fix and the explanation", () => {
    render(
      <CorrectionList
        corrections={[
          {
            id: "1",
            spanStart: 0,
            spanEnd: 9,
            original: "le maison",
            fix: "la maison",
            explanation: "Maison is feminine, so it takes la.",
            category: "GENDER",
          },
        ]}
      />,
    );

    expect(screen.getByText("Gender")).toBeInTheDocument();
    expect(screen.getByText("le maison")).toBeInTheDocument();
    expect(screen.getByText("la maison")).toBeInTheDocument();
    expect(screen.getByText("Maison is feminine, so it takes la.")).toBeInTheDocument();
  });

  it("says so when the entry has no corrections", () => {
    render(<CorrectionList corrections={[]} />);

    expect(screen.getByText("No corrections for this entry.")).toBeInTheDocument();
  });
});
