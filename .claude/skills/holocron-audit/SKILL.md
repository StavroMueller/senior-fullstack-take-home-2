---
name: holocron-audit
description: Audit code for violations of this project's coding conventions. Use when the user says "holocron", "holocron audit", "audit", "check conventions", "review patterns", "lint architecture", "check code quality", or wants to verify that new or changed code follows the project's patterns. Checks naming, comments, defensive code, structure, API shape, permissions, tests, migrations, security and idioms borrowed from another language. Works on one file, a directory, recent changes or the whole codebase.
metadata:
  version: 1.0.0
---

# Convention auditor

You audit code against the conventions this project wrote down. `CLAUDE.md` is the authority.

`conventions.md`, beside this file, is the checklist: one entry per convention, each with an id, a
severity and what a violation looks like. The `house-rules` skill writes that checklist from the
owner's answers.

A linter checks what a pattern can match. This audit checks what needs a reader: a name that
lies, a rule written twice, logic in the wrong layer.

## Invocation

- `/holocron-audit`: recent changes, meaning uncommitted work plus the last three commits.
- `/holocron-audit path/to/file`: one file.
- `/holocron-audit path/to/directory/`: one directory.
- `/holocron-audit --full`: the whole codebase, one agent per top-level source directory.

## Process

1. **Set the scope.** With no argument, use `git diff --name-only HEAD~3` plus
   `git diff --name-only`. Skip generated files, lockfiles and vendored code.
2. **Read `CLAUDE.md` in full.** Where `CLAUDE.md` and the checklist disagree, `CLAUDE.md` wins,
   and the disagreement is a separate finding: name the stale checklist entry.
3. **Read `conventions.md`.** Skip a section whose condition is false for this project.
4. **Run the project's linter on the scope first** and keep the output. Do not report by hand
   what the linter already reports.
5. **Read every file in scope against every entry.** For each violation record the file and
   line, the convention id, the severity, what is wrong and the fix.
6. **Report every finding.** Group by severity, then by section of the checklist. Never trim the
   list to a shortlist: what to fix is the owner's call. A recommendation, when you have one,
   comes after the full list.

Do not fix anything during an audit. The audit reports, and the owner picks.

## Severity

- **ERROR:** breaks a guarantee the codebase relies on, such as a permission check missing from
  an entry point.
- **WARN:** departs from a convention.
- **INFO:** a style point.

## Report format

```
# Convention audit

**Scope:** {what was audited}
**Files read:** {count}
**Findings:** {errors} errors, {warnings} warnings, {info} info

## Errors

### {file_path}:{line}
**{ID}**: {convention name}
{What is wrong}
**Fix:** {what to change}

## Warnings

## Info

## Stale checklist entries

{Each entry that disagrees with CLAUDE.md, with both texts}
```

With no violations, report: "No convention violations found. {N} files read."

## Keeping the checklist current

When the owner states a new code rule, `house-rules` in record mode writes the rule to
`CLAUDE.md` and adds an entry here with the next free id. An entry that `CLAUDE.md` no longer
supports is deleted in the same change.
