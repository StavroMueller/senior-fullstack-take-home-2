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
