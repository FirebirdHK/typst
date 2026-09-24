---
name: typst-author
description: Write, debug, or verify Typst documents (PDF, HTML, slides, figures, plots, math, code listings) using the personal typst-research catalogue — routes to condensed skills, 7 known-good templates, 16 golden examples with 128 measured failure probes, the verify.sh loop, and 26 measured reference chapters. Use whenever the user asks for a Typst document, .typ file, figure/plot for a paper, deck, or dual HTML/PDF output.
---

# Typst authoring router

You are writing Typst. The catalogue at `/Users/wyli/benchmark/typst-research`
holds measured answers — use them instead of improvising.

## Always do this

1. Start from a template, not from scratch: `templates/*.typ` (8 files, each
   self-contained, each verified by `scripts/verify.sh`).
2. After ANY edit: `scripts/verify.sh <file>.typ [--html]` — it compiles,
   classifies diagnostics (ERROR/BLANK/SPARSE/DROP/WARN), renders page PNGs.
3. **Vision-read the `page-*.png` files before claiming done.** rc=0 lies:
   figures render blank at rc=0; content silently drops between PDF and HTML.
   Near-empty pages are SPARSE-warned — judge them visually yourself.
4. If the catalogue has no answer and you must guess: say so, then measure
   (`verify.sh` + one render) rather than trusting memory.
5. Before shipping: `scripts/pdf-audit.py FILE.verify/FILE.pdf` (content
   insets + per-role type minima; `--min-size 13.5` for slides) and, for a
   set of documents, `scripts/deploy_html.py OUTDIR *.typ --shared-css` —
   that injects the `<title>` the export never emits and builds an index.
   Touched colour? `typst compile scripts/contrast.typ` must still pass.

## Route by intent

| You need | Read first | Template |
|---|---|---|
| Note / explainer / scratch doc | `skills/typst-scaffold.md` | `scratch-note.typ` |
| Multi-section report, refs, TOC | `skills/typst-doc-structure.md` | `report.typ` |
| Lecture notes / theorem environments | `skills/typst-doc-structure.md` (→ `typography-utils.md`) | `notebook.typ` |
| Slides / deck (PDF) | `skills/typst-slides.md` (→ `presentations.md`) | `slides.typ` |
| Deck that is also a web page | `skills/typst-slides.md` §Two decks | `deck.typ` |
| Paper / arXiv-style HTML | `skills/typst-html-pdf.md` item 11 (→ `html-styling-css.md`) | `report.typ` |
| Diagrams, drawings (fletcher/cetz) | `skills/typst-figure.md` (→ `fletcher-diagrams.md`, `cetz.md`) | `figure-heavy.typ` |
| Data plots (lilaq) | `skills/typst-plot.md` (→ `lilaq.md`) | `figure-heavy.typ` |
| Code listings (codly) | `skills/typst-code-listings.md` (→ `codly.md`) | `code-heavy.typ` |
| Math, proofs, physics | `skills/typst-proofs-math.md` (→ `base-math.md`, `physica.md`, `curryst.md`) | — |
| Markdown → Typst (cmarker) | `skills/typst-markdown-authoring.md` (→ `cmarker.md`) | — |
| PDF **and** HTML from one source | `skills/typst-html-pdf.md` (→ `html-pdf-dual-target.md`) | `dual-target.typ` |
| Ship/host the HTML (site, package) | `skills/typst-html-pdf.md` §12–13 (→ `html-styling-css.md` §9) | — |
| Debug an error / trust a result | `skills/typst-verify.md` (→ `verification-loops.md`, `diagram-legibility.md`) | — |
| Package choice (deckz, glossarium, …) | `README.md` corpus table → chapter | — |

## Non-negotiables (measured, not stylistic)

- Compile BOTH targets whenever you claim dual-target: one rc says nothing
  about the other; `--features html` on both (verify.sh handles it).
- Legibility floors for figures: label text ≥ 9pt, `node-inset ≥ 4pt`,
  `label-sep ≥ 4pt`, ≤ 6 tick markers per row, captions ≤ container width.
- One spacing rhythm — never sprinkle `#v()`; anchor movable blocks to the
  edge they grow away from.
- Style built-ins with `set`, never wrap them in show rules (0.15 quirks).
- Don't restyle `emph`/`strong` (0.15 show-rule quirks: `emph` italics are a
  toggle, so a wrapping show rule can leave it upright). `strong` inside
  `link` is fine — the reported fill loss did not reproduce
  (`taxonomy-patch-proposals.md` P6).

## Escape hatch (adaptable, not rigid)

Anything here can be deviated from — that's why verify.sh exists. Change the
approach, re-run verify, look at the render. The catalogue is evidence, not a
straitjacket; if a rule fights the document, measure both and keep what wins.
