import { gql } from "@apollo/client";

export type AnalysisStatus = "ANALYZING" | "ANALYZED" | "ANALYSIS_FAILED";

export type CorrectionCategory =
  | "VERB_TENSE"
  | "VERB_AGREEMENT"
  | "GENDER"
  | "ADJECTIVE_AGREEMENT"
  | "ARTICLE"
  | "PREPOSITION"
  | "SPELLING"
  | "WORD_CHOICE";

export type Correction = {
  id: string;
  spanStart: number;
  spanEnd: number;
  original: string;
  fix: string;
  explanation: string;
  category: CorrectionCategory;
};

export type Entry = {
  id: string;
  body: string;
  analysisStatus: AnalysisStatus;
  insertedAt: string;
  teacherLine: string | null;
  corrections: Correction[];
};

export type EntrySummary = Pick<Entry, "id" | "body" | "analysisStatus" | "insertedAt"> & {
  corrections: Pick<Correction, "id">[];
};

export const CURRENT_JOURNEY = gql`
  query CurrentJourney {
    currentJourney {
      id
    }
  }
`;

export const START_JOURNEY = gql`
  mutation StartJourney {
    startJourney {
      id
    }
  }
`;

export const ENTRY = gql`
  query Entry($id: ID!) {
    entry(id: $id) {
      id
      body
      analysisStatus
      insertedAt
      teacherLine
      corrections {
        id
        spanStart
        spanEnd
        original
        fix
        explanation
        category
      }
    }
  }
`;

export const ENTRIES = gql`
  query Entries {
    entries {
      id
      body
      analysisStatus
      insertedAt
      corrections {
        id
      }
    }
  }
`;

export const SUBMIT_ENTRY = gql`
  mutation SubmitEntry($input: SubmitEntryInput!) {
    submitEntry(input: $input) {
      id
    }
  }
`;

export const RETRY_ANALYSIS = gql`
  mutation RetryAnalysis($entryId: ID!) {
    retryAnalysis(entryId: $entryId) {
      id
      analysisStatus
    }
  }
`;

export function isAnalyzing(entry: Pick<Entry, "analysisStatus">) {
  return entry.analysisStatus === "ANALYZING";
}

export function analysisFailed(entry: Pick<Entry, "analysisStatus">) {
  return entry.analysisStatus === "ANALYSIS_FAILED";
}

export function isAnalyzed(entry: Pick<Entry, "analysisStatus">) {
  return entry.analysisStatus === "ANALYZED";
}
