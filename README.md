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
   (override with `MULTIVAC_HOME`).
2. Symlinks `skills/` into `~/.agents/skills/multivac` — the open-standard
   location that OpenCode V2 discovers globally.
3. Adds the skills path to `~/.config/opencode/opencode.json`, backing up the
   file first. Nothing existing is removed.

Safe to re-run. Update with `./install.sh` (it pulls and re-verifies).
Check health with `./install.sh --doctor`. Remove with
`./install.sh --uninstall` (add `--purge` to also delete the clone).

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
├── install.sh          # idempotent installer / doctor / uninstall
├── AGENTS.md           # rules for agents working on this repo
├── skills/             # thin SKILL.md entry points + fat folders
│   └── <skill>/
│       ├── SKILL.md
│       ├── references/
│       └── scripts/
├── knowledge/          # harvested cross-project canon
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
