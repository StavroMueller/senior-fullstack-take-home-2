import { type RouteConfig, index, layout, route } from "@react-router/dev/routes";

export default [
  layout("routes/journey-layout.tsx", [
    index("routes/home.tsx"),
    route("entries/:entryId", "routes/entry.tsx"),
    route("usual-suspects", "routes/usual-suspects.tsx"),
  ]),
] satisfies RouteConfig;
