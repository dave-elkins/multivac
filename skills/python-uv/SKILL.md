---
name: Python uv Toolchain
description: The standard Python project toolchain — uv (never pip), ruff, strict type checking, pytest with markers, Makefile gates, preflight discipline. Use when starting, scaffolding, or tooling a Python project, or when the user asks how to structure tests, linting, or quality gates in Python.
---

# Python uv Toolchain

## When to use

Any Python project: new scaffolds, dependency changes, lint/type/test setup,
quality-gate design. The canon lives in `references/python-toolchain.md`.

## Gotchas

- `uv`, never `pip`. Run everything through `uv run`. Commit `uv.lock` and
  `.python-version`.
- No comments in code. Docstrings on public APIs instead. Type hints on
  every signature.
- Import order is enforced by ruff's `I` rules: stdlib, then third-party,
  then local.
- Type checker varies by repo (`ty`, `mypy --strict`, or `pyright`). Read the
  repo's config and match it. Do not introduce a second checker.
- Run `make preflight` (or the repo's equivalent) before every commit.
  `git commit --no-verify` is forbidden. If the gate fails, fix the cause or
  file an issue.
- Keep preflight under 60 seconds. Slow checks belong in `code-health`, not
  preflight.

## Recipe

For a new project, follow the bootstrap sequence and skeleton at the end of
`references/python-toolchain.md`.
