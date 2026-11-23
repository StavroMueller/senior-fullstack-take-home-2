# Give the map the aged-parchment style

`frontend/app/journey/JourneyMap.tsx` loads OpenFreeMap's stock "liberty" style. `DESIGN.md`
asks for aged parchment: land in `mapLand`, coasts, roads and place names in `mapInk`, and the
trail in `action`, under The Aged Map Exception.

Write a MapLibre style file that reads the OpenFreeMap vector tiles and sets those colors, keep
the OpenStreetMap attribution, and check the result in a screenshot.
