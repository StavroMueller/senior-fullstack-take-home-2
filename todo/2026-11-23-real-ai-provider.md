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
