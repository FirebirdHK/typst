---
name: typst-doc-structure
description: Document structure: sections, counters, columns, glossary.
---

# Document structure: sections, counters, columns, glossary
**Trigger**: multi-section report/thesis-shaped document — numbered headings, TOC, cross-references, figure/table counters, columns, a glossary.
**Start from**: `templates/report.typ` (the PDF workhorse); `templates/dual-target.typ` if HTML is also required.

## Default path
1. Page, rhythm, numbering — exactly as `report.typ` does it:
```typst
#set page(paper: "a4", margin: (x: 2.4cm, y: 2.2cm))
#set par(justify: true, leading: 0.72em, spacing: 0.95em)   // Typst defaults justify: false
#set heading(numbering: "1.1")   // multi-level headings
#set figure(numbering: "1")      // sequential; fig counters are 1-level
#set math.equation(numbering: "(1)")
#show link: it => underline(it)  // 0.13+ links are bare and read as plain text
#outline(depth: 2)               // requires headings to have numbering
```
2. Sections are plain `= H1`. Attach labels at definition (`#figure(…)<fig:x>`, `table(…)<tab:units>`, `$ … $ <eq:derivative>`) and reference with `@fig:x`/`@tab:units`/`@eq:derivative`. `#set figure(supplement: [Fig.])` changes the `@ref` reading; LoF via `outline(title: [List of Figures], target: figure.where(kind: image))`.
3. Counter reality: heading numbering is multi-level; figure/table/equation counters are **sequential, 1-level** (`report.typ` comment) — don't port LaTeX `1.1` figure-numbering expectations. Counters/top-level state are `context`-read (`counter(page).get()`); `#counter(page).update(1)` restarts footer/body immediately but the same page's header keeps the old number.
4. Columns: two rules, both required — `#set page(columns: 2)` (page semantics: breaks/footnotes) **and** `#set columns(gutter: 5mm)` (gutter; `page(column-gutter:)` does not exist). Default gutter = 4% = 9.64pt (a6/10mm probe: text width 240.94pt). `#colbreak()` = `\columnbreak`; full-width band = `#place(top + center, scope: "parent", float: true, clearance: 4pt, rect(width: 100%)[…])` — `scope: "parent"` requires `float: true`.
5. Anchors to edges, never to a fixed y: a component that can grow is anchored to the edge it must not cross and grows away from it (`#place(bottom + left, dy: -10pt)[author block]`). The 0.1/0.2 firebird title slide anchored the author block at a fixed top offset and pushed the date off the page — the overflow gate couldn't see it. Related: state updates must precede the break they affect; gates/markers under-report on title slides and in the footer zone (26.8pt silent overflow measured).
6. Glossary only when first-use long/short expansion, usage counts, back-references, or grouped prints matter (the LaTeX `glossaries` role). Trivial term lists: skip it.
7. Glossarium order contract: `#show: make-glossary` before any use/print; `#register-glossary(entry-list)` before the first use of each key; every used key covered by exactly **one** `print-glossary`. Keys are unique registry-wide (case-sensitive).
8. Single-pass pattern: `print-glossary` may sit at document start (0.5.4+) — labels are document-global, so forward `@`/`gls` resolve; no external index run. Data goes in a pure-data file (`glossary-data.typ`, no glossarium import) and registers as one concatenated list, or keep `group:` for headings and pass one list to a single `print-glossary`.

## Fail modes → fix
| Exact string / symptom | Fix |
|---|---|
| `error: unexpected argument: column-gutter` | `page()` has `columns:` but no gutter arg — add `#set columns(gutter: 12pt)` |
| `error: parent-scoped positioning is currently only available for floating placement` + `hint: … place(float: true, ..)` / `error: parent-scoped placement is only available for floating figures` | `place(..., scope: "parent", float: true)`; for figures `figure(..., scope: "parent", placement: auto)` |
| `error: unexpected argument: two-sided` / `error: unexpected argument: binding-offset` | no twoside flag/offset — `#set page(binding: right, margin: (inside: 16mm, outside: 10mm))`; fold the offset into `margin.inside` |
| `error: entry does not have field "target"` (outline show rule) | 0.13 rework — methods `it.body()`, `it.page()`, `it.element.location()`, `it.prefix()` |
| `error: unexpected argument: numbering` (`counter.display`) | pattern is the first positional: `context counter(page).display("1")` |
| `error: can only be used when context is known` | `#context page.width` / `#context measure([hi])` |
| `error: expected relative length, found content` | `context` must wrap the **whole** dependent expression: `#context { let dx = …; place(..., dx: dx) }` |
| ``warning: `show page` is not supported and has no effect`` (rc=0) | page is not show-targetable — `#set page(...)`; an exit-code-only check passes this no-op |
| `error: panicked with: glossarium@0.5.10 error : key 'ok' not found` | register-after-use (message is identical to a typo) — move `#register-glossary` above the first use |
| ``error: label `<kdf>` does not exist in the document`` | print coverage: the key's `print-glossary` subset/`groups:` filter omits it — one print must cover each used key |
| ``error: panicked with: glossarium@0.5.10 error : make-glossary not called. Add `#show: make-glossary` at the beginning of the document.`` | add the show rule before print |
| ``shorthand 'long-plural' is not supported. Use one of plural, capitalize, capitalize-plural, short, long, description, longplural, custom`` | code param is `longplural` (docs say otherwise); `minimum-refs` not `minimum-ref` |

## Deviate safely
- **Free**: section order/depth, numbering patterns, margin geometry, one-vs-many `print-glossary` calls, `group:` organization, per-entry `styles:`.
- **Measured floors**: columns need both `page(columns:)` + `set columns(gutter:)`; `scope: "parent"` needs `float: true`; no automatic column balance exists (docs: "planned") — the manual measure+binary-search demo is mis-calibrated, recalibrate `col-w`/`target` before trusting it; `@key` and `#gls()` are different machines (the four `always-first` knobs wrap `show ref` only — prefer `@key` in headings/captions/outlines); `#gls()` in a description needs `update: false`; user `show figure:` must go **before** `make-glossary` and be scoped `figure.where(kind: …)` or it boxes glossary entries (silent, vision-only).
- **Escape hatches**: no auto balance → accept single column or hand-balance; heavy multi-file docs that can't hold the register/print order contract → put data and print in one place; `Agls`/`gls-sort` are documented but not exported — use `#gls(..., capitalize: true, article: true)` or drop them; `emph`/`strong`/`link` are styled with `set` only (0.15 show-rule quirks) — one comment in `report.typ`'s lineage is the regression test.

## Verify
`scripts/verify.sh <file>.typ` (add `--html` when the doc is dual-target), then read `.verify/page-*.png`: outline entries numbered and page-accurate, `@fig`/`@tab`/`@eq` resolve, gutter/band geometry, and no stray □ column or boxed glossary entries. Grep stderr for `did not converge`/`did not stabilize` — rc=0 with those warnings is not clean. Do not assert from theme counters; count exported pages/files.

## Deep reference
`glossarium.md` — §1 package facts/order contract, §2 skeleton, §3.6–3.8 (print utilities, math entries, file-organization/single-pass), §5 error catalog (loud vs silent), §9 pitfalls P-1/P-3/P-4/P-7. `base-layouts.md` — §1 anchors table, §2.1 columns, §2.2 headers/state lag, §2.9 binding, §3 error catalog, §4 LaTeX parity table. `template-design-for-agents.md` — §1 anchor-to-edge, §2 marker coverage, §3 state resets, §4 builtins, §5 one rhythm. Template: `templates/report.typ`.
