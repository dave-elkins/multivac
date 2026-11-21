# Mistake Log Policy

Harvested from the prdct-firsttry repo.

## The policy

We only make mistakes once. A mistake that repeats is a process failure,
not bad luck. The log turns each mistake into a rule.

## When a mistake occurs

1. Fix the immediate problem.
2. Document the solution in the mistake log.
3. Prevent recurrence with a test, a lint rule, or documentation.

Complete all three steps before you move on.

## When to add an entry

Add an entry when any of these holds:

- Debugging took more than 15 minutes.
- The same error occurred before.
- The fix was not obvious from the symptom.
- The mistake could recur in another file, module, or session.

When in doubt, add the entry. Future you will thank you.

## Entry format

| Date | Mistake | Symptom | Solution | Prevention |
|------|---------|---------|----------|------------|
| YYYY-MM-DD | Root cause in one sentence. | What you observed. | What fixed it. | What blocks recurrence. |

Write the root cause in the Mistake column. The symptom alone hides the
cause. Name the cause so a later search finds the entry.

## How to add an entry

1. Identify the root cause.
2. Write the fix.
3. Add the row: Date, Mistake, Symptom, Solution, Prevention.
4. Choose the strongest prevention available.

Prefer mechanical prevention. A test is stronger than a comment. A lint
rule is stronger than a test. Documentation is the floor, not the ceiling.

## From entries to standing rules

Watch the Prevention column. When the same prevention appears twice,
promote it. Promote it into the repo's agent instructions as a standing
rule. Standing rules bind every future session. They also bind every human
editor.

Order of strength:

1. Lint rule or quality gate. It blocks the mistake.
2. Test. It fails when the mistake returns.
3. Standing rule in agent instructions.
4. Comment at the code site.

## Log hygiene

Keep the log in the repo at a fixed path. Keep one row per mistake. Never
delete an entry. Old entries are the memory of the codebase.
