import Box from "@mui/material/Box";
import { type GeoJSONSource, LngLatBounds, Map as MapLibreMap, Marker } from "maplibre-gl";
import { useEffect, useRef, useState } from "react";
import type { PointOfInterest, RouteOnMap } from "~/journal/operations";
import { palette, sizes } from "~/palette";

const franceCenter: [number, number] = [2.4, 46.6];
const franceZoom = 5;
const openFreeMapStyle = "https://tiles.openfreemap.org/styles/liberty";
const routeSourceId = "route";
const routePaddingPixels = 48;

type Coordinates = [number, number];

function coordinatesOf(pointOfInterest: PointOfInterest): Coordinates {
  return [pointOfInterest.longitude, pointOfInterest.latitude];
}

function midpoint(start: PointOfInterest, finish: PointOfInterest): Coordinates {
  return [(start.longitude + finish.longitude) / 2, (start.latitude + finish.latitude) / 2];
}

function markerElement(label: string, color: string, highlighted: boolean) {
  const size = highlighted ? sizes.highlightedMarker : sizes.marker;
  const element = document.createElement("div");
  element.setAttribute("role", "img");
  element.setAttribute("aria-label", label);
  Object.assign(element.style, {
    width: `${size}px`,
    height: `${size}px`,
    borderRadius: "50%",
    backgroundColor: highlighted ? palette.action : color,
    border: `${sizes.markerBorder}px solid ${palette.surface}`,
  });
  return element;
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
    paint: { "line-color": palette.action, "line-width": sizes.routeLine },
  });
}

export function JourneyMap({
  route,
  highlightedPointOfInterestIndex = null,
  highlightedEncounterId = null,
}: {
  route?: RouteOnMap;
  highlightedPointOfInterestIndex?: number | null;
  highlightedEncounterId?: string | null;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [map, setMap] = useState<MapLibreMap>();

  useEffect(() => {
    if (!containerRef.current) return;
    const createdMap = new MapLibreMap({
      container: containerRef.current,
      style: openFreeMapStyle,
      center: franceCenter,
      zoom: franceZoom,
    });
    setMap(createdMap);
    return () => createdMap.remove();
  }, []);

  useEffect(() => {
    if (!map || !route) return;
    const { pointsOfInterest, encounters } = route;

    const pointOfInterestMarkers = pointsOfInterest.map((pointOfInterest, index) =>
      new Marker({
        element: markerElement(
          pointOfInterest.name,
          palette.ink,
          index === highlightedPointOfInterestIndex,
        ),
      }).setLngLat(coordinatesOf(pointOfInterest)),
    );
    const encounterMarkers = encounters.map((encounter) =>
      new Marker({
        element: markerElement(
          `Encounter after ${pointsOfInterest[encounter.afterPointOfInterestIndex].name}`,
          palette.win,
          encounter.id === highlightedEncounterId,
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

    const showRoute = () => {
      drawRouteLine(map, pointsOfInterest);
      const bounds = new LngLatBounds();
      pointsOfInterest.forEach((pointOfInterest) => bounds.extend(coordinatesOf(pointOfInterest)));
      map.fitBounds(bounds, { padding: routePaddingPixels });
    };
    if (map.isStyleLoaded()) showRoute();
    else map.once("load", showRoute);

    return () => markers.forEach((marker) => marker.remove());
  }, [map, route, highlightedPointOfInterestIndex, highlightedEncounterId]);

  return (
    <Box
      ref={containerRef}
      role="region"
      aria-label="Journey map"
      sx={{ width: "100%", height: "100%" }}
    />
  );
}
