import { useMutation, useQuery } from "@apollo/client";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import { useNavigate } from "react-router";
import { Buddy } from "~/journal/Buddy";
import { JOURNEYS, type Language, LANGUAGES, START_JOURNEY } from "~/journal/operations";
import { sizes } from "~/palette";

type StartedJourney = { startJourney: { id: string } };

export function StartJourneyButtons() {
  const navigate = useNavigate();
  const { data } = useQuery<{ languages: Language[] }>(LANGUAGES);
  const [startJourney, { loading: startingJourney }] = useMutation<StartedJourney>(START_JOURNEY, {
    refetchQueries: [JOURNEYS],
  });

  async function startJourneyIn(language: Language) {
    const result = await startJourney({
      variables: { language: language.code, level: language.level },
    });
    if (result.data) navigate(`/journeys/${result.data.startJourney.id}`);
  }

  return (
    <Stack direction="row" spacing={2} sx={{ alignItems: "center", flexWrap: "wrap" }}>
      {(data?.languages ?? []).map((language) => (
        <Button
          key={`${language.code}-${language.level}`}
          disabled={startingJourney}
          onClick={() => startJourneyIn(language)}
        >
          Start a journey in {language.country}
        </Button>
      ))}
      {startingJourney && <Buddy size={sizes.thinkingBuddy} expression="thinking" />}
    </Stack>
  );
}
