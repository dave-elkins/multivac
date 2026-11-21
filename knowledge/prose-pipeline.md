# Prose Linting Pipeline

Four tools check prose. Each tool has one job. No tool duplicates another.
Harvested from the blog and dave-elkins.github.io repos.

| Tool | Job |
| --- | --- |
| `sentencefmt` | Normalize formatting. One sentence per line. |
| `markdownlint` | Check Markdown structure. |
| `Vale` | Check prose style and quality. |
| `cspell` | Check spelling. |

Spelling belongs to `cspell` alone. Keep Vale's spelling rules off. This
prevents duplicate warnings.

## 1. sentencefmt — one sentence per line

`sentencefmt` reformats Markdown prose so each sentence sits on its own
line. This makes diffs sentence-scoped. Reviewers see exactly which sentence
changed.

It leaves untouched: fenced code blocks, indented code blocks, YAML front
matter, headings, lists, blockquotes, HTML blocks, and tables. It does not
split abbreviations (`e.g.`, `i.e.`, `Dr.`, `vs.`, `etc.`). It preserves
inline code, links, bold, and italics exactly.

Usage:

```bash
sentencefmt file.md [file2.md ...]   # fix files in place
sentencefmt --check file.md         # CI mode: exit 1 if changes needed
cat file.md | sentencefmt -          # stdin → stdout
```

Pass a directory to recurse over `*.md`. Use `--check` in CI. Use the plain
form locally or in a pre-commit hook.

The canonical copy lives in the multivac repo (`tools/sentencefmt.py`). The
multivac installer links it into `~/.local/bin/sentencefmt`, and `mvac
sentencefmt` runs it too. Do not copy the script into writing projects — call
the shared command. Extend the `ABBREVIATIONS` set in multivac when a domain
term needs it, then update every project at once.

## 2. Vale — prose style linter

Install Vale (`brew install vale` / `choco install vale` /
`snap install vale`). Place this config at the project root as `.vale.ini`.
Then run `vale sync` to fetch the style packages.

```ini
# .vale.ini
# Vale prose linter configuration for a writing project.
# Docs: https://vale.sh/docs
#
# Install Vale:
#   brew install vale          # macOS
#   choco install vale         # Windows
#   snap install vale          # Linux
#
# Install style packages after placing this file:
#   vale sync
#
# Run:
#   vale content/              # lint all content
#   vale content/ch1.md        # lint one file

StylesPath = .vale/styles

# Minimum alert level to report: suggestion | warning | error
MinAlertLevel = suggestion

# Your project vocabulary (domain terms that are always correct)
Vocab = ProjectTerms

# Style packages to install (run 'vale sync' after updating)
Packages = write-good, proselint

[formats]
# Treat .md files as Markdown
md = md

# -----------------------------------------------------------------------
# Paths to lint — adjust to match your directory structure
# -----------------------------------------------------------------------
[*.md]
BasedOnStyles = Vale, write-good, proselint

# -----------------------------------------------------------------------
# Vale built-in rules (fine-tune as needed)
# -----------------------------------------------------------------------

# Spelling is handled by cspell — disable Vale's spell check to avoid
# duplicate warnings. Re-enable if you prefer Vale-only tooling.
Vale.Spelling = NO

# Avoid overly wordy constructions
Vale.Redundancy = warning
Vale.Repetition = warning

# Hedging language ("sort of", "kind of", "a bit")
Vale.Hedging = suggestion

# -----------------------------------------------------------------------
# write-good rules
# Catches passive voice, weasel words, and weak prose
# -----------------------------------------------------------------------
write-good.Passive       = warning    # "is considered" → prefer active voice
write-good.Weasel       = warning    # "many", "various", "fairly", "quite"
write-good.TooWordy     = suggestion # "in order to" → "to"
write-good.Cliches      = suggestion
write-good.ThereIs      = suggestion # "There is a..." → restructure
write-good.Illusions    = error      # doubled words ("the the")
write-good.E-Prime      = NO         # too strict for technical writing

# -----------------------------------------------------------------------
# proselint rules
# Editorial quality checks
# -----------------------------------------------------------------------
proselint.Annotations          = warning   # TODO/FIXME left in prose
proselint.But                  = NO        # too strict
proselint.Cliches              = suggestion
proselint.DateRedundancy       = warning
proselint.GarnerMisused        = warning   # commonly misused words
proselint.Hedging              = suggestion
proselint.Hyperbole            = suggestion
proselint.Jargon               = NO        # technical jargon is intentional
proselint.LGBTTerms            = warning
proselint.Malapropisms         = error
proselint.Needless             = suggestion
proselint.Oxymorons            = warning
proselint.Pretension           = suggestion
proselint.Racism                = error
proselint.Skunked               = warning
proselint.Spelling              = NO        # handled by cspell
proselint.Typography           = warning
proselint.Uncomparables         = warning   # "very unique", "more perfect"
```

The `Vocab` name must match a directory under
`.vale/styles/config/vocabularies/` (see the vocabulary section below).

## 3. cspell — spell checker

Place `cspell.json` at the project root:

