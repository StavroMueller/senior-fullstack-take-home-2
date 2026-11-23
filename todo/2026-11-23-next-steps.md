# Pick up the Stage 1 work after the entry flow

Pull requests #3 and #4 are merged into `main`. A person can start a journey, write an entry, see
each correction marked inside it, read the teacher's reaction under it, and reopen the entry from
"Your entries".

## Waiting on Julien

- Pick the AI provider and supply a key, per `todo/2026-11-23-real-ai-provider.md`.
- Record his preference from 2026-11-23 in `CLAUDE.md`. He said to keep working through the
  steps of an open pull request without stopping for "done" between them. That reverses
  Engagement rule 6, "Ask one thing at a time". Auto mode blocked the agent's edit to rule 6, so
  Julien makes it or approves it.
- Choices made in `CorrectionParser` that Julien may veto: the eight categories in the
  `correction_category` enum; dropping a correction whose category is unknown, with no `other`
  value; matching `original` regardless of case; dropping a correction that appears before the
  previous one.

## Stage 1 work left, in order

1. The real AI provider, once Julien picks one.
2. The README answers, per `todo/2026-11-23-readme.md`, once the real provider works.
3. Journey stops on the map: the seed draws a route between French towns, and each entry moves
   the person along it, per "Journeys cross real France on a restyled open map" in `PRODUCT.md`.
   `JourneyMap` shows the map with no route today.
4. The aged map style, per `todo/2026-11-23-aged-map-style.md`.

Stage 2, the "Usual suspects" screen, starts after these.
