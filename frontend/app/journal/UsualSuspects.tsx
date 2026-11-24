import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { categoryLabels } from "~/journal/categoryLabels";
import type { CategoryTrendDirection, CategoryTrends } from "~/journal/operations";
import { TeacherReaction } from "~/journal/TeacherReaction";
import { palette } from "~/palette";

const trendLabels: Record<CategoryTrendDirection, string> = {
  FEWER_LATELY: "fewer lately",
  MORE_LATELY: "more lately",
  STEADY: "steady",
  GONE_LATELY: "gone lately",
};

const trendColors: Record<CategoryTrendDirection, string> = {
  FEWER_LATELY: palette.fix,
  MORE_LATELY: palette.error,
  STEADY: palette.ink,
  GONE_LATELY: palette.fix,
};

function timesLabel(count: number) {
  return count === 1 ? "1 time" : `${count} times`;
}

function entriesLabel(count: number) {
  return count === 1 ? "1 entry" : `${count} entries`;
}

function comparisonNote(categoryTrends: CategoryTrends) {
  if (categoryTrends.olderEntryCount === 0) {
    return "Trends show up once two entries are analyzed.";
  }
  return `Comparing your older ${entriesLabel(categoryTrends.olderEntryCount)} with your recent ${entriesLabel(categoryTrends.recentEntryCount)}.`;
}

export function UsualSuspects({ categoryTrends }: { categoryTrends: CategoryTrends }) {
  const [mostFrequent] = categoryTrends.categories;

  if (!mostFrequent) {
    return (
      <Typography>
        No corrections yet. Write an entry and the usual suspects show up here.
      </Typography>
    );
  }

  return (
    <Stack spacing={3}>
      <TeacherReaction
        reaction={`${categoryLabels[mostFrequent.category]} keeps tripping you up.`}
      />
      <Stack component="ul" spacing={2} sx={{ listStyle: "none", padding: 0, margin: 0 }}>
        {categoryTrends.categories.map((categoryTrend) => (
          <Paper
            component="li"
            key={categoryTrend.category}
            sx={{ padding: 2, display: "flex", justifyContent: "space-between", gap: 2 }}
          >
            <Typography variant="overline" component="span">
              {categoryLabels[categoryTrend.category]}
            </Typography>
            <Stack direction="row" spacing={2}>
              <Typography component="span">{timesLabel(categoryTrend.count)}</Typography>
              {categoryTrend.trend && (
                <Typography component="span" sx={{ color: trendColors[categoryTrend.trend] }}>
                  {trendLabels[categoryTrend.trend]}
                </Typography>
              )}
            </Stack>
          </Paper>
        ))}
      </Stack>
      <Typography>{comparisonNote(categoryTrends)}</Typography>
    </Stack>
  );
}
