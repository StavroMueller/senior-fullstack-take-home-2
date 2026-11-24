# Replace the stub AI provider with a real one

The assignment requires AI analysis of each entry. `Backend.Journal.AiProvider.Stub` returns
canned corrections for four phrases, so the requirement is unmet until a real adapter exists.

The option on the table is an OpenAI-compatible adapter in `backend/apps/journal/`. It reads the
base URL, key and model from the environment and points at a pinned free open-weight model on
OpenRouter. Groq, a local Ollama or Anthropic would work through the same environment. The stub
stays for tests and for running with no key, and `config :journal, :ai_provider` selects the
adapter.

The adapter meets `Backend.Journal.AiProvider`: `correct_entry(body, language, level)` returns
`{:ok, %{"corrections" => [...]}}`, and each item has `original`, `fix`, `explanation` and a
`category` from the eight `correction_category` values. The prompt must ask for corrections in
the order they appear in the text, because `CorrectionParser` searches forward and drops an item
that sits before the previous one. The prompt must also ask for `original` copied exactly from
the entry.

Before building it, Julien picks the provider and supplies a key. Then send one real request and
confirm `CorrectionParser.parse/2` keeps the corrections it returns.

## A reviewer runs this

Julien said on 2026-11-23 that he hands the repository to a reviewer, who clones it and runs it
on their own machine. The provider is picked for that reviewer: what they install, download and
sign up for before `docker compose up` shows a real correction.

## Ollama in Docker, measured 2026-11-23

Measured on an Apple M5 Pro with Docker Desktop given 8.3 GB. The `ollama/ollama` image
documents CPU, NVIDIA and AMD setups only, so a Mac runs the model on its CPU.

- `qwen2.5:7b` is a 4.7 GB download and holds 4.8 GB in memory. With a second model loaded,
  the server was killed for memory twice.
- `qwen2.5:7b` took 128 s on the first entry and 24 s warm. Two runs at temperature 0 differed.
  One run invented the categories `noun_agreement` and `no_correction` and returned a fix
  identical to its original.
- `qwen2.5:3b` took 14 s, marked whole sentences as one span, and changed the correct
  "mon amie" to "ma amie".

OpenRouter was not measured, because no key was available.

## OpenRouter prices, read 2026-11-23

Read from `https://openrouter.ai/api/v1/models`, which needs no key. Of 476 models, 408 accept
structured outputs. Cost assumes 450 input and 350 output tokens per entry, an estimate that no
request has measured, and reasoning tokens bill as output on top of that.

| Model | Cost per 1000 entries |
| --- | --- |
| `deepseek/deepseek-v4.1-flash-1017` | $0.08 |
| `openai/gpt-oss-120b` | $0.11 |
| `mistralai/ministral-8b-2512` | $0.12 |
| `anthropic/claude-haiku-5.5` | $0.22 |
| `openai/gpt-6-luna` | $0.22 |
| `mistralai/mistral-small-2603` | $0.28 |
| `google/gemini-3.5-flash` | $3.83 |
| `anthropic/claude-sonnet-5.5` | $4.40 |

The six free models that accept structured outputs come from smaller vendors, such as
`liquid/lfm-3-1.7b:free`. Price per entry is under one cent for every model above, so the pick
turns on correction quality, schema adherence and latency, and those need a key to measure.

## Keys

Julien ruled on 2026-11-23 that the repository never holds a key. The reviewer brings their
own OpenRouter key. Julien keeps one dedicated key with a credit cap for the benchmark and hands
it over outside the repository only if the reviewer asks.

`.env` is git-ignored, `.env.example` names `OPENROUTER_API_KEY` with no value, and compose
passes the key to `backend` as an empty string when `.env` is absent. The output of
`docker compose config` prints the key, so that output is never pasted anywhere.

The benchmark starts once `OPENROUTER_API_KEY` is set in `.env`: ten French A1 entries with
known errors through `anthropic/claude-haiku-5.5`, `openai/gpt-6-luna`,
`mistralai/mistral-small-2603`, `deepseek/deepseek-v4.1-flash-1017` and
`google/gemini-3.5-flash`.

## Benchmark, run 2026-11-23

Ten French A1 entries, nine with known errors and one with none, went to each model through
OpenRouter with `json_schema` in strict mode, `category` as an enum of the eight
`correction_category` values, `max_tokens: 2000` and `provider.require_parameters: true`.
No endpoint of `claude-haiku-5.5` or `gpt-6-luna` accepts `temperature`, so no request sent it.
Categories were judged by reading each correction.

| Model | Entries answered | Errors caught | Right category | Broken or false fixes | Median latency | Measured cost per 1000 entries |
| --- | --- | --- | --- | --- | --- | --- |
| `anthropic/claude-haiku-5.5` | 10 of 10 | 11 of 12 | 10 of 10 | 0 | 1.8 s | $0.15 |
| `mistralai/mistral-small-2603` | 10 of 10 | 12 of 12 | 10 of 11 | 1 | 0.8 s | $0.05 |
| `deepseek/deepseek-v4.1-flash-1017` | 10 of 10 | 12 of 12 | 6 of 11 | 0 | 2.3 s | $0.18 |
| `openai/gpt-6-luna` | 8 of 10 | 10 of 10 | 9 of 9 | 0 | 3.0 s | $0.08 |
| `google/gemini-3.5-flash` | 6 of 10 | 9 of 9 | 8 of 8 | 0 | 3.0 s | $6.66 |

- Gemini and Luna lost entries to the account's credit balance, which was zero, so their rows
  are incomplete.
- Haiku returned no correction for "Ma frère".
- Mistral turned "Je aime" into "J' aime" by replacing only "Je" with "J'".
- DeepSeek put "Je aime" under `article` and "Je suis faim" under `verb_tense`. Stage 2 counts
  categories, so a wrong category is a wrong count on "Usual suspects".
- No model flagged the entry that has no errors.
- `correction_category` has no value for noun number, so "trois chambre" landed in `spelling`,
  `adjective_agreement` or `verb_agreement` depending on the model.

## Decision

Julien picked `anthropic/claude-haiku-5.5` on 2026-11-23, from the benchmark above: every
category right, no broken fix, a median of 1.8 s and $0.15 per 1000 entries measured. The
adapter calls OpenRouter with the request shape the benchmark used.

## Built

`Backend.Journal.AiProvider.OpenRouter` is selected in `backend/config/runtime.exs` when
`OPENROUTER_API_KEY` is set outside the test environment. One entry submitted through the app
against `anthropic/claude-haiku-5.5` came back in 6.0 s with four corrections, each one marked in
the entry with its category and explanation. Julien ruled that the real provider gets no
automated test.

Left open:

- `CorrectionParser.validate/1` accepts a correction whose `fix` equals its `original`.
- `correction_category` has no value for noun number.
- A fix that only elides, such as "Je" to "J'", renders as "J' aime" with a space.
