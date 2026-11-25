# Product

## Register

Wayword is a gamified product. The person returns to it to practice a language, and the game gives each
entry a reason to exist. The journal is the product and the adventure frames it.

## Users

- **A beginner learning French, at a desk.** One person on a laptop or desktop browser, writing
  a few sentences a day and reading every correction closely. Desktop is the main screen; a
  smaller window or a tablet gets a layout that still works, and a phone is not a target. Ruled
  by Julien, 2026-11-23.

## Brand personality

**Wayword, in three words: warm. cheeky. clear.**

Warm toward a beginner who gets plenty wrong, cheeky in the teacher's lines and
the celebrations, and clear wherever a correction is explained. The theme is tongue in cheek:
dry teasing, never gushing. Ruled by Julien, 2026-11-23.

## Anti-references

- **Duolingo, as a brand.** Duolingo is the reference for how the product feels: characters who
  react, a bright rounded interface, small wins and a daily habit. Its owl, its green, its Feather
  typeface, its name and its characters never appear, and no screen may pass for a Duolingo
  screen. Ruled by Julien, 2026-11-23.
- **The Oregon Trail, as a game.** The trail-game feel is the reference: stops, events, a party
  on the move. Its name, its art, its events and its screens never appear. Ruled by Julien,
  2026-11-23.
- **A corporate SaaS dashboard.** No metrics language, no "KPI" dashboard, no "insights" jargon. A
  few stat tiles (streak, points, entries) may sit at the top of a screen; mistake categories
  are always a list.
  Rejected: "Track your learning KPIs and optimize your progress." Write: "Verb tense keeps
  tripping you up."
- **Too friendly.** No gushing, no pet names, no praise the entry did not earn. The theme is
  tongue in cheek: the teacher teases and stays dry. Rejected: "Amazing job, superstar! We're SO
  proud of you!" Write: "Oh là là! Only two verbs fell off the cliff this time."

Ruled by Julien, 2026-11-23.

## Design principles

Taken from what Julien wants from the Duolingo feel, 2026-11-23.

- **Characters react.** A teacher answers each entry with a short line in character. The AI
  writes the line, and a hand-written one stands in when the AI's line fails its check.
- **Bright, chunky and rounded.** Big rounded buttons with a pressed-down edge, flat saturated
  colors and large type, in this product's own palette and typeface.
- **Every entry is a win.** Finishing an entry moves the person along the journey map and shows a
  short celebration.
- **A daily habit.** Streaks and points reward writing on consecutive days. This goes past the
  assignment, so it stays as small as the no-scale rule in `CLAUDE.md` allows.

## Voice and copy

### Who speaks

Interface copy speaks to the reader as "you": "Write about the storm." A teacher speaks as "I":
"I have never seen a pass that steep!" Ruled by Julien, 2026-11-23.

### Who we write for

A beginner in French, at CEFR level A1, writing short entries and reading every word of the
reply. At A1 the teacher speaks English with French interjections: "Mon dieu! That was a bad
storm!" Higher levels get more French when their strings are written. Ruled by Julien,
2026-11-23.

### Approved specimens

Approved by Julien, 2026-11-23.

Teacher lines:

> Oh là là! You crossed the pass in a storm and only tripped on two verbs. Bravo!

> Mon dieu, the bridge is gone! Tell me in French how you get across.

> Zut! Three wrong genders. The mountain doesn't care, but I do. Let's fix them.

**Why these work:** each opens on a French interjection a beginner can read, then names
something real: the number of corrections, the journey event, the most common mistake category.
The cheek sits in the reaction, and the fact stays plain.

Interface lines:

> Write about today's stop. Three sentences is enough.

> We couldn't check this entry. Your text is saved. Try again.

> No entries yet. Start a journey to write your first one.

**Why these work:** each says what the person does next. The prompt sets the size of the task,
the error says nothing was lost, and the empty state names the one action that fills the screen.

Not approved, offered in the same round: "Bon. Five sentences today. Tomorrow, the river, so
bring an umbrella." and "Verb tense: 7 this week, down from 12."

### Humor

Teacher lines and celebrations may joke. Corrections, explanations and error messages stay plain,
because a person reading why a verb is wrong needs the fact and not a wink.

Rejected, and why: "Oops! That verb went on vacation." hides which verb and why. Write: "fui"
should be "iba", because an ongoing past action takes the imperfect.

Ruled by Julien, 2026-11-23.

### Bans in product copy

All kept by Julien, 2026-11-23.

- **Name the contents.** A label says what the box holds. Rejected: "The Archive". Write "Your
  entries".
- **Show the role.** No brand-voice names for plain things.
- **A spinner shows text only when the text is real.** "Checking your entry" stays; a themed
  line such as "Sharpening the quill..." goes.
- **A message says what to do next.** Rejected: "Analysis failed." Write "We couldn't check this
  entry. Try again."
- **A message states a cause only when the code knows the cause.**
- **One phrasing per event.** The same failure reads the same on every screen.
- **A page title picks out the reader.** It says what the page holds.
- **No technical notation on screen.** No routes, ids, field names or category keys such as
  `verb_tense`; show "Verb tense".
