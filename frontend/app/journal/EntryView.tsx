import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useCallback } from "react";
import { useAnalysisEnd } from "~/journal/analysisSocket";
import { CorrectedText } from "~/journal/CorrectedText";
import { CorrectionList } from "~/journal/CorrectionList";
import { ENTRIES, ENTRY, type Entry, RETRY_ANALYSIS } from "~/journal/operations";

export function EntryView({ entryId }: { entryId: string }) {
  const { data, refetch } = useQuery<{ entry: Entry | null }>(ENTRY, {
    variables: { id: entryId },
  });
  const [retryAnalysis] = useMutation(RETRY_ANALYSIS, {
    variables: { entryId },
    refetchQueries: [ENTRIES],
  });

  const entry = data?.entry;
  const refetchAfterAnalysis = useCallback(() => {
    refetch();
  }, [refetch]);
  useAnalysisEnd(entryId, entry?.analysisStatus === "ANALYZING", refetchAfterAnalysis);

  if (!entry) return null;

  return (
    <Stack spacing={3}>
      <CorrectedText body={entry.body} corrections={entry.corrections} />
      {entry.analysisStatus === "ANALYZING" && (
        <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
          <CircularProgress size={24} />
          <Typography>Checking your entry</Typography>
        </Stack>
      )}
      {entry.analysisStatus === "ANALYSIS_FAILED" && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>We couldn't check this entry. Your text is saved. Try again.</Typography>
          <Button onClick={() => retryAnalysis()}>Try again</Button>
        </Stack>
      )}
      {entry.analysisStatus === "ANALYZED" && <CorrectionList corrections={entry.corrections} />}
    </Stack>
  );
}
