import Button from "@mui/material/Button";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Buddy, useTalking } from "~/journal/Buddy";
import { sizes } from "~/palette";

export function JourneyIntro({ intro, onStart }: { intro: string; onStart: () => void }) {
  const talking = useTalking(intro);

  return (
    <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
      <Stack direction="row" spacing={2} sx={{ alignItems: "flex-end", width: "100%" }}>
        <Buddy size={sizes.buddy} expression={talking ? "talking" : "resting"} />
        <Paper sx={{ padding: 2, flex: 1 }}>
          <Typography>{intro}</Typography>
        </Paper>
      </Stack>
      <Button onClick={onStart}>Let's go</Button>
    </Stack>
  );
}
