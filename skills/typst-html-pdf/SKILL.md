---
name: typst-html-pdf
description: Dual target: one source, PDF + HTML.
---

# Dual target: one source, PDF + HTML
**Trigger**: one Typst source must export both PDF and HTML; or you are about to use `html.*`, `html.frame`, or `-f html`.
**Start from**: `templates/dual-target.typ` — the reference pattern where nothing disappears (rc=0 both targets, only EXPECT lines, zero DROP).

## Default path
1. Compile **both targets from the same entry** every time you claim dual-target: `scripts/verify.sh doc.typ --html` (verify.sh compiles the PDF and the HTML with `--features html`). The exit code of one target says nothing about the other.
2. Put `--features html` on **both** targets (or `TYPST_FEATURES=html`). It gates *availability*, not layout: without it `.html` output errors and `html.*` is `unknown variable: html` at its first use on the paged path.
3. Branch on `context target()` — format-based, not feature-based: same source yields `"paged"` for a PDF output and `"html"` for an HTML output. Bare `#target()` is a context error. Design: `#context if target() == "paged" { … } else { … }`.
4. rc=0 never means "nothing dropped": the standing banners and every ignore warning are rc=0. Grep **both** stderr logs for `was ignored during`, `error:`, `unknown variable: html`, `only available when`.
5. Drawings go inside `html.frame(...)` unless you verified the package converts: framed fletcher → 2,993 B HTML with 1 `<svg>` and 0 warnings; bare fletcher → 286 B, 0 `<svg>`, empty inline-block span + `@preview/cetz:0.3.4` `layout was ignored`. The frame is the sanctioned escape hatch for drawing packages whose internals don't survive HTML.
6. `#set page` has no HTML meaning → `page set rule was ignored during HTML export` is EXPECT, not a bug. Move paper-dependent layout into blocks/regions and branch with `target()`.
7. `hline` is the only dual-warned element (`hline was ignored during HTML export` **and** `…during paged export`) — avoid it in dual-export tables: `stroke: (x, y) => if y == 0 { (bottom: 0.8pt) } else { none }` + `table.header(...)`.
8. Bundle is a **third target**, not a superset: `asset`, `#document`, and top-level structure exist only under `--features bundle,html -f bundle`; E2b/E3/E4/E8 all come from mixing the feature/target axes.
9. Anchor strategy: HTML links resolve to `path/index.html`; ids must be minted explicitly — `#link(<Meta>)` yields an href, not an anchor target.
10. **Style the web target explicitly — the export is semantically rich and visually bare**: 0 `class=` attributes, no `<h1>`, inline `style` only on exported `<svg>`. Ship the stylesheet with `#html-style()` and give structural containers a class via `hook(cls, body)` — both from `assets/html-style.typ`. NEVER call a bare `html.elem`: on the paged target it is dropped **silently** (marker present in the HTML, absent from the PDF text, rc=0), so an unguarded hook deletes PDF content. `hook()` branches on `context target()` internally, so the PDF keeps both its content and its own Typst styling. `hook-tag(tag, cls, body)` is the variant for when the ELEMENT carries meaning: a document title must be `<h1>`, not a `<p>` (measured: without it the report had no `<h1>` at all and deployed with the tab title "TECHNICAL REPORT", its small-caps kicker).
11. **`html-style()` is variadic — pick a look, do not fork the base sheet.** `#html-style()` = the editorial base (`typst-html.css`: warm canvas, serif prose, teal structure). `#html-style("arxiv-html.css")` = the paper look, measured against arXiv's own LaTeXML output (Times 16px/24px justified, sans headings, centered `<h1>` at 27.2px/400, abstract with 64px/32px margins, sticky 240px left TOC sidebar, black ink). `#html-style("slides-html.css")` = the deck look (one card per slide). Extras concatenate AFTER the base, so a variant overrides only what it must — keep the shared invariants (measure, figure padding, `.callout`) in the base.
12. Compile from a subdirectory with `--root <repo root>` or shared-asset imports die (`path … would escape the project root`); `scripts/verify.sh` passes it for you.
13. **Deploying is its own step — the export is a page fragment, not a page.** Typst emits no `<title>` and no description, so a deployed document shows its *filename* in the browser tab, and a set of documents has no landing page. `python3 scripts/deploy_html.py OUTDIR FILE.typ …` compiles the set (`--root` + `--features html` handled), injects `<title>`/description from each document's own title block, optionally lifts our stylesheet into one cacheable `typst-html.css` (`--shared-css`), and writes an `index.html` in the same design language; `--serve PORT` previews it. Derive nothing from raw export text before stripping `<style>`/`<script>` — the shipped stylesheet names `<h2>` in its own comment, so a heading regex returns CSS prose as the page title (measured).
14. **Outside the repo, install the package rather than copying assets**: `scripts/install-package.sh` installs `assets/` as `@local/typst-html:0.1.0`, then `#import "@local/typst-html:0.1.0": html-style, hook` works from any cwd with no `--root` and no depth counting. Measured: a consumer compiled from `/tmp` got `class="doc-title"`/`class="callout"` + the stylesheet in HTML and intact prose in the PDF.

