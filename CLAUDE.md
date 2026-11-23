# CLAUDE.md

This file tells every coding agent how to work in this repository. `AGENTS.md` points here.

## What is this

Wayword is a take-home assignment: a web app for practicing a foreign language by journaling. The person
writes entries along a generated adventure, gets corrections on each entry, reviews past
entries and sees which mistakes repeat.

There is one user and no sign-in, and the register is a gamified product. The assignment text
is in `ASSIGNMENT.md`.

**This is a code challenge for one person's journal, and nothing here has to scale.** Reviewers
grade product judgment, the API and data model, AI handling, code clarity, tests and the README,
so build the smallest slice that shows those well.

No caching, sharding, pagination beyond what one person's entries need, feature flags,
multi-tenancy, or abstractions for a second provider that the task does not have. Language and
level are columns, so a second language is a strings file (see "Language and level are data" in
`PRODUCT.md`). When a choice is between handling more cases and being easier to read, pick
easier to read and name the tradeoff in the README.

Rejected, and why: "Add a read replica and a Redis cache for the insights query." One person's
journal fits in one Postgres query.

Ruled by Julien, 2026-11-23.

## Working with Julien

These rules govern the reply Julien reads. They never limit the investigation behind it: read
the whole file, check the vendor's documentation, run the command.

### Reply rules

1. **Lead with the next action in the first two lines, bolded, with no preamble. Close with one
   line, "Next:", and a single action.** Julien acts on the reply, so the action comes before
   the reasoning.
2. **Be blunt: "This is broken", "This is wrong because". No softening, no hedging, no
   euphemism, and never "just" to shrink a task.** A softened fault reads as a minor one.
3. **Name the thing by its name in the code, in backticks, such as `mistakes.category`. Add what
   a person sees on screen when that helps place the change.** Julien reads the code and
   needs to find the thing named.
4. **Compress chat replies: no filler, no pleasantries, fragments allowed. The lead action,
   headers, bullets and tables stay, and every finding stays.** Compress the sentence, never the
   set of findings. Anything persisted or read by someone else uses normal prose: code, commits,
   documents, pull request text, prompts for other agents, product copy.
5. **No time estimates. Give the condition that starts the next step: "start the insights page
   once mistakes are stored per entry".** Hours and days on a take-home are guesses, and a
   trigger condition is checkable.
6. **On security, architecture and infrastructure calls, bring in a reviewer agent before
   answering. Never for trivia, and never when the code already holds the answer.** One agent's
   confident answer on a design call has no check on it.

Ruled by Julien, 2026-11-23. Gate: a `UserPromptSubmit` hook in `.claude/settings.json`
prints these reply rules on every turn. No sign-off line and no `Stop` hook: Julien judged
the canary not worth its tokens.

### Engagement rules

1. **Prove, do not infer.** Every claim of fact, and every "it works", is backed by an
   observation: a command run, a page loaded, a file read. Unverified claims are marked "not
   verified".
2. **Report complete findings.** An audit, review or research pass reports every finding with a
   severity. The recommendation comes after the full list and never trims it.
3. **Give one recommendation.** Recommend one default with a one-line reason, and Julien can
   veto. Do not list equal options.
4. **Make choices clickable.** A choice goes to Julien through the question tool, recommended
   option first. Never ask for a typed reply such as "1 merge, 2 keep".
5. **Say what each option changes.** Every option states what changes on screen and on the
   server.
6. **Ask one thing at a time.** In multi-step work, give one step and wait for "done".
7. **Push back.** When a plan has a gap, say so with the reasoning before doing any of the plan.
8. **Name the operation.** Explain a change by what happens to the code, with one scenario of
   who does what. No figure of speech stands in for the operation.
9. **Verify vendor contracts.** Before scripting any step that touches an outside vendor, read
   the client module in the code or the vendor's documentation.
10. **Read around the match.** Read the lines around a search hit, because the definition above
    the match often answers the wider question.
