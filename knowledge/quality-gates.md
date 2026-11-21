# Quality Gates: Ratchet Baselines

Harvested from the clarafi-technical-review-dave and prdct-firsttry repos.

## The principle

A quality gate must never get weaker. A ratchet gate enforces this. The gate
counts current debt. It fails when debt grows. It passes when debt stays
flat or falls.

Do not wait for a clean codebase. Add gates on day one. Let them fail.
Record the failure counts. This record is the baseline. Burn the debt down
from there.

## The rules

1. Baselines only move down.
2. Lower a baseline only with a change that removes real findings.
3. Never raise a baseline to make CI pass.
4. Never add `// biome-ignore`, `@ts-ignore`, `eslint-disable`, or
   `# type: ignore`.
5. Never suppress a rule in tool config to silence a gate.
6. Never switch off a gate in CI.
7. Fix the finding. That is the whole policy.

A red gate is a work list, not a blocker. Only a tracked burn-down log may
annotate a red gate.

## Baseline script mechanism

Write one script per gate. The script runs the tool. The tool emits JSON.
The script counts findings by category. The script compares each count to a
maximum. It fails on any count above the maximum. It prints each count next
to its maximum. It exits non-zero on failure.

Treat missing or unparseable tool output as a failure. Print the raw
output. Do not guess. The failure message must state the policy. Use this
wording: "debt increased — lower the baseline only via burn-down."

## Recipe: add a ratchet gate to a new repo

Step 1. Pick the tool. Run it once. Record the current finding counts.
Step 2. Write a baseline script. See the sketch below.
Step 3. Add a Make target for the gate.
Step 4. Add the gate to `preflight` and to CI.
Step 5. Register the baseline in the burn-down log. Plan small changes that
lower it.

### Baseline file format

Keep maxima in one `MAX` object at the top of the script. Comment each
number with the date of the last burn-down.

```js
// scripts/check-lint-baseline.mjs
// Ratchet gate. Baselines only move down via burn-down changes.
const MAX = {
  errors: 212,    // 2026-11-21 initial baseline
  warnings: 1189, // 2026-11-21 initial baseline
};
```

### Script sketch

```js
import { spawnSync } from 'node:child_process';

const result = spawnSync('node_modules/.bin/<tool>',
  ['--reporter', 'json'],
  { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });

const data = JSON.parse(result.stdout);
const counts = { errors: 0, warnings: 0 };
for (const issue of data.issues ?? []) {
  counts.errors += issue.errors?.length ?? 0;
  counts.warnings += issue.warnings?.length ?? 0;
}

let failed = false;
for (const [key, max] of Object.entries(MAX)) {
  if (counts[key] > max) {
    failed = true;
    console.error(`FAIL ${key} ${counts[key]} > ${max}`);
  } else {
    console.log(`${key} ${counts[key]}/${max}`);
  }
}
process.exit(failed ? 1 : 0);
```

### Makefile sketch

```make
.PHONY: preflight preflight-smart code-health typecheck lint secrets

preflight: typecheck lint secrets
	@echo "preflight PASS"

preflight-smart:
	<runner> scripts/preflight.ts changed   # changed files only

code-health:
	<runner> scripts/code-health.ts         # slow: coverage, SAST

typecheck:
	tsc --noEmit

lint:
	node scripts/check-lint-baseline.mjs

secrets:
	betterleaks scan   # or: gitleaks detect --config gitleaks.toml
```

## Secrets scanning

Put a secret scan in every preflight. Configure allow-filters in
`betterleaks.toml` or `gitleaks.toml`. Scope each filter to the exact
placeholder value. Never ignore a whole path or a whole file. Test fixtures
may hold fake secrets. Label them as placeholders. Keep real credentials
out of source. If a real secret leaks, rotate and revoke it at once. Never
re-commit a leaked secret.

## Preflight discipline

Keep preflight under 60 seconds. Include type checks, lint, fast tests, and
the secret scan. Use a smart mode for iteration on changed files. Run full
preflight before every commit. Run deep analysis before releases.

`git commit --no-verify` is forbidden. If preflight fails, fix the cause.
If the cause predates your change, you own it now. Fix it, or file a
top-priority issue and record it in the burn-down log.
