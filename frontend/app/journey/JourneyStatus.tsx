import Box from "@mui/material/Box";
import { isFinished } from "~/journal/operations";
import { fonts, palette, sizes } from "~/palette";

export function JourneyStatus({
  currentPointOfInterestIndex,
}: {
  currentPointOfInterestIndex: number | null;
}) {
  const finished = isFinished(currentPointOfInterestIndex);

  return (
    <Box
      component="span"
      sx={{
        display: "inline-block",
        paddingX: 1.5,
        paddingY: 0.25,
        borderRadius: sizes.journeyStatusRadius,
        border: `${sizes.journeyStatusBorder}px solid ${finished ? palette.ink : palette.surfaceEdge}`,
        backgroundColor: finished ? palette.win : palette.surface,
        color: palette.ink,
        fontFamily: fonts.display,
        fontWeight: 600,
      }}
    >
      {finished ? "Finished" : "In progress"}
    </Box>
  );
}
