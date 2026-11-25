import { useQuery } from "@apollo/client";
import { useEffect } from "react";
import { Logbook } from "~/journal/Logbook";
import { JOURNEY, type Journey } from "~/journal/operations";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";

export function JourneyScreen({ journeyId }: { journeyId: string }) {
  const { data } = useQuery<{ journey: Journey | null }>(JOURNEY, {
    variables: { id: journeyId },
  });
  const journey = data?.journey;
  const showOnJourneyMap = useShowOnJourneyMap();

  useEffect(() => {
    if (!journey) return;
    showOnJourneyMap({
      route: journey,
      highlightedPointOfInterestIndex: journey.openEncounter
        ? null
        : journey.currentPointOfInterestIndex,
      highlightedEncounterId: journey.openEncounter?.id,
    });
  }, [showOnJourneyMap, journey]);

  return <Logbook key={journeyId} journeyId={journeyId} />;
}
