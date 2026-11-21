# multivac

> "INSUFFICIENT DATA FOR A MEANINGFUL ANSWER."
> — Multivac, Isaac Asimov, *The Last Question*

A personal agent knowledge core. One repo holds the skills and knowledge that
apply across every coding and writing project, and one script installs them
into your agent harness. Currently targeting **OpenCode V2**, built on open
standards (`SKILL.md` folders, `AGENTS.md`, the `~/.agents/skills` discovery
location) so it moves to another harness later without a rewrite.

The name follows the mission: Multivac is Asimov's machine that accumulates
knowledge across every human project and answers questions from all of it.
This repo is that, for one person's work.

## Install

```bash
git clone https://github.com/dave-elkins/multivac.git
cd multivac && ./install.sh
```

One line, once the repo exists on a machine (or after a manual clone):

```bash
MULTIVAC_HOME=~/code/multivac ./install.sh
```

What the installer does:

1. Clones or updates the repo at `~/.local/share/multivac`
   (override with `MULTIVAC_HOME` — running `./install.sh` from inside a
   checkout makes that checkout the home, no duplicate clone).
2. Symlinks `skills/` into `~/.agents/skills/multivac` — the open-standard
   location that OpenCode V2 discovers globally.
3. Adds the skills path to `~/.config/opencode/opencode.json`, backing up the
   file first. Nothing existing is removed.
4. Links the `mvac` CLI and `sentencefmt` into `~/.local/bin`.

Safe to re-run. Update with `./install.sh` (it pulls and re-verifies).
Check health with `./install.sh --doctor`. Remove with
`./install.sh --uninstall` (add `--purge` to also delete the clone).

## Fresh-machine bootstrap

`./install.sh --bootstrap` runs the standard install, then installs the
working toolchain. Missing tools only — anything already present is left
alone. `sudo` prompts for system packages. Preview without installing:
`./install.sh --bootstrap --dry-run`.

| Tier | Tools | Method |
| --- | --- | --- |
| Core CLI | git, jq, ripgrep, fd, fzf, bat, shellcheck, shfmt, tmux, direnv, watchexec | apt (Ubuntu `fdfind`/`batcat` get linked as `fd`/`bat`; when apt carries no watchexec, as on 24.04, the official static binary goes to `~/.local/bin` with a checksum check) |
| Snaps | gh, vale | snap |
| Python | uv, then ruff + ty + mypy as uv tools | official uv installer |
| Writing | bun, then cspell + markdownlint-cli2 as bun globals | official bun installer |
| Tracker | beads (`bd`) | official installer (steveyegge/beads) |

Deliberately not installed globally: pytest, prettier, html-validate, knip —
the canon runs these per-project through `uv run` / `bun run`. The
Clarafi-review security stack (opengrep, bearer, betterleaks, hadolint) is
project-specific and stays out of the core bootstrap.

`--doctor` reports the presence of every bootstrap tool.

## The mvac CLI

`install.sh` links `bin/mvac` into `~/.local/bin`. One CLI for common tasks,
consistent conventions across repos and machines.

```bash
mvac wt clone <url> [dir]     # clone a repo and set up its worktree root
cd "$(mvac wt checkout bugfix)"   # create worktree+branch wt/bugfix, cd into it
mvac wt list                   # worktrees: name, branch, path, dirty/merged
mvac wt cleanup --dry-run      # remove merged, clean worktrees (asks first)
mvac sentencefmt --check docs/ # the canonical one-sentence-per-line formatter
mvac doctor                    # full health check
mvac update                    # git pull the multivac clone
```

Worktree conventions: worktrees live at `<repo>/../.worktrees/<repo>/<name>`
(override the root with `MVAC_WT_ROOT`), new worktrees get branch `wt/<name>`
from the default branch, and `wt checkout` prints the path only — it works
inside `cd "$( ... )"`. Safety: `wt cleanup` removes only worktrees that are
clean and merged into the default branch, asks each time, never discards
modified files without `--force`, and deletes the `wt/` branch along with the
worktree.

`sentencefmt` has exactly one canonical copy here (`tools/sentencefmt.py`),
linked as a command at install time. Writing projects call the shared command
instead of vendoring copies.

## Skills (v1 — the core six)

| Skill | Use |
| --- | --- |
| `ste-writing` | Rewrite docs in Simplified Technical English and check them with a script. For READMEs, runbooks, error messages, incident reports, release notes, rule files. |
| `explain-artifact` | Render understanding artifacts — diagrams or self-contained HTML explorers — so a human can verify agent output fast. |
| `python-uv` | The standard Python toolchain: uv, ruff, strict types, pytest, Makefile gates. |
| `concept-architect` | Canonical Concept Design (WYSIWID) rules: concepts are islands, syncs coordinate, wire layers wire. |
| `session-close` | End-of-session protocol: gates, issues, commit, push, session note. |
| `harvest` | Extract general knowledge learned during a session into this repo. |

## Knowledge

Cross-project canon, deduplicated from the projects it was harvested from.
Index in [`knowledge/README.md`](knowledge/README.md): prose linting pipeline,
design tokens, static-site CI battery, ratchet quality gates, agent commit
authority, mistake log policy. Deeper canon for skills lives in each skill's
`references/` folder (concept design, Python toolchain, session protocol,
STE rules, render recipes).

## Design principles

Three sources shaped this repo. Credit where due:

- **Thin prompts, thick artifacts, thin skills** — Thariq Shihipar's framework,
  as analyzed by [explainx.ai](https://explainx.ai/blog/thin-prompts-thick-artifacts-thin-skills-thariq-july-2026).
  Every `SKILL.md` stays under ~40 lines: gotchas and pointers. Depth lives in
  `references/` and `knowledge/`. Deterministic actions live in `scripts/`.
- **ASD-STE100 Simplified Technical English** — the controlled-language
  standard, applied as summarized in [explainx.ai's guide](https://explainx.ai/blog/how-to-use-asd-ste100-simplified-technical-english-with-ai-guide-2026).
  Used as a *second-pass rewrite* at the reading boundary, never baked into a
  working prompt, with a checker script and per-document-type recipes.
- **The four-format ladder** — Karpathy's ranking of output formats for human
  oversight, covered by [explainx.ai](https://explainx.ai/blog/karpathy-understand-llm-outputs-ste100-diagrams-html-video-2026).
  The `explain-artifact` skill implements the ladder with the verification
  steps built in.

Also borrowed, with attribution in the files themselves: rule-block structure
from the open-source [AminBlg/SimpleEnglish](https://github.com/AminBlg/SimpleEnglish)
skill, and the session/mistake-log patterns from my own project repos.

## Repository layout

```
multivac/
├── install.sh          # idempotent installer / bootstrap / doctor / uninstall
├── bin/mvac            # CLI: worktrees, sentencefmt, doctor, update
├── AGENTS.md           # rules for agents working on this repo
├── skills/             # thin SKILL.md entry points + fat folders
│   └── <skill>/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── knowledge/          # harvested cross-project canon
├── tools/              # shared command-line tools (sentencefmt)
├── docs/
│   └── MIGRATION.md    # moving to another harness
└── LICENSE             # MIT
```

## Updating and harvesting

The loop that makes this repo compound:

1. Work in any project with OpenCode.
2. When the session learns something general, the `harvest` skill extracts it
   here — a thin knowledge file or a skill update.
3. `./install.sh` on each machine (or just `git pull` on the clone — the
   symlink and config entry already point at it).

Knowledge in a chat evaporates at session end. Knowledge harvested here
survives, deduplicates, and reaches every future session.

## License

MIT — see [LICENSE](LICENSE).
