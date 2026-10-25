# NeNe Sand — Agent Guide

Short English entry point. The authoritative handbook is [CLAUDE.md](CLAUDE.md) (Japanese);
the normative documents live in [docs/](docs/).

## Project identity

- Product: NeNe Sand — a mouse-drawn falling-sand simulator for the terminal, with incremental-game progression
- Language / UI: Swift 6.4.1 / the terminal (ANSI). Sand, water, and oil draw and fall. Oil floats on water. `a` toggles automatic drawing, alternating sand, water, and oil on each stroke. Fire, wood, lava, reactions, progression, and save are not in this revision
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
