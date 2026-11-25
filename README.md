# Wayword

Wayword is a language journal set on a trail across France. You write a few sentences at each
stop, in French, and get corrections on what you wrote. The assignment this answers is in
`ASSIGNMENT.md`.

## Run it

You need Docker.

```bash
./start.sh
```

The script asks for an OpenRouter API key at a hidden prompt, saves the key to `.env`, then
starts the stack in the background and prints its address once every container is healthy. Press Enter at the prompt to run with the stub provider. Once `.env` holds a key, the script uses that key without
asking; delete `.env` to change or drop it.

Open http://localhost:5173. The GraphQL API answers at http://localhost:4000/api/graphql, and
Postgres listens on port 55433. The map loads its tiles from OpenFreeMap, so it needs internet.

## Example journeys

The backend container loads three example journeys at every start, with entries, corrections and
teacher reactions recorded once from the real model. Loading empties every journey and entry
first, so a restart deletes anything written in the app. To load the examples again without a
restart:

```bash
docker compose exec backend mix run apps/database/priv/repo/seeds.exs
```

The examples come from `backend/apps/database/priv/repo/example_journeys.json`, and loading them
makes no AI call. On the host, `cd backend && mix ecto.setup` creates the database, runs
the migrations and loads the same journeys.

To record that file again, run `mix api.record_example_journeys` from `backend` with
`OPENROUTER_API_KEY` set. The task plays three journeys through the real commands on a scratch
database. The model writes each learner entry, then corrects the entry.

## Corrections from a real model

With no key, the backend uses a stub provider that knows four phrases, such as "je va" and "à le",
so the app runs with no AI service. To get corrections from
`anthropic/claude-haiku-5.5` through OpenRouter, give `./start.sh` your own key, or set
`OPENROUTER_API_KEY` in a `.env` file at the repository root. The file is git-ignored. Keys come from
https://openrouter.ai/keys, and 1000 entries cost about $0.15, measured over ten. The model is set in
`backend/config/config.exs`.

## Test it

```bash
docker compose run --rm -e MIX_ENV=test backend mix test
docker compose run --rm frontend npm test
cd e2e && npm ci && npx playwright install chromium && npx playwright test
```

The Playwright spec deletes every journey and entry in the dev database, then asserts the
stub's corrections, so start the stack without the key before running it:

```bash
OPENROUTER_API_KEY= docker compose up -d --build --wait
```

Restart the stack afterward to load the example journeys again.

## How it is built

- `backend/`: an Elixir umbrella with four apps. `database` holds the repo, schemas and
  migrations; `journal` holds entries, corrections and journeys; `graphql` holds the Absinthe
  schema; `api` holds Phoenix, the GraphQL endpoint and the Oban queue.
- `frontend/`: React Router 7 as a single-page app, with Apollo Client, MUI and MapLibre GL JS.
- `e2e/`: the Playwright spec.

The product and design decisions, with the reason for each, are in `PRODUCT.md` and `DESIGN.md`.

## Correction approach

Of the options in the assignment, Wayword combines three kinds of correction: a fix for each
error, a one-sentence explanation of the fix and a mistake category. You see the corrections after
you send an entry, with no help on screen while you write.

Each correction covers one span of your entry and holds the original words, the fix, the
explanation in English and a category such as verb tense or gender. Claude Haiku 5.5 finds the
errors through OpenRouter. The backend then looks up each original span in the entry on word
boundaries, so no highlight depends on a position the model counted.

Corrections fix errors only: grammar, spelling, agreement and a wrong word. No correction
suggests a style change or rewrites the whole entry. On screen, the corrected spans are
highlighted inside the entry, one card per correction sits below the entry, and the teacher adds a
short reaction.

## Why it helps a learner

Writing first and reading the corrections after makes you recall French with no hint on screen.
Seeing each error in place, with a one-sentence reason, shows which rule broke and leaves the
rest of your sentence as you wrote it.

Categories turn single corrections into patterns. The recap of a finished journey counts its
categories, and "Usual suspects" compares your older entries with your recent ones. The two
screens show which kinds of error come back and which have dropped off.

## How the interface supports writing and review

- **Journeys.** The opening page lists every journey, newest first, under a "Start a journey in
  France" button. Each card shows the route from its first town to its last, marked "Finished" or
  "In progress". Under the route come the country, the start date, the entry count, and the town
  you are in or the town where the journey finished.
- **Writing.** The left half is a map of France with the journey's route. On the right, the
  teacher, drawn as a travel buddy, sets the scene at the current route position and asks for a
  few French sentences, above an entry field. At a town the scene names something the town is
  known for. Between two towns the journey may meet a fantastical encounter with its own scene.
- **Moving on.** A new journey opens on the teacher's intro to the route, and "Let's go" moves to
  the first town. A route position takes as many entries as you like. Once the route position has
  an entry, "Keep going" moves the journey on, and the "You are here" marker walks along the route.
- **Waiting.** After you send an entry, the page shows "Checking your entry" until analysis ends.
  The browser gets the result over a Phoenix channel, with no reload.
- **Reading corrections.** The entry sits in its own card, with each corrected span highlighted.
  Below the entry come the teacher's reaction and one card per correction, showing the original
  crossed out, the fix, the category and the explanation.
- **Failure.** When analysis fails, the entry is kept, and "Try again" runs the analysis again.
- **Review.** On a journey's page, "Your entries" lists that journey's entries, newest first, with
  their correction count. Each entry opens on its own page, with its route position marked on the
  map.
