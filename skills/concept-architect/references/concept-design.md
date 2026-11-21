# Concept Design (WYSIWID) — Canonical Rules

The canonical rules for building software with **Concept Design** (Daniel
Jackson, *The Essence of Software*) implemented through the **WYSIWID**
pattern (What You See Is What It Does; Meng & Jackson, Onward!). Harvested
from the AlphaTrace, legible-py, and prdct repos. Think in concepts first.
Write implementation code only after the design answers the concept
questions.

## What a concept is

A **concept** is a standalone unit of functionality. A user can name it and
understand it independently. Examples: `Post`, `Comment`, `Subscription`,
`Inventory`, `Notification`.

Each concept:

- Has its **own state**. No other concept touches it.
- Exposes **actions**. Actions are public async methods that modify state
  and return a typed record.
- Has an **operational principle** — an invariant it maintains internally.
- **Never imports another concept.**

Cross-concept coordination happens exclusively in the **sync layer**. It
never happens inside concepts.

## The three-layer rule

Every piece of application code belongs in exactly one layer:

```
concepts/<name>.py   — what things DO (domain logic, no framework)
syncs/<feature>.py   — how things are COORDINATED (sync rules, no concepts)
app.py / cli.py      — how things are WIRED (triggers, dispatcher, routes)
```

Dependencies flow downward only:

```
app.py / cli.py
    ↓ imports concepts + syncs
concepts/   (no imports from syncs/ or other concepts/)
syncs/      (no imports from concepts/; references by namespace string)
```

A violation of this rule is not a style issue. It breaks the engine's
contract invariants.

## Non-negotiable rules

**1. Concepts are islands.**
A concept file must never import from another concept. If you feel the urge
to do so, that's a **misfit**. Stop. Resolve it with a sync rule instead.

**2. Cross-concept references are opaque IDs.**
If `Comment` needs to refer to a `Post`, it stores `post_id: UUID` — not a
`Post` object. This is called an **uninterpreted atom**. Never pass a rich
object across concept boundaries. A foreign key typed as another concept's
dataclass is a modularity violation, even if it works.

**3. Syncs live in `syncs/`, not in concepts.**
"When X happens, do Y in another concept" always belongs in a sync rule.
The concept that fires the action does not know what happens next.

**4. Actions return ActionRecords.**
Every public action emits a typed record of what happened (in dict-based
runtimes: an `async def <action>(inputs: dict) -> dict` that always returns
a dict). This is how the sync engine knows to trigger downstream rules. Do
not use callbacks or direct calls inside actions. An action that returns
nothing is invisible to the sync engine — it can never be matched in a
`when` clause.

**5. Guards are sync-layer concerns.**
"Only allow action A if condition B is true" is a guard rule registered with
the engine. Do not encode cross-concept guards inside concept action
methods.

**6. View concepts are read-only.**
Views aggregate data across concepts for efficient reads (CQRS-style). Sync
rules maintain them. Views expose no mutating actions.

**7. Where clauses are pure reads.**
A `where` clause is a plain, non-async function. It takes `bindings: dict`
and returns `list[dict]`. It has no side effects, no `await`, and no
mutation of external state. Return `[]` to skip; return multiple dicts to
fan out.

**8. Sync rules reference concepts by namespace string only.**
Concepts are identified as `"ConceptName/action_name"` — PascalCase concept,
snake_case action. Never import concept modules in a sync file. This
guarantees that replacing a concept implementation never requires changing
sync files.

## Design moves (refactoring vocabulary)

When the design does not feel right, use these named moves:

- **Split**: One concept is doing two things → split into two concepts + a
  sync rule.
- **Merge**: Two concepts always move together and have no independent
  value → merge them.
- **Lift**: Logic that maps between concepts is inside a concept → lift it
  to the sync layer.

Name refactoring commits with these terms (e.g.,
`refactor: lift label-assignment to sync layer`).

## Recipe: add a concept

1. Create `concepts/<name>.py` (or `concepts/<name>/` as a package, per
   layout convention).
