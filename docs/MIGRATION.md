# Migrating to another harness

These skills follow open conventions so they transfer without a rewrite.

## The formats

- **`SKILL.md` folders.** Each skill is a directory with a `SKILL.md` that has
  `name` and `description` frontmatter, plus optional `references/` and
  `scripts/`. This is the folder convention used across OpenCode V2,
  Claude Code, and tools that read the `.agents/skills` location.
- **`AGENTS.md`.** Repo-level agent instructions in the cross-tool standard
  (agentsmd), not a tool-proprietary file.
- **No harness-specific config in the skills themselves.** Skills declare no
  permissions, tools, or plugin APIs. They are instructions plus scripts.

## Where harnesses look

| Harness | Global skill discovery |
| --- | --- |
| OpenCode V2 | `~/.config/opencode/skills`, `~/.claude/skills`, `~/.agents/skills`, plus explicit `skills` config entries |
| Claude Code | `~/.claude/skills` (global), `.claude/skills` (project) |
| Others (Codex, Cursor, Gemini CLI family) | Varies. Most read `SKILL.md` folders or `~/.agents/skills`. Check the tool's current docs. |

## To move

1. Clone or copy this repo anywhere stable.
2. Symlink `skills/` into the discovery location your harness reads:

   ```bash
   ln -sfn /path/to/multivac/skills ~/.claude/skills/multivac
   ```

3. If the harness has no global skills discovery, symlink individual skills
   into a project's skills directory. Each skill folder is self-contained.

## Limits

- `install.sh` edits `~/.config/opencode/opencode.json` — OpenCode-specific.
  The knowledge and skills are not.
- Skill *loading* semantics differ by harness (progressive disclosure,
  token budgets, invocation syntax). The content needs no change.
