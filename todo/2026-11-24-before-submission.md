# Close the open items before the repository goes to a reviewer

Stage 1 and Stage 2 are merged into `main`. A person starts a journey,
follows its route across France, writes entries at each route position, sees corrections marked
inside each entry, and reopens past entries from "Your entries". "Usual suspects" lists the
mistake categories with a trend for each.

## Run the checks on main

No run of every command under "Commands" in `CLAUDE.md` is recorded since pull requests #19 and
#20 merged. Pull request #20 changed how `JourneyMap` mounts, so the Playwright journey is the
check that matters most. Start this once `main` holds every merge meant for the reviewer.

## Julien rules on three choices in `CorrectionParser`

The forward search and the drop of a correction it cannot find are ruled in `PRODUCT.md`, under
"Corrections are highlighted inside the entry". These three choices have no ruling:

- `original` matches regardless of case.
- A correction whose category is unknown is dropped, and `correction_category` has no `other`
  value.
- `correction_category` holds nine values: the eight from the corrections migration and
  `noun_number`.

Each ruling Julien keeps goes into `PRODUCT.md` with its date.

## Julien approves the "Usual suspects" copy

The trend labels "fewer lately", "more lately", "steady" and "gone lately" are ruled in
`PRODUCT.md`. The rest of the copy in `frontend/app/journal/UsualSuspects.tsx` has no approval:

- the teacher reaction "{Category} keeps tripping you up."
- the empty state "No corrections yet. Write an entry and the usual suspects show up here."
- the note "Trends show up once two entries are analyzed."
- the note "Comparing your older {n} entries with your recent {m} entries."

## Town coordinates

Not verified: the coordinates of the 70 towns in `backend/apps/journal/priv/routes/fr.json` were
written by hand. On the map, the markers for Limoges, Poitiers, Avignon, Aix-en-Provence, Nantes
and Bourges sit on those towns, and the other 64 are unchecked.