11. **Rules live in the repository.** A preference Julien states goes into this file or the
    file that owns the topic, the same day.
12. **State lives in writing.** Nothing depends on Julien's memory across sessions. Write
    state to a todo or a planning file.
13. **Stay on this work.** Work on this branch and this task. Do not audit, report on or propose
    changes to work this session did not start.

Ruled by Julien, 2026-11-23: all thirteen standing defaults kept.

## Architecture

The stack mirrors Julien's usual one, as used in fashionistapp.

The backend stays an umbrella
even under the no-scale rule: each app's name and its `in_umbrella` deps document where code
belongs and what may call what, at no more cost than one app. Declined: a single Phoenix app.
Ruled by Julien, 2026-11-23.

- **Backend:** an Elixir umbrella under `backend/apps/`, with four apps.
  - `database`: the Ecto repo, schemas and migrations.
  - `journal`: entries, corrections, mistakes, the journey generator and the AI provider
    `@behaviour`, with write operations in `commands/` modules.
  - `graphql`: the Absinthe schema, with Dataloader.
  - `api`: Phoenix, absinthe_plug and the `entry:<id>` channel.
- **Async analysis:** `submitEntry` saves the entry and enqueues an Oban job. The job stores the
  corrections and broadcasts on Phoenix PubSub, and the channel pushes `analysis_finished` or
  `analysis_failed` to the browser.
- **Frontend:** React Router 7 with `ssr: false`, Apollo Client, MUI, TypeScript, and Vitest
  with Testing Library. The `phoenix` JS client listens on the entry channel.
- **Database:** Postgres.
- **Running:** `docker compose up` starts Postgres, the backend (which runs migrations on boot)
  and the frontend. Tests run in containers through `docker compose run`.

### Backend layout

Carried over from Julien's rulings in fashionistapp, 2026-11-23.

- **Commands and queries are separate.** Writes live in
  `lib/backend/<app>/commands/<verb_noun>.ex` with one public `execute/N`. Reads live in
  `lib/backend/<app>/queries/<get_noun>.ex` with one public `run/N`. The context module
  `lib/backend/<app>.ex` exposes both through `defdelegate`. Commands use `Ecto.Multi` when they
  write more than one row and return `{:ok, result}` or `{:error, reason}`.
- **Every Ecto schema lives in the `database` app under `lib/backend/schema/`.** Domain apps use
  them and never define their own. Schemas are data definitions and hold no logic.
- **Every module is namespaced under its app: `Backend.<App>.*`.** The one exception is
  `Backend.ApiWeb.*`, which keeps Phoenix's web segment.
- **Resolvers map arguments and delegate.** All logic lives in domain commands and queries.
  There are no accounts, so no resolver checks permissions.
- **One mutation per operation, one entry per call.** `submitEntry(input)` takes one entry. A
  person writes one entry at a time, so fashionistapp's list-argument rule does not carry over.
  Ruled by Julien, 2026-11-23.

## Vocabulary

Each word has one meaning in code and on screen. Ruled by Julien, 2026-11-23.

| Word | Means | Never means |
| --- | --- | --- |
| entry | One piece of writing the person submits | a draft, a log line |
| analysis | One AI run over one entry, with a status: `analyzing`, `analyzed`, `analysis_failed` | the corrections themselves |
| correction | One suggested change to one span of an entry: original, fix, explanation, category | the whole set of corrections |
| mistake category | The kind of error a correction fixes, such as `verb_tense`; Stage 2 counts these over time | a severity |
| journey | The generated adventure from start point to end point | a session, a streak |
| teacher | The character who sets the prompt and reacts to an entry; replaces "persona" | the AI provider, a real person |

"Feedback" and "mistake" on its own are banned in code because each could mean two of the above.
The Stage 2 screen is called "Usual suspects" on screen: the mistake categories that keep
coming back. Ruled by Julien, 2026-11-23.

