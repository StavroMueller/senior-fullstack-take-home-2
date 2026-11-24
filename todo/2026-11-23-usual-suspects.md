# Build the "Usual suspects" screen

Branch `usual-suspects`. Stage 2 in `ASSIGNMENT.md` asks for a summary of mistakes over time, and
`CLAUDE.md` names the screen "Usual suspects". `PRODUCT.md` rules that mistake categories are
always a list, with no dashboard language.

## Settled by Julien, 2026-11-23

Analyzed entries split into an older half and a recent half by `inserted_at`. With an odd count,
the recent half holds the extra entry. For each mistake category, corrections per entry in each
half are compared, and the category reads "fewer lately", "more lately", "steady" or "gone
lately". With fewer than two analyzed entries, no category gets a trend.

## Plan

1. No new storage: `corrections.category` and `entries.inserted_at` hold everything the screen
   needs.
2. `Backend.Journal.CategoryTrends.from_entries/1` takes the categories of each analyzed entry,
   oldest first, and returns each category with its count and trend. It is a pure function, so
   ExUnit covers the split and every trend without a database.
3. `Backend.Journal.Queries.GetCategoryTrends.run/0` reads analyzed entries with their correction
   categories in one query and calls `CategoryTrends.from_entries/1`.
4. GraphQL: `categoryTrends` returns the analyzed entry count, the size of each half, and one row
   per category with `category`, `count` and `trend`.
5. Frontend: the `/usual-suspects` route lists the rows, most frequent first, and a link on the
   home screen opens it.
6. Tests: ExUnit for `CategoryTrends` and for the query through the `api` app, Vitest for the
   list, and the Playwright journey reaches the screen from `/`.

## State

Built on branch `usual-suspects`, with every check under "Commands" in `CLAUDE.md` passing.

- Copy for Julien to approve: the link "Usual suspects: the mistake categories that keep coming
  back", the teacher line "{Category} keeps tripping you up.", the empty state "No corrections
  yet. Write an entry and the usual suspects show up here.", the note "Trends show up once two
  entries are analyzed.", the note "Comparing your older {n} entries with your recent {m}
  entries." and the trend labels "fewer lately", "more lately", "steady" and "gone lately".
- Apollo served a cached `categoryTrends` after a new entry, so the screen showed the old count
  until a reload. The query now uses `fetchPolicy: "cache-and-network"`.
- The map lost its route line after a client-side navigation since the aged map style merged.
  `JourneyMap` now hands the map to React only after its `load` event.
