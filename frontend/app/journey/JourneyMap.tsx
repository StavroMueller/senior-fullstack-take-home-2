import Box from "@mui/material/Box";
import GlobalStyles from "@mui/material/GlobalStyles";
import { type GeoJSONSource, LngLatBounds, Map as MapLibreMap, Marker } from "maplibre-gl";
import { useEffect, useRef, useState } from "react";
import type { PointOfInterest, RouteOnMap } from "~/journal/operations";
import { agedMapStyle } from "~/journey/agedMapStyle";
import { fonts, palette, sizes } from "~/palette";

const franceCenter: [number, number] = [2.4, 46.6];
const franceZoom = 5;
const routeSourceId = "route";
const routePaddingPixels = 48;
const handDrawnFilterId = "hand-drawn-map";
const handDrawnNoiseOctaves = 2;
const handDrawnNoiseSeed = 7;
const travelerPulseAnimation = "traveler-pulse";

type Coordinates = [number, number];

type Place = { coordinates: Coordinates; name: string };

type Traveler = { marker: Marker; element: HTMLElement; label: HTMLElement; at: Coordinates };

function coordinatesOf(pointOfInterest: PointOfInterest): Coordinates {
  return [pointOfInterest.longitude, pointOfInterest.latitude];
}

function midpoint(start: PointOfInterest, finish: PointOfInterest): Coordinates {
  return [(start.longitude + finish.longitude) / 2, (start.latitude + finish.latitude) / 2];
}

function placeOf(
  route: RouteOnMap | undefined,
  pointOfInterestIndex: number | null,
  encounterId: string | null,
): Place | null {
  if (!route) return null;
  const { pointsOfInterest, encounters } = route;
  if (pointOfInterestIndex !== null) {
    const pointOfInterest = pointsOfInterest[pointOfInterestIndex];
    return { coordinates: coordinatesOf(pointOfInterest), name: pointOfInterest.name };
  }
  const encounter = encounters.find((candidate) => candidate.id === encounterId);
  if (!encounter) return null;
  const previousPointOfInterest = pointsOfInterest[encounter.afterPointOfInterestIndex];
  const nextPointOfInterest = pointsOfInterest[encounter.afterPointOfInterestIndex + 1];
  return {
    coordinates: midpoint(previousPointOfInterest, nextPointOfInterest),
    name: `on the road to ${nextPointOfInterest.name}`,
  };
}

function stopMarkerElement(label: string, color: string) {
  const element = document.createElement("div");
  element.setAttribute("role", "img");
  element.setAttribute("aria-label", label);
  Object.assign(element.style, {
    width: `${sizes.marker}px`,
    height: `${sizes.marker}px`,
    borderRadius: "50%",
    backgroundColor: color,
    border: `${sizes.markerBorder}px solid ${palette.surface}`,
  });
  return element;
}

function travelerElements() {
  const element = document.createElement("div");
  element.setAttribute("role", "img");
  Object.assign(element.style, {
    width: `${sizes.travelerMarker}px`,
    height: `${sizes.travelerMarker}px`,
    borderRadius: "50%",
    backgroundColor: palette.action,
    border: `${sizes.markerBorder}px solid ${palette.surface}`,
    animation: `${travelerPulseAnimation} ${sizes.travelerPulseMilliseconds}ms ease-out infinite`,
    zIndex: "1",
  });

  const label = document.createElement("div");
  Object.assign(label.style, {
    position: "absolute",
    top: "100%",
    left: "50%",
    transform: "translateX(-50%)",
    marginTop: `${sizes.markerBorder * 2}px`,
    padding: `${sizes.markerBorder}px ${sizes.markerBorder * 4}px`,
    borderRadius: `${sizes.travelerMarker}px`,
    backgroundColor: palette.ink,
    color: palette.surface,
    fontFamily: fonts.display,
    whiteSpace: "nowrap",
  });
  element.append(label);
  return { element, label };
}

function easeInOut(progress: number) {
  return progress < 0.5 ? 2 * progress * progress : 1 - (-2 * progress + 2) ** 2 / 2;
}

function walk(traveler: Traveler, destination: Coordinates) {
  const [startLongitude, startLatitude] = traveler.at;
  const [endLongitude, endLatitude] = destination;
  const startedAt = performance.now();
  let frame = 0;

  const step = (now: number) => {
    const progress = Math.min((now - startedAt) / sizes.travelMilliseconds, 1);
    const eased = easeInOut(progress);
    traveler.marker.setLngLat([
      startLongitude + (endLongitude - startLongitude) * eased,
      startLatitude + (endLatitude - startLatitude) * eased,
    ]);
    if (progress < 1) frame = requestAnimationFrame(step);
  };

  frame = requestAnimationFrame(step);
  traveler.at = destination;
  return () => cancelAnimationFrame(frame);
}

function routeLine(pointsOfInterest: PointOfInterest[]) {
  return {
    type: "Feature" as const,
    properties: {},
    geometry: { type: "LineString" as const, coordinates: pointsOfInterest.map(coordinatesOf) },
  };
}

