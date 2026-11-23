import type { CurrentJourney } from "~/journal/operations";

const towns = [
  { name: "Nancy", longitude: 6.18, latitude: 48.69 },
  { name: "Troyes", longitude: 4.07, latitude: 48.3 },
  { name: "Bourges", longitude: 2.4, latitude: 47.08 },
  { name: "Tours", longitude: 0.69, latitude: 47.39 },
  { name: "La Rochelle", longitude: -1.15, latitude: 46.16 },
];

export function testJourney(changes: Partial<Record<keyof CurrentJourney, unknown>> = {}) {
  return {
    __typename: "Journey",
    id: "1",
    pointsOfInterest: towns.map((town) => ({ __typename: "PointOfInterest", ...town })),
    encounters: [],
    openEncounter: null,
    nextPointOfInterestIndex: 0,
    ...changes,
  };
}
