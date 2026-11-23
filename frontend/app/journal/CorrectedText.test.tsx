import { render, screen } from "@testing-library/react";
import { CorrectedText, splitByCorrections } from "~/journal/CorrectedText";
import type { Correction } from "~/journal/operations";

const correction: Correction = {
  id: "1",
  spanStart: 6,
  spanEnd: 15,
  original: "j'ai allé",
  fix: "je suis allé",
  explanation: "Aller takes être in the passé composé.",
  category: "VERB_TENSE",
};

describe("splitByCorrections", () => {
  it("cuts the body at code point spans, so accented letters count once", () => {
    expect(splitByCorrections("Hier, j'ai allé à le marché.", [correction])).toEqual([
      { text: "Hier, ", isCorrected: false },
      { text: "j'ai allé", isCorrected: true },
      { text: " à le marché.", isCorrected: false },
    ]);
  });

  it("counts an emoji as one code point even though it takes two UTF-16 units", () => {
    expect(splitByCorrections("🙂 le maison", [{ spanStart: 2, spanEnd: 11 }])).toEqual([
      { text: "🙂 ", isCorrected: false },
      { text: "le maison", isCorrected: true },
    ]);
  });
});

describe("CorrectedText", () => {
  it("marks the corrected characters inside the entry", () => {
    render(<CorrectedText body="Hier, j'ai allé à le marché." corrections={[correction]} />);

    expect(screen.getByText("j'ai allé").tagName).toBe("MARK");
  });
});
