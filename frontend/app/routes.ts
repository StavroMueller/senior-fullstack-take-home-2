import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  route("entries/:entryId", "routes/entry.tsx"),
  route("usual-suspects", "routes/usual-suspects.tsx"),
] satisfies RouteConfig;
