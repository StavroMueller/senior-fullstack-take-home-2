# Convention checklist

Written by `house-rules` for Wayword on 2026-11-23, from Julien's answers. `CLAUDE.md` is the
authority. Every entry names the convention, what a violation looks like and a severity.

Removed because the condition is false: permissions (no accounts), security (no public pages or
uploads), migration rules for production data (none exists), old paths (nothing has shipped),
and "a write names the person acted for" (one user).

## Naming (NM)

**NM-01: No abbreviations.** WARN. A name shortens a word: `orgs`, `cfg`, `idx`, `res`, `corrs`.

**NM-02: No single-character names.** WARN. `e`, `i`, `x` as a variable, a parameter, a lambda
argument or an Ecto query binding.

**NM-03: A name states what the thing does.** ERROR. A function named for one scope returns
another, or a name no longer matches the behavior after a change.

**NM-04: Siblings share one naming scheme.** WARN. Functions behind one screen use different
verbs for the same act.

**NM-05: One word per concept.** WARN. A word used against the "Vocabulary" table in
`CLAUDE.md`: "feedback" or "mistake" alone in code, "persona" for the teacher, "session" for a
journey.

**NM-06: Long and descriptive beats short.** WARN. A name shortened past what it holds, or one
that pairs near-synonyms or uses a word that reads as a verb in a noun name, such as
`PlaceScene`.

## Comments (CM)

**CM-01: No comments.** WARN. Any comment other than a tool directive (`eslint-disable`,
`@ts-expect-error`, `prettier-ignore`, `credo:`, the shebang). A `@moduledoc` of one or two
lines and a one-line `@doc` are allowed; longer ones, or ones carrying a plan or ticket id, are
violations.

**CM-02: No comment or doc the code disproves.** ERROR. A `@moduledoc` or `@doc` that asserts
something the module does not do.

## Discipline (CD)

**CD-01: No defensive code.** WARN. A `try` or `rescue` around code that cannot fail, a guard on
a value present by contract, `?.` or `??` on a value the type says exists, a fallback for a case
that cannot happen.

**CD-02: No catch-all handler that hides a fault.** ERROR. A handler that catches everything,
logs and returns a default.

**CD-03: No speculative structure.** WARN. A helper with one caller, a behaviour with one
implementation other than the AI provider, an option nothing sets, any structure the no-scale
rule in `CLAUDE.md` bans. The functions in `Backend.Journal.AiProvider` that call the configured
provider are exempt: each one replaces a copy of the provider lookup.

**CD-04: One rule, one function.** ERROR. The same predicate about an entry, a correction or a
journey written in two places.

**CD-05: Unfinished work is a todo file.** INFO. A `TODO` or `FIXME` in source.

**CD-06: No speculative cache work.** WARN. A GraphQL selection with fields the screen does not
render, or Apollo cache configuration with no reproduced bug behind it.

## Structure (ST)

**ST-01: Resolvers map arguments and delegate, and nothing else.** ERROR. Business logic or a
direct `Repo` call in an Absinthe resolver or a Phoenix channel.

**ST-02: Commands and queries are separate.** WARN. A write outside
`lib/backend/<app>/commands/` with one public `execute/N`, or a read outside
`lib/backend/<app>/queries/` with one public `run/N`, or a context module that does more than
`defdelegate`.

**ST-03: Schemas live in `database` and hold no logic but their changesets.** WARN. An Ecto schema
defined in another app, a function in a schema module other than a changeset, or a command that
builds a changeset with `Ecto.Changeset` itself. Every changeset is a `*_changeset` function on its
schema.

**ST-04: Every module sits under its app's namespace.** WARN. A module outside
`Backend.<App>.*`, other than `Backend.ApiWeb.*` and a Mix task named `Mix.Tasks.<App>.<Name>`.

**ST-05: No dependency cycle between umbrella apps.** ERROR.

**ST-06: A pipe chain reads top to bottom.** WARN. A chain that starts from something other
than the data, pipes into a call on a module looked up at runtime such as `provider().x()`, or
pipes into `case` anywhere, including after `Repo.transaction()` at the end of a `Multi` chain.

## API writes (AP)

**AP-01: One operation, one mutation.** ERROR. Two mutations perform the same operation, or one
mutation performs two. Two operations may write the same row: `submitEntry` creates an entry and
`retryAnalysis` sets it back to `analyzing`.

## Tests (TS)

**TS-01: A test can fail.** ERROR. An assertion on a mock, or on a value the test itself set.

**TS-02: A change to the GraphQL schema or a query selection has a Playwright run behind it.**
WARN. A claim of done that rests on mocked Apollo tests alone.

**TS-03: A browser test starts at `/`.** WARN. A Playwright spec that opens a deep address such
as `/entries/<id>` directly.

## Data (MG)

**MG-01: The generator created the migration.** ERROR. A migration with a hand-picked version
number.

**MG-02: Timestamps are UTC at whole-second precision.** WARN. A schema without
`timestamps(type: :utc_datetime)`.

## Wayword rulings (WW)

**WW-01: Each kind of AI response is validated in one place.** ERROR. Provider corrections or
a teacher reaction used before `CorrectionParser`, a scene or intro used before
`TeacherText.usable/1`, or a second validator for either.

**WW-03: Language and level are data.** WARN. `"fr"` or `"A1"` hard-coded outside the strings
files and the seeds.

**WW-04: Analysis runs in the Oban job.** ERROR. `submitEntry` calling the AI provider inside
the request.

## Borrowed idioms (BI)

Julien writes Elixir and TypeScript. These are habits carried from one into the other.

**BI-01: `||` for a default value in Elixir.** ERROR. `||` treats `false` as missing, so a real
`false` is replaced. Use `Map.get/3` or a match.

**BI-02: A truthy `if` on a value that may be nil, in Elixir.** WARN. Match on the shape:
`%Entry{} = entry`.

**BI-03: `try`/`rescue` for control flow in Elixir.** WARN. Return `{:ok, _}` or `{:error, _}`
and use `with`.

**BI-04: Mutating an accumulator inside `Enum.each`.** ERROR. Rebinding inside the block changes
nothing outside it. Use `Enum.reduce/3`.

**BI-05: `any` or a non-null `!` in TypeScript.** WARN. Use the types in
`frontend/app/journal/operations.ts`, which repeat the GraphQL schema by hand, and narrow by shape.

**BI-06: `==` in TypeScript.** WARN. Use `===`.