- **No borrowed verbs:** unlocks, empowers, triggers, surfaces, drives.
- **No internal jargon.**

### What copy never claims

Ruled by Julien, 2026-11-23.

- **No fluency or level claims.** Nothing measures either. Rejected: "You're 40% fluent."
- **No claim that the teacher is a person or a native speaker,** whoever writes the lines.
- **No feelings.** Rejected: "effortless", "fun", "you'll love it".
- **No number nobody counted.** Every count on screen comes from stored corrections or entries.

### No decorative text

Every line on screen tells the person something they need or asks them to do something. Teacher
lines pass this test: the reaction is the reward for writing.

Out: a tagline under the logo, an audience list, a slogan as a heading, a pitch in an empty
state, and a line that repeats its neighbor.

When one instance is flagged, find the class of fault and sweep the whole surface for that class.

## Rulings

Decisions that the code obeys and cannot state. Reversing one is a product decision.

### A server and Postgres own the data

Entries, feedback and mistakes live in Postgres behind an Elixir backend, and the frontend reads
and writes them only through GraphQL. `docker compose up` starts Postgres, the backend and the
frontend, so a reviewer needs one command.

This reverses the earlier ruling that kept everything in browser storage on a static site. The
assignment asks for a backend API, a database and a backend flow test, and a static site gives
none of them. Declined: a static site with IndexedDB, and SQLite.

Ruled by Julien, 2026-11-23. Source: `docker-compose.yml`, `backend/apps/database/`.

### Submitting an entry returns at once and analysis runs after

`submitEntry` saves the entry with status `analyzing`, enqueues an Oban job and returns. The job
calls the AI provider, stores the corrections and broadcasts on the `analysis:<id>` PubSub
topic. `EntryChannel` relays that event to the `entry:<id>` channel. The writing screen joins
that channel and refetches the entry when it hears `analysis_finished` or `analysis_failed`.

A failed analysis keeps the entry, so nothing the person wrote is lost to a provider error.
Declined: analyzing inside the request, an Absinthe subscription, and polling.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`, `backend/apps/api/`.

### AI corrects entries and writes the teacher's reaction

The one AI call takes the entry text and returns structured corrections, each with the mistake,
the fix, a category and an explanation. The same call returns the teacher's reaction, one line in
the voice set under "Voice and copy", stored in `entries.teacher_reaction`.

The parser keeps the reaction only when it is one short line and every correction in the
response survived parsing, so its count matches the screen. Otherwise, and with the stub, the
teacher speaks a hand-written line picked by the seed. The map and the journey events stay
seeded, so the same seed always gives the same route.

This reverses the ruling "AI corrects entries and does nothing else", once the real provider
returned valid corrections. Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`.

### The teacher travels with you and sets the scene at each route position

The teacher is a travel buddy walking the road with the person. At each route position the buddy says, in
the voice set under "Voice and copy", what is there and asks for a few French sentences about it,
so the person always has something to write about.

In a town, Haiku writes the scene on arrival, naming one real thing the town is known for, and the
scene is stored in `journeys.current_point_of_interest_scene`. With no key, or when the scene comes back empty
or longer than 600 characters, a hand-written scene from `point_of_interest_scenes/fr-A1.json` names the town
instead. At an encounter, the scene is the hand-written prompt for that encounter. When a journey
starts, the teacher also gives an intro built from the route: the first and last towns and the
towns between, stored in `journeys.intro`. The intro is the first thing a new journey shows, alone
with a "Let's go" button that opens the first town's scene. A hand-written
intro from `journey_intros/fr-A1.json` stands in the same way. Both are written at the same time. Writing the
scene adds 4 to 5 seconds to "Start a journey" and "Keep going", measured on three towns.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/lib/backend/journal/point_of_interest_scene.ex`, `journey_intro.ex` and `teacher_text.ex`, which holds the 600-character cap.

### Claude Haiku 5.5 corrects entries through OpenRouter when a key is set

The correction call goes through a provider `@behaviour` with two adapters. With
`OPENROUTER_API_KEY` set, `Backend.Journal.AiProvider.OpenRouter` asks
`anthropic/claude-haiku-5.5` for corrections as strict JSON. With no key, the stub returns canned
corrections, so the app runs and every test passes with no AI service.

Haiku won a benchmark of five models on ten French A1 entries: every category right, no broken
fix, a median of 1.8 seconds and $0.15 per 1000 entries. Ollama in Docker was declined because a
Mac runs the model on its CPU, taking 24 to 128 seconds an entry, and its categories were wrong.
The measurements are in `todo/2026-11-23-real-ai-provider.md`.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`, `backend/config/runtime.exs`.

### Language and level are data

Each journey stores a `language` (an ISO code such as `fr`) and a `level` (a CEFR level such as
`A1`), and each entry carries both into the AI prompt. Hand-written strings live in data files
under `backend/apps/journal/priv/`, and only French A1 exists. Towns depend on the language alone,
so `routes/fr.json` covers every French level. Teacher reactions, encounter scenes, town scenes and
journey intros depend on the level too, so they live in `teacher_reactions/fr-A1.json`,
`encounters/fr-A1.json`, `point_of_interest_scenes/fr-A1.json` and `journey_intros/fr-A1.json`. The AI
prompts take the language and level as arguments and name no language or country.

