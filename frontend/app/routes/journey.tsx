import { JourneyScreen } from "~/journey/JourneyScreen";
import type { Route } from "./+types/journey";

export function meta() {
  return [{ title: "Your journey · Wayword" }];
}

export default function JourneyRoute({ params }: Route.ComponentProps) {
  return <JourneyScreen journeyId={params.journeyId} />;
}
