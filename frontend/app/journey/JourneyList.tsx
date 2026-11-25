import { useQuery } from "@apollo/client";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect } from "react";
import { Link } from "react-router";
import {
  isFinished,
  JOURNEYS,
  type JourneySummary,
  lastTown,
  routePositionName,
} from "~/journal/operations";
import { StartJourneyButtons } from "~/journal/StartJourneyButtons";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { palette } from "~/palette";

const startedDate = new Intl.DateTimeFormat("en-US", { month: "short", day: "numeric" });

function whereThePersonIs(journey: JourneySummary) {
  const currentPointOfInterestIndex = journey.currentPointOfInterestIndex;
  return isFinished(currentPointOfInterestIndex)
    ? `Finished in ${lastTown(journey)}`
    : routePositionName(journey, currentPointOfInterestIndex);
}

function entryCountLabel(journey: JourneySummary) {
  return journey.entries.length === 1 ? "1 entry" : `${journey.entries.length} entries`;
}

export function JourneyList() {
  const { data, loading } = useQuery<{ journeys: JourneySummary[] }>(JOURNEYS);
  const journeys = data?.journeys ?? [];
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    showOnJourneyMap({});
  }, [showOnJourneyMap]);

  return (
    <Stack spacing={4}>
      <Stack direction="row" sx={{ justifyContent: "space-between", alignItems: "baseline" }}>
        <Typography variant="h1">Wayword</Typography>
        <Link to="/usual-suspects" style={{ color: palette.ink }}>
          Usual suspects
        </Link>
      </Stack>
      <StartJourneyButtons />
      {!loading && journeys.length === 0 && (
        <Typography>No journeys yet. Start one to write your first entry.</Typography>
      )}
      {journeys.length > 0 && (
        <Stack spacing={2}>
          <Typography variant="h2">Your journeys</Typography>
          <Stack component="ul" spacing={2} sx={{ listStyle: "none", padding: 0, margin: 0 }}>
            {journeys.map((journey) => (
              <Paper component="li" key={journey.id} sx={{ padding: 2 }}>
                <Link to={`/journeys/${journey.id}`} style={{ color: palette.ink }}>
                  {journey.pointsOfInterest[0].name} to {lastTown(journey)}
                </Link>
                <Typography>
                  {journey.country}, started {startedDate.format(new Date(journey.insertedAt))},{" "}
                  {entryCountLabel(journey)}.
                </Typography>
                <Typography>{whereThePersonIs(journey)}</Typography>
              </Paper>
            ))}
          </Stack>
        </Stack>
      )}
    </Stack>
  );
}
