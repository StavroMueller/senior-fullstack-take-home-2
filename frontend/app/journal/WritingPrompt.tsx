import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import type { CurrentJourney } from "~/journal/operations";

export const pointOfInterestPrompt = "Write about today's stop. Three sentences is enough.";

export function WritingPrompt({
  journey,
  currentPointOfInterestIndex,
}: {
  journey: CurrentJourney;
  currentPointOfInterestIndex: number;
}) {
  if (journey.openEncounter) {
    const nextPointOfInterest = journey.pointsOfInterest[currentPointOfInterestIndex + 1];
    return (
      <Stack spacing={1}>
        <Typography variant="h2">On the road to {nextPointOfInterest.name}</Typography>
        <Typography>{journey.openEncounter.prompt}</Typography>
      </Stack>
    );
  }

  return (
    <Stack spacing={1}>
      <Typography variant="h2">
        {journey.pointsOfInterest[currentPointOfInterestIndex].name}
      </Typography>
      <Typography>{pointOfInterestPrompt}</Typography>
    </Stack>
  );
}
