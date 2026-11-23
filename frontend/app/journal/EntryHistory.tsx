import { useQuery } from "@apollo/client";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { Link } from "react-router";
import { ENTRIES, type EntrySummary } from "~/journal/operations";
import { palette } from "~/palette";

const entryDate = new Intl.DateTimeFormat("en-US", { month: "short", day: "numeric" });

function analysisSummary(entry: EntrySummary) {
  if (entry.analysisStatus === "ANALYZING") return "Checking your entry";
  if (entry.analysisStatus === "ANALYSIS_FAILED") return "We couldn't check this entry.";
  const count = entry.corrections.length;
  return count === 1 ? "1 correction" : `${count} corrections`;
}

export function EntryHistory() {
  const { data } = useQuery<{ entries: EntrySummary[] }>(ENTRIES);
  const entries = data?.entries ?? [];

  if (entries.length === 0) return null;

  return (
    <Stack spacing={2}>
      <Typography variant="h2" sx={{ fontSize: "1.5rem" }}>
        Your entries
      </Typography>
      <Stack component="ul" spacing={2} sx={{ listStyle: "none", padding: 0, margin: 0 }}>
        {entries.map((entry) => (
          <Paper component="li" key={entry.id} sx={{ padding: 2 }}>
            <Link to={`/entries/${entry.id}`} style={{ color: palette.ink }}>
              {entryDate.format(new Date(entry.insertedAt))}: {analysisSummary(entry)}
            </Link>
            <Typography noWrap>{entry.body}</Typography>
          </Paper>
        ))}
      </Stack>
    </Stack>
  );
}
