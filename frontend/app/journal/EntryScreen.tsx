import Grid from "@mui/material/Grid";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Link } from "react-router";
import { EntryView } from "~/journal/EntryView";
import { JourneyMap } from "~/journey/JourneyMap";
import { palette } from "~/palette";

export function EntryScreen({ entryId }: { entryId: string }) {
  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid size={{ xs: 12, md: 6 }} sx={{ minHeight: { xs: "50vh", md: "100vh" } }}>
        <JourneyMap />
      </Grid>
      <Grid size={{ xs: 12, md: 6 }} sx={{ padding: 4 }}>
        <Stack spacing={4}>
          <Link to="/" style={{ color: palette.ink }}>
            Back to your entries
          </Link>
          <Typography variant="h1">Your entry</Typography>
          <EntryView entryId={entryId} />
        </Stack>
      </Grid>
    </Grid>
  );
}
