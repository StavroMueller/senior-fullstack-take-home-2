# Settle the info items from the entry flow audit

The convention audit of the entry flow pull request left six info items unfixed.

- `Backend.Journal.CorrectionParser` logs the whole dropped item, entry text included. A log line
  that names the reason and the category would carry no entry text.
- The Playwright journey reuses the dev database, so it clicks "Start a journey" only when no
  journey exists and opens the newest entry with `.first()`. A database reset before each run
  would make the spec independent of earlier runs.
- `AnalysisEvents.broadcast_analysis_ended/2` sends the entry id, and `EntryChannel` ignores it,
  because the topic already names the entry.
- The `PRODUCT.md` ruling "Submitting an entry returns at once and analysis runs after" says the
  job broadcasts on the `entry:<id>` channel. The job broadcasts on the `analysis:<id>` PubSub
  topic, and `EntryChannel` relays the event to the browser.
- The TypeScript unions for `AnalysisStatus` and `CorrectionCategory` in
  `frontend/app/journal/operations.ts` repeat the GraphQL enums by hand, because the frontend has
  no GraphQL code generation.
- The holocron checklist entry AP-01 says "Two mutations write the same row", which flags
  `submitEntry` and `retryAnalysis`, while `CLAUDE.md` rules "One mutation per operation". ST-03
  allows `changeset/2` in a schema, while `CLAUDE.md` says schemas hold no logic.
