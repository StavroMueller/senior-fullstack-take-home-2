import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import { palette, sizes } from "~/palette";

export function TeacherLine({ line }: { line: string }) {
  return (
    <Paper
      component="aside"
      aria-label="Your teacher"
      sx={{
        padding: 2,
        backgroundColor: palette.teacher,
        borderColor: palette.teacherEdge,
        boxShadow: `0 ${sizes.edgeHeight}px 0 ${palette.teacherEdge}`,
      }}
    >
      <Typography variant="h2" component="p" sx={{ color: palette.surface }}>
        {line}
      </Typography>
    </Paper>
  );
}
