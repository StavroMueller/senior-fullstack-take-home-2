import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { type FormEvent, useState } from "react";
import { EntryHistory } from "~/journal/EntryHistory";
import { EntryView } from "~/journal/EntryView";
import {
  CURRENT_JOURNEY,
  type CurrentJourney,
  ENTRIES,
  START_JOURNEY,
  SUBMIT_ENTRY,
} from "~/journal/operations";
import { WritingPrompt } from "~/journal/WritingPrompt";

type SubmittedEntry = { submitEntry: { id: string } };

export function Logbook() {
  const { data: journeyData, loading } = useQuery<{ currentJourney: CurrentJourney | null }>(
    CURRENT_JOURNEY,
  );
  const [startJourney] = useMutation(START_JOURNEY, { refetchQueries: [CURRENT_JOURNEY] });
  const [submitEntry, { loading: submitting }] = useMutation<SubmittedEntry>(SUBMIT_ENTRY, {
    refetchQueries: [ENTRIES, CURRENT_JOURNEY],
  });
  const [body, setBody] = useState("");
  const [submittedEntryId, setSubmittedEntryId] = useState<string>();

  const journey = journeyData?.currentJourney;
  const nextPointOfInterestIndex = journey ? journey.nextPointOfInterestIndex : null;
  const finishedJourney = journey && nextPointOfInterestIndex === null ? journey : undefined;

  async function sendEntry(event: FormEvent) {
    event.preventDefault();
    const result = await submitEntry({
      variables: { input: { journeyId: journey?.id, body } },
    });
    setSubmittedEntryId(result.data?.submitEntry.id);
    setBody("");
  }

  async function startNextJourney() {
    await startJourney();
    setSubmittedEntryId(undefined);
  }

  return (
    <Stack spacing={4}>
      <Typography variant="h1">Wayword</Typography>
      {!loading && !journey && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>No entries yet. Start a journey to write your first one.</Typography>
          <Button onClick={() => startJourney()}>Start a journey</Button>
        </Stack>
      )}
      {submittedEntryId && <EntryView entryId={submittedEntryId} />}
      {submittedEntryId && journey && nextPointOfInterestIndex !== null && (
        <Button sx={{ alignSelf: "flex-start" }} onClick={() => setSubmittedEntryId(undefined)}>
          Write another entry
        </Button>
      )}
      {finishedJourney && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>
            You reached{" "}
            {finishedJourney.pointsOfInterest[finishedJourney.pointsOfInterest.length - 1].name},
            the end of this journey. Start a journey to keep writing.
          </Typography>
          <Button onClick={startNextJourney}>Start a journey</Button>
        </Stack>
      )}
      {journey && nextPointOfInterestIndex !== null && !submittedEntryId && (
        <Stack component="form" spacing={2} onSubmit={sendEntry} sx={{ alignItems: "flex-start" }}>
          <WritingPrompt journey={journey} nextPointOfInterestIndex={nextPointOfInterestIndex} />
          <TextField
            label="Your entry"
            multiline
            minRows={6}
            fullWidth
            value={body}
            onChange={(event) => setBody(event.target.value)}
          />
          <Button type="submit" disabled={body.trim() === "" || submitting}>
            Send entry
          </Button>
        </Stack>
      )}
      <EntryHistory />
    </Stack>
  );
}
