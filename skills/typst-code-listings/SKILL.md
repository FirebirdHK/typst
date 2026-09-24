---
name: typst-code-listings
description: Typst code listings — codly 1.3.0.
---

# Typst code listings — codly 1.3.0

**Trigger**: a code listing needing chrome — frame, zebra, gutter numbers, highlights, filename bar.
**Start from**: `templates/code-heavy.typ` (codly 1.3.0, PDF **and** HTML).

**Dual-target: frame the listing, at an explicit width.** codly draws its gutter bar, numbers
and highlight with `grid`/`place`/`rect`, all dropped on the HTML target — measured, the
unframed template exported **313 bytes with four empty `<div></div>`** at rc=0. Wrap each
listing in `html.frame` through a `target()`-guarded helper — and **state the width**, because
a frame has no containing block:

```typst
#let text-width = 21cm - 2 * 2cm   // the page's text measure (a4, 2cm margins)
#let listing(code, lang: none) = context if target() == "html" {
  html.frame(box(width: text-width, raw(code, lang: lang, block: true)))
} else {
  raw(code, lang: lang, block: true)
}
```

**The unwrapped frame is invisible, and nothing mechanical catches it.** Measured:
`html.frame(raw(…, block: true))` exports `viewBox="0 0 1 235.67"` / `width="1pt"` — codly's
gutter is drawn (the `#f0f0f0` fill is in the file) but every glyph lands inside a 1pt column.
rc=0, one `<svg>` per listing, zero empty divs, `verify.sh` PASS: a browser shows *nothing*
below the heading. `box(width: …)` restores it (measured: `width="481.89pt"` = 17cm, gutter
intact); `width: 100%` does **not** (no containing block → collapses to 1pt again). So: check
the SVG's width attribute, or render the page — never the tag count. `body > svg { max-width:
100% }` in `assets/typst-html.css` keeps a bare frame from overflowing narrow viewports.

Measured after the fix: 89 kB HTML, one `<svg>` per listing at 481.89pt, zero empty divs, only
the `page set rule` EXPECT warning; plain `typst compile` (no `--features html`) still rc=0.
Guard on `target()` — an unguarded `html.frame` breaks the plain compile with
`error: unknown variable: html`, and putting it in a show rule adds
`warning: elem may not occur inside of a paragraph and was ignored`. Framed listings are SVG
in HTML (not selectable): for semantic `<pre><code>` use plain `raw` (dual-target.typ).

## Default path

1. Skeleton, in this order — `codly-init` is positional, and raw before it stays stock with
   zero diagnostics:
   ```typst
   #import "@preview/codly:1.3.0": *
   #import "@preview/codly-languages:0.1.10": *   // optional chip data
   #show: codly-init
   #codly(languages: codly-languages, zebra-fill: luma(246), stroke: 0.75pt + luma(200))
   ```
   `codly-languages`' single export IS the dict: `languages: codly-languages`, never `.languages`.
2. No Typst `set` rules: `#codly(...)` behaves like a set rule over 53 keys (prior values kept
   for unspecified keys) but is mutable state; `#local(...)` scopes, `#codly-reset()` restores.
3. Ten keys are one-shot (consumed by the next raw block, then reverted): `offset`,
   `offset-from`, `range`, `ranges`, `skips`, `annotations`, `highlights`,
   `highlighted-lines`, `header`, `footer`. Everything else persists — a highlight meant for
   "the next block" lands on the wrong listing otherwise.
4. Filename bar: `filename:` is DEAD — `#codly(filename: …)` panics
   `codly: unknown arguments: filename`; `#local(filename: …)` silently swallows it. Use the
   header idiom (one raw block per wrapper body, or the bar leaks):
   ```typst
   #let with-file(file, body) = {
     [#codly(header: text(font: "DejaVu Sans Mono", weight: 600, file))]
     body
   }
   ```
5. Helper calls (both published README snippets are wrong): defaults are named-only, required
   args positional-only → `#codly-offset(offset: 5)` not `codly-offset(5)`;
   `#codly-range(5, end: 10)` not `codly-range(start: 5, end: 10)`.
6. Highlights are arrays: `#codly(highlighted-lines: (2,))` — `(2,)` not bare `2`; colors per
   line `((1, red.lighten(60%)), 2, (5, blue.lighten(70%)))`, 1-indexed. Keep numbers ON when
   highlighting (bug #88: `number-format: none` + highlights draws no rect); char `highlights`
   `start:`/`end:` are 0-indexed.
7. References: wrap blocks you will `@`-reference in `#figure(```…```) <lbl>`, then `@fib` /
   `@fib:3`; never `@` an annotation label on 1.3.0.
8. HTML: codly drops the chrome grid (`warning: grid was ignored during HTML export ┌─
   @preview/codly:1.3.0/src/lib.typ:1744:8`) → codly for PDF, zebraw 0.6.3 for HTML.

## Fail modes → fix

| `exact error` (verbatim) | fix |
|---|---|
| `panicked with: codly: unknown arguments: filename` | use the `header:` idiom |
| `panicked with: codly: overlapping annotations` | non-overlapping only → disjoint spans `(2,3)`, `(4,5)` |
| `assertion failed: codly: ranges must be an array of arrays, found integer` | `ranges: ((2, 4),)`, or `range: (2, 4)` for one window |
| `error: unexpected argument: numbering` | the key is `number-format:` → `#codly(number-format: none)` |
| ``the argument `start` is positional`` (+ hint) | required args positional-only, defaults named-only → `#codly-range(5, end: 10)`, `#codly-offset(offset: 5)` |
| ``error: label `<nofile:3>` does not exist in the document`` | wrap in `#figure(…) <lbl>` before `@lbl:n` |
| `error: package found, but version 1.3.1 does not exist (latest is 1.3.0)` | 1.3.1 is GitHub-only → pin `:1.3.0` |
| *(no error — exit 0, wrong render)* raw before `#show: codly-init` | stays stock, zero diagnostics → init at document top |
| *(no error)* `#local(filename: …)` / `#codly(filename: …)` | swallowed / panics → don't rely on signature validity; use `header:` |

## Deviate safely

Free: theme colors (`zebra-fill`, `stroke`, `radius`, `inset`), chip settings (`display-name` /
`display-icon: false`, `lang-format: none`), custom language entries (missing keys fall back
per-field), your own `header-transform`. Floor (measured): `#show: codly-init` before every
styled block; one `header:` per wrapper holding one raw block; numbers ON for highlighted
blocks; range/skip/annotation lines 1-indexed (docs and args.json claim otherwise — trust
behavior). Escape hatch: if the chrome fights the document, drop to stock raw or scope with
`#no-codly[...]`; for HTML targets switch to zebraw.

## Verify

`scripts/verify.sh templates/code-heavy.typ` — **PDF-only, no `--html`** (codly's chrome is
primitives HTML export drops; the grid warning is expected in any HTML smoke). Vision-read
`.verify/page-*.png`: chips show the right language name/color, gutter numbers continue across
`offset`/`offset-from` blocks, the header bar lands on the right block, and highlight rects are
present (count them — bug #88 is silent). Byte-diff stderr against `experiments/codly/_build/`.

## Deep reference

`codly.md` §2 (skeletons, options by group), §3.1 (one-shot vs persistent), §3.2 (indexing
truth table), §3.4 (highlighting, bug #88), §3.6 (references), §3.8 (annotations, HTML
export), §4 (error catalog, loud + silent), §5 (minted comparison).
