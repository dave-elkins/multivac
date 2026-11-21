# Design Tokens Pattern

A token is a named design decision: a color, a font, a width, a radius.
Tokens live in CSS custom properties. Everything else references tokens.
Harvested from the dave-elkins.github.io DESIGN.md.

## Principles

1. **Tokens over literals.** Use CSS custom properties for colors, fonts,
   radii, and repeated widths. No hard-coded hex values outside `:root`.
2. **CSS custom properties are the source of truth.** Define them once in a
   global stylesheet under `:root`. Every component reads from there. A
   theme change edits one block, not fifty files.
3. **Global for shared, scoped for local.** Shared building blocks live in
   the global stylesheet. A component `<style>` block holds only layout
   unique to that component.
4. **Promote to global on second use.** If a rule appears on two pages,
   move it to the global stylesheet and document it. One-off values are
   debt; the second occurrence is the trigger to pay it.
5. **Progressive enhancement.** Ship static HTML with no client-side
   JavaScript. Every interactive element must work as a plain link. Keep
   visible `:focus-visible` styles.
6. **One visual language.** Every page uses the same colors, type scale,
   containers, and card treatment.

## Token set

Keep the set small. One block in the global stylesheet:

```css
:root {
    /* Color */
    --color-bg:          #fbfaf8;   /* page background */
    --color-surface:     #ffffff;   /* cards */
    --color-text:        #1d1d1f;   /* body text */
    --color-muted:       #6b6b70;   /* secondary text, metadata */
    --color-border:      #dedbd5;   /* borders, dividers */
    --color-accent:      #9a3f2d;   /* links, eyebrows, hover */
    --color-accent-soft: #f5e8e3;   /* placeholders, inline code */
    /* Font */
    --font-sans:  "Open Sans", system-ui, sans-serif;
    --font-serif: Lora, Georgia, serif;
    --font-mono:  ui-monospace, monospace;
    /* Width */
    --measure:        46rem;       /* narrow reading text */
    --article-measure: 60rem;     /* article header, prose, footer */
    /* Shape */
    --radius: 0.5rem;
}
```

## Type scale

Keep the scale intentionally few. Body copy uses sans; headings use serif.
Do not invent intermediate sizes. Pick the closest row to the need.

| Element | Size |
| --- | --- |
| `h1` | `clamp(2rem, 5vw, 3rem)` — exactly one per page |
| `h2` | `clamp(1.5rem, 3.5vw, 2rem)` |
| `h3` | `1.25rem` |
| Body | `1rem`, line-height `1.6` |
| Meta / eyebrow | `0.85rem` / `0.78rem`, muted |

## Shared classes

Define reusable classes once in the global stylesheet. A page composes
them; it does not restate them.

- `.page-shell` — the standard page container. Every page uses it.
- `.narrow` — constrains a block to the reading measure.
- `.eyebrow` — accent-colored uppercase label.
- `.lede` — muted introductory paragraph.
- `.subtitle` — serif italic subtitle.
- `.card`, `.card--compact`, `.card--horizontal` — one card treatment for
  every listing.
- `.prose` — rendered article body.

Variant modifiers use BEM-style suffixes (`--compact`, `--horizontal`);
internal parts use `__` (`card__body`).

## Checklist for new work

1. Does the page use the standard shell?
2. Do colors, fonts, widths, and radii come from tokens?
3. Can an existing shared class do the job?
4. Is there exactly one `h1`, with sections as `h2`/`h3`?
5. Do links show a visible `:focus-visible` outline?
6. Does it look right at small widths?
7. Did the full check battery pass?