2. Write one or more `async def <action>(inputs: dict) -> dict` functions.
3. Each function must return a dict — never `None`, never void.
4. Use only stdlib and approved third-party imports. No web framework
   imports. No engine imports. No imports from other concept files.
5. Run the concept linter on the new file. It must report zero violations.
6. Register the concept in the wiring layer via
   `dispatcher.register_action("Concept/action", handler)`.
7. Write unit tests that call the function directly. No engine required.

## Recipe: add a sync rule

1. Open the appropriate `syncs/<feature>.py` file. Create a new one if the
   feature area is new.
2. Add a `Sync("RuleName").when(...).then(...).build()` call.
3. Reference concepts by **namespace string only**. Never import concept
   modules in a sync file.
4. If the rule needs a `where` clause, write a plain non-async function.
   It takes `bindings: dict` and returns `list[dict]`. No side effects.
5. Run the sync linter on the file. It must report zero violations.
6. Register the rule by adding it to the list returned by
   `get_<feature>_rules()`. The wiring layer picks it up automatically.
7. Write a rule in plain English before coding it:
   - `When [Concept A].[action] → [Concept B].[action]([args])`
   - `Guard [Concept A].[action] provided [condition from Concept B]`

## Anti-hallucination clause

Do not invent framework or package names. If a name does not exist in the
repository, it does not exist. Specifically: do not use "LegibleSync",
"@legible-sync/core", or "LegibleEngine". These are not real packages. Build
the sync engine yourself in `engine/sync_engine.py` (or the project's engine
module) following the WYSIWID pattern. Never import a sync-engine package
that is not already declared as a dependency.

## What NOT to do

- Do not add `import concepts.<anything>` to a sync file.
- Do not add `import syncs.<anything>` to a concept file.
- Do not define concept functions in the wiring layer.
- Do not define sync rules in the wiring layer.
- Do not write `async def where_clause(...)` — where clauses are plain
  synchronous functions.
- Do not call `await` inside a where clause, even in a nested function.
- Do not mutate external state in a where clause. No `.append()`. No
  assignment to non-local variables.
- Do not write an action that returns nothing or returns `None`.
- Do not add business logic to route handlers. Route handlers call triggers
  only.
- Do not build a **god concept** — one concept that knows about everything.
  Split it.
- Do not put sync logic inside a concept — an action that calls another
  concept's action directly. Lift it.
- Do not leak state — exposing internal DB models from a concept's public
  interface. Use `Out` models.
- Do not coordinate implicitly — two concepts sharing a DB table or a global
  variable. Give each its own state.
- Do not trust a typo'd namespace string. `"Inventry/check"` silently never
  matches. No error is logged. Check the flow trace when a rule appears
  missing.

## Divergences between source repos

- **Concept shape**: AlphaTrace models a concept as a package
  (`concepts/<name>/actions.py`, `state.py`, `state.yaml`) with Pydantic +
  DB state and typed `ActionRecord` returns. legible-py models a concept as
  a single module with plain dict-based actions. Both follow the same
  isolation rules.
- **Guards and views**: AlphaTrace defines dedicated `guards/` and `views/`
  directories. legible-py expresses guards as ordinary sync rules and has no
  separate views layer.
- **Engine location**: AlphaTrace places the engine at
  `engine/sync_engine.py` inside the app. legible-py ships the engine as a
  standalone top-level package. prdct-firsttry packages it as an
  installable `legible-architecture` library with wiring in `bootstrap.py`
  instead of `app.py`.
- **Design-first artifacts**: prdct-firsttry stores concept designs as YAML
  files in `docs/concept-design/` before implementation. The other repos
  design directly in code.
- **Enforcement**: legible-py enforces the rules mechanically with a
  `conceptlint` linter (rules R001–R005). AlphaTrace and prdct-firsttry rely
  on review conventions.
- **wysiwid-petstore-py** documents Concept Design / WYSIWID only as a
  planned refactor target; its current code is MVC.
