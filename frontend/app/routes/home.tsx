import { JourneyList } from "~/journey/JourneyList";

export function meta() {
  return [{ title: "Wayword" }];
}

export default function Home() {
  return <JourneyList />;
}
