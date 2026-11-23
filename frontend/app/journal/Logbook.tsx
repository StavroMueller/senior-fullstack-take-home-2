import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";

export function Logbook() {
  return (
    <Stack spacing={3}>
      <Typography variant="h1" sx={{ fontSize: "2.5rem" }}>
        Wayword
      </Typography>
      <Typography>Write about today's stop. Three sentences is enough.</Typography>
      <TextField label="Your entry" multiline minRows={6} fullWidth />
    </Stack>
  );
}
