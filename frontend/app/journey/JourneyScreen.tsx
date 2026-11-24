import { useQuery } from "@apollo/client";
import { useEffect } from "react";
import { Logbook } from "~/journal/Logbook";
import { CURRENT_JOURNEY, type CurrentJourney } from "~/journal/operations";
import { useShowOnJourneyMap } from "~/journey/JourneyLayout";

export function JourneyScreen() {
  const { data } = useQuery<{ currentJourney: CurrentJourney | null }>(CURRENT_JOURNEY);
  const journey = data?.currentJourney;
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

  return <Logbook />;
}
