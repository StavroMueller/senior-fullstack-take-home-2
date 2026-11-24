import { useQuery } from "@apollo/client";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect } from "react";
import { Link } from "react-router";
import {
  CATEGORY_TRENDS,
  type CategoryTrends,
  CURRENT_JOURNEY,
  type CurrentJourney,
} from "~/journal/operations";
import { UsualSuspects } from "~/journal/UsualSuspects";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { palette } from "~/palette";

export function UsualSuspectsScreen() {
  const { data: journeyData } = useQuery<{ currentJourney: CurrentJourney | null }>(
    CURRENT_JOURNEY,
  );
  const { data: trendsData } = useQuery<{ categoryTrends: CategoryTrends }>(CATEGORY_TRENDS, {
    fetchPolicy: "cache-and-network",
  });
  const journey = journeyData?.currentJourney;
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    if (!journey) return;
    showOnJourneyMap({ route: journey });
  }, [showOnJourneyMap, journey]);

  return (
    <Stack spacing={4}>
      <Link to="/" style={{ color: palette.ink }}>
        Back to your entries
      </Link>
      <Typography variant="h1">Usual suspects</Typography>
      {trendsData && <UsualSuspects categoryTrends={trendsData.categoryTrends} />}
    </Stack>
  );
}
