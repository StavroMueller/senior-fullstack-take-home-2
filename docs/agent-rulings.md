# What Julien ruled against the agent's work

Every time Julien overturned something the agent wrote, the ruling goes here with the code before
and after. The agent reads this file before writing code and adds a section the same day a new
ruling lands. The rule itself also goes into `CLAUDE.md`, and this file keeps the example.

## 2026-11-23

### Every check runs locally, with no CI

The agent added a GitHub Actions workflow that ran the prose checker, the backend checks, the
frontend checks and the Playwright journey on every pull request. Julien ruled that hosted runs
cost money and slow the loop, and deleted the workflow after one passing run.

Commit `78e5822`.

Rejected, in `.github/workflows/checks.yml`:

```yaml
on:
  pull_request:
  push:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - run: mix credo --strict
      - run: mix test
```

Write instead, run on the machine before work is called done:

```bash
cd backend && mix format --check-formatted && mix compile --warnings-as-errors && mix credo --strict && mix test
cd frontend && npm run format:check && npm run typecheck && npm test
```

### Schema modules carry their app's namespace

The first house rules put every Ecto schema under `lib/backend/schema/`, which gives bare
`Backend.Schema.*` module names. Julien ruled that the app namespace wins, so each schema lives
under `lib/backend/database/schema/` as `Backend.Database.Schema.*`.

Commit `238f39a`.

Write instead, in `Backend.Database.Schema.Entry`:

```elixir
defmodule Backend.Database.Schema.Entry do
  use Ecto.Schema

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Journey
```

### A function name says what the function does

The agent named the failure path of the analysis job `record_failure`, though on every attempt
before the last it returned an error and recorded nothing. Julien's rule says a name states
exactly what the thing does, so the function became `retry_or_fail`. The same commit renamed
`normalize` to `trim_and_compose`, the two steps it runs.

Commit `13c09a4`.

Rejected, in `Backend.Journal.Jobs.AnalyzeEntry`:

```elixir
{:error, reason} -> record_failure(entry, job, reason)

defp record_failure(_entry, %Oban.Job{attempt: attempt, max_attempts: max_attempts}, reason)
     when attempt < max_attempts do
  {:error, reason}
end
```

Write instead:

```elixir
{:error, reason} -> retry_or_fail(entry, job, reason)

defp retry_or_fail(_entry, %Oban.Job{attempt: attempt, max_attempts: max_attempts}, reason)
     when attempt < max_attempts do
  {:error, reason}
end
```

### Each enum list lives in one place

The agent typed out the analysis statuses and the mistake categories a second time in the GraphQL
types, beside the `Ecto.Enum` lists in the schemas. Two copies of one list drift apart. The GraphQL
enums now read their values from the schemas.

Commit `13c09a4`.

Rejected, in `Backend.Graphql.Types.JournalTypes`:

```elixir
enum :correction_category do
  value :verb_tense
  value :verb_agreement
  value :gender
  value :adjective_agreement
  value :article
  value :preposition
  value :spelling
  value :word_choice
end
```

Write instead:

```elixir
enum :analysis_status, values: Ecto.Enum.values(Entry, :analysis_status)

enum :correction_category, values: Ecto.Enum.values(Correction, :category)
```

### One function decides each analysis status

The agent compared `entry.analysisStatus` to a string literal in each component, and wrote the
status messages twice with different wording. Julien's rule says a rule about an entity lives in
one function that every screen calls.

Commit `d3cba30`.

Rejected, in `frontend/app/journal/EntryHistory.tsx`:

```tsx
function analysisSummary(entry: EntrySummary) {
  if (entry.analysisStatus === "ANALYZING") return "Checking your entry";
  if (entry.analysisStatus === "ANALYSIS_FAILED") return "We couldn't check this entry.";
```

Write instead, with the checks in `operations.ts` and the messages in `analysisCopy.ts`:

```tsx
function analysisSummary(entry: EntrySummary) {
  if (isAnalyzing(entry)) return analyzingMessage;
  if (analysisFailed(entry)) return analysisFailedMessage;
```

### Name the teacher's reply a reaction

The agent called the teacher's reply to an analyzed entry a "line", in `TeacherLine`,
`GetTeacherLine` and the GraphQL field `teacherLine`. Julien ruled that a generic noun fits many
things and makes the reader guess, so every name says reaction. "Line" on its own is now banned
in code names.

Commits `4be75ce` and `783146d`.

Rejected, in `Backend.Journal.TeacherLine`:

```elixir
def for_entry(%Entry{id: entry_id}, %Journey{} = journey, corrections) do
  strings = read_strings(journey.language, journey.level)
  lines = strings[line_group(corrections)]
```

Write instead, in `Backend.Journal.TeacherReaction`:

```elixir
def for_entry(%Entry{id: entry_id}, %Journey{} = journey, corrections) do
  strings = read_strings(journey.language, journey.level)
  reactions = strings[reaction_group(corrections)]
```

### Return only the fields a screen shows

