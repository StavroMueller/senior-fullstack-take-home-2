import { useQuery } from "@apollo/client";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect } from "react";
import { Link } from "react-router";
import { EntryView } from "~/journal/EntryView";
import { ENTRY_ON_ROUTE, type EntryOnRoute } from "~/journal/operations";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { palette } from "~/palette";

export function EntryScreen({ entryId }: { entryId: string }) {
  const { data } = useQuery<{ entry: EntryOnRoute | null }>(ENTRY_ON_ROUTE, {
    variables: { id: entryId },
  });
  const entry = data?.entry;
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    if (!entry) return;
    showOnJourneyMap({
      route: entry.journey,
      highlightedPointOfInterestIndex: entry.pointOfInterestIndex,
      highlightedEncounterId: entry.encounter?.id,
      travelerMarkerLabel: "Written here",
    });
  }, [showOnJourneyMap, entry]);

  return (
    <Stack spacing={4}>
      <Link to="/" style={{ color: palette.ink }}>
        Back to your entries
      </Link>
      <Typography variant="h1">Your entry</Typography>
      <EntryView entryId={entryId} />
    </Stack>
  );
}
