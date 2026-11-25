import { type RouteConfig, index, layout, route } from "@react-router/dev/routes";

export default [
  layout("routes/journey-layout.tsx", [
    index("routes/home.tsx"),
    route("journeys/:journeyId", "routes/journey.tsx"),
    route("journeys/:journeyId/recap", "routes/journey-recap.tsx"),
    route("entries/:entryId", "routes/entry.tsx"),
    route("usual-suspects", "routes/usual-suspects.tsx"),
  ]),
] satisfies RouteConfig;
