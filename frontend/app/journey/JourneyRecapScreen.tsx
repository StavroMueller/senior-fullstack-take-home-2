import { useQuery } from "@apollo/client";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect } from "react";
import { Link } from "react-router";
import { categoryLabels } from "~/journal/categoryLabels";
import { CorrectionChange } from "~/journal/CorrectionList";
import { correctionsLabel, entriesLabel } from "~/journal/countLabels";
import { JOURNEY_RECAP, type JourneyRecap, lastTown } from "~/journal/operations";
import { UsualSuspects } from "~/journal/UsualSuspects";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { JourneyStatus } from "~/journey/JourneyStatus";
import { palette } from "~/palette";

export function JourneyRecapScreen({ journeyId }: { journeyId: string }) {
  const { data } = useQuery<{ journey: JourneyRecap | null }>(JOURNEY_RECAP, {
    variables: { id: journeyId },
    fetchPolicy: "cache-and-network",
  });
  const journey = data?.journey;
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    if (!journey) return;
    showOnJourneyMap({ route: journey });
  }, [showOnJourneyMap, journey]);

  if (!journey) return null;

  const corrections = journey.entries.flatMap((entry) => entry.corrections);

  return (
    <Stack spacing={4}>
      <Link to="/" style={{ color: palette.ink }}>
        Back to your journeys
      </Link>
      <Stack spacing={1} sx={{ alignItems: "flex-start" }}>
        <JourneyStatus currentPointOfInterestIndex={journey.currentPointOfInterestIndex} />
        <Typography variant="h1">
          {journey.pointsOfInterest[0].name} to {lastTown(journey)}
        </Typography>
        <Typography>
          {journey.country}. {entriesLabel(journey.entries.length)},{" "}
          {correctionsLabel(corrections.length)}.
        </Typography>
      </Stack>
      <UsualSuspects categoryTrends={journey.categoryTrends} />
      {corrections.length > 0 && (
        <Stack spacing={2}>
          <Typography variant="h2">Every correction</Typography>
          {journey.categoryTrends.categories.map((categoryTrend) => (
            <Paper key={categoryTrend.category} sx={{ padding: 2 }}>
              <Typography variant="overline">{categoryLabels[categoryTrend.category]}</Typography>
              <Stack component="ul" spacing={1} sx={{ listStyle: "none", padding: 0, margin: 0 }}>
                {corrections
                  .filter((correction) => correction.category === categoryTrend.category)
                  .map((correction) => (
                    <li key={correction.id}>
                      <CorrectionChange correction={correction} />
                    </li>
                  ))}
              </Stack>
            </Paper>
          ))}
        </Stack>
      )}
      <Link to={`/journeys/${journey.id}`} style={{ color: palette.ink }}>
        Read the entries of this journey
      </Link>
    </Stack>
  );
}
