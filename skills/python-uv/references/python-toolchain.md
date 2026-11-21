# Python Toolchain Standard

The standard Python toolchain, harvested from the AlphaTrace, legible-py,
wysiwid-petstore-py, and prdct repos. Apply it to every new Python project.
Every rule below is a MUST unless stated otherwise.

## Package management: uv, never pip

- MUST use `uv` for managing Python version, virtual environment, and
  dependencies. Never use `pip` directly.
- MUST keep `pyproject.toml` as the single configuration file for the project
  and its tools.
- MUST commit `.python-version` (for example `3.12`) at the repo root.
- MUST commit `uv.lock`. Run `uv sync` after every dependency change.
- Add dependencies with `uv add <pkg>`. Run all commands through
  `uv run <cmd>`.

## Formatting and linting: ruff

- MUST use `ruff` for both formatting (`ruff format .`) and linting
  (`ruff check .`). Auto-fix with `ruff check --fix .`.
- Typical rule selection:

```toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]        # pycodestyle, pyflakes, isort, pep8-naming
# optionally extend: "UP" (pyupgrade), "B" (flake8-bugbear)
ignore = ["E501"]  # line length handled by the formatter

[tool.ruff.format]
quote-style = "double"
```

- The `I` selection enforces import ordering. Order imports: stdlib →
  third-party → local.

## Type checking

- MUST run a strict type checker. Preferred: `ty`. Accepted alternatives:
  `mypy --strict` or `pyright` in strict mode.
- Typical strict settings: `disallow_untyped_defs = true`,
  `warn_return_any = true`.
- Type checking must pass before every commit.

## Testing: pytest

- MUST use `pytest` with tests in a `tests/` directory.
- In async projects, set `asyncio_mode = "auto"` in
  `[tool.pytest.ini_options]` and add `pytest-asyncio` as a dev dependency.
- Where test tiers are used, every test must carry exactly one marker:
  `@pytest.mark.unit`, `@pytest.mark.integration`, or `@pytest.mark.e2e`.
  Register the markers in `pyproject.toml`.
- Use `pytest-cov` for coverage. Set `fail_under` (for example 80) where
  coverage gates apply.

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
markers = [
    "unit: Fast unit tests (no external dependencies)",
    "integration: Integration tests (requires setup, slower)",
    "e2e: End-to-end tests (requires running app)",
]
```

## Code style

- No comments in code. Use docstrings on public APIs instead.
- Type hints are required on all function signatures.
- Use Pydantic `BaseModel` for request/response schemas. Use `Field()`
  constraints for validation.
- Use `async def` for all route handlers. Raise `HTTPException` for errors.
- Use SQLAlchemy for database models where a database is present. Prefer
  SQLite for file-based storage.

## Quality gates: the Makefile lint-gate pattern

Expose all commands as Makefile targets. Never skip a gate.

```make
test-api:
	cd apps/api && uv run pytest -m unit

lint-api:
	cd apps/api && uv run ruff check . --fix

typecheck-api:
	cd apps/api && uv run pyright   # or: uv run ty / uv run mypy

preflight:
	# runs tests + type check + lint + secret scan; <60 sec

preflight-smart:
	# same checks, only on changed files; for fast local iteration

code-health:
	# deep analysis: coverage, complexity, SAST
```

Rules for the gates:

- Run the smallest relevant check first (`preflight-smart`). Run the full
  `preflight` before commit.
- `git commit --no-verify` is forbidden. If preflight fails, fix it. Rerun
  until it passes.
- If blocked, file an issue for the failure. Do not work around the gate.

## Skeleton for a new project

```
<project>/
├── AGENTS.md             # agent instructions
├── README.md
├── Makefile              # lint / typecheck / test / preflight targets
├── pyproject.toml        # project + ruff + pytest + typechecker config
├── .python-version       # e.g. "3.12"
├── uv.lock               # committed
├── .gitignore
├── app/                  # application code
│   ├── __init__.py
│   ├── main.py           # FastAPI entry point
│   └── ...
└── tests/
    ├── __init__.py
    ├── conftest.py       # shared fixtures
    └── test_*.py
```

Bootstrap sequence for a new project:

1. `uv init` and pin `.python-version`.
2. `uv add fastapi uvicorn pydantic` (adjust to the stack).
3. `uv add --dev ruff pytest pytest-asyncio mypy` (or `ty` / `pyright`).
4. Paste the ruff, pytest, and typechecker config blocks above into
   `pyproject.toml`.
5. Write the Makefile targets above.
6. Run `make preflight` before the first commit.

## Divergences between source repos

- **Type checker**: AlphaTrace mandates `ty`. legible-py and
  wysiwid-petstore-py use `mypy` in strict mode. prdct-firsttry uses
  `pyright` in strict mode. All agree on strict type checking; the tool
  differs.
- **Ruff selection**: legible-py and prdct use `["E", "F", "I", "N", "W"]`.
  wysiwid-petstore-py and prdct-firsttry extend this to
  `["E", "F", "I", "N", "W", "UP", "B"]`.
- **Line length**: 100 in legible-py and prdct-firsttry; 88 (ruff default)
  in wysiwid-petstore-py.
- **asyncio mode**: legible-py and prdct-firsttry set
  `asyncio_mode = "auto"`. wysiwid-petstore-py does not configure it.
- **Test markers**: only prdct-firsttry requires `unit` / `integration` /
  `e2e` markers on every test.
- **Version pinning**: prdct-firsttry pins dev tool versions exactly
  (`ruff==0.1.11`); the other repos use minimum versions (`ruff>=0.1.0`).