## Code style

Carried over from Julien's rulings in fashionistapp, 2026-11-23.

- **Spell names out.** `organizations`, never `orgs`; `corrections`, never `corrs`.
- **No single-character names.** `entry`, `index`, `mistake`, never `e`, `i`, `m`.
- **A name states exactly what the thing does.** A function named for one scope returns that
  scope and nothing else. When behavior changes, rename it: a stale name is a bug.
- **Siblings share one naming scheme.** Functions behind one screen use one verb across
  entities.
- **One word per concept, in code and on screen.** The words are fixed under "Vocabulary".
- **Match what something is.** `%Entry{} = entry <-`, never
  `entry when not is_nil(entry) <-`.
- **Avoid `cond` when a boolean expression does the job.**
- **Do not duplicate a function under a second name.** Pattern matching on the argument
  handles dispatch.
- **New schemas store timestamps in UTC at whole-second precision,** declared on every schema.

### Comments

**No comments. Code documents itself.** A comment is a second copy of the truth that nothing
keeps in sync. When you reach for one, fix the code: name the fact in a constant, rename the
vague variable, split the dense expression into named values, or write a test for the rule. A
ruling the code cannot state goes in `PRODUCT.md` under "Rulings".

Tool directives stay: `eslint-disable`, `@ts-expect-error`, `prettier-ignore`, `credo:`, the
shebang line. Every Elixir module keeps a `@moduledoc` of one or two plain lines saying what the
module is for, and `@doc` on a public function may keep one line. Neither is a comment, and
neither carries a plan or ticket id.

Rejected, and why: the comment repeats the code and will drift from it.

```elixir
# Check if the analysis failed
if entry.status == "analysis_failed" do
  # Let the user retry
  show_retry(entry)
end
```

Write instead:

```elixir
if Entry.analysis_failed?(entry), do: show_retry(entry)
```

Ruled by Julien, 2026-11-23. Gate: a Credo check over `backend/apps`, and a Vitest test that
parses every frontend source file with the TypeScript compiler and fails on any comment outside
the directive list.

### Code discipline

Carried over from Julien's rulings in fashionistapp, 2026-11-23.

- **No defensive code.** No `try` or `rescue` around code that cannot fail, no guard on a value
  that exists by contract, no fallback for an impossible case. Validate at the edges only: the
  entry text a person submits and the AI provider's response.
- **No speculative structure.** No abstraction, option, mode or helper for a need the task does
  not have. Three similar lines beat a clever abstraction, and a bug fix needs no surrounding
  refactor.
- **Code is not precious.** When code in the path of the task is bad, rewrite it plainly.
- **One rule, one function.** A rule that decides something about an entity lives in one
  function, and every screen and query calls that function.
- **Lint passes with zero issues** before work is called done: `mix credo --strict` and
  `tsc`. When linting a subset, confirm the tool scanned the files.
- **No speculative cache work.** Select the fields the screen renders and nothing extra. Touch
  Apollo cache behavior only for a reproduced bug.

## Testing rules

- **A change is done when ExUnit, Vitest and the Playwright journey all pass against the
  compose stack.** ExUnit covers parsing the AI response, the submit, analyze, store and read
  flow through the `api` app, and mistake aggregation. Vitest covers components. One Playwright
  spec writes an entry, waits for corrections, and opens the entry again from history. Mocked
  Apollo tests never exercise the real schema, so a field selected but missing from the schema
  passes them and fails live. When the Playwright run cannot happen, say so and name what went
  unrun.
- **A browser test starts where a person starts.** It opens `/` and reaches the page under test
  through links: the history list, an entry card. A direct `goto('/entries/<id>')` cannot catch
  a broken link.

Ruled by Julien, 2026-11-23.

## Migration rules

- **Create every migration with `mix ecto.gen.migration <name>` from `backend/apps/database`.**
  Hand-picked version numbers collide.