```json
{
    "$schema": "https://raw.githubusercontent.com/streetsidesoftware/cspell/main/packages/cspell-types/cspell.schema.json",
    "version": "0.2",
    "language": "en",

    "files": ["content/**/*.md", "*.md"],

    "ignorePaths": [".git", "node_modules", ".vale"],

    "ignoreRegExpList": ["https?://[^\\s]+", "`[^`]+`", "\\[\\[.*?\\]\\]"],

    "words": [
        "codebase",
        "codebases",
        "refactoring",
        "idempotent",
        "idempotency",
        "composable",
        "composability",
        "deserialization",
        "serialization",
        "worktree",
        "monorepo",
        "monorepos"
    ],

    "dictionaries": ["en_US", "software-terms", "python"],

    "dictionaryDefinitions": [
        {
            "name": "python",
            "path": "./node_modules/@cspell/dict-python/dict/python.txt"
        }
    ]
}
```

Adjust three things per project:

- `files` — point at your content directories.
- `words` — add project terms when the checker flags them. Use the term
  exactly as written. Add all inflections (`misfit`, `misfits`) because
  cspell does not stem.
- `dictionaries` — add stack dictionaries (`@cspell/dict-python`,
  `@cspell/dict-software-terms`, `@cspell/dict-en_us`) as devDependencies
  and wire them through `dictionaryDefinitions`.

The `ignoreRegExpList` skips URLs, inline code, and wiki-style links. These
should never fail a spell check.

## 4. markdownlint — structure linter

Place `.markdownlint.json` at the project root:

```json
{
    "default": true,

    "MD013": false,
    "MD033": false,
    "MD036": false,
    "MD042": false,

    "MD003": { "style": "atx" },
    "MD007": { "indent": 2 },
    "MD024": { "siblings_only": true },
    "MD029": { "style": "ordered" },
    "MD030": {
        "ul_single": 1,
        "ol_single": 1,
        "ul_multi": 1,
        "ol_multi": 1
    },

    "MD041": true,

    "MD049": false,
    "MD050": false,
    "MD060": false
}
```

Two rules are deliberately disabled:

- **MD013 (line length)** — off. One-sentence-per-line formatting means
  line length tracks sentence length. A hard wrap limit would fight the
  formatter.
- **MD033 (inline HTML)** — off. Technical prose legitimately embeds HTML
  for things Markdown cannot express (`<figure>`, `<img>`, `<details>`).

Also disabled: MD036 (emphasis as pseudo-heading), MD042 (empty links),
MD049/MD050 (list marker style — the formatter owns this), MD060 (table
column padding). Everything else stays on.

## 5. Pre-commit hook scoping

Run all four tools at commit time with the pre-commit framework. Scope them
to the prose directories only. Do not run them on config files, changelogs,
or generated docs.

```yaml
# .pre-commit-config.yaml
# pip install pre-commit && pre-commit install
#
# Runs prose linters on content-directory .md files at commit time.

repos:
    - repo: local
      hooks:
          - id: sentencefmt
            name: Sentence-per-line Markdown formatter
            entry: sentencefmt
            language: system
            types: [markdown]
            files: '^(content|articles)/'
            pass_filenames: true

          - id: markdownlint
            name: Markdownlint
            entry: markdownlint
            language: system
            types: [markdown]
            files: '^(content|articles)/'
            pass_filenames: true

          - id: vale
            name: Vale prose linter
            entry: vale
            language: system
            types: [markdown]
            files: '^(content|articles)/'
            pass_filenames: true

          - id: cspell
            name: Spell check (cspell)
            entry: cspell
            language: system
            types: [markdown]
            files: '^(content|articles)/'
            pass_filenames: true
```

The pattern: one `files:` regex per hook, identical across hooks. Change the
regex in one place — e.g. `^(series|research)/` for a book project,
`^(posts|notes)/` for a blog. The `types: [markdown]` filter plus the path
regex keeps hooks off non-prose Markdown.

Order matters. `sentencefmt` runs first because it is the only hook that
rewrites files. The read-only hooks then check the corrected text.

## 6. Dual-vocabulary maintenance pattern

Two term registries serve two masters.

**Vale vocabulary** — create both files, empty:

```
.vale/styles/config/vocabularies/ProjectTerms/accept.txt
.vale/styles/config/vocabularies/ProjectTerms/reject.txt
```

- `accept.txt` — one term per line. Terms Vale's spelling rule would accept.
  Vale reads this as "known correct".
- `reject.txt` — one term per line. Misspellings to flag even if a
  dictionary allows them.

**cspell `words`** — the live spelling registry. Vale's spelling rules are
disabled here, so cspell carries the whole spelling load.

Maintenance workflow:

1. cspell flags a legitimate project term → add it to `words` in
   `cspell.json`. Add every inflection.
2. The term is domain canon, not just a spelling → also add it to
   `accept.txt`.
3. A typo keeps recurring in drafts → add the typo to `reject.txt`.
4. Re-run `vale sync` after touching vocabulary files.

Both vocabulary files start empty. They grow on demand. This keeps the
registries honest: every entry exists because a real failure demanded it.
