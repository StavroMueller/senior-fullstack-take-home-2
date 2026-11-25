import { JourneyRecapScreen } from "~/journey/JourneyRecapScreen";
import type { Route } from "./+types/journey-recap";

export function meta() {
  return [{ title: "Journey recap · Wayword" }];
}

export default function JourneyRecapRoute({ params }: Route.ComponentProps) {
  return <JourneyRecapScreen journeyId={params.journeyId} />;
}
