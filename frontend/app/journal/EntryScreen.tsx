import { useQuery } from "@apollo/client";
import Grid from "@mui/material/Grid";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Link } from "react-router";
import { EntryView } from "~/journal/EntryView";
import { ENTRY_ON_ROUTE, type EntryOnRoute } from "~/journal/operations";
import { JourneyMap } from "~/journey/JourneyMap";
import { palette } from "~/palette";

export function EntryScreen({ entryId }: { entryId: string }) {
  const { data } = useQuery<{ entry: EntryOnRoute | null }>(ENTRY_ON_ROUTE, {
    variables: { id: entryId },
  });
  const entry = data?.entry;

  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid
        size={{ xs: 12, md: 6 }}
        sx={{ height: { xs: "50vh", md: "100vh" }, position: { md: "sticky" }, top: 0 }}
      >
        {entry ? (
          <JourneyMap
            route={entry.journey}
            highlightedPointOfInterestIndex={entry.pointOfInterestIndex}
            highlightedEncounterId={entry.encounter?.id}
          />
        ) : (
          <JourneyMap />
        )}
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
