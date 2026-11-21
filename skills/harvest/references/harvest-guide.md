# Harvest guide

Where knowledge lives in multivac, and how to add it.

## Placement map

| The lesson is... | It goes... |
| --- | --- |
| Owned by one skill's topic (concept rules, Python toolchain, STE rules, render recipes, session protocol) | Into that skill's `references/` file. Update the canon, not the entry point. |
| Cross-cutting process canon (quality gates, agent authority, mistake log, prose pipeline, design tokens, static-site battery) | Into `knowledge/<topic>.md` at the repo root. |
| A repeatable task the agent should discover by description | A new skill folder: thin `SKILL.md` + `references/`. |
| A deterministic check | A `scripts/` file inside the owning skill. |
| A shared command-line tool useful in several projects | `tools/` in this repo, linked into `~/.local/bin` by the installer, and exposed as an `mvac` subcommand when it fits. |

Skill canon lives inside each skill's `references/` so every skill folder is
self-contained and portable on its own. `knowledge/` holds canon no single
skill owns.

## Knowledge file template

```markdown
# <Topic>

<One paragraph: what this is and when to apply it.>

## Rules or setup

<The content. Simplified Technical English:
short sentences, active voice, one instruction per sentence.>

## Provenance

<Which projects or sources this was harvested from.>
```

## Before you write

1. Search the repo for the topic. `grep -ri "<keyword>" knowledge/ skills/`.
2. If a file exists, extend it. Keep the existing structure.
3. If two files overlap after your change, merge them and leave a pointer.

## Skill quality bar

- `SKILL.md` under 40 lines: when-to-use, workflow, gotchas, pointers.
- `description` frontmatter specific enough to fire on the right requests
  and not on everything.
- Depth in `references/`. Deterministic actions in `scripts/`.
- Lowercase kebab-case ID matching the directory name.

## After you write

- Commit with a conventional message (subject states the topic, not the
  session).
- The symlink and config entry already point at the clone, so other
  machines pick it up on the next `git pull`. Mention this to the user.
