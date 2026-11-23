import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import type { CurrentJourney } from "~/journal/operations";

export const pointOfInterestPrompt = "Write about today's stop. Three sentences is enough.";

export function WritingPrompt({
  journey,
  nextPointOfInterestIndex,
}: {
  journey: CurrentJourney;
  nextPointOfInterestIndex: number;
}) {
  const nextPointOfInterest = journey.pointsOfInterest[nextPointOfInterestIndex];

  if (journey.openEncounter) {
    return (
      <Stack spacing={1}>
        <Typography variant="h2">On the road to {nextPointOfInterest.name}</Typography>
        <Typography>{journey.openEncounter.prompt}</Typography>
      </Stack>
    );
  }

  return (
    <Stack spacing={1}>
      <Typography variant="h2">{nextPointOfInterest.name}</Typography>
      <Typography>{pointOfInterestPrompt}</Typography>
    </Stack>
  );
}
