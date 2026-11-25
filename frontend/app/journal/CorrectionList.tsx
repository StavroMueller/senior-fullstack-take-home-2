import Box from "@mui/material/Box";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { categoryLabels } from "~/journal/categoryLabels";
import type { Correction } from "~/journal/operations";
import { palette } from "~/palette";

export function CorrectionChange({
  correction,
}: {
  correction: Pick<Correction, "original" | "fix">;
}) {
  return (
    <Typography>
      <Box component="del" sx={{ color: palette.error }}>
        {correction.original}
      </Box>
      {" → "}
      <Box component="ins" sx={{ color: palette.fix, fontWeight: 700, textDecoration: "none" }}>
        {correction.fix}
      </Box>
    </Typography>
  );
}

export function CorrectionList({ corrections }: { corrections: Correction[] }) {
  if (corrections.length === 0) {
    return <Typography>No corrections for this entry.</Typography>;
  }

  return (
    <Stack component="ol" spacing={2} sx={{ listStyle: "none", padding: 0, margin: 0 }}>
      {corrections.map((correction) => (
        <Paper component="li" key={correction.id} sx={{ padding: 2 }}>
          <Typography variant="overline">{categoryLabels[correction.category]}</Typography>
          <CorrectionChange correction={correction} />
          <Typography>{correction.explanation}</Typography>
        </Paper>
      ))}
    </Stack>
  );
}
