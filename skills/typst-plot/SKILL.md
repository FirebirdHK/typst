---
name: typst-plot
description: Typst plots — lilaq 0.6.0 (axes, series, legends, colorbars).
---

# Typst plots — lilaq 0.6.0 (axes, series, legends, colorbars)

**Trigger**: data plots — line/scatter/bar/stem/error bars, subplot grids, log/datetime axes.
**Start from**: `templates/figure-heavy.typ` (aligned lilaq panels, dual-target).

## Default path

1. Exactly one import: `#import "@preview/lilaq:0.6.0" as lq`. Re-importing another version
   is legal and last-wins — a file silently runs on 0.5.0 while claiming 0.6.0 (err01).
2. A diagram is a container element plus child plot objects: `#lq.diagram(width: ..., height:
   ..., xlabel: [...], ylabel: [...], legend: (position: ...), lq.plot(...), ...)`. Plot fns
   return data; shape fns return geometry. Every plot sits inside `lq.diagram(...)` or a
   child axis (`lq.yaxis(position: right, ...)` owns its own plots).
3. `lq.plot` = data series; `lq.line` = a 2-point shape, NOT a series. At ≥ 3 points it fails
   deep in `process-coordinates.typ`; at exactly 2 points it silently draws one segment
   (err09 — the sharpest naming trap in the package).
4. Compute data in-source: `#let xs = lq.linspace(0, 10, num: 50)` (`num:` is named);
   `lq.plot(xs, xs.map(x => calc.sin(x)), mark: none, label: [sin])`; `y` may be `x => f(x)`.
5. Sparse ticks by hand — defaults fuse into mush in small panels:
   `xaxis: (scale: "log", ticks: (0.01, 0.1, 1, 10, 100), subticks: none)`; ≤ 5 tick labels
   per 4cm panel. Scale shorthand: `xscale: "log"`, `yscale: "log"` (symlog exists).
6. Subplot grids: `show: lq.layout` inside the figure, then plain Typst `grid(columns: 2,
   row-gutter: 1em, column-gutter: 1em, lq.diagram(...), lq.diagram(...))`. Omitting the
   layout line compiles and silently misaligns rows by 17/11 px (err07).
7. Style via elembic shims, never `set`: `#show: lq.set-diagram(...)`, `lq.set-spine(...)`,
   `lq.set-tick(...)`, `#show lq.selector(lq.tick-label): set text(0.8em)`; raw
   `#set lq.diagram` is rejected (err04).
8. Ratios, not floats, for bar widths: `lq.bar(..., width: 80%)`; a float means data units
   (0.8 → 8px sliver bars on a sparse axis, measured @144dpi).
9. Verify by measurement, not compiles: fresh renders re-diff to 0 differing px against stored
   output (lilaq.md §4) because data is recomputed from source. Pixel-diff or spine-measure grid
   alignment; PNG @144dpi + vision for everything else.

## Fail modes → fix

| `exact error` (verbatim) | fix |
|---|---|
| `unexpected argument` @ `process-coordinates.typ:178:25` (≥3 pts) — silent single segment at 2 pts | data passed to `lq.line` → use `lq.plot` |
| `assertion failed: Unexpected named argument "tick-label-formatter"` | no such kwarg → `xaxis: (format-ticks: lq.tick-format.*)` |
| `panicked with: The provided value matches none of the given types. Found integer` | `scatter(size: 120)` panics at render time → array of lengths or one length |
| `unexpected argument` on the 3rd positional of `fill-between` | `y2` is named-only → `lq.fill-between(x, y1, y2: ...)` |
| `assertion failed: Cannot realize an aspect ratio of 1 with fixed y limits.` | fixed w/h + `aspect-ratio:` needs ≥ 1 limit side `auto` |
| `assertion failed: elembic: element 'diagram': unknown named field 'x_label'` | names are `xlabel`/`ylabel` — no underscore, no kebab |
| `only element functions can be used in set rules` | `#set lq.diagram` → `lq.set-diagram` / `lq.selector` |
| ``assertion failed: `plot()`: The dimensions for x (3) and y (2) don't match`` | equal-length numeric arrays, or `y` as `x => f(x)` |
| `cannot destructure integer` | 0.5.0 tuple callback under 0.6.0 → `vec.transform` takes individual args |
| *(no error — exit 0, wrong render)* `width: 0.8` float on a sparse axis | data units, not a fraction → `width: 80%` |
| *(no error)* grid without `show: lq.layout` | rows drift 17/11 px → add the layout line |
| *(no error)* a second `@preview/lilaq` import at another version | last import wins → one import line; grep `@preview/lilaq` before trusting a pin |

## Deviate safely

Free: cycle/palette, labels, legend position (`(position: left + horizon, dx: 100%)` for fully
outside), marks, cm sizing, series count. Floor (measured): one import line; `num:` for
`linspace`; `show: lq.layout` on every diagram grid; ratio bar widths; ≥ 1 auto limit when
w/h are fixed; sparse ticks with `subticks: none`; colorbar is a sibling diagram placed with
`box[... #h(0.5em) ...]` and one shared `set-diagram` for both dims. When NOT lilaq: polar
axes and true parametric primitives do not exist (`polar` appears nowhere in `src/` — sample
`t` yourself or drop to cetz); markup/annotation-heavy figures where TikZ-style drawing is the
content → a cetz scene; directed graphs → fletcher. No cetz bridge: a lilaq figure and a cetz
figure sit side by side as independent `figure`s. Escape hatch: if the API fights you, sample
data more coarsely, split the figure, or move the annotation off the curve — then re-measure.

## Verify

`scripts/verify.sh templates/figure-heavy.typ --html` (or your figure file). Vision-read
`.verify/page-*.png` @144dpi: fused tick labels, legends over data, twin-axis label sides, and
hairline misalignment are vision-class defects — and a green compile proves nothing for
`lq.layout` omission or bar width; re-render and diff, or measure spine x-positions.

## Deep reference

`lilaq.md` §1 (versions/deps), §3 (converged idioms), §4 (probe measurements), §5 (pgfplots
mapping), §6.1 (loud errors), §6.2 (silent failures), §7 (composition rules), §9 (ranked
pitfalls), §10 (verify checklist); `diagram-legibility.md` §2 P5 (tick fusion);
`experiments/lilaq/logs/` (byte-exact stderr for every probe class).