The agent's `categoryTrends` query returned an `analyzedEntryCount` that the "Usual suspects"
screen never displayed. Julien's rule says to select the fields the screen renders and nothing
extra, so the field left the GraphQL type, the query and the tests.

Commit `8050515`.

Rejected, in `Backend.Graphql.Types.JournalTypes`:

```elixir
object :category_trends do
  field :analyzed_entry_count, non_null(:integer)
  field :older_entry_count, non_null(:integer)
  field :recent_entry_count, non_null(:integer)
```

Write instead:

```elixir
object :category_trends do
  field :older_entry_count, non_null(:integer)
  field :recent_entry_count, non_null(:integer)
```

### A pipe chain reads top to bottom

`JourneyIntro.for_journey` piped a town list into a provider module looked up at runtime, then
piped the result into `case`. Julien ruled that a pipe starts from the data and goes only into a
named module's function, and that a result is bound to a name before a `case` branches on it.
Commit `acd31e3`, with the rule recorded in `CLAUDE.md` in commit `90ee58c`.

Rejected, in `Backend.Journal.JourneyIntro`:

```elixir
towns
|> provider().introduce_journey(journey.language, journey.level)
|> PlaceScene.usable()
|> case do
  nil -> hand_written(journey, towns)
  intro -> intro
end
```

Write instead:

```elixir
ai_intro = provider().introduce_journey(towns, journey.language, journey.level)

case PlaceScene.usable(ai_intro) do
  nil -> hand_written(journey, towns)
  intro -> intro
end
```

### The AI provider is looked up in one place

Three modules each held a private `provider/0` that read the provider from config, so one rule
lived in three copies. Under Julien's rule of one rule, one function, the lookup moved into
`Backend.Journal.AiProvider`, which exposes one function per call and dispatches to the
configured module.

Commit `931a5ea`.

Rejected, in `Backend.Journal.Jobs.AnalyzeEntry`, `JourneyIntro` and `PlaceScene`:

```elixir
ai_intro = provider().introduce_journey(towns, journey.language, journey.level)

defp provider, do: Application.fetch_env!(:journal, :ai_provider)
```

Write instead, in `Backend.Journal.AiProvider`:

```elixir
def introduce_journey(towns, language, level),
  do: configured().introduce_journey(towns, language, level)

defp configured, do: Application.fetch_env!(:journal, :ai_provider)
```

### One module checks what the AI writes for the teacher

`JourneyIntro` checked the AI's intro by calling `PlaceScene.usable/1`, a function owned by the
town scene, which returned `nil` on failure. Julien ruled that the check lives in one module
named for both texts it covers, `TeacherText`, and returns `{:ok, text}` or `:error`. A generic
noun is allowed here because the owner qualifies it.

Commit `b5f5cbd`.

Rejected, in `Backend.Journal.PlaceScene`:

```elixir
def usable({:ok, line}) when is_binary(line) do
  trimmed_line = String.trim(line)
  if trimmed_line != "" and String.length(trimmed_line) <= @longest_scene, do: trimmed_line
end

def usable(_failure), do: nil
```

Write instead, in `Backend.Journal.TeacherText`:

```elixir
def usable({:ok, teacher_text}) when is_binary(teacher_text) do
  trimmed = String.trim(teacher_text)
  fits? = trimmed != "" and String.length(trimmed) <= @longest_teacher_text

  if fits?, do: {:ok, trimmed}, else: :error
end

def usable(_failure), do: :error
```

### Long, exact names over short ones

The agent named the town scene module `PlaceScene`. Julien ruled that "place" reads as a verb and
sits beside its near-synonym "scene", so a reader cannot tell what the module holds. The module,
its provider callback, its column and its data folder now say point of interest.

Commit `adb6f15`.

Rejected:

```elixir
defmodule Backend.Journal.PlaceScene do

ai_scene = AiProvider.describe_place(town, journey.language, journey.level)
```

Write instead:

```elixir
defmodule Backend.Journal.PointOfInterestScene do

ai_scene = AiProvider.describe_point_of_interest(town, journey.language, journey.level)
```

### The map draws a traveler marker

`JourneyMap` called the highlighted spot a `Place`, with `placeOf`, `placeLabel` and `placeRef`.
Under Julien's ban on "place" in code names, the type, its finder and its props now name the map
marker they draw.

Commit `d11604f`.

Rejected, in `frontend/app/journey/JourneyMap.tsx`:

```tsx
type Place = { coordinates: Coordinates; name: string };

const place = placeOf(route, highlightedPointOfInterestIndex, highlightedEncounterId);
const placeText = place ? `${placeLabel}: ${place.name}` : null;
```

Write instead:

```tsx
type TravelerMarker = { coordinates: Coordinates; name: string };

const travelerMarker = findTravelerMarker(
  route,
  highlightedPointOfInterestIndex,
  highlightedEncounterId,
);
```

### A point of interest or an encounter is a route position

The backend called the spot where the person writes an entry a "place", in variable names and in
GraphQL descriptions. Julien added "route position" to the vocabulary for one point of interest or
one encounter, and banned "place" in code names.

Commit `b4f97c9`.

Rejected, in `Backend.Journal.Commands.SubmitEntry`:

