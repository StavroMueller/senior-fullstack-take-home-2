import { useQuery } from "@apollo/client";
import Grid from "@mui/material/Grid";
import { Logbook } from "~/journal/Logbook";
import { CURRENT_JOURNEY, type CurrentJourney } from "~/journal/operations";
import { JourneyMap } from "~/journey/JourneyMap";

export function JourneyScreen() {
  const { data } = useQuery<{ currentJourney: CurrentJourney | null }>(CURRENT_JOURNEY);
  const journey = data?.currentJourney;

  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid
        size={{ xs: 12, md: 6 }}
        sx={{ height: { xs: "50vh", md: "100vh" }, position: { md: "sticky" }, top: 0 }}
      >
        {journey ? (
          <JourneyMap
            route={journey}
            highlightedPointOfInterestIndex={
              journey.openEncounter ? null : journey.nextPointOfInterestIndex
            }
            highlightedEncounterId={journey.openEncounter?.id}
          />
        ) : (
          <JourneyMap />
        )}
      </Grid>
      <Grid size={{ xs: 12, md: 6 }} sx={{ padding: 4 }}>
        <Logbook />
      </Grid>
    </Grid>
  );
}
