import { EntryScreen } from "~/journal/EntryScreen";
import type { Route } from "./+types/entry";

export function meta() {
  return [{ title: "Your entry · Wayword" }];
}

export default function EntryRoute({ params }: Route.ComponentProps) {
  return <EntryScreen entryId={params.entryId} />;
}
