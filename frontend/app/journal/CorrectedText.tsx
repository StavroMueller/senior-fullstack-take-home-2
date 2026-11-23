import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import type { Correction } from "~/journal/operations";
import { palette } from "~/palette";

type Segment = { text: string; isCorrected: boolean };

export function splitByCorrections(
  body: string,
  corrections: Pick<Correction, "spanStart" | "spanEnd">[],
): Segment[] {
  const codePoints = Array.from(body);
  const segments: Segment[] = [];
  let cursor = 0;

  for (const correction of corrections) {
    segments.push({
      text: codePoints.slice(cursor, correction.spanStart).join(""),
      isCorrected: false,
    });
    segments.push({
      text: codePoints.slice(correction.spanStart, correction.spanEnd).join(""),
      isCorrected: true,
    });
    cursor = correction.spanEnd;
  }

  segments.push({ text: codePoints.slice(cursor).join(""), isCorrected: false });
  return segments.filter((segment) => segment.text !== "");
}

export function CorrectedText({ body, corrections }: { body: string; corrections: Correction[] }) {
  return (
    <Typography sx={{ whiteSpace: "pre-wrap" }}>
      {splitByCorrections(body, corrections).map((segment, index) =>
        segment.isCorrected ? (
          <Box
            component="mark"
            key={index}
            sx={{
              backgroundColor: "transparent",
              color: palette.error,
              fontWeight: 700,
              textDecoration: "underline",
              textDecorationThickness: 2,
            }}
          >
            {segment.text}
          </Box>
        ) : (
          <span key={index}>{segment.text}</span>
        ),
      )}
    </Typography>
  );
}
