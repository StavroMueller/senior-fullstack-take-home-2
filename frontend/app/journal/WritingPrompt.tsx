import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Buddy, useTalking } from "~/journal/Buddy";
import type { CurrentJourney } from "~/journal/operations";
import { sizes } from "~/palette";

export function WritingPrompt({
  journey,
  currentPointOfInterestIndex,
  thinking,
}: {
  journey: CurrentJourney;
  currentPointOfInterestIndex: number;
  thinking: boolean;
}) {
  const talking = useTalking(journey.currentScene);
  const heading = journey.openEncounter
    ? `On the road to ${journey.pointsOfInterest[currentPointOfInterestIndex + 1].name}`
    : journey.pointsOfInterest[currentPointOfInterestIndex].name;

  return (
    <Stack spacing={2} sx={{ width: "100%" }}>
      <Typography variant="h2">{heading}</Typography>
      <Stack direction="row" spacing={2} sx={{ alignItems: "flex-end" }}>
        <Buddy
          size={sizes.buddy}
          expression={thinking ? "thinking" : talking ? "talking" : "resting"}
        />
        <Paper sx={{ padding: 2, flex: 1 }}>
          <Typography>{journey.currentScene}</Typography>
        </Paper>
      </Stack>
    </Stack>
  );
}
