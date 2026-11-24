import { expect, test } from "@playwright/test";

test("the journey screen shows the map of France beside the logbook", async ({
  page,
}) => {
  await page.goto("/");

  const journeyMap = page.getByRole("region", { name: "Journey map" });
  await expect(journeyMap.locator("canvas")).toBeVisible();
});

test("a person writes an entry, sees its corrections, opens it again from history and finds its category among the usual suspects", async ({
  page,
}) => {
  await page.goto("/");

  await page.getByRole("button", { name: "Start a journey" }).click();
  await page.getByRole("button", { name: "Let's go" }).click();

  const journeyMap = page.getByRole("region", { name: "Journey map" });
  await expect(journeyMap.getByRole("img").first()).toBeVisible();
  expect(await journeyMap.getByRole("img").count()).toBeGreaterThanOrEqual(5);

  const entryField = page.getByLabel("Your entry");
  await entryField.fill("Hier, j'ai allé à le marché.");
  await page.getByRole("button", { name: "Send entry" }).click();

  await expect(page.getByText("Verb tense", { exact: true })).toBeVisible();
  await expect(page.getByText("je suis allé")).toBeVisible();
  await expect(page.locator("mark", { hasText: "à le" })).toBeVisible();
  await expect(
    page.getByRole("complementary", { name: "Your teacher" }),
  ).toContainText("2 corrections");

  const keepGoing = page.getByRole("button", { name: "Keep going" });
  await expect(keepGoing).toBeEnabled();
  await keepGoing.click();
  await expect(entryField).toBeVisible();

  await page.getByRole("link", { name: /2 corrections/ }).click();

  await expect(page).toHaveURL(/\/entries\/\d+$/);
  await expect(page.getByRole("heading", { name: "Your entry" })).toBeVisible();
  await expect(
    page.getByRole("region", { name: "Journey map" }).getByRole("img").first(),
  ).toBeVisible();
  await expect(page.getByText("Preposition", { exact: true })).toBeVisible();
  await expect(page.locator("mark", { hasText: "j'ai allé" })).toBeVisible();
  await expect(
    page.getByRole("complementary", { name: "Your teacher" }),
  ).toContainText("verb tense");

  await page.getByRole("link", { name: "Back to your entries" }).click();
  await expect(
    page.getByRole("heading", { name: "Your entries" }),
  ).toBeVisible();

  const mapCanvas = page
    .getByRole("region", { name: "Journey map" })
    .locator("canvas");
  await mapCanvas.evaluate((canvas) => {
    canvas.dataset.drawnBeforeNavigation = "true";
  });

  await page.getByRole("link", { name: /Usual suspects/ }).click();
  await expect(page).toHaveURL(/\/usual-suspects$/);
  await expect(mapCanvas).toHaveAttribute(
    "data-drawn-before-navigation",
    "true",
  );
  await expect(
    page.getByRole("heading", { name: "Usual suspects" }),
  ).toBeVisible();
  await expect(
    page.getByRole("listitem").filter({ hasText: "Verb tense" }),
  ).toContainText(/\d+ times?/);
  await expect(
    page.getByRole("complementary", { name: "Your teacher" }),
  ).toContainText("keeps tripping you up.");
});
