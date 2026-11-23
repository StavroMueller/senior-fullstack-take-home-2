import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { type FormEvent, useState } from "react";
import { EntryHistory } from "~/journal/EntryHistory";
import { EntryView } from "~/journal/EntryView";
import { CURRENT_JOURNEY, ENTRIES, START_JOURNEY, SUBMIT_ENTRY } from "~/journal/operations";

type CurrentJourney = { currentJourney: { id: string } | null };
type SubmittedEntry = { submitEntry: { id: string } };

export function Logbook() {
  const { data: journeyData, loading } = useQuery<CurrentJourney>(CURRENT_JOURNEY);
  const [startJourney] = useMutation(START_JOURNEY, { refetchQueries: [CURRENT_JOURNEY] });
  const [submitEntry, { loading: submitting }] = useMutation<SubmittedEntry>(SUBMIT_ENTRY, {
    refetchQueries: [ENTRIES],
  });
  const [body, setBody] = useState("");
  const [submittedEntryId, setSubmittedEntryId] = useState<string>();

  const journey = journeyData?.currentJourney;

  async function sendEntry(event: FormEvent) {
    event.preventDefault();
    const result = await submitEntry({
      variables: { input: { journeyId: journey?.id, body } },
    });
    setSubmittedEntryId(result.data?.submitEntry.id);
    setBody("");
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
      {journey && submittedEntryId && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <EntryView entryId={submittedEntryId} />
          <Button onClick={() => setSubmittedEntryId(undefined)}>Write another entry</Button>
        </Stack>
      )}
      {journey && !submittedEntryId && (
        <Stack component="form" spacing={2} onSubmit={sendEntry} sx={{ alignItems: "flex-start" }}>
          <Typography>Write about today's stop. Three sentences is enough.</Typography>
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
