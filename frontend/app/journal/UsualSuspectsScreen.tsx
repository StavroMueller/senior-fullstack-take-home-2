import { useQuery } from "@apollo/client";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect } from "react";
import { Link } from "react-router";
import { CATEGORY_TRENDS, type CategoryTrends } from "~/journal/operations";
import { UsualSuspects } from "~/journal/UsualSuspects";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { palette } from "~/palette";

export function UsualSuspectsScreen() {
  const { data: trendsData } = useQuery<{ categoryTrends: CategoryTrends }>(CATEGORY_TRENDS, {
    fetchPolicy: "cache-and-network",
  });
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    showOnJourneyMap({});
  }, [showOnJourneyMap]);

  return (
    <Stack spacing={4}>
      <Link to="/" style={{ color: palette.ink }}>
        Back to your journeys
      </Link>
      <Typography variant="h1">Usual suspects</Typography>
      {trendsData && <UsualSuspects categoryTrends={trendsData.categoryTrends} />}
    </Stack>
  );
}
