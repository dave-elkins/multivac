---
name: STE Writing
description: Rewrite documentation in Simplified Technical English (ASD-STE100 style) and check it with scripts/ste_check.py. Use when the user asks to clarify, de-slop, or tighten a README, runbook, error message, incident report, release note, or agent rule file — or mentions "STE", "plain English", or "make this unambiguous".
---

# STE Writing

## When to use

Documents where clarity beats style: READMEs, runbooks, error messages,
incident reports, release notes, `AGENTS.md` rule blocks.

Do not use for marketing copy, blog posts, brand stories, speeches, or fiction.

## Workflow

1. Treat this as a rewrite pass, not a writing style. Do not apply these rules
   while producing a first draft. Render at the boundary where a human reads.
2. Do not add facts. Do not remove steps. Check the diff for both.
3. Follow the rules and the per-document recipes in
   `references/ste-rules.md`.
4. Run `python3 scripts/ste_check.py <file>` on the result. Fix what it
   flags. Expect false positives — nouns like "string" are fine.
5. If the text is long, show the user the diff instead of the full rewrite.

## Gotchas

- STE removes personality on purpose. Warn before applying it to persuasive
  text. The user may want 80% of the way to the standard, not 100%.
- A model reads "should" as optional. Rewrite agent rules as direct commands.
- A flat sentence can still be wrong. Keep human review for safety-relevant,
  legal, or regulated text.
