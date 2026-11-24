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
  teacherReaction: string | null;
  corrections: Correction[];
};

export type EntrySummary = Pick<Entry, "id" | "body" | "analysisStatus" | "insertedAt"> & {
  corrections: Pick<Correction, "id">[];
};

export type CategoryTrendDirection = "FEWER_LATELY" | "MORE_LATELY" | "STEADY" | "GONE_LATELY";

export type CategoryTrend = {
  category: CorrectionCategory;
  count: number;
  trend: CategoryTrendDirection | null;
};

export type CategoryTrends = {
  olderEntryCount: number;
  recentEntryCount: number;
  categories: CategoryTrend[];
};

export type PointOfInterest = { name: string; longitude: number; latitude: number };

export type Encounter = { id: string; afterPointOfInterestIndex: number; prompt: string };

export type RouteOnMap = {
  pointsOfInterest: PointOfInterest[];
  encounters: Pick<Encounter, "id" | "afterPointOfInterestIndex">[];
};

export type CurrentJourney = RouteOnMap & {
  id: string;
  openEncounter: Pick<Encounter, "id" | "prompt"> | null;
  nextPointOfInterestIndex: number | null;
};

export type EntryOnRoute = {
  id: string;
  pointOfInterestIndex: number | null;
  encounter: Pick<Encounter, "id"> | null;
  journey: RouteOnMap;
};

const ROUTE_ON_MAP = gql`
  fragment RouteOnMap on Journey {
    pointsOfInterest {
      name
      longitude
      latitude
    }
    encounters {
      id
      afterPointOfInterestIndex
    }
  }
`;

export const CURRENT_JOURNEY = gql`
  query CurrentJourney {
    currentJourney {
      id
      ...RouteOnMap
      openEncounter {
        id
        prompt
      }
      nextPointOfInterestIndex
    }
  }
  ${ROUTE_ON_MAP}
`;

export const ENTRY_ON_ROUTE = gql`
  query EntryOnRoute($id: ID!) {
    entry(id: $id) {
      id
      pointOfInterestIndex
      encounter {
        id
      }
      journey {
        id
        ...RouteOnMap
      }
    }
  }
  ${ROUTE_ON_MAP}
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
      teacherReaction
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

export const CATEGORY_TRENDS = gql`
  query CategoryTrends {
    categoryTrends {
      olderEntryCount
      recentEntryCount
      categories {
        category
        count
        trend
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
