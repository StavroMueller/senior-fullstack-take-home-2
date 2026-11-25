import Grid from "@mui/material/Grid";
import { type ComponentProps, useState } from "react";
import { Outlet, useOutletContext } from "react-router";
import type { Encounter, RouteOnMap } from "~/journal/operations";
import { JourneyMap } from "~/journey/JourneyMap";

type JourneyMapView = ComponentProps<typeof JourneyMap>;

type ShowOnJourneyMap = (journeyMapView: JourneyMapView) => void;

type JourneyAtRoutePosition = RouteOnMap & {
  currentPointOfInterestIndex: number | null;
  openEncounter: Pick<Encounter, "id"> | null;
};

export function currentRoutePositionView(journey: JourneyAtRoutePosition): JourneyMapView {
  return {
    route: journey,
    highlightedPointOfInterestIndex: journey.openEncounter
      ? null
      : journey.currentPointOfInterestIndex,
    highlightedEncounterId: journey.openEncounter?.id,
  };
}

export function JourneyLayout() {
  const [journeyMapView, setJourneyMapView] = useState<JourneyMapView>({});

  return (
    <Grid container sx={{ minHeight: "100vh" }}>
      <Grid
        size={{ xs: 12, md: 6 }}
        sx={{ height: { xs: "50vh", md: "100vh" }, position: { md: "sticky" }, top: 0 }}
      >
        <JourneyMap {...journeyMapView} />
      </Grid>
      <Grid size={{ xs: 12, md: 6 }} sx={{ padding: 4 }}>
        <Outlet context={setJourneyMapView satisfies ShowOnJourneyMap} />
      </Grid>
    </Grid>
  );
}

export function useShowOnJourneyMap() {
  return useOutletContext<ShowOnJourneyMap>();
}
