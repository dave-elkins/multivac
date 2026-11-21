#!/usr/bin/env python3
"""Flag common ASD-STE100 style violations in a Markdown or text file.

Unofficial summary of ASD-STE100 ideas — not the standard, not certified.
Checker pattern adapted from explainx.ai's sketch:
https://explainx.ai/blog/how-to-use-asd-ste100-simplified-technical-english-with-ai-guide-2026

Expect false positives. Treat the output as prompts for review, not errors.
Usage:
    python3 ste_check.py file.md [more.md ...]
    cat file.md | python3 ste_check.py -
"""

import re
import sys

HEDGES = {"should", "would", "may", "might", "could"}

# Nouns and words that end in -ing but are fine. Extend as your domain needs.
ING_OK = {
    "string", "strings", "setting", "settings", "things", "something",
    "anything", "everything", "nothing", "during", "morning", "evening",
    "underlying", "engineering", "ordering", "messaging", "logging",
    "naming", "padding", "spacing", "shipping", "booking", "testing",
    "warning", "warnings", "beginning", "building", "buildings", "ceiling",
    "crossing", "listing", "listings", "missing", "offering", "offerings",
    "writing", "marketing", "meaning", "spelling", "wording", "heading",
    "headings", "messaging", "running", "matching",
}


def strip_non_prose(text: str) -> str:
    """Drop fenced code blocks, tables, and YAML front matter. Keep prose."""
    lines, out, in_fence = text.splitlines(), [], False
    if lines and lines[0].strip() == "---":
        lines = lines[1:]
        for i, line in enumerate(lines):
            if line.strip() in ("---", "..."):
                lines = lines[i + 1:]
                break
    for line in lines:
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if not in_fence and not line.lstrip().startswith("|"):
            out.append(line)
    return "\n".join(out)


def sentences(text: str) -> list[str]:
    return [s.strip() for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]


def check(text: str) -> list[tuple[str, str]]:
    issues: list[tuple[str, str]] = []
    for s in sentences(text):
        words = re.findall(r"[A-Za-z0-9'-]+", s)
        if not words:
            continue
        if len(words) > 20:
            issues.append((s, f"{len(words)} words (limit about 20)"))
        low = [w.lower() for w in words]
        bad = sorted(HEDGES.intersection(low))
        if bad:
            issues.append((s, "hedge word: " + ", ".join(bad)))
        ing = [w for w in low if w.endswith("ing") and len(w) > 4 and w not in ING_OK]
        if ing:
            issues.append((s, "-ing form: " + ", ".join(sorted(set(ing)))))
    return issues


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    found = 0
    for path in args:
        text = sys.stdin.read() if path == "-" else open(path, encoding="utf-8").read()
        issues = check(strip_non_prose(text))
        if issues:
            found += len(issues)
            print(f"== {path} ==")
            for s, why in issues:
                print(f"- {why}\n    {s}")
    if found:
        print(f"\n{found} issue(s). Expect false positives; review, do not auto-fix blindly.")
    else:
        print("No violations found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
