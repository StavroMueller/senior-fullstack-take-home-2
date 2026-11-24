import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { type FormEvent, useState } from "react";
import { Link } from "react-router";
import { Buddy } from "~/journal/Buddy";
import { EntryHistory } from "~/journal/EntryHistory";
import { EntryView } from "~/journal/EntryView";
import { JourneyIntro } from "~/journal/JourneyIntro";
import {
  CURRENT_JOURNEY,
  type CurrentJourney,
  ENTRIES,
  ENTRY,
  type Entry,
  isAnalyzing,
  type Language,
  LANGUAGES,
  START_JOURNEY,
  SUBMIT_ENTRY,
  TRAVEL_ON,
} from "~/journal/operations";
import { WritingPrompt } from "~/journal/WritingPrompt";
import { palette, sizes } from "~/palette";

type SubmittedEntry = { submitEntry: { id: string } };

export function Logbook() {
  const { data: journeyData, loading } = useQuery<{ currentJourney: CurrentJourney | null }>(
    CURRENT_JOURNEY,
  );
  const [startJourney, { loading: startingJourney }] = useMutation(START_JOURNEY, {
    refetchQueries: [CURRENT_JOURNEY],
    awaitRefetchQueries: true,
  });
  const [submitEntry, { loading: submitting }] = useMutation<SubmittedEntry>(SUBMIT_ENTRY, {
    refetchQueries: [ENTRIES, CURRENT_JOURNEY],
  });
  const [travelOn, { loading: traveling }] = useMutation(TRAVEL_ON, {
    refetchQueries: [CURRENT_JOURNEY],
    awaitRefetchQueries: true,
  });
  const { data: languagesData } = useQuery<{ languages: Language[] }>(LANGUAGES);
  const [introSeenJourneyId, setIntroSeenJourneyId] = useState<string>();
  const [body, setBody] = useState("");
  const [submittedEntryId, setSubmittedEntryId] = useState<string>();
  const { data: submittedEntryData } = useQuery<{ entry: Entry | null }>(ENTRY, {
    variables: { id: submittedEntryId },
    skip: !submittedEntryId,
  });

  const journey = journeyData?.currentJourney;
  const currentPointOfInterestIndex = journey ? journey.currentPointOfInterestIndex : null;
  const finishedJourney = journey && currentPointOfInterestIndex === null ? journey : undefined;
  const submittedEntry = submittedEntryData?.entry;
  const analyzingSubmittedEntry =
    submittedEntryId !== undefined && (!submittedEntry || isAnalyzing(submittedEntry));
  const showIntro =
    journey?.intro &&
    currentPointOfInterestIndex === 0 &&
    !journey.openEncounter &&
    !journey.canTravelOn &&
    introSeenJourneyId !== journey.id;

  async function sendEntry(event: FormEvent) {
    event.preventDefault();
    const result = await submitEntry({
      variables: { input: { journeyId: journey?.id, body } },
    });
    setSubmittedEntryId(result.data?.submitEntry.id);
    setBody("");
  }

  async function keepGoing() {
    await travelOn({ variables: { journeyId: journey?.id } });
    setSubmittedEntryId(undefined);
  }

  async function startJourneyIn(language: Language) {
    await startJourney({ variables: { language: language.code, level: language.level } });
    setSubmittedEntryId(undefined);
  }

  const startButtons = (languagesData?.languages ?? []).map((language) => (
    <Button key={`${language.code}-${language.level}`} onClick={() => startJourneyIn(language)}>
      Start a journey in {language.country}
    </Button>
  ));

  const keepGoingButton = journey?.canTravelOn && (
    <Button disabled={analyzingSubmittedEntry || traveling} onClick={keepGoing}>
      Keep going
    </Button>
  );

  return (
    <Stack spacing={4}>
      <Stack direction="row" sx={{ justifyContent: "space-between", alignItems: "baseline" }}>
        <Typography variant="h1">Wayword</Typography>
        <Link to="/usual-suspects" style={{ color: palette.ink }}>
          Usual suspects
        </Link>
      </Stack>
      {startingJourney && <Buddy size={sizes.thinkingBuddy} expression="thinking" />}
      {!loading && !journey && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>No entries yet. Start a journey to write your first one.</Typography>
          {startButtons}
        </Stack>
      )}
      {submittedEntryId && <EntryView entryId={submittedEntryId} />}
      {submittedEntryId && (
        <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
          <Button onClick={() => setSubmittedEntryId(undefined)}>Write another entry</Button>
          {keepGoingButton}
          {traveling && <Buddy size={sizes.thinkingBuddy} expression="thinking" />}
        </Stack>
      )}
      {finishedJourney && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>
            You reached{" "}
            {finishedJourney.pointsOfInterest[finishedJourney.pointsOfInterest.length - 1].name},
            the end of this journey. Start a journey to keep writing.
          </Typography>
          {startButtons}
        </Stack>
      )}
      {journey && showIntro && journey.intro && (
        <JourneyIntro intro={journey.intro} onStart={() => setIntroSeenJourneyId(journey.id)} />
      )}
      {journey && currentPointOfInterestIndex !== null && !submittedEntryId && !showIntro && (
        <Stack component="form" spacing={2} onSubmit={sendEntry} sx={{ alignItems: "flex-start" }}>
          <WritingPrompt
            journey={journey}
            currentPointOfInterestIndex={currentPointOfInterestIndex}
            thinking={traveling}
          />
          <TextField
            label="Your entry"
            multiline
            minRows={6}
            fullWidth
            value={body}
            onChange={(event) => setBody(event.target.value)}
          />
          <Stack direction="row" spacing={2}>
            <Button type="submit" disabled={body.trim() === "" || submitting}>
              Send entry
            </Button>
            {keepGoingButton}
          </Stack>
        </Stack>
      )}
      <EntryHistory />
    </Stack>
  );
}
