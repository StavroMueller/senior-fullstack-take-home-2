import type { CorrectionCategory } from "~/journal/operations";

export const categoryLabels: Record<CorrectionCategory, string> = {
  VERB_TENSE: "Verb tense",
  VERB_AGREEMENT: "Verb agreement",
  GENDER: "Gender",
  ADJECTIVE_AGREEMENT: "Adjective agreement",
  ARTICLE: "Article",
  PREPOSITION: "Preposition",
  SPELLING: "Spelling and accents",
  WORD_CHOICE: "Word choice",
};
