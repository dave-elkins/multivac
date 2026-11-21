# Session Close Protocol

Harvested from the AlphaTrace and prdct repos.

## When to run it

Run this protocol when the user says "wrap up", "land the plane", or ends the
session. Run every step. Verify each step. Each step guards the next
session's start state.

## The principle

Work is not done when the code compiles. Work is done when the remote holds
the work. Under a push-enabled profile, never stop before the push step.
Local-only work is stranded work.

## Authority profiles

Check the repo's agent instructions for a named profile. Default to
conservative.

| Profile | Commit | Push / sync | Duty at handoff |
| --- | --- | --- | --- |
| Conservative (default) | No. Only on explicit request. | No. | Report changed files, validation, and suggested commands. |
| Team-maintainer | Yes, at session close. | Yes, at session close. | Full close: run gates, commit, push, verify. |

A direct user instruction wins over any profile. A current "do not commit"
instruction beats a standing opt-in. When instructions conflict, state
assumptions and ask before proceeding. The full authority canon lives in
this repo at `knowledge/agent-safety.md`.

## Stop-and-ask triggers

The agent must stop and ask when:

- The action is destructive: deletes, force-pushes, history rewrites,
  credential changes.
- A required push or sync is blocked. Report the exact command and error.
  Do not improvise.
- A quality gate fails and the fix falls outside the task scope.
- The active instructions conflict with the repo's standing policy.

## The checklist

1. **File issues for remaining work.** Create an issue for each known
   follow-up. Untracked work is lost work.
2. **Run quality gates.** Run preflight if code changed. Forbid
   `--no-verify`. If preflight fails, fix the cause. If you are blocked,
   file a top-priority issue that documents the failure.
3. **Update issue status.** Close finished issues. Update in-progress
   issues with current state.
4. **Commit.** Use a conventional commit message. State type, scope, and
   subject. Keep the header under 100 characters.
5. **Push to remote.** Run the sequence below. `git status` must show
   "up to date with origin" at the end.

   ```bash
   git pull --rebase
   bd dolt push   # or: bd sync, per tracker setup
   git push
   git status
   ```

6. **Clean up.** Clear stashes. Prune dead remote branches.
7. **Write a session note.** See below.
8. **Hand off.** Summarize changes, validation, issue status, and any
   blocked step.

## Push rules

- Never stop before the push step when you hold push authority.
- Never say "ready to push when you are" when you hold push authority. Push
  yourself.
- If push fails, resolve the cause and retry until it succeeds.
- If you hold a conservative profile, do not push. Report the proposed
  commands and wait for approval.

## Session note

Write one note file per session. Store notes under `docs/notes/`. Name
files `NNNN-session-name.md`. Pad the sequence number to four digits. Find
the next number with this command, then increment it:

```bash
ls docs/notes/*.md | sort -V | tail -1
```

Note template:

```markdown
# NNNN - Session Name

**Date:** YYYY-MM-DD

## What Was Done
[Accomplishments, each with an issue ID]

## Key Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|

## What Is Open
[Unfinished work, each with an issue ID]

## What to Read Next
[Files, docs, or issues for the next session]
```

Write the note last. Keep it short. Point to issues instead of repeating
their text.

## Handoff summary

End the session with a short report:

- What changed.
- What validation passed.
- What issues remain open.
- What the next session should read first.
