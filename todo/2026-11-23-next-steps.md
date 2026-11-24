# Pick up the Stage 1 work after the entry flow

Pull requests #3, #4 and #5 are merged into `main`. A person can start a journey, follow its route
across France through towns and encounters, write an entry at each route position, see each correction
marked inside it, read the teacher's reaction under it, and reopen the entry from "Your entries".

## Waiting on Julien

- Choices made in `CorrectionParser` that Julien may veto: the nine categories in the
  `correction_category` enum; dropping a correction whose category is unknown, with no `other`
  value; matching `original` regardless of case; dropping a correction that appears before the
  previous one.

## Stage 1 and Stage 2

Both stages are built, and the README answers each question the assignment asks of it.

The aged map style is merged with pull request #7. The map draws water in `mapInk` at half
opacity, a choice Julien may veto, because `DESIGN.md` named no water color.

The "Usual suspects" screen merged with pull request #11.
