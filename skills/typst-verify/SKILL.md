---
name: typst-verify
description: Verify: the loop that tells you the truth.
---

# Verify: the loop that tells you the truth
**Trigger**: after ANY edit to a `.typ`; before claiming done; whenever rc=0 and you are unsure anything rendered; before shipping any figure.
**Start from**: the file you just edited (no template). Inner loop: a standalone harness file that imports the real document/packages and holds only the construct under test — seconds per compile instead of a full-document build.

## Default path
1. Run the ladder: `scripts/verify.sh FILE.typ [extra typst args ...] [--html]`. It (a) compiles the PDF, (b) optionally compiles HTML with `--features html`, (c) classifies each stderr log, (d) renders page PNGs and measures ink/blank. Output lands in `FILE.verify/` (`FILE.pdf`, `FILE.html`, `pdf.stderr`, `html.stderr`, `page-*.png`).
2. Read the report classes, not the exit code alone: `ERROR` compile/panic → exit 1; `BLANK` page with ZERO ink → exit 1 (nothing landed); `SPARSE` ink bbox < 5% of the page but text present → warn, judge visually; `DROP` `was ignored during <other> export` → warn, content disappears on ONE target; `WARN` anything else (fonts, convergence, `[touying]`); `EXPECT` html banner / page-set-rule noise → known fine.
3. rc=0 is mechanical only. **Vision-read the `.verify/page-*.png` files before claiming done** — every page at ~1.3×, 3× on anything suspicious (formulas, tables, diagrams), or a contact sheet (16 representative pages in one image) for wide sweeps. Ask one-sentence verdict questions ("is any text cut off?", "are the table rules doubled?"); vague "looks good?" prompts produce slop.
4. Re-verify vision findings mechanically when possible: glyph span dump for silent style loss (bold/italic/fill), row-darkness profiling for doubled rules, PyMuPDF text extraction for structure.
5. Never trust one instrument. The firebird overflow gate (`typst compile --input gate=true`) measures only the body box: title/TOC slides carry no marker, and body overflow landing in the footer zone is invisible — the winning loop re-measures the **rendered PDF** (`page.get_text("blocks")`, max block `y1` vs the ~439.6pt body-box line), which caught a 26.8pt overflow the green gate had missed.
6. Structural invariants: page-count formula `pages = 1 + sections + slides + pauses` asserted after every compile (catches stray blanks and runaway pauses); independent re-derivation of every number (recompute, never copy); pixel-identity diff before/after when the *template* is what changed.
7. Figure gate — 15-step legibility checklist: (1) render the PNG, (2) blank/ink check, (3) zoom pass at 100% **and** 55%, (4) font floor ≥ 9pt (≥ 7pt post-scale; node text 10pt), (5) collision sweep at 200%, (6) label-pos 0.35–0.65, (7) corner/bend turn cells empty, (8) border-kiss test (inset ≥ 5pt), (9) clip test at every edge, (10) sparse ticks (≤ 5 labels per 4 cm, `subticks: none`), (11) rotations ≤ 45° and ≥ 8pt, (12) `fletcher debug: 0`, no `repr(style)` labels, (13) hygiene (delete scratch/error renders — never ship `err-*` as figures), (14) contact-sheet eyeball, (15) breathing room (`set figure(gap: 1.1em)`; drawing padding on HTML) — measured: default body↔caption gap is ~5pt, a collision.
8. Severity map for what you see: **S1 ships broken/unreadable** — blank render, unreadable micro-text, clipping at container edge, error-demo shipped as figure, near-empty leftovers; **S2 ships but wrong** — label-on-edge/node/struck text, cramped borders, crowded axes, debug strings as labels, stacked duplicate labels, corner route through a node, rotated collisions; **S3 minor** — touching boxes, duplicates, orphan marks.
9. Then audit the **rendered** file, not the source: `python3 scripts/pdf-audit.py FILE.verify/FILE.pdf` — content insets to each page edge (full-page background fills excluded, so a *negative* inset is real overflow past the page, which the ink/raster method cannot see because it clamps at 0), per-role type minima, and the embedded-font census (a substituted font shows up here and nowhere else). `--min-size 13.5` for projected slides. For colour: `typst compile scripts/contrast.typ` asserts 23 role pairs with per-role floors and **fails the compile** on a violation — run it after any palette change; it caught a 4.32:1 caption grey and a 1.38 structural hairline in this repo's own stylesheet.
10. Role, not size, decides a type floor: prose 9 pt, code 8 pt, small prose 7.5 pt, small code 7 pt; math (including mitex's `NewCM10`, which carries no "Math" in the font name) and sub/superscripts are ignored, and full-page backgrounds are not content. A single 9 pt floor called the report's 8.8 pt inline code, 7.5 pt table footnotes and base-layouts' 8 pt captions all defects.
11. A document whose HTML is a few hundred bytes is a PDF-first source, not a styled page — the export dropped its content at rc=0 (codly's chrome becomes four empty `<div></div>`). `scripts/deploy_html.py` refuses to publish it; fix the source (frame the listing) rather than shipping the blank.

## Fail modes → fix
| Class / exact string | Fix |
|---|---|
| `BLANK` (page rendered with ZERO ink) | nothing landed — check the figure reached the page; the 8 corpus exemplars were byte-identical **11,578 B pure-white A4** at rc=0 |
| `SPARSE` (ink bbox < 5%) | vision-read: designed title/divider pages are legit → re-run `VERIFY_MIN_INK=0.01`; accidental near-empty → fix or delete |
| `DROP`: `{elem} was ignored during paged export` / `{elem} was ignored during HTML export` | content vanishes on one target at rc=0 — branch on `context target()`, replace the element, or accept and document |
| ``page set rule was ignored during HTML export`` | EXPECT noise unless you relied on `#set page` styling for HTML — it has no HTML meaning |
| `warning: document did not converge within five attempts` | state/query fixed-point loop — treat as failure, not noise |
| ``warning: query for a unique element labelled `<zz>` did not stabilize`` | same family; a non-converging label/count loop |
| ``warning: `show page` is not supported and has no effect`` | warning-level = exit 0: an exit-code-only harness passes the no-op — use `#set page(...)` |
| `warning: unknown font family: …` | exact family case, or pass `--font-path`; catch it before rendering |
| green gate + clipped content | gate blind spots (marker-less slides, footer band) — PyMuPDF bottom sweep: max text-block `y1` vs ~439.6pt |
| label ≈ 3pt / effective < 7pt after scaling | micro-text defect (S1) — ≤ 6 markers per row, 9pt+ labels, pre-bump when display scaling < 60% |
| labels ON the path / on nodes | `label-sep ≥ 4pt`, `label-pos` 0.35–0.65, one label per edge, annotations off the curve |
| "I looked at it" without a rendered PNG | not a verification — render, then look; a past agent that claimed vision while only measuring was called out on it |
| `pdf-audit: p1: content -26.6pt from a page edge` | content sits past the page boundary (backgrounds excluded, so this is real) — measured on `experiments/deckz/verify/e09_overflow_in_firebird_slide.pdf`, whose subject *is* the overflow |
| `pdf-audit: prose span 8.9pt below its 9.0pt floor` | check the role before "fixing": inline code (8 pt floor), captions/footnotes (7.5), and math are separate roles — a *body* paragraph under 9 pt is the real defect |
| HTML output of a few hundred bytes, or several empty `<div></div>` | PDF-first source exporting at rc=0 — frame the dropped content (`html.frame` guarded by `target()`) or document it as PDF-first |
| HTML has N `<svg>` and the page still shows nothing | **presence ≠ visible.** A framed block collapses: `html.frame(raw(…, block: true))` exports `viewBox="0 0 1 235.67"` / `width="1pt"` — rc=0, SVG counted, `verify.sh` PASS, browser blank. Assert the SVG's **width attribute** (`> 50pt`), or render the page. Fix: `html.frame(box(width: <the page's text measure>, …))`; `width: 100%` collapses too |
| `contrast.typ` fails to compile | a palette pair is under its role floor — the compile *is* the assertion; darken the pair, do not lower the floor without re-measuring every role |

## Deviate safely
- **Free**: zoom levels, contact-sheet size, which vision backend, extra typst args (`--input gate=true`), and thresholds via `VERIFY_MIN_INK` — the script is evidence, not a straitjacket.
- **Measured floors**: rc=0 is never "done"; never claim vision without a rendered PNG (the firebird overflow gate's under-reporting is the proof that one instrument lies); ink bbox ≥ 5% of the page; edge-label font ≥ 9pt source / ≥ 7pt post-scale; `label-sep ≥ 4pt`; node inset ≥ 4pt (5–6 normal); tick labels ≤ 5 per 4 cm; error-demo renders never ship.
- **Escape hatches**: a vision backend can die mid-session — fall back to the MCP `analyze_image` route (different transport) or programmatic pixel analysis; for a huge deck, harness compiles for the inner loop and partitioned page-range QA waves for the outer; when the catalogue has no answer, measure (compile + one render) instead of trusting memory.

## Verify
`scripts/verify.sh <file>.typ` and, for dual-target, `scripts/verify.sh <file>.typ --html` (expect rc=0 both targets, only EXPECT lines, no DROP). Then open `.verify/page-*.png`, then `python3 scripts/pdf-audit.py .verify/<file>.pdf` (geometry + type roles + fonts; `--min-size 13.5` for decks) and `typst compile scripts/contrast.typ` if you touched colour. Single figures: `typst compile figure.typ figure.png` plus the PIL ink assert — `lo, hi = Image.open("figure.png").convert("L").getextrema()`; `assert (lo, hi) != (255, 255)` = `BLANK RENDER` — then steps 3–14. Legibility floors to eyeball in the PNGs: 9pt+ labels, no text within 4pt of a box stroke, no clipping at the figure/block border, sparse ticks, no debug strings.

## Deep reference
`verification-loops.md` — §2.2 the gate's under-reporting, §2.3 PyMuPDF bottom sweep, §3 vision loops, §4 page-count formula, §5 independent re-derivation, §7 gate hygiene, ranked-takeaways table. `diagram-legibility.md` — §1 defect catalog with S1/S2/S3 severities, §2 before/after fix patterns + measured thresholds table, §3 the 15-step checklist, §6 one-page ship gate. `html-styling-css.md` §7/§9 — the HTML-specific loop and the deploy gate (empty exports, name collisions). Probe evidence: `experiments/vision-qa/report.md`, `experiments/vision-qa/probes/p{1..10}-*.typ`, `experiments/html-css/report.md`.
