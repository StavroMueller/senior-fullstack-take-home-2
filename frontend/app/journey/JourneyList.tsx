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
import { entriesLabel } from "~/journal/countLabels";
import { StartJourneyButtons } from "~/journal/StartJourneyButtons";
import { currentRoutePositionView, useShowOnJourneyMap } from "~/journey/JourneyLayout";
import { JourneyStatus } from "~/journey/JourneyStatus";
import { palette } from "~/palette";

const startedDate = new Intl.DateTimeFormat("en-US", { month: "short", day: "numeric" });

function whereThePersonIs(journey: JourneySummary) {
  const currentPointOfInterestIndex = journey.currentPointOfInterestIndex;
  return isFinished(currentPointOfInterestIndex)
    ? `Finished in ${lastTown(journey)}`
    : routePositionName(journey, currentPointOfInterestIndex);
}

function journeyAddress(journey: JourneySummary) {
  return isFinished(journey.currentPointOfInterestIndex)
    ? `/journeys/${journey.id}/recap`
    : `/journeys/${journey.id}`;
}

export function JourneyList() {
  const { data, loading } = useQuery<{ journeys: JourneySummary[] }>(JOURNEYS);
  const journeys = data?.journeys ?? [];
  const showOnJourneyMap = useShowOnJourneyMap();

  const newestJourney = data?.journeys[0];

  useEffect(() => {
    showOnJourneyMap(newestJourney ? currentRoutePositionView(newestJourney) : {});
  }, [showOnJourneyMap, newestJourney]);

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
                <Stack
                  direction="row"
                  sx={{ justifyContent: "space-between", alignItems: "baseline", gap: 2 }}
                >
                  <Link to={journeyAddress(journey)} style={{ color: palette.ink }}>
                    {journey.pointsOfInterest[0].name} to {lastTown(journey)}
                  </Link>
                  <JourneyStatus
                    currentPointOfInterestIndex={journey.currentPointOfInterestIndex}
                  />
                </Stack>
                <Typography>
                  {journey.country}, started {startedDate.format(new Date(journey.insertedAt))},{" "}
                  {entriesLabel(journey.entries.length)}.
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
