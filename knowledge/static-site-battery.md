# Static Site CI Battery

A layered check battery for Astro static sites (Bun or Node). Harvested
from the dave-elkins.github.io and 25x8ai.github.io repos. Each layer
catches what the previous layer cannot. Run them in order. Later layers
need build output, so build first, then check the output.

## The battery, in order

1. **Format** — `prettier --write .` (or `--check .` in CI). Normalize
   whitespace and quotes first so later diffs are clean.
2. **markdownlint** — structural lint on source Markdown.
3. **Prose checks** — cspell spell check plus `sentencefmt --check` on
   article directories.
4. **Type check** — `astro check`. Catches bad props, missing imports,
   schema violations.
5. **Build** — `astro build`. Emits static HTML to `dist/`.
6. **HTML validation** — `html-validate` against `dist/**/*.html`. Catches
   what templates hide.
7. **Internal link check** — crawl `dist/` for broken internal links and
   missing assets.
8. **Accessibility audit** — run axe-core (via jsdom, no browser needed)
   against the built pages.
9. **External link check** — scheduled CI job, not per-commit. External
   checks are slow, flaky, and outside your control. Run them on a cadence
   (for example, weekly) instead of on every push.

## Scripts

```json
{
    "scripts": {
        "dev": "astro dev",
        "build": "astro build",
        "preview": "astro preview",
        "check": "astro check",
        "format": "prettier --write .",
        "format:check": "prettier --check .",
        "lint": "npm run lint:md && npm run lint:prose && npm run lint:html",
        "lint:md": "markdownlint-cli2 \"src/**/*.md\" \"README.md\" \"DESIGN.md\"",
        "lint:prose": "cspell --no-progress \"src/content/**/*.md\" && python3 tools/sentencefmt.py --check src/content/articles",
        "lint:html": "html-validate \"dist/**/*.html\"",
        "lint:links": "node tools/check-links.mjs",
        "audit:a11y": "node tools/check-a11y.mjs"
    }
}
```

Key wiring details:

- `lint:html`, `lint:links`, and `audit:a11y` read from `dist/`. Always
  run `build` before them.
- `lint:prose` chains two commands with `&&`. The check fails if either
  fails.
- `--no-progress` keeps cspell output readable in CI logs.
- DevDependencies to back the battery: `markdownlint-cli2`, `cspell` plus
  `@cspell/dict-*` packages, `html-validate`, `axe-core`, `jsdom`,
  `prettier`, `prettier-plugin-astro`, `@astrojs/check`, `typescript`.
- Keep `check-links.mjs` and `check-a11y.mjs` as small Node scripts in
  `tools/`. They need no extra framework: jsdom parses the built HTML,
  axe-core audits it.

## Code style conventions

Formatting: 2-space indentation. Single quotes in JS/TS. No semicolons.
Prettier enforces this; do not fight it.

Naming:

- Astro components: `kebab-case.astro` (`hero-section.astro`).
- TypeScript files: `camelCase.ts`.
- CSS files: `kebab-case.css`.
- Assets in `public/`: all lowercase.

Import order in Astro frontmatter:

1. Type imports.
2. Layouts and components.
3. Styles.
4. Assets (images, icons).

```astro
---
import type { ComponentProps } from '../types';
import Layout from '../layouts/Layout.astro';
import Hero from '../components/Hero.astro';
import '../styles/global.css';
import logo from '../assets/logo.png';
---
```

Components: keep them small and focused. Hold logic in the frontmatter
fence, template below. Keep frontmatter concise. Extract complex logic to a
separate `.ts` file. Type props with a TypeScript interface:

```astro
---
interface Props {
    title: string;
    subtitle?: string;
}

const { title, subtitle = '' } = Astro.props;
---
```

## HTML and accessibility rules

- Set `lang` on `<html>`.
- Use semantic elements: `<nav>`, `<main>`, `<section>`, `<article>`.
- Provide alt text for every image.
- Keep heading hierarchy strict: one `h1`, then `h2`, then `h3`.
- Optimize images before adding them. Prefer WebP.
- Use absolute URLs for external links, relative for internal.

## Working rules

- **Zero JavaScript by default.** Astro ships no client JS unless a
  directive asks for it. Keep it that way. Prefer plain links and CSS over
  scripts. Add a script only when the task is impossible without one.
- **Run the build before committing.** `bun run build` (or `npm run build`)
  is the gate. A commit that does not build is not done.
- **Test at the breakpoints.** Check mobile, tablet, and desktop before
  calling a page finished.
- A static marketing or content site needs no backend, no auth, no
  database. Do not add one speculatively.
