import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect, useState } from "react";
import { Buddy } from "~/journal/Buddy";
import type { CurrentJourney } from "~/journal/operations";
import { sizes } from "~/palette";

function talkMilliseconds(scene: string) {
  return Math.min(
    scene.length * sizes.buddyTalkMillisecondsPerCharacter,
    sizes.buddyLongestTalkMilliseconds,
  );
}

export function WritingPrompt({
  journey,
  currentPointOfInterestIndex,
  thinking,
}: {
  journey: CurrentJourney;
  currentPointOfInterestIndex: number;
  thinking: boolean;
}) {
  const [talking, setTalking] = useState(false);
  const scene = journey.currentScene;
  const atFirstTown = currentPointOfInterestIndex === 0 && !journey.openEncounter;
  const intro = atFirstTown ? journey.intro : null;
  const spokenText = [intro, scene].filter(Boolean).join(" ");
  const heading = journey.openEncounter
    ? `On the road to ${journey.pointsOfInterest[currentPointOfInterestIndex + 1].name}`
    : journey.pointsOfInterest[currentPointOfInterestIndex].name;

  useEffect(() => {
    if (!spokenText) return;
    setTalking(true);
    const timer = setTimeout(() => setTalking(false), talkMilliseconds(spokenText));
    return () => clearTimeout(timer);
  }, [spokenText]);

  return (
    <Stack spacing={2} sx={{ width: "100%" }}>
      <Typography variant="h2">{heading}</Typography>
      <Stack direction="row" spacing={2} sx={{ alignItems: "flex-end" }}>
        <Buddy
          size={sizes.buddy}
          expression={thinking ? "thinking" : talking ? "talking" : "resting"}
        />
        <Paper sx={{ padding: 2, flex: 1 }}>
          <Stack spacing={1}>
            {intro && <Typography>{intro}</Typography>}
            <Typography>{scene}</Typography>
          </Stack>
        </Paper>
      </Stack>
    </Stack>
  );
}
