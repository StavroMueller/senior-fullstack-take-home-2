import { expect, test } from "@playwright/test";

test("the journey screen shows the map of France beside the logbook", async ({
  page,
}) => {
  await page.goto("/");

  const journeyMap = page.getByRole("region", { name: "Journey map" });
  await expect(journeyMap.locator("canvas")).toBeVisible();
});

test("a person writes an entry, sees its corrections, and opens it again from history", async ({
  page,
}) => {
  await page.goto("/");

  const startJourney = page.getByRole("button", { name: "Start a journey" });
  const entryField = page.getByLabel("Your entry");
  await expect(startJourney.or(entryField)).toBeVisible();
  if (await startJourney.isVisible()) await startJourney.click();

  await expect(
    page.getByText("Write about today's stop. Three sentences is enough."),
  ).toBeVisible();
  await entryField.fill("Hier, j'ai allé à le marché.");
  await page.getByRole("button", { name: "Send entry" }).click();

  await expect(page.getByText("Verb tense")).toBeVisible();
  await expect(page.getByText("je suis allé")).toBeVisible();
  await expect(page.locator("mark", { hasText: "à le" })).toBeVisible();

  await page
    .getByRole("link", { name: /2 corrections/ })
    .first()
    .click();

  await expect(page).toHaveURL(/\/entries\/\d+$/);
  await expect(page.getByRole("heading", { name: "Your entry" })).toBeVisible();
  await expect(page.getByText("Preposition")).toBeVisible();
  await expect(page.locator("mark", { hasText: "j'ai allé" })).toBeVisible();

  await page.getByRole("link", { name: "Back to your entries" }).click();
  await expect(
    page.getByRole("heading", { name: "Your entries" }),
  ).toBeVisible();
});
