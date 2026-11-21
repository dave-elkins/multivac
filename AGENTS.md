# Multivac

Personal agent knowledge core for Dave Elkins. Skills and knowledge that apply
across all coding and writing projects.

## Layout

- `skills/` — thin `SKILL.md` entry points. Each skill folder carries its own
  `references/` and `scripts/`.
- `knowledge/` — thick canonical knowledge harvested from projects. See
  `knowledge/README.md` for the index. Some canon lives inside a skill's
  `references/` when that skill owns the topic.
- `docs/MIGRATION.md` — how to point another harness at these skills.
- `install.sh` — idempotent installer. Reads `MULTIVAC_HOME` and
  `MULTIVAC_REPO` from the environment.

## Rules for editing this repo

- Keep every `SKILL.md` under 40 lines. Put depth in `references/`. Put
  deterministic actions in `scripts/`.
- State gotchas, not generic advice. Do not restate what the model already
  knows.
- Make the `description` frontmatter specific enough to trigger without
  over-firing. It costs tokens on every scan.
- Skill IDs are lowercase kebab-case and match the directory name.
- Write knowledge files in Simplified Technical English. Short sentences.
  Active voice. One instruction per sentence.
- When you borrow an idea from an external source, credit the source in the
  file. Add a link.
- Never commit a secret. The installer backs up user config before it edits.

## Harvest workflow

When a session learns something general — a gotcha, a convention, a tool
preference, a methodology — extract it into this repo with the `harvest` skill.
Knowledge that accumulates here survives the session. Knowledge left in chat
does not.
