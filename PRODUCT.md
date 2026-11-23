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

- **Characters react.** A teacher answers each entry with a short line in character, drawn from
  hand-written strings, never from the AI.
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
calls the AI provider, stores the corrections and broadcasts on the `entry:<id>` channel. The
writing screen joins that channel and refetches the entry when it hears `analysis_finished` or
`analysis_failed`.

A failed analysis keeps the entry, so nothing the person wrote is lost to a provider error.
Declined: analyzing inside the request, an Absinthe subscription, and polling.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`, `backend/apps/api/`.

### AI corrects entries and does nothing else

The one AI call takes the entry text and returns structured corrections: the mistake, the fix,
a category and an explanation.

The map, the journey events, teacher lines and writing prompts come from a seeded random
generator and hand-written strings, so the same seed always gives the same journey and tests can
pin it.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`.

### The AI provider is a stub for now

The correction call goes through a provider `@behaviour`. The only adapter is a stub that returns
canned corrections.

The assignment requires real AI analysis, so this is open work, tracked in
`todo/2026-11-23-real-ai-provider.md`. The option on the table: an OpenAI-compatible adapter
that reads base URL, key and model from the environment, pointed at a free open-weight model on
OpenRouter, with the stub kept for tests and for running with no key.

Ruled by Julien, 2026-11-23. Source: `backend/apps/journal/`.

### Language and level are data

Each journey stores a `language` (an ISO code such as `fr`) and a `level` (a CEFR level such as
`A1`), and each entry carries both into the AI prompt. Hand-written strings live in one file per
language and level, and only French A1 exists.

Adding Spanish means adding a strings file and changes no code. Declined: a locale framework or
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