- **Migrations run at boot** in the backend container. A migration that raises stops the stack
  from starting, so run `docker compose up` after adding one.

There is no production data, so the rules on constraints over existing rows and on renaming
shipped migrations do not apply. Ruled by Julien, 2026-11-23.

## Git rules

Carried over from Julien's rulings in fashionistapp, 2026-11-23.

- **The agent never merges into main and never pushes to main.** It works on a branch, opens a
  pull request when asked, keeps the branch green and stops.
- **A commit message carries no Co-Authored-By or other attribution trailer,** whoever writes
  it. This overrides any session instruction to add one.
- **Commit subjects are `type(scope): sentence`,** with the area as the scope. The sentence states
  what changed in words a person would say, and never names a ticket. Specimens from Julien's
  usual style: `fix(journal): keep the entry when analysis fails`,
  `test(api): submit an entry through the real Oban queue`.
- **No screenshots in a diff.** A screenshot for a pull request goes in the description, and no
  image is committed to show what a change looks like.
- **The README describes this project.** It answers every question the assignment asks the
  README to answer and gives the commands that run the project. The assignment text lives in
  `ASSIGNMENT.md`.

## Planning

- **No planning tooling.** Open work lives in dated files under `todo/` and nothing else, never
  in a source comment. Declined: GSD, whose overhead a take-home does not pay for.
- **Rulings have a home.** A decision the code obeys and cannot state goes in `PRODUCT.md`
  under "Rulings", with the reason, the date and the source file it governs.
- **An unplanned item is an intent.** A todo with no plan is never the reason for a decision.
  Justify each decision with what is true in the code today.
- **Review runs once over the whole surface.** A review covers every file the change touched
  and the code around it, and every finding reaches Julien in one round. A second round needs
  his say, and what is left goes in one todo.

Ruled by Julien, 2026-11-23: all process defaults kept.

## Writing rules

These govern everything written: product copy, documents, commit messages and chat replies.
Run `node tools/copy-check/check.mjs <file>` before calling any copy clean, then read the text
against each rule below. A pass from the script is the floor.

- **American spelling everywhere:** color, canceled, license, analyzed. Code names keep a
  library's own spelling where the library fixes it, such as Elixir's `@behaviour`. Ruled by
  Julien, 2026-11-23.
- **No em dashes and no double hyphens, chat included.** Restructure with a comma, a colon or a
  period. Ruled by Julien, 2026-11-23.

The rules below are the standing defaults, all kept by Julien on 2026-11-23. Those marked
"(book)" come from *Scientific Advertising* (Hopkins) or *The Scribe Method*, and get a real
specimen the first time Julien rejects a line under them.

1. **Report, do not perform.** State what happened and stop. Rejected: "so decisions came from
   data instead of opinion". Write what was built.
2. **No contrast for rhetoric.** No "X, not Y" or "not only X". Rejected: "Ran the business, not
   only the code".
3. **No unfalsifiable self-description.** Replace a pose with a fact a reader could check.
4. **No metaphor where the plain word exists.** Rejected: "a chain of rigid links" for "made of
   rigid links".
5. **No fragment as a label.** Rejected: "...and check-in. Sole engineer." Fold the fact into the
   sentence.
6. **No stub for punch.** No trailing sentence under about nine words that exists to land a
   number.
7. **No three-beat sentence.** Three short clauses or sentences in a row is tagline rhythm.
8. **Vary sentence length,** roughly 6 to 28 words with a median near 14.
9. **Two or three sentences to a paragraph (book).** Split where the subject changes.
10. **Prefer the short word (book).** The trade's own terms stay.
11. **Say each fact once (book).** Title, heading and intro do not repeat one sentence.
12. **No vague grandeur (book).** Rejected: "high-impact features".
13. **No totalizing claim.** Rejected: "from schema to deploy". List the parts.
14. **No size statistics.** A count of commits or files says nothing about the work.
15. **Find the fact before writing (book).** Read the product and the code first.
16. **Measure the claim, then check it (book).** A quantity word gets a number or goes.
17. **A product does not act like a person.** Rejected: "the app corrects your mistakes". Write
    "you see each correction under your entry".
