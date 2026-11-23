import { expect, test } from "@playwright/test";

test("the journey screen shows the map of France beside the logbook", async ({ page }) => {
  await page.goto("/");

  const journeyMap = page.getByRole("region", { name: "Journey map" });
  await expect(journeyMap.locator("canvas")).toBeVisible();
  await expect(page.getByText("Write about today's stop. Three sentences is enough.")).toBeVisible();
  await page.getByLabel("Your entry").fill("Je suis à Lyon.");
  await expect(page.getByLabel("Your entry")).toHaveValue("Je suis à Lyon.");
});
