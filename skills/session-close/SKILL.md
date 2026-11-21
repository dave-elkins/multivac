---
name: Session Close
description: End-of-session protocol — file follow-up issues, run quality gates, commit with a conventional message, push to remote, write a session note, hand off. Use when the user says "wrap up", "land the plane", "close out", "end the session", or asks what state the work is in.
---

# Session Close

## When to run

When the user says "wrap up", "land the plane", or ends the session. Run
every step in `references/session-protocol.md`. Verify each step. Each step
guards the next session's start state.

## The principle

Work is not done when the code compiles. Work is done when the remote holds
the work. Local-only work is stranded work.

## Authority check first

Read the repo's agent instructions for an authority profile. Default to
conservative: no commit, no push, report and wait. If the repo grants
team-maintainer authority, run the full protocol yourself — including the
push. Never say "ready to push when you are" when you hold push authority.

## Checklist

1. File issues for remaining work.
2. Run quality gates. `--no-verify` is forbidden.
3. Update issue status.
4. Commit with a conventional message.
5. Push to remote. Verify with `git status`.
6. Clean up stashes and dead branches.
7. Write a session note under `docs/notes/`.
8. Hand off: changes, validation, open issues, what to read next.

## Gotchas

- Never stop before the push step when you hold push authority.
- If a gate fails and the fix falls outside the task scope, stop and ask.
- Write the session note last. Keep it short. Point to issues instead of
  repeating their text.