## Fail modes → fix
| Exact string | Fix |
|---|---|
| ``error: html export is only available when `--features html` is passed`` (rc=1, +2 hints) | add the flag or `TYPST_FEATURES=html` |
| `error: unknown variable: html` (at the use site, rc=1) | `html.*` evaluated on a PDF build without the feature — keep `--features html` in the harness or guard the branch so it never evaluates (E6 happens at eval, not layout) |
| `error: assets are only supported in the bundle target` | features ≠ target — `asset(...)` needs `-f bundle` |
| `error: constructing a document is only supported in the bundle target` | `#document` only under bundle |
| `error: text is not allowed at the top-level in bundle export` (one per offending line) | wrap top-level prose in `#document` |
| ``error: html export is only available when the `html` feature is enabled`` + hint ``pass `--features bundle,html` `` | one error per `#document` — add the feature pair |
| `elem may not occur inside of a paragraph…` / `{elem} was ignored during paged export` (rc=0) | the E9 family — HTML-only element leaking into the paged path: branch on `context target()` |
| `layout was ignored` from `@preview/cetz:0.3.4` package paths (rc=0) | bare drawing package in HTML — wrap the diagram in `html.frame(...)` |
| `html export is under active development and incomplete` (warning + 3 hints) / `bundle export is experimental` (warning + 2 hints) | standing banners once the feature is on — expected, not errors |
| `error: unknown variable: asset` on a plain PDF compile | the weby trap: an HTML-first source is not proof of dual-targetness — compile both targets from the same entry |
| `error: HTML raw text element cannot have non-text children` (`html.elem("style", raw(…))`) | `style` takes TEXT children → pass the CSS as a string: `html.elem("style", read("typst-html.css"))` |
| `error: unknown variable: FBFBFA` (a markup body on `html.elem("style")[…]`) | markup parses `#` as code → use a string body, never `[…]` |
| `error: path "../assets/html-style.typ" would escape the project root` | compile with `--root <repo root>` (verify.sh does); wrong depth gives `file not found (searched at …)` |
| hooked `html.elem` compiled to the paged target (rc=0, no diagnostic) | the content is **dropped from the PDF** — route every hook through `hook()`/`hook-inline()` |
| `error: input file not found (searched at OUTDIR)` from the deploy tool | only `.typ` positionals are inputs; a leading non-`.typ` token is the output directory (`deploy_html.py out a.typ`) |
| a deployed page's tab shows the filename, or CSS prose | the export has no `<title>` — derive it *after* stripping `<style>`/`<script>` (`deploy_html.py` does both) |

## Deviate safely
- **Free**: HTML styling (Typst emits no CSS — link your stylesheet; the aim is semantic HTML), which elements you branch per target, `html.elem` tag choices (`details`/`summary` demo works), and the `<svg>`-fallback strategy (frame the drawings that matter).
- **Measured floors**: `--features html` on both targets; compile both from one entry before claiming dual-target; `html.frame` for fletcher/cetz/lilaq unless you verified the primitives convert; no page rules on the HTML side; `hline` special-cased; count HTML pages only from a **clean** output dir (stale files lie — the weby dist was 23 files/16 HTML after `rm -rf`, not 26/18); `a11y-extras` accepts but its behavior delta is unstudied — don't rely on it.
- **Escape hatches**: package internals that don't convert → `html.frame` (SVG fallback); math needs no frame on 0.15 (MathML equations exist); a genuinely HTML-only site framework (`asset`/`#document` bindings) should stay HTML-first and hand PDF a separate entry — don't force both axes onto one source and call it dual-target.

## Verify
`scripts/verify.sh doc.typ --html` → expect rc=0 both targets, only EXPECT lines, no DROP. Then, from a clean output dir: grep both logs for `error:`, `was ignored during`, `unknown variable: html`, `only available when`; assert HTML count > 0 for every intended page; spot-render the HTML and look for empty inline-block spans where a diagram should be (⇒ wrap in `html.frame`); check math renders (MathML `<math>` count) and icons/glyphs are not boxes. Vision-check `.verify/page-*.png` for the PDF side; the HTML side needs its own look — measure the export (`<svg>`, `<math>`, `class="` counts) and then **render it in a browser**: a stylesheet that never loaded, a class that never got emitted, and an SVG that overflows all look identical in rc. Shipping more than one document? `python3 scripts/deploy_html.py out *.typ --shared-css --serve 8000`, then look at `index.html` and one document in the browser.

## Deep reference
`html-pdf-dual-target.md` — §1 feature/target matrix + standing banners, §2 error catalog E1–E9 (exact strings, rc), §3 the ignore census and the grep rule, §4 `html.frame` proof numbers, §5 the weby-is-not-a-reference trap, §6 the 8 authoring rules, §7 the dual-target ship checklist. `html-styling-css.md` — making the export look designed: the emitted tag census, the class-hook trap, `target()` vs `sys.target` vs `--input`, CSS-as-string, the `--root` sandbox, the wrong-but-green catalogue, and §9 the deploy script + installable `@local/typst-html` package. Templates: `templates/dual-target.typ` (rules live inline as comments), `templates/scratch-note.typ` (CSS hooks in use). Evidence: `experiments/html-css/report.md`, `experiments/weby/review.md` (corrections R1–R11), `experiments/codebase/review.md`.
