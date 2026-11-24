import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useCallback } from "react";
import { useAnalysisEnd } from "~/journal/analysisSocket";
import { Buddy } from "~/journal/Buddy";
import { CorrectedText } from "~/journal/CorrectedText";
import { CorrectionList } from "~/journal/CorrectionList";
import { analysisFailedMessage, analyzingMessage } from "~/journal/analysisCopy";
import {
  analysisFailed,
  ENTRIES,
  ENTRY,
  type Entry,
  isAnalyzed,
  isAnalyzing,
  RETRY_ANALYSIS,
} from "~/journal/operations";
import { TeacherReaction } from "~/journal/TeacherReaction";
import { sizes } from "~/palette";

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
  useAnalysisEnd(entryId, entry ? isAnalyzing(entry) : false, refetchAfterAnalysis);

  if (!entry) return null;

  return (
    <Stack spacing={3}>
      <CorrectedText body={entry.body} corrections={entry.corrections} />
      {isAnalyzing(entry) && (
        <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
          <Buddy size={sizes.thinkingBuddy} expression="thinking" />
          <Typography>{analyzingMessage}</Typography>
        </Stack>
      )}
      {analysisFailed(entry) && (
        <Stack spacing={2} sx={{ alignItems: "flex-start" }}>
          <Typography>{analysisFailedMessage}</Typography>
          <Button onClick={() => retryAnalysis()}>Try again</Button>
        </Stack>
      )}
      {entry.teacherReaction && <TeacherReaction reaction={entry.teacherReaction} />}
      {isAnalyzed(entry) && <CorrectionList corrections={entry.corrections} />}
    </Stack>
  );
}
