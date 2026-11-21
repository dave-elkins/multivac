---
name: Concept Architect
description: Canonical Concept Design (WYSIWID, Daniel Jackson / Meng & Jackson) rules — concepts are islands, syncs coordinate, the wire layer wires. Use when designing or refactoring a concept-design codebase, adding a concept or sync rule, deciding where logic belongs, or when the user mentions "concept", "sync rule", "WYSIWID", or "legible".
---

# Concept Architect

## When to use

Any Concept Design / WYSIWID project: designing concepts, writing sync
rules, refactoring between layers, deciding where a piece of logic belongs.
The full canon lives in `references/concept-design.md`.

## The three-layer rule

```
concepts/<name>.py   — what things DO (domain logic, no framework)
syncs/<feature>.py   — how things are COORDINATED (sync rules, no concepts)
app.py / cli.py      — how things are WIRED (triggers, dispatcher, routes)
```

Dependencies flow downward only. A violation breaks the engine's contract
invariants.

## Gotchas

- Concepts never import other concepts. The urge to do so is a **misfit** —
  resolve it with a sync rule.
- Cross-concept references are opaque IDs (`post_id: UUID`), never rich
  objects.
- Actions return a dict/record. An action that returns nothing is invisible
  to the sync engine.
- Where clauses are plain synchronous functions. No `await`, no mutation.
- Sync files reference concepts by namespace string only
  (`"ConceptName/action"`). A typo'd namespace silently never matches —
  check the flow trace when a rule appears missing.
- Do not invent sync-engine packages. Build the engine in-repo. If a name
  does not exist in the repository, it does not exist.

## Recipes

Step-by-step recipes for "add a concept" and "add a sync rule", the
refactoring moves (Split / Merge / Lift), and the full "what NOT to do"
list are in `references/concept-design.md`.
