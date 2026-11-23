import { render, screen } from "@testing-library/react";
import { TeacherLine } from "~/journal/TeacherLine";

describe("TeacherLine", () => {
  it("shows the teacher's line in the teacher's bubble", () => {
    render(<TeacherLine line="Presque! One correction, in gender." />);

    expect(screen.getByRole("complementary", { name: "Your teacher" })).toHaveTextContent(
      "Presque! One correction, in gender.",
    );
  });
});