Adding Spanish A1 means adding those five files and a `country` in `routes/es.json`, and
changes no code. The `languages` query lists every language and level whose files all exist, the
screen shows one "Start a journey in {country}" button for each, and `startJourney` refuses any
other. Declined: a locale framework or
a registry of languages, which the no-scale rule bans, and hard-coding French.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`.

### Journeys cross real France on a restyled open map

A journey runs between real French towns, and its events are tied to stops along the way, so
French practice happens on a French map. A Spanish journey would cross Spain.

The map is MapLibre GL JS with a custom style file that gives OpenStreetMap vector tiles the
aged-map look in `DESIGN.md`. Tiles come from the public OpenFreeMap instance, which needs no
key and no signup.

OpenFreeMap is provided as is, with no uptime promise, and the map needs internet. The map keeps
the OpenStreetMap attribution. Declined: Leaflet with raster tiles, a local PMTiles extract, and
an invented world.

Ruled by Julien, 2026-11-23. Source: `frontend/app/journey/`.

### Encounters along the route are fantastical

The seed picks a start town and an end town at least 400 km apart, draws a line between them,
and picks three more real towns along that line, each within 60 km of it and in order along it.
These towns are the route's points of interest.

Between two points of interest the seed may place an encounter, and encounters are fantastical:
a dragon on a bridge, a talking goat at a ford. Encounters come from hand-written strings, so the
same seed always gives the same route.

A person stays at a route position, a point of interest or an encounter, until they choose to move on. A
route position takes as many entries as the person writes. Once it has one entry, "Keep going" appears,
and pressing it moves the journey to the next route position, where the seed may draw an encounter first.
Sending an entry never moves the journey, so a person reads the corrections before leaving.
Requested by Julien, 2026-11-23.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`.

### Corrections are highlighted inside the entry

A person sees exactly which characters of an entry each correction covers. Each correction
stores `span_start` and `span_end`, counted in Unicode code points from the start of the entry
body, with the end excluded.

Code points count the same in Elixir (`String.codepoints/1`) and in the browser
(`Array.from`). Graphemes were declined because the two sides segment them by different Unicode
versions: `क्ष` is 2 graphemes in Elixir 1.18 and 1 in Node 24. UTF-16 code units and bytes were
declined because only one side counts them natively.

Language models count characters unreliably, so the parser ignores any position in the AI
response. The parser finds `original` in the body on word boundaries, searching forward from the
end of the previous correction, and drops a correction whose text it cannot find.

The entry body, `original` and `fix` are normalized to NFC first, so an accented letter typed as
two code points still matches.

Ruled by Julien, 2026-11-23. Source: `backend/apps/database/priv/repo/migrations/`,
`backend/apps/journal/`.

### Usual suspects compares the older half of the entries with the recent half

The "Usual suspects" screen lists each mistake category with its count, most frequent first. A
category reads "fewer lately", "more lately", "steady" or "gone lately" by comparing corrections
per entry in the older half of the analyzed entries with the recent half. With an odd count, the
recent half holds the extra entry.

Halves were picked because a reviewer writes a few entries in one sitting. A comparison by week
would put every entry in one bucket, and a fixed window of the last five entries would show no
trend before ten entries. Comparing per entry keeps two halves of different sizes fair.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/lib/backend/journal/category_trends.ex`.

### The opening page lists every journey

`/` lists every journey, the one started most recently first, under a "Start a journey in
<country>" button for each language with data files. Each card names the route by its first and
last town, then gives the country, the start date, where the person is and the entry count.

Starting a journey opens `/journeys/<id>`. That page holds the writing prompt and "Your entries"
for that journey only. Usual suspects still counts every entry across every journey.

Requested by Julien, 2026-11-24. Source: `frontend/app/journey/JourneyList.tsx`,
`backend/apps/journal/lib/backend/journal/queries/list_journeys.ex`.

### Example journeys are recorded once and loaded from a file

Running `seeds.exs` empties the journal tables and loads three example journeys from
`backend/apps/database/priv/repo/example_journeys.json`: one finished, one partway along its
route and one just started. Loading them makes no AI call. Each timestamp in the file is counted
back from the moment of loading, so the entries stay recent and Usual suspects shows trends.

`mix api.record_example_journeys` writes that file. The task plays each journey through the
real commands on a scratch database, `wayword_example_journeys`.

The OpenRouter model writes
the entries, as a learner at the journey's level with planted mistakes, and corrects them. The
task stops unless the OpenRouter provider is configured, and stops when an analysis fails.
Rerun the task only to change the examples.

Cassettes for HTTP calls, such as ExVCR, were declined. The file stores database rows, so loading
it sends no request to replay. Also, every journey starts from a random route seed, so each
recording sends different prompts.

Requested by Julien, 2026-11-24. Source: `backend/apps/database/lib/backend/database/commands/load_example_journeys.ex`,
`backend/apps/api/lib/mix/tasks/api.record_example_journeys.ex`.
