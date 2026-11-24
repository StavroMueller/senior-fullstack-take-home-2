# Draw each journey's route and place every entry on it

Branch `journey-stops`. The words are fixed in `CLAUDE.md` under "Vocabulary": route, point of
interest, encounter. The product ruling is "Encounters along the route are fantastical" in
`PRODUCT.md`.

## Settled by Julien, 2026-11-23

- The seed picks a start town and an end town at least 400 km apart, draws a line between them,
  and picks three more towns along the line, each within 60 km of it and in order along it.
- Encounters are fantastical and happen by chance between two points of interest. An encounter
  takes its own entry.
- `entries.point_of_interest_index` places an entry written at a point of interest, and is null
  for an encounter entry.
- `entries.encounter_id` is a nullable, unique foreign key to `encounters.id`. An encounter that
  is triggered is written to an `encounters` table.
- The dev database is reset with `docker compose down -v` before the migrations run.
- In code, POI is spelled out: `PointOfInterest`, `points_of_interest`.

## Plan

1. `priv/routes/fr.json` lists about 50 real French towns with coordinates.
   `Backend.Journal.Route` derives the five points of interest from the seed on read.
2. `priv/encounters/fr-A1.json` holds the hand-written encounters in the teacher's voice, each
   with a key.
3. Two migrations:
   - Create `encounters`, with `journey_id`, `after_point_of_interest_index` and
     `encounter_key`, unique on `(journey_id, after_point_of_interest_index)`.
   - Add the nullable `point_of_interest_index` and `encounter_id` to `entries`. A check
     constraint requires exactly one of the two to be set, and unique indexes stop a second
     entry at the same route position.
4. `SubmitEntry` writes the entry at the open encounter when one exists, or else at the next
   point of interest. After an entry at a point of interest that is not the last, the seed
   decides whether an encounter follows and writes the `encounters` row in the same
   transaction. A journey whose last point of interest has an entry is finished, and
   `SubmitEntry` refuses another entry.
5. GraphQL: `Journey.pointsOfInterest`, `Journey.encounters`, and `Journey.writingPrompt`, which
   is null when the journey is finished. `Entry.pointOfInterest`, `Entry.encounter` and
   `Entry.journey` let a reopened entry draw its route position.
6. Frontend:
   - `JourneyMap` draws the route line in `action`, a marker per point of interest and per
     encounter, and the current route position.
   - `Logbook` shows the writing prompt and the finished state, and refetches
     `CURRENT_JOURNEY` after a submit.
7. Tests:
   - ExUnit pins a seed to a route.
   - ExUnit checks seeds 1 to 200 for five ordered points of interest within the corridor.
   - ExUnit runs the submit flow through an encounter to the finished journey.
   - Vitest covers the prompt and the finished state.
   - Playwright follows the journey from `/`.

## Changed after merge

On 2026-11-23 Julien asked for several entries per route position and a "Keep going" button. The unique
indexes on `entries` became plain indexes, `journeys` stores the current route position, and the new
`travelOn` mutation draws encounters. The rulings below about one entry per route position no longer hold.

## State

Merged into `main` with pull request #5, after every check under "Commands" in `CLAUDE.md` passed.

- Not verified: the coordinates of the 70 towns in `routes/fr.json` were written by hand. On the
  map, the markers for Limoges, Poitiers, Avignon, Aix-en-Provence, Nantes and Bourges sit on
  those towns.
- No test submits two entries at once. The unique indexes on `entries` reject a second entry at
  the same point of interest or encounter, and no test exercises that path.
- Julien approved the copy on 2026-11-23: the eight encounter prompts in `encounters/fr-A1.json`,
  the heading "On the road to {town}", and the finished line "You reached {town}, the end of this
  journey. Start a journey to keep writing."
