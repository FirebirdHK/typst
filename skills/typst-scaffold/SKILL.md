---
name: typst-scaffold
description: Typst scaffold — pick the template, keep one rhythm.
---

# Typst scaffold — pick the template, keep one rhythm

**Trigger**: starting any new `.typ` document, or deciding which template to copy.
**Start from**: `templates/scratch-note.typ` as the default; the other five templates below.

## Default path

1. Choose by intent — all six `templates/*.typ` are self-contained and verify-clean:

| need | template |
|---|---|
| note / explainer / design memo / worked problem (zero packages, PDF+HTML) | `templates/scratch-note.typ` |
| multi-section report with refs + TOC | `templates/report.typ` |
| lecture notes / notebook: numbered theorem environments, margin notes | `templates/notebook.typ` |
| deck (PDF only) | `templates/slides.typ` |
| deck that is also a web page | `templates/deck.typ` |
| drawings + data plots | `templates/figure-heavy.typ` |
| code listings | `templates/code-heavy.typ` |
| PDF **and** HTML from one source | `templates/dual-target.typ` |

Every template styles both targets: the HTML side imports `assets/html-style.typ`, calls `#html-style()` once, and wraps structural blocks (`hook("doc-title", …)`, `hook("callout", …)`). Manual compiles from a subdirectory also need `--root <repo root>` or the shared-asset import dies with `path … would escape the project root` (`scripts/verify.sh` passes it).

2. Keep the copied preamble (`#set page`/`text`/`par`/`heading`) — it is the ONE spacing
   rhythm (leading 0.72em, block spacing 0.95em). Typst collapses adjacent spacing to the
   max, so no gap doubles up and no element needs `#v(...)` (template-design §5).
3. Anchor anything that can grow to the edge it must not cross, and let it grow away from that
   edge (`place(bottom + left, dy: -52pt)`); a fixed top anchor once pushed a date off-page
   invisibly (template-design §1).
4. Fit oversized content with `measure()` + `scale(..., reflow: true)` (base-layouts.md §2.6)
   — default `scale()` does not affect layout, so shrunk content still reserves its natural
   footprint:
   ```typst
   #let fit(body) = context {
     let nat = measure(body)
     let f = calc.min(1, 70mm / nat.width)
     scale(x: f * 100%, y: f * 100%, origin: top + left, reflow: true, body)
   }
   ```
5. Style built-ins with `set`, never show rules (`show emph:` drops italics; `show strong:`
   breaks `link` fill), and restore links: `#show link: it => underline(it)` (template-design §4).
6. Reset section-scoped chrome state in the component that opens the next scope; a state
   flipped after `#pagebreak()` is too late for the page that just started (template-design §3).
7. Treat rc=0 as a first approximation, never validation. Silently wrong at exit 0: overlay
   `place` under text, `scale()` without reflow, unbreakable tokens +113.8pt past a block
   stroke, invisible footer-zone overflow (26.8pt) — re-measure and read the PNGs (loops §2).
8. Anti-slop before adding components: rule-of-three bans and palette discipline live in
   the corpus chapter `typst-anti-slop.md`.
9. **Ship HTML as a site, not as loose files**: `python3 scripts/deploy_html.py out doc.typ
   --shared-css` compiles the set (repo root as `--root`), injects the `<title>`/description
   Typst never emits, lifts the stylesheet into one cacheable file, and writes an
   `index.html`; `--serve 8000` previews it. Outside this repo, `scripts/install-package.sh`
   makes the same styling importable as `@local/typst-html:0.1.0` from any cwd.

## Fail modes → fix

| `exact error` (verbatim; base-layouts.md §3 catalog) | fix |
|---|---|
| `error: unclosed delimiter` (points at `block(set ...`) | `set` inside an argument list parses as an unclosed call → `block({ set par(...); text(...) })` |
| `error: unexpected argument: leading` | `leading` is a `par` key → `#set par(leading: 1em)` |
| `error: can only be used when context is known` + hint ``the `context` expression should wrap everything that depends on this function`` | contextual value (`page.width`, `measure()`) → wrap the whole expression: `#context ...` or `layout(size => ...)` |
| `error: parent-scoped positioning is currently only available for floating placement` | full-width band → `place(..., scope: "parent", float: true)` |
| `error: unexpected argument: column-gutter` | no page gutter arg → `#set page(columns: 2)` **and** `#set columns(gutter: 12pt)` |
| `error: expected "simple", "optimized", or auto` | `par.linebreaks` has no `"strict"` → `linebreaks: "optimized"` |
| ``error: `inside` and `outside` are mutually exclusive with `left` and `right` `` | don't mix margin families → `margin: (inside: 5mm, rest: 3mm)` |
| `error: expected relative length, found content` | `context` must wrap the whole dependent expression → `#context { let dx = ...; place(..., dx: dx) }` |
| `error: unexpected argument: binding-offset` / `two-sided` | fold into `margin: (inside:, outside:)` + `#set page(binding: right)` |
| ``warning: `show page` is not supported and has no effect`` (exit 0) | use `#set page(...)`; a warning-level no-op passes exit-code-only harnesses |
| `error: path "../assets/html-style.typ" would escape the project root` | compile with `--root <repo root>` (verify.sh does it) — typst sandboxes to the entry file's directory |
| `error: file not found (searched at …/examples/assets/html-style.typ)` | wrong relative depth: `templates/x.typ` → `../assets/…`, `examples/topic/x.typ` → `../../assets/…` |

## Deviate safely

Free: paper/margins, colors, fonts, headings, section count, body content — templates are
starting points, not contracts. Floor (measured): one spacing rhythm (no `#v()` between
blocks), edge-anchoring for anything that can grow, `reflow: true` on any `scale()`, link
underlines kept, built-ins styled only via `set`. Escape hatch: if a rule fights the document,
change it, re-run verify, keep whichever render wins — the corpus is evidence, not a
straitjacket.

## Verify

`scripts/verify.sh templates/scratch-note.typ --html` (swap in the template you copied;
`--html` only for dual-target work). Then read `.verify/page-*.png`: rc=0 lies — BLANK means
nothing landed, SPARSE needs a look (intentional divider vs near-empty), DROP means content
vanished on one target.

## Deep reference

`template-design-for-agents.md` §1 (edge anchoring), §4 (0.15 show quirks), §5 (one rhythm),
§7 (package-vs-scratch trade-offs); `base-layouts.md` §2.6 (fit-to-width), §3 (error catalog),
§5 (silent-wrong class); `html-styling-css.md` §6 (the shipped stylesheet and its tokens),
§8 (wrong-but-green catalogue); `DELIVERABLES.md` §3 (template/script plan).