- **Journey recap.** The card of a finished journey opens its recap page, and so does "Keep going"
  at the last town. The recap counts that journey's mistake categories with their trends, then
  lists every correction under its category.
- **Usual suspects.** Each mistake category with its count, most frequent first. A label says
  whether the category shows up fewer times lately, more times lately, about the same, or not at
  all lately.

## What was left out

- Help while writing: hints, translation, autocomplete and vocabulary lookup.
- Style suggestions and a corrected full version of the entry.
- Editing or deleting an entry after you send it.
- Accounts and sign-in: Wayword has one user.
- Keeping your entries across a restart: the example journeys replace every journey at each boot.
- Languages other than French at A1. Language and level are columns, and a second language needs
  new data files, which `PRODUCT.md` lists.
- A phone layout, an accessibility audit and deployment.
- An automated test against the real AI provider. Every test runs on the stub.

## API design

The frontend talks to one GraphQL endpoint, `/api/graphql`, built with Absinthe. Each operation
is one mutation or query, and resolvers only map arguments to the `journal` app.

| Operation | Does |
| --- | --- |
| `startJourney` | Starts a journey in a language and level from `languages`, from a random seed |
| `submitEntry(input)` | Saves one entry as `analyzing` and enqueues its analysis |
| `retryAnalysis(entryId)` | Runs a failed analysis again |
| `travelOn(journeyId)` | Moves the journey to its next route position, once the current route position has an entry |
| `languages` | Each language and level a journey can start in, with its country |
| `journeys` | Every journey, newest first, with its country, route and entries |
| `journey(id)` | One journey, with its route, the route position you are at, `canTravelOn`, its entries and its `categoryTrends` |
| `entry(id)` | One entry with its corrections and the teacher's reaction |
| `categoryTrends` | Each mistake category with its count and trend |

The browser joins the Phoenix channel `entry:<id>` to hear `analysis_finished` or
`analysis_failed`, then refetches the entry.

## Data model

Postgres holds four tables:

- `journeys`: `seed`, `language`, `level`, and the route position the person is at:
  `current_point_of_interest_index`, `current_encounter_id` and `finished_at`. The route is drawn
  from the seed when read, so it is not stored.
- `entries`: `body`, `analysis_status` (`analyzing`, `analyzed` or `analysis_failed`), a
  `point_of_interest_index` or an `encounter_id`, `teacher_reaction` and `inserted_at`. A check
  constraint requires exactly one route position, and a route position can hold several entries.
- `corrections`: `entry_id`, `span_start` and `span_end` in Unicode code points, `original`,
  `fix`, `explanation` and `category`. `category` is a Postgres enum of nine values.
- `encounters`: the encounters met on a journey, each placed after one point of interest.

Columns with a fixed set of values are Postgres enum types, so the database rejects any other
value. The mistake data for Stage 2 is the `corrections.category` column, counted over entries.

## How analysis is triggered and stored

1. `submitEntry` saves the entry with status `analyzing`, enqueues an Oban job in the same
   transaction, and returns.
2. The job sends the entry to the AI provider. With `OPENROUTER_API_KEY` set, the provider is
   `anthropic/claude-haiku-5.5` through OpenRouter, asked for JSON that matches a strict schema.
   The same call returns the teacher's reaction. With no key, the stub answers.
3. `CorrectionParser` validates the response, the one place that does. The parser finds each
   `original` in the entry, searching forward on word boundaries, and stores its code point span.
   A correction with an unknown category, text not found in the entry, or a fix that changes
   nothing is dropped.
4. The job stores the corrections and the teacher's reaction, sets the status to `analyzed` and
   broadcasts the result. The reaction is kept only when every correction survived step 3, so its
   count matches the screen; otherwise the teacher speaks a hand-written line.
5. When the provider fails, Oban retries up to three attempts. After the last one, the status
   becomes `analysis_failed` and the entry text stays saved.

The "Usual suspects" trends come from one query at read time. Analyzed entries split into an
older half and a recent half, and each category compares corrections per entry across the halves.

## Tradeoffs and limitations

- **Haiku through OpenRouter.** Five models were tested on ten French entries before the pick,
  and Ollama in Docker was measured too. Haiku got every category right, with a median of 1.8
  seconds. The results are in `docs/ai-provider-benchmark.md`.
- **The stub knows four phrases,** such as "je va" and "à le". Without a key, other errors go
  uncorrected.
- **Halves over dates for trends.** A reviewer writes a few entries in one sitting, so a weekly
  comparison would put them all in one bucket. Halves give a trend from the second entry.
- **The parser trusts no position from the model.** It locates each correction itself, so a
  correction whose text the model changed is dropped, and no highlight lands on the wrong words.
- **The map needs internet,** because tiles come from the public OpenFreeMap instance.
- **The Playwright spec empties the dev database before it runs,** so every journey and entry
  written in the app is deleted. A second database for tests would keep them, at the cost of a
  second backend in compose. The spec also asserts the stub's corrections, so the stack starts
  with `OPENROUTER_API_KEY=` blank before it runs.
- **The frontend types repeat two GraphQL enums by hand.** `AnalysisStatus` and
  `CorrectionCategory` in `frontend/app/journal/operations.ts` match the schema with no code
  generation, so a new enum value is added in both places.
