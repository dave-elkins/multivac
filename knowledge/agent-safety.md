# Agent Safety: Commit and Push Authority

Harvested from the prdct and AlphaTrace repos.

## The principle

An agent must know its authority before it touches git. Authority is
granted, never assumed. Write the grant into the repo's agent instructions.
Name the grant so the agent can cite it at session close.

## Context profiles

Use named profiles. A profile defines what the agent may do with commits,
pushes, and issue-tracker sync.

| Profile | Commit | Push / sync | Duty at handoff |
| --- | --- | --- | --- |
| Conservative (default) | No. Only on explicit request. | No. | Report changed files, validation, and suggested commands. |
| Minimal | No. | No. | Same as conservative. Keep tool guidance as pointers only. |
| Team-maintainer | Yes, at session close. | Yes, at session close. | Full close: run gates, commit, push, verify. |

Default to the conservative profile. A repo opts in to team-maintainer
explicitly. No profile grants unconditional authority.

## Precedence

1. A direct user instruction wins over any profile.
2. A current "do not commit" or "do not push" instruction beats a standing
   opt-in.
3. A profile wins over agent judgment.
4. When instructions conflict, state assumptions and ask before proceeding.

## Stop-and-ask triggers

The agent must stop and ask when:

- The action is destructive. This covers deletes, force-pushes, history
  rewrites, and credential changes.
- A required push or sync is blocked. Report the exact command and the exact
  error. Do not improvise.
- A quality gate fails and the fix falls outside the task scope.
- The active instructions conflict with the repo's standing policy.

## Never do

- Do not commit or push without authority from the active profile or the
  current request.
- Do not force-push or rewrite history without an explicit instruction.
- Do not say "ready to push when you are" under the team-maintainer
  profile. Push yourself.
- Do not skip hooks with `--no-verify`.

## Permanent-ID discipline

Give every tracked artifact a permanent ID. Never reassign, reuse, or
renumber an ID. If an artifact is deleted, retire its ID. Do not fill the
gap. Assign the next ID by incrementing from the highest existing ID in the
series. This keeps references valid across files and history. It also stops
parallel sessions from colliding on IDs.

## Artifact gates

Treat artifact quality like code quality. Run the quality checklist before
you write the file. Do not mark an artifact reviewed without explicit user
confirmation. Do not write a file that you know fails a quality check.
Surface the failure and rework the artifact.

## Handoff under the conservative profile

At session end, report four things:

1. Which files changed.
2. Which validations ran and with what result.
3. Which issues remain open.
4. The exact commands you propose to run next.

Then wait for approval.
