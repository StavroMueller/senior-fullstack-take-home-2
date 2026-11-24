# Design system: Wayword

## 1. Overview

**North star: "An old map on one half of the screen, the logbook open on the other."**

The main screen splits in two. One half is a map from an open-source map library, restyled to
look like an old map, with the journey drawn across it. The other half is where the person
writes the entry and reads the corrections.

The feel is a pioneer trail game: a party moving
stop by stop across a map, with events along the way. Ruled by Julien, 2026-11-23.

Wayword is a tool in game clothes: every screen serves writing an entry and reading its
corrections, with one clear action per screen. The map, the teacher and the celebrations wrap
around that task and never block it. Ruled by Julien, 2026-11-23.

The system rejects Duolingo's brand, the corporate SaaS dashboard and cream journal pages, as
listed under "Anti-references" in `PRODUCT.md`.

## 2. Colors

Every value lives in `frontend/app/palette.ts`. Palette "Sky and tomato", ruled by Julien,
2026-11-23.

| Token | Value | Used for | Contrast measured 2026-11-23 |
| --- | --- | --- | --- |
| `ground` | `#E3F4FF` | Page ground, pale sky | |
| `ink` | `#1B1F3B` | Text, navy | 14.28 on `ground` |
| `action` | `#FF5A36` | The main action, tomato | 2.76 on `ground`; white text on it 3.10; `ink` on it 5.18 |
| `win` | `#FFC83D` | Celebrations, sunflower | `ink` on it 10.40 |
| `teacher` | `#7B4DFF` | The teacher's speech bubble, grape | white text on it 4.83; as text on `ground` 4.29 |
| `fix` | `#12A876` | Corrected text, green-teal | as text on `ground` 2.71; white text on it 3.05 |
| `error` | `#D7263D` | What the person wrote, red | as text on `ground` 4.40; white text on it 4.96 |

The ratios are a record from 2026-11-23 and nothing asserts them. Julien ruled accessibility out
of scope for the code challenge, so no contrast floor applies and no test recomputes these
numbers: `fix` at 2.71 and `teacher` at 4.29 as text on `ground` ship as they are. Ruled by
Julien, 2026-11-23.

### Named rules

**The No-Cream Rule.** No ground in the warm off-white band (cream, beige, sand, parchment,
ivory, bone, linen): lightness 0.84 to 0.97, chroma under 0.06, hue 40 to 100 in OKLCH. Ruled by
Julien, 2026-11-23.

**The Aged Map Exception.** The map half is exempt from The No-Cream Rule and looks like aged
parchment: brown, never cream. Its land color stays below lightness 0.84 in OKLCH, so it can
never drift into the cream band. Ruled by Julien, 2026-11-23.

| Token | Value | Used for | OKLCH, measured 2026-11-23 |
| --- | --- | --- | --- |
| `mapLand` | `#C8A46E` | Land on the map | L 0.739, C 0.083, h 77 |
| `mapInk` | `#8B6B3E` | Water at half opacity, shorelines, roads and place names on the map | L 0.549, C 0.074, h 75 |

The two hex values are defaults, not yet ruled on. The trail itself is drawn in `action`.

**The Hand-Drawn Map.** An SVG turbulence filter wobbles every line on the map canvas, so coasts,
roads and borders look inked by hand. The trail is a dashed line in `action` with round caps, and
place names are set in Noto Sans Italic, the italic face the OpenFreeMap glyph server offers.
Requested by Julien, 2026-11-23.

**The Traveler.** One marker in `action`, larger than a stop, with a pulsing ring and an `ink`
label, marks the current place: "You are here: {town}" on the journey screen, "Written here:
{town}" on an entry. When the journey moves on, the traveler walks along the trail to the next
place, so the move reads as travel. Stops are plain dots. Requested by Julien, 2026-11-23.

## 2a. Layout

**The Grid Rule.** Every screen is laid out on the MUI `Grid`. From the `md` breakpoint up, the map
and the logbook sit side by side, half each. Below `md` they stack, map on top, so a narrow
window still works. Desktop is the screen every layout is designed for first. Ruled by Julien,
2026-11-23; the breakpoint is a default, not yet ruled on.

## 3. Typography

| Face | Token | Job |
| --- | --- | --- |
| Fredoka | `fontDisplay` | Headings, buttons, the teacher's lines, celebrations |
| Atkinson Hyperlegible | `fontReading` | Entries, corrections, explanations, every other label |

Atkinson Hyperlegible sets every word a learner has to read closely, because its letterforms
keep similar letters apart. Both faces are free on Google Fonts and cover French accents. Ruled
by Julien, 2026-11-23.

## 4. Corners and depth

**The Pressed Button Rule.** Buttons and cards take a 16px radius, a 2px border and a solid
4px edge in a darker shade of their fill. A pressed button drops 2px and its edge shrinks to 2px.

**The No-Blur Rule.** No blurred shadow anywhere. Depth comes from the solid edge alone.

Julien first picked a soft radius with blurred shadows, then kept the "Bright, chunky and
rounded" principle in `PRODUCT.md` when the two were set side by side. Ruled by Julien,
2026-11-23.

## 7. Do and do not

**Do**

- Keep every color, face, size, radius and shadow as a token in one file. Components name
  tokens and never hold a literal.
- Give each typeface one job, reached through a token.
- Name each design rule Julien cares about, so review can cite it.
- Keep decoration only when it helps the person read or scan.
- Fix emphasis, scanning and density in the style sheet, never by rewriting copy.
- Treat `DESIGN.md` and `PRODUCT.md` as the authority over any feature spec and any tool's
  defaults.

All kept by Julien, 2026-11-23. Struck: a reduced-motion alternative for each animation, and a test
that recomputes contrast, both of which the no-scale rule does not pay for on a code challenge.

**Do not**

- Use a cream ground (The No-Cream Rule).
- Use a blurred shadow (The No-Blur Rule).
- Use gradients, glow or frosted glass. Color is flat.
- Use emoji as icons. Icons come from one icon set; a teacher line may still contain an emoji as
  text.
- Number sections, such as "01 · Write".
- Put a colored stripe down one edge of a card.

Banned by Julien, 2026-11-23. Not banned, by his choice: feeds and counters, and a hero with a
headline and two buttons. A few stat tiles for streak, points and entries are allowed; a grid of
equal number boxes for mistake categories is not.
