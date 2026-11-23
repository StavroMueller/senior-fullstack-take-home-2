# Replace the stub AI provider with a real one

The assignment requires AI analysis of each entry. The stub returns canned corrections, so the
requirement is unmet until a real adapter exists.

The option on the table: an OpenAI-compatible adapter in `backend/apps/journal/` that reads base
URL, key and model from the environment, pointed at a pinned free open-weight model on
OpenRouter. Groq or a local Ollama would work by changing the environment. The stub stays for
tests and for running with no key set.

Before building it, send one real request with the chosen model and confirm it returns
corrections in the JSON shape the parser expects.
