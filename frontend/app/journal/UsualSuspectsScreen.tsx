import { useQuery } from "@apollo/client";
import Grid from "@mui/material/Grid";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Link } from "react-router";
import {
  CATEGORY_TRENDS,
  type CategoryTrends,
  CURRENT_JOURNEY,
  type CurrentJourney,
} from "~/journal/operations";
import { UsualSuspects } from "~/journal/UsualSuspects";
import { JourneyMap } from "~/journey/JourneyMap";
import { palette } from "~/palette";

export function UsualSuspectsScreen() {
  const { data: journeyData } = useQuery<{ currentJourney: CurrentJourney | null }>(
    CURRENT_JOURNEY,
  );
  const { data: trendsData } = useQuery<{ categoryTrends: CategoryTrends }>(CATEGORY_TRENDS, {
    fetchPolicy: "cache-and-network",
  });
  const journey = journeyData?.currentJourney;

  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid
        size={{ xs: 12, md: 6 }}
        sx={{ height: { xs: "50vh", md: "100vh" }, position: { md: "sticky" }, top: 0 }}
      >
        {journey ? <JourneyMap route={journey} /> : <JourneyMap />}
      </Grid>
      <Grid size={{ xs: 12, md: 6 }} sx={{ padding: 4 }}>
        <Stack spacing={4}>
          <Link to="/" style={{ color: palette.ink }}>
            Back to your entries
          </Link>
          <Typography variant="h1">Usual suspects</Typography>
          {trendsData && <UsualSuspects categoryTrends={trendsData.categoryTrends} />}
        </Stack>
      </Grid>
    </Grid>
  );
}
