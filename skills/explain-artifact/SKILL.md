---
name: Explain Artifact
description: Render understanding artifacts — SVG or Mermaid diagrams and self-contained HTML explorers — when the user needs to understand or verify complex output. Use when the user asks to "explain", "help me understand", "review this output", "draw", "diagram", or wants an interactive walkthrough of an architecture, auth flow, PR diff, paper, or unfamiliar repo.
---

# Explain Artifact

## When to use

Human understanding is the bottleneck when reviewing agent work. Pick the
format by content shape:

| If the answer is mostly... | Render |
| --- | --- |
| A procedure or explanation, re-read later | STE-style text (use the ste-writing skill) |
| Structure, flows, relationships | Diagram |
| Exploration, comparison, many parameters | HTML page |
| A concept to learn from zero | Narrated video (only on request) |

## Workflow

1. Read `references/render-recipes.md` for the prompt patterns and pick a
   rung. Default to the HTML rung — it gives the biggest readability jump
   for the least setup.
2. Produce the artifact as a single self-contained file. No external
   dependencies.
3. Include the self-check: list the three places the artifact is least
   certain. A diagram looks authoritative even when a label is wrong.
4. Tell the user the artifact is discardable. Do not wire it into
   maintenance or add it to the repo unless asked.

## Gotchas

- Do not constrain a working session mid-task. Render at the boundary, when
  the user reads the result — never as a style rule inside a build prompt.
- A better format makes a wrong answer easier to believe. Keep the
  verification step.
- Prefer Markdown when the content lives in git, gets diffed in pull
  requests, or is read by other agents.
