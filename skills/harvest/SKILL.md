---
name: Harvest
description: Extract generalizable knowledge learned during a session into the multivac knowledge repo, so it reaches every future project. Use when the user says "harvest this", "save this lesson", "add to multivac", or when a session resolves a gotcha, convention, or tool preference that applies beyond the current repo.
---

# Harvest

## When to use

A session just learned something general: a gotcha that will recur, a tool
preference, a convention worth keeping, a methodology that worked. If it
only matters to this repo, it belongs in this repo's AGENTS.md. If it
applies across projects, it belongs in multivac.

## Workflow

1. Locate the multivac clone. Check `~/.agents/skills/multivac` for the
   symlink target, or `~/.local/share/multivac`. Ask the user if neither
   exists.
2. Read `references/harvest-guide.md` and decide placement: a new knowledge
   file, an update to an existing one, or a skill change.
3. Write in Simplified Technical English. Credit borrowed ideas with a
   link.
4. Keep skills thin. If a change pushes a `SKILL.md` past 40 lines, move
   the depth into that skill's `references/`.
5. Commit to the multivac clone. Follow the repo's authority profile —
   default conservative: propose the commit and wait for approval.

## Gotchas

- Harvest the lesson, not the story. Drop session context; keep the rule.
- Do not duplicate. Search `knowledge/` and the skills first. Extend the
  existing file instead of creating a near-copy.
- A prevention stronger than a note is better: suggest a lint rule, gate,
  or script when one fits.
