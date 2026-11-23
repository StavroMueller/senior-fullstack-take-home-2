import { render, screen } from "@testing-library/react";
import { TeacherReaction } from "~/journal/TeacherReaction";

describe("TeacherReaction", () => {
  it("shows the teacher's reaction in the teacher's bubble", () => {
    render(<TeacherReaction reaction="Presque! One correction, in gender." />);

    expect(screen.getByRole("complementary", { name: "Your teacher" })).toHaveTextContent(
      "Presque! One correction, in gender.",
    );
  });
});