function drawRouteLine(map: MapLibreMap, pointsOfInterest: PointOfInterest[]) {
  const source = map.getSource<GeoJSONSource>(routeSourceId);
  if (source) {
    source.setData(routeLine(pointsOfInterest));
    return;
  }
  map.addSource(routeSourceId, { type: "geojson", data: routeLine(pointsOfInterest) });
  map.addLayer({
    id: routeSourceId,
    type: "line",
    source: routeSourceId,
    layout: { "line-cap": "round" },
    paint: {
      "line-color": palette.action,
      "line-width": sizes.routeLine,
      "line-dasharray": [...sizes.routeDash],
    },
  });
}

export function JourneyMap({
  route,
  highlightedPointOfInterestIndex = null,
  highlightedEncounterId = null,
  placeLabel = "You are here",
}: {
  route?: RouteOnMap;
  highlightedPointOfInterestIndex?: number | null;
  highlightedEncounterId?: string | null;
  placeLabel?: string;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const travelerRef = useRef<Traveler>(undefined);
  const [map, setMap] = useState<MapLibreMap>();
  const place = placeOf(route, highlightedPointOfInterestIndex, highlightedEncounterId);
  const placeLongitude = place?.coordinates[0];
  const placeLatitude = place?.coordinates[1];
  const placeText = place ? `${placeLabel}: ${place.name}` : null;

  useEffect(() => {
    if (!containerRef.current) return;
    const createdMap = new MapLibreMap({
      container: containerRef.current,
      style: agedMapStyle,
      center: franceCenter,
      zoom: franceZoom,
    });
    createdMap.once("load", () => setMap(createdMap));
    return () => createdMap.remove();
  }, []);

  useEffect(() => {
    if (!map || !route) return;
    const { pointsOfInterest, encounters } = route;

    const pointOfInterestMarkers = pointsOfInterest.map((pointOfInterest) =>
      new Marker({ element: stopMarkerElement(pointOfInterest.name, palette.ink) }).setLngLat(
        coordinatesOf(pointOfInterest),
      ),
    );
    const encounterMarkers = encounters.map((encounter) =>
      new Marker({
        element: stopMarkerElement(
          `Encounter after ${pointsOfInterest[encounter.afterPointOfInterestIndex].name}`,
          palette.win,
        ),
      }).setLngLat(
        midpoint(
          pointsOfInterest[encounter.afterPointOfInterestIndex],
          pointsOfInterest[encounter.afterPointOfInterestIndex + 1],
        ),
      ),
    );
    const markers = [...pointOfInterestMarkers, ...encounterMarkers];
    markers.forEach((marker) => marker.addTo(map));

    drawRouteLine(map, pointsOfInterest);
    const bounds = new LngLatBounds();
    pointsOfInterest.forEach((pointOfInterest) => bounds.extend(coordinatesOf(pointOfInterest)));
    map.fitBounds(bounds, { padding: routePaddingPixels });

    return () => markers.forEach((marker) => marker.remove());
  }, [map, route]);

  useEffect(() => {
    if (!map || placeLongitude === undefined || placeLatitude === undefined || !placeText) return;
    const destination: Coordinates = [placeLongitude, placeLatitude];
    const traveler = travelerRef.current;

    if (!traveler) {
      const { element, label } = travelerElements();
      const marker = new Marker({ element }).setLngLat(destination).addTo(map);
      travelerRef.current = { marker, element, label, at: destination };
      label.textContent = placeText;
      element.setAttribute("aria-label", placeText);
      return;
    }

    traveler.label.textContent = placeText;
    traveler.element.setAttribute("aria-label", placeText);
    return walk(traveler, destination);
  }, [map, placeLongitude, placeLatitude, placeText]);

  return (
    <>
      <GlobalStyles
        styles={{
          [`@keyframes ${travelerPulseAnimation}`]: {
            from: { boxShadow: `0 0 0 0 ${palette.action}` },
            to: { boxShadow: `0 0 0 ${sizes.travelerPulse}px transparent` },
          },
        }}
      />
      <svg aria-hidden="true" width="0" height="0" style={{ position: "absolute" }}>
        <filter id={handDrawnFilterId}>
          <feTurbulence
            type="fractalNoise"
            baseFrequency={sizes.handDrawnGrain}
            numOctaves={handDrawnNoiseOctaves}
            seed={handDrawnNoiseSeed}
          />
          <feDisplacementMap in="SourceGraphic" scale={sizes.handDrawnWobble} />
        </filter>
      </svg>
      <Box
        ref={containerRef}
        role="region"
        aria-label="Journey map"
        sx={{
          width: "100%",
          height: "100%",
          overflow: "hidden",
          backgroundColor: palette.mapLand,
          "& .maplibregl-canvas": { filter: `url(#${handDrawnFilterId})` },
        }}
      />
    </>
  );
}
