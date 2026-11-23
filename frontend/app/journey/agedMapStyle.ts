import type { StyleSpecification } from "maplibre-gl";
import { palette } from "~/palette";

const vectorSourceId = "openmaptiles";
const labelFont = ["Noto Sans Regular"];
const waterOpacity = 0.5;
const riverOpacity = 0.6;
const labelHaloWidth = 1.5;

const motorwayTrunkPrimaryRoadClasses = ["motorway", "trunk", "primary"];
const secondaryTertiaryRoadClasses = ["secondary", "tertiary"];

export const agedMapStyle: StyleSpecification = {
  version: 8,
  glyphs: "https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf",
  sources: {
    [vectorSourceId]: { type: "vector", url: "https://tiles.openfreemap.org/planet" },
  },
  layers: [
    { id: "land", type: "background", paint: { "background-color": palette.mapLand } },
    {
      id: "water",
      type: "fill",
      source: vectorSourceId,
      "source-layer": "water",
      filter: ["!=", ["get", "brunnel"], "tunnel"],
      paint: { "fill-color": palette.mapInk, "fill-opacity": waterOpacity },
    },
    {
      id: "water_outline",
      type: "line",
      source: vectorSourceId,
      "source-layer": "water",
      filter: ["!=", ["get", "brunnel"], "tunnel"],
      paint: { "line-color": palette.mapInk, "line-width": 1.5 },
    },
    {
      id: "waterway_river",
      type: "line",
      source: vectorSourceId,
      "source-layer": "waterway",
      filter: ["==", ["get", "class"], "river"],
      paint: {
        "line-color": palette.mapInk,
        "line-opacity": riverOpacity,
        "line-width": ["interpolate", ["linear"], ["zoom"], 6, 0.5, 12, 2],
      },
    },
    {
      id: "road_secondary_tertiary",
      type: "line",
      source: vectorSourceId,
      "source-layer": "transportation",
      minzoom: 8,
      filter: ["match", ["get", "class"], secondaryTertiaryRoadClasses, true, false],
      paint: {
        "line-color": palette.mapInk,
        "line-width": ["interpolate", ["linear"], ["zoom"], 8, 0.5, 14, 2],
      },
    },
    {
      id: "road_motorway_trunk_primary",
      type: "line",
      source: vectorSourceId,
      "source-layer": "transportation",
      filter: ["match", ["get", "class"], motorwayTrunkPrimaryRoadClasses, true, false],
      paint: {
        "line-color": palette.mapInk,
        "line-width": ["interpolate", ["linear"], ["zoom"], 5, 0.5, 14, 3],
      },
    },
    {
      id: "boundary_country",
      type: "line",
      source: vectorSourceId,
      "source-layer": "boundary",
      filter: ["all", ["==", ["get", "admin_level"], 2], ["!=", ["get", "maritime"], 1]],
      paint: { "line-color": palette.mapInk, "line-width": 1.5, "line-dasharray": [3, 2] },
    },
    {
      id: "label_city_town",
      type: "symbol",
      source: vectorSourceId,
      "source-layer": "place",
      filter: ["match", ["get", "class"], ["city", "town"], true, false],
      layout: {
        "text-field": ["get", "name"],
        "text-font": labelFont,
        "text-size": ["interpolate", ["linear"], ["zoom"], 5, 11, 10, 15],
      },
      paint: {
        "text-color": palette.mapInk,
        "text-halo-color": palette.mapLand,
        "text-halo-width": labelHaloWidth,
      },
    },
    {
      id: "label_country",
      type: "symbol",
      source: vectorSourceId,
      "source-layer": "place",
      filter: ["==", ["get", "class"], "country"],
      layout: {
        "text-field": ["get", "name"],
        "text-font": labelFont,
        "text-size": 14,
        "text-transform": "uppercase",
        "text-letter-spacing": 0.2,
      },
      paint: {
        "text-color": palette.mapInk,
        "text-halo-color": palette.mapLand,
        "text-halo-width": labelHaloWidth,
      },
    },
  ],
};
