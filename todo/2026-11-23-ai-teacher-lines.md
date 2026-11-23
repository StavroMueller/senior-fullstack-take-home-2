# Consider AI-written teacher lines

Julien expects the teacher's lines to come from the AI once the correction call has proved
reliable. Until he rules on it, the ruling "AI corrects entries and does nothing else" in
`PRODUCT.md` stands, and teacher lines come from hand-written strings.

Reversing that ruling would change three things:

- The ruling itself and the "Characters react" design principle in `PRODUCT.md`.
- The AI response shape, which would carry a teacher line beside the corrections, plus a
  hand-written fallback when the line fails validation.
- The tests that pin teacher lines to a seed, which stop being deterministic.

Start once the real AI provider from `todo/2026-11-23-real-ai-provider.md` returns valid
corrections reliably.
