# NeNe Sand — Agent Guide

Short English entry point. The authoritative handbook is [CLAUDE.md](CLAUDE.md) (Japanese);
the normative documents live in [docs/](docs/).

## Project identity

- Product: NeNe Sand — a mouse-drawn falling-sand simulator for the terminal, with incremental-game progression
- Language / UI: Swift 6.4.1 / the terminal (ANSI). Sand, water, oil, fire, wood, and lava can be drawn. Oil floats on water. Fire rises through air and expires. Wood stays where it is placed. Fire and lava ignite orthogonal oil and wood, and water puts fire out. Lava flows on every other tick. Orthogonal water turns lava into stone, which falls and piles. After the first stone, `7` draws stone and the HUD shows that it is available. Right-click erases along the same stroke as drawing. `c` clears every grain and keeps the brush, automatic drawing, and the stone unlock. Space pauses physics and automatic drawing; the mouse can still draw and erase. `[` and `]` set a centered square brush of 1, 3, or 5 cells, used for drawing, erasing, and automatic drawing. `m` toggles free play, which draws stone before it has been made. `a` toggles automatic drawing, alternating the other materials on each stroke. Three English instrument rows sit above the field and three below: palette, brush gauge, mode lamps, status, a joke, and the key help. Below 76 columns the title drops and the keys split. `t` cycles twelve themes for the instrument and the grains. Water stays blue in every theme. The key line shows the current name. In progression the bottom-center cell is a collector: a grain sitting there is removed on the next tick and added to the purse, shown as `$` on the status line. Prices start at sand 1, water 2, stone 4, wood 8, oil 16, fire 0, lava 32. Free play does not collect. Currency and save are not in this revision
- Package root: `nene-sand` (composition module `NeNeSandApp`)
- Governing principle: **one meaning, one canonical implementation path, enforced by machines**

## Required reading before changing production code

1. `docs/ARCHITECTURE_CONSTITUTION.md`
2. `docs/PROJECT_LAYOUT.md`
3. `docs/CODING_RULES.md`
4. `docs/QUALITY_GATES.md`
5. `docs/DEVELOPMENT_WORKFLOW.md`
6. `docs/COMMIT_CONVENTIONS.md`
7. `docs/GLOSSARY.md`

Then the active issue, the relevant accepted ADRs, and any active waivers.

## Agent rules

- Do not invent a second implementation path because it is locally convenient.
- Do not weaken a gate to make a change pass. Fix the code instead.
- Do not mark a rule `active` in `docs/QUALITY_GATES.md` before its enforcement exists.
- Do not read the current time, randomness, locale, or environment outside `NeNeSandApp`.
- Do not write `default`, `case _`, or `@unknown default` over a closed set.
- Do not add suppressions, lint baselines, or tool exclusions without an active waiver.
- Do not claim a command passed unless it was actually executed.
- Do not add falling-sand behavior in the strictness-scaffold issue. That is a later issue.
- Prefer the smallest change that fully follows the canonical path.

## The only definition of done

```bash
make check
```

Local and CI run exactly this. Use narrow checks while iterating; run the full gate before
moving the PR from Draft to Ready.

## Required completion report

Issue and rule IDs, files and behavior changed, verification commands and results,
documentation or schema changes, active waiver IDs (or `none`), remaining risks.

Investigation-only requests do not authorize editing, committing, pushing, or opening PRs.
