import Grid from "@mui/material/Grid";
import { JourneyMap } from "~/journey/JourneyMap";
import { Logbook } from "~/journal/Logbook";

export function JourneyScreen() {
  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid size={{ xs: 12, md: 6 }} sx={{ minHeight: { xs: "50vh", md: "100vh" } }}>
        <JourneyMap />
      </Grid>
      <Grid size={{ xs: 12, md: 6 }} sx={{ padding: 4 }}>
        <Logbook />
      </Grid>
    </Grid>
  );
}
