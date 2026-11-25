import { useQuery } from "@apollo/client";
import { useEffect } from "react";
import { Logbook } from "~/journal/Logbook";
import { JOURNEY, type Journey } from "~/journal/operations";
import { currentRoutePositionView, useShowOnJourneyMap } from "~/journey/JourneyLayout";

export function JourneyScreen({ journeyId }: { journeyId: string }) {
  const { data } = useQuery<{ journey: Journey | null }>(JOURNEY, {
    variables: { id: journeyId },
  });
  const journey = data?.journey;
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    if (!journey) return;
    showOnJourneyMap(currentRoutePositionView(journey));
  }, [showOnJourneyMap, journey]);

  return <Logbook key={journeyId} journeyId={journeyId} />;
}