```elixir
defp entry_changeset(journey, body, place) do
  %Entry{analysis_status: :analyzing, journey_id: journey.id}
  |> cast(Map.put(place, :body, trim_and_compose(body)), [
```

Write instead:

```elixir
defp entry_changeset(journey, body, route_position) do
  %Entry{analysis_status: :analyzing, journey_id: journey.id}
  |> cast(Map.put(route_position, :body, trim_and_compose(body)), [
```

## 2026-11-24

### A changeset lives in its schema

The agent kept the entry's `cast` and validations in the command that wrote the row, because the
audit checklist said "Changesets belong to the command that writes the row." Julien ruled that a
changeset is the one piece of logic a schema holds, since it is tied to the schema.

Rejected, in `Backend.Journal.Commands.SubmitEntry`:

```elixir
defp entry_changeset(journey, body, route_position) do
  %Entry{analysis_status: :analyzing, journey_id: journey.id}
  |> cast(Map.put(route_position, :body, trim_and_compose(body)), [:body, :point_of_interest_index, :encounter_id])
  |> validate_required([:body])
  |> validate_length(:body, max: @longest_body)
end
```

Write instead, in `Backend.Database.Schema.Entry`, and call it from the command:

```elixir
def submission_changeset(%__MODULE__{} = entry, attributes) do
  entry
  |> cast(attributes, [:body, :point_of_interest_index, :encounter_id])
  |> update_change(:body, &trim_and_compose/1)
  |> validate_required([:body])
  |> validate_length(:body, max: @longest_body)
end
```

### Every changeset, even a bare status change

The agent moved the validating changeset into the schema but left `Ecto.Changeset.change/2` calls
in the commands, on the grounds that they set known values. Julien asked for the same treatment
everywhere.

Rejected, in `Backend.Journal.Commands.FailAnalysis`:

```elixir
entry |> Ecto.Changeset.change(analysis_status: :analysis_failed) |> Repo.update()
```

Write instead, with the changeset on `Entry` and named for the write:

```elixir
entry |> Entry.analysis_failed_changeset() |> Repo.update()
```

No command calls `Ecto.Changeset` to build a changeset.

### Bind the Multi, then case on the transaction

`CLAUDE.md` had allowed a `Multi` chain to end in `Repo.transaction() |> case do`, and the agent
followed it. Julien ruled that the bound form is the only accepted one.

Rejected:

```elixir
Multi.new()
|> Multi.insert(:entry, entry_changeset)
|> Repo.transaction()
|> case do
  {:ok, %{entry: entry}} -> {:ok, entry}
  {:error, :entry, changeset, _changes} -> {:error, changeset}
end
```

Write instead:

```elixir
multi =
  Multi.new()
  |> Multi.insert(:entry, entry_changeset)

case Repo.transaction(multi) do
  {:ok, %{entry: entry}} -> {:ok, entry}
  {:error, :entry, changeset, _changes} -> {:error, changeset}
end
```

The Credo check `Backend.CredoChecks.PipeIntoCase` fails on any `|> case`. The rule is also in the
starter kit, on the branch `multi-and-changeset-rules`.

### No Dataloader for one person's journal

The agent kept Dataloader because the stack ruling listed it. Julien judged it overkill: batching
saved a few queries on a list of three to five journeys. The journal queries now preload what the
GraphQL fields read, and each association declares its order once with `preload_order` on the
schema.

### No helper module for a one-line list

To avoid writing a preload list twice, the agent added `Backend.Journal.LoadedAssociations`, one
of whose two functions had a single caller. Julien questioned the abstraction. `CLAUDE.md` already
says three similar lines beat a clever abstraction.

Rejected:

```elixir
|> Repo.preload(LoadedAssociations.journey())
```

Write instead, in each query:

```elixir
|> Repo.preload([:encounters, entries: [:corrections, :encounter]])
```

### Sibling queries read the same way

`ListJourneys` preloaded with the `Ecto.Query.preload/3` macro, which needs a pin, while
`GetJourney` and `GetEntry` used `Repo.preload/2`. Julien asked why one was pinned and the others
were not. Siblings use one form, so all three now end in `Repo.preload/2`.

Rejected:

```elixir
Journey
|> order_by(desc: :inserted_at, desc: :id)
|> preload(^LoadedAssociations.journey())
|> Repo.all()
```

Write instead:

```elixir
Journey
|> order_by(desc: :inserted_at, desc: :id)
|> Repo.all()
|> Repo.preload([:encounters, entries: [:corrections, :encounter]])
```

### Example journeys load at every boot

The agent left seeding as a manual command. Julien asked for the seeds to run on server start, and
chose to load them on every boot over loading them only into an empty journal, accepting that a
restart deletes what was written.

### One open pull request takes the related work

The agent started the changeset change on a new branch from `main`. Julien said to put it all in
the open pull request, #23.

### Act on the repository named

Asked to resolve conflicts, the agent began by checking the pull requests of both Wayword and the
starter kit. Julien stopped the call and named the challenge pull request. Work on the repository
the request names.