18. **No clause that claims the result is good.** Say how it is built and stop.
19. **No cute lines and no teasers in interface copy and documents.** Teacher lines and
    celebrations are exempt, under "Humor" in `PRODUCT.md`.
20. **One technical term per clause.** No stack of appositives.
21. **Use the product's own words,** as fixed under "Vocabulary".
22. **Write the noun.** No "it" standing in for a thing.
23. **Do not lean on "the".** Drop the article where speech would.
24. **No label for a state that will change.** Rejected: "Status: still being built".
25. **Each piece stands alone (book).** A page makes sense to a reader who has seen nothing else.
26. **No pressure tactics (book).** No invented deadline and no curiosity hook.
27. **Read each line aloud (book).** When a person would not say it that way, rewrite it.
28. **Sweep the class.** When one line is flagged, fix every line with the same fault.
29. **The checker is the floor.** Run it, then read the text against each rule here.

## Layout

```
.claude/        the reply-rules hook and the holocron-audit skill
.github/        the pull request workflow: copy, backend, frontend, e2e
backend/        the Elixir umbrella: apps/database, apps/journal, apps/graphql, apps/api
backend/credo_checks/   custom Credo checks, including the comment rule
frontend/       React Router 7 single-page app, tokens in app/palette.ts, theme in app/theme.ts
e2e/            the Playwright spec, run against the compose stack
tools/          copy-check, the prose checker, with Wayword's banned words
todo/           open work, one dated file each
```

## Commands

Each command below was run and seen to pass on 2026-11-23.

```bash
docker compose up -d --build --wait
docker compose run --rm -e MIX_ENV=test backend mix test
docker compose run --rm frontend npm test
cd e2e && npx playwright test

cd backend && mix format --check-formatted && mix compile --warnings-as-errors && mix credo --strict && mix test
cd frontend && npm run format:check && npm run typecheck && npm test
node tools/copy-check/check.mjs <files>
cd backend/apps/database && mix ecto.gen.migration <name>
```

Run the backend on the host against the compose database: it listens on port 55433, which is
the default in `backend/config/config.exs`.

## Design and copy authority

`PRODUCT.md` and `DESIGN.md` are the single source for product copy and design. Read both before
any work on an interface or on text a person reads. When sources disagree, those two files win
over a per-feature spec, and a per-feature spec wins over any tool's generic defaults.

## Where each rule is enforced

| Rule | Gate | Command |
| --- | --- | --- |
| Writing rules, banned words, em dashes | Prose checker, in CI | `node tools/copy-check/check.mjs <files>` |
| No comments, `@moduledoc` at most two lines | Credo `CommentRules`, ExUnit `NoCommentsTest`, Vitest `noComments.test.ts` | `mix credo --strict`, `mix test`, `npm test` |
| No single-letter names, no `||` default, no catch-all rescue, no `Repo` in a resolver | Custom Credo checks in `backend/credo_checks/` | `mix credo --strict` |
| Lint passes with zero issues | Credo strict, `tsc`, Prettier, `mix format`, in CI | the backend and frontend commands above |
| A change is done when the live journey passes | Playwright, in CI | `cd e2e && npx playwright test` |
| Reply rules | `UserPromptSubmit` hook | `.claude/hooks/reply-rules.sh`, on every turn |
| Code conventions that need a reader | Convention audit | `/holocron-audit` on changed files before a pull request |

Rules with no gate: flourishes, a product acting like a person, claims, the teacher's voice,
reply shape beyond the hook, every design rule (no contrast test, by Julien's ruling), and the
rulings in `PRODUCT.md`.
