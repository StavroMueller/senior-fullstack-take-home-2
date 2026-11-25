import { gql } from "@apollo/client";

export type AnalysisStatus = "ANALYZING" | "ANALYZED" | "ANALYSIS_FAILED";

export type CorrectionCategory =
  | "VERB_TENSE"
  | "VERB_AGREEMENT"
  | "GENDER"
  | "ADJECTIVE_AGREEMENT"
  | "NOUN_NUMBER"
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

export type Journey = RouteOnMap & {
  id: string;
  entries: EntrySummary[];
  openEncounter: Pick<Encounter, "id"> | null;
  currentPointOfInterestIndex: number | null;
  canTravelOn: boolean;
  currentScene: string | null;
  intro: string | null;
};

export type EntryOnRoute = {
  id: string;
  pointOfInterestIndex: number | null;
  encounter: Pick<Encounter, "id"> | null;
  journey: RouteOnMap & { id: string };
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

export type JourneySummary = {
  id: string;
  country: string;
  insertedAt: string;
  pointsOfInterest: Pick<PointOfInterest, "name">[];
  currentPointOfInterestIndex: number | null;
  openEncounter: Pick<Encounter, "id"> | null;
  entries: Pick<Entry, "id">[];
};

export const JOURNEYS = gql`
  query Journeys {
    journeys {
      id
      country
      insertedAt
      pointsOfInterest {
        name
      }
      currentPointOfInterestIndex
      openEncounter {
        id
      }
      entries {
        id
      }
    }
  }
`;

export const JOURNEY = gql`
  query Journey($id: ID!) {
    journey(id: $id) {
      id
      ...RouteOnMap
      entries {
        id
        body
        analysisStatus
        insertedAt
        corrections {
          id
        }
      }
      openEncounter {
        id
      }
      currentPointOfInterestIndex
      canTravelOn
      currentScene
      intro
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

export type Language = { code: string; level: string; country: string };

export const LANGUAGES = gql`
  query Languages {
    languages {
      code
      level
      country
    }
  }
`;

export const START_JOURNEY = gql`
  mutation StartJourney($language: String!, $level: String!) {
    startJourney(language: $language, level: $level) {
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

export const TRAVEL_ON = gql`
  mutation TravelOn($journeyId: ID!) {
    travelOn(journeyId: $journeyId) {
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

type RouteNames = { pointsOfInterest: Pick<PointOfInterest, "name">[] };

export function isFinished(
  currentPointOfInterestIndex: number | null,
): currentPointOfInterestIndex is null {
  return currentPointOfInterestIndex === null;
}

export function lastTown(journey: RouteNames) {
  return journey.pointsOfInterest[journey.pointsOfInterest.length - 1].name;
}

export function routePositionName(
  journey: RouteNames & { openEncounter: Pick<Encounter, "id"> | null },
  currentPointOfInterestIndex: number,
) {
  return journey.openEncounter
    ? `On the road to ${journey.pointsOfInterest[currentPointOfInterestIndex + 1].name}`
    : journey.pointsOfInterest[currentPointOfInterestIndex].name;
}
