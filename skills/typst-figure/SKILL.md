---
name: typst-figure
description: Typst figures — fletcher by default, cetz for geometry, maquette for meshes.
---

# Typst figures — fletcher by default, cetz for geometry, maquette for meshes

**Trigger**: any drawing — node/edge diagram, engineering figure, 3D mesh render.
**Start from**: `templates/figure-heavy.typ` (fletcher + lilaq, dual-target clean).

## Default path

1. Default to fletcher for nodes + edges; import pinned exactly:
   `#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge`
2. Build with typed node constructors and semantic palette constants, not raw node dicts at
   every site — a reviewer can then check row structure at a glance. Label content uses
   markup `[*Alice*]`, never `#strong` (fletcher-diagrams.md §1, §7).
3. Stay above the measured legibility floors (diagram-legibility.md §2): `label-sep ≥ 4pt`;
   node `inset ≥ 5–6pt` (4pt min in dense grids); labels ≥ 9pt source, ≥ 7pt after scaling;
   node text 10pt; `label-pos` 0.35–0.65; grid spacing ≥ (30,18)pt; ≤ 6 markers per row (cap
   grid n ≤ 12); ≤ 5 tick labels per 4cm panel; rotated labels ≤ 45°.
   **Air is a floor too** (checklist step 15): `#set figure(gap: 1.1em)` for body↔caption
   (Typst's default ~5pt reads as a collision), and on HTML the drawing gets its own padding
   from `assets/typst-html.css` (`figure svg, figure img { padding: 0.7em 0.35em }`) because an
   exported SVG's viewBox is tight to the ink — an edge label defines its top edge.
4. Dual-target: wrap ONLY the drawing in `html.frame(...)`; the caption stays semantic text
   outside it (`templates/figure-heavy.typ`; html-pdf-dual-target.md §4).
5. Iterate figure-first: one-page harness → compile → render PNG → vision-read → adjust
   bend/label-pos/spacing → repeat (fletcher-diagrams.md §8; zoom 3× on arcs). TikZ bends do
   not transfer: 70°-class bends land at ±45°, row swoops at 16°.
6. Choose cetz when geometry, precise coordinates, shapes + intersections + layers matter and
   no auto-layout is needed. Pin `@preview/cetz:0.5.2`; never ≤ 0.2.x on 0.15.1 (hard
   crashes). Midpoint is `(a, 50%, b)` — `(a, 0.5, b)` is 0.5 *units* (12.51% of a 4-unit
   line, measured).
7. Choose maquette only for real meshes (STL/OBJ/PLY → shaded image, one atomic element — it
   is not a layout package). Pin `@preview/maquette:0.1.3`; `read(..., encoding: none)` for
   binary meshes; always pass named `width` (default display 500pt × 500pt); expect no
   warnings ever — pixel-diff against a baseline when correctness matters.
8. Compose fletcher + cetz at the Typst-content level only: fletcher bundles cetz 0.3.4, your
   0.5.2 is a separate instance, and elements never cross (cetz.md §9).

## Fail modes → fix

| `exact error` (verbatim) | fix |
|---|---|
| `Unrecognised value passed to diagram:, context()` | raw `cetz.canvas(...)` as a fletcher child → compose at content level (cetz.md §9) |
| `panicked with: Expected \`length\` to be of type length, got 50%` | cetz `canvas(length:)` takes a length → `length: 1cm` or `layout(ly => ...)` |
| `error: assertion failed: Unknown mark '->'` | cetz marks are mnemonics → `mark: (end: ">")` |
| `dictionary does not contain key "body"` (tree callback) | use `n.content`; spread children `(root, (a...), (b...))` — one wrapped array is the error |
| `panicked with: Anchor 'north' not in anchors ("centroid",) for element 't'` | closed `line(..., close: true)` exposes only `centroid` — use vertex coords |
| `error: unresolved import` under `plot` | plot left cetz at 0.3.0 → `@preview/cetz-plot` (also on fletcher's bundled 0.3.4) |
| `expected relative length or auto, found integer` | named `width` is a display length; int pixels only in the positional dict |
| `failed to convert to string (file is not valid UTF-8 …)` | binary mesh → `read(..., encoding: none)`; match `get-*info` to the format |
| `package found, but version 0.2.0 does not exist (latest is 0.1.3)` | pin `@preview/maquette:0.1.3`; GitHub's 0.2.0 is unpublished |
| *(no error — exit 0, wrong render)* `#draw.line(...)` outside `canvas` | body text becomes `((..) => ..,)`; keep every draw call inside `canvas({ ... })` |
| *(no error)* `dash-pattern:` / unknown style keys | silently ignored, dashes render solid → `stroke: (dash: "dashed")` |
| *(no error)* `color: "red"` (maquette) | CSS names give neutral gray; hex strings only |

## Deviate safely

Free: palette, per-diagram spacing (tuned once, then left alone), shapes, arrow style, package
choice when the task is better served elsewhere. Floor: the legibility numbers are measured
thresholds, not decoration; the version pins are inspection points; never mix API assumptions
across the two cetz instances. Determinism: no seeding needed anywhere — renders are
pixel-reproducible across recompiles (measured 0 differing px, lilaq.md §4); the only RNG in
this stack is lilaq's `vec.jitter` (suiji, lazily imported). Escape hatch: if a floor blocks
the figure, change it, re-render, and vision-check at 100% and 3× zoom.

## Verify

`scripts/verify.sh templates/figure-heavy.typ --html` for dual-target work (otherwise
`scripts/verify.sh <your-figure.typ>`). rc=0 does not mean the figure landed: a drawing that
never reached the page still compiles (BLANK page class). Vision-read every
`.verify/page-*.png` at 100% and zoomed: labels sitting on edges, text overlapping nodes,
piled tick labels, raw debug strings shipped as labels, empty rects; run the 15-step checklist
(diagram-legibility.md §3) for figures that matter.

## Deep reference

`fletcher-diagrams.md` §1 (skeleton, typed constructors), §2 (bend table), §4 (bit-string
nodes), §6b (y grows downward), §8 (iteration loop); `cetz.md` §2 (mental model vs TikZ),
§4 (midpoint/angles), §5 (probe measurements), §6 (loud errors), §7 (silent errors), §9
(composition rules); `maquette.md` §2 (width semantics), §3 (camera precedence), §4 (no
validation), §6 (performance), §8 (checklist); `diagram-legibility.md` §2 (measured
thresholds, P1–P10), §3 (15-step checklist).
