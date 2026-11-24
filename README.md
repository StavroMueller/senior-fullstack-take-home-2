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

The Playwright spec asserts the stub's corrections, so start the stack without the key before
running it:

```bash
OPENROUTER_API_KEY= docker compose up -d --build --wait
```

## How it is built

- `backend/`: an Elixir umbrella with four apps. `database` holds the repo, schemas and
  migrations; `journal` holds entries, corrections and journeys; `graphql` holds the Absinthe
  schema; `api` holds Phoenix, the GraphQL endpoint and the Oban queue.
- `frontend/`: React Router 7 as a single-page app, with Apollo Client, MUI and MapLibre GL JS.
- `e2e/`: the Playwright spec.

The product and design decisions, with the reason for each, are in `PRODUCT.md` and `DESIGN.md`.

## Correction approach

Wayword gives feedback after writing. You write a few sentences at each stop on the trail, send
the entry, and read the corrections once analysis finishes. Nothing interrupts you while you write.

Each correction names one span of your entry, the fix, a one-sentence explanation in English and
a mistake category, such as verb tense or gender. Corrections stay small on purpose: grammar and
spelling errors only, with no style rewrites and no fully rewritten version.

## Why it helps a learner

Writing first and checking after makes you produce French from memory, which is the practice.
Seeing the error in place, with a short reason, tells you which rule broke and leaves the rest of
your sentence as you wrote it.

Categories turn single corrections into patterns. Over several entries, the "Usual suspects"
screen shows which kinds of error keep coming back and which have dropped off.

## How the interface supports writing and review

- **Writing.** The left half is a map of France with the journey's route. The right half gives a
  prompt for the current stop, such as "Write about today's stop. Three sentences is enough.",
  and an entry field. Some stops are fantastical encounters with their own prompt.
- **Waiting.** After you send an entry, it shows "Checking your entry" until analysis ends. The
  page hears the result over a Phoenix channel, with no reload.
- **Reading corrections.** Each corrected span is highlighted inside the entry. Below it, the
  teacher's reaction sums up the entry, and one card per correction shows the original crossed
  out, the fix, the category and the explanation.
- **Failure.** When analysis fails, the entry is kept and a "Try again" button runs it again.
- **Review.** "Your entries" lists past entries, newest first, with their correction count. Each
  one opens on its own page, with its place on the route marked on the map.
- **Usual suspects.** Each mistake category with its count, most frequent first. A label says
  whether the category shows up fewer times lately, more times lately, about the same, or not at
  all lately.

## What was left out

- Help while writing: hints, translation, autocomplete and vocabulary lookup.
- Style suggestions and a corrected full version of the entry.
- Accounts and sign-in: Wayword has one user.
- Languages other than French at A1. Language and level are columns, and a second language needs
  new data files, which `PRODUCT.md` lists.
- A phone layout, an accessibility audit and deployment.
- An automated test against the real AI provider. Every test runs on the stub.

## API design

The frontend talks to one GraphQL endpoint, `/api/graphql`, built with Absinthe. Each operation
is one mutation or query, and resolvers only map arguments to the `journal` app.

| Operation | Does |
| --- | --- |
| `startJourney` | Starts a journey from a random seed |
| `submitEntry(input)` | Saves one entry as `analyzing` and enqueues its analysis |
| `retryAnalysis(entryId)` | Runs a failed analysis again |
| `currentJourney` | The newest journey, with its route and the next place to write |
| `entries` | Every entry, newest first |
| `entry(id)` | One entry with its corrections and the teacher's reaction |
| `categoryTrends` | Each mistake category with its count and trend |

The browser joins the Phoenix channel `entry:<id>` to hear `analysis_finished` or
`analysis_failed`, then refetches the entry.

## Data model

Postgres holds four tables:

- `journeys`: `seed`, `language` and `level`. The route is drawn from the seed when read, so it is
  not stored.
- `entries`: `body`, `analysis_status` (`analyzing`, `analyzed` or `analysis_failed`), a
  `point_of_interest_index` or an `encounter_id`, `teacher_reaction` and `inserted_at`. A check constraint requires
  exactly one place.
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
  seconds. The results are in `todo/2026-11-23-real-ai-provider.md`.
- **The stub knows four phrases,** such as "je va" and "à le". Without a key, other errors go
  uncorrected.
- **Halves over dates for trends.** A reviewer writes a few entries in one sitting, so a weekly
  comparison would put them all in one bucket. Halves give a trend from the second entry.
- **The parser trusts no position from the model.** It locates each correction itself, so a
  correction whose text the model changed is dropped, and no highlight lands on the wrong words.
- **The map needs internet,** because tiles come from the public OpenFreeMap instance.
- **The Playwright spec uses the dev database** and the stub, so the stack starts with
  `OPENROUTER_API_KEY=` blank before it runs.
