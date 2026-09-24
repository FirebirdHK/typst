---
name: typst-slides
description: Typst slides — touying 0.7.4 by default.
---

# Typst slides — touying 0.7.4 by default

**Trigger**: building a deck (any page-per-slide deliverable).
**Start from**: `templates/slides.typ` (touying 0.7.4 + `themes.simple`, PDF-only) — or
`templates/deck.typ` when the deck must also work in a browser.

## Two decks, two jobs

| You need | Use | Why |
|---|---|---|
| A PDF deck with themes, overlays, speaker notes | `templates/slides.typ` (touying) | richest slide model; **PDF-only** |
| A deck that is *also* a web page | `templates/deck.typ` (no packages) | one `#slide(title: …)[…]` = one 16:9 page **and** one `<section class="slide">` |

**No package's HTML export is a deck** (measured 2026-09-22, `experiments/deck-html/`):
touying 0.7.4 → 2,023 B, 0 `<section>`, 0 classes, and *every* slide heading exported as the
LAST slide's title (heading text is read from mutable state at export time); polylux 0.4.0 →
headings survive, slide boundaries do not (`pagebreak was ignored`), 3 slides become one flat
`<h2>/<p>` stream; deckz 0.3.1 → its CeTZ canvases export as empty `<div></div>` (251 B, cards
gone). None emits per-slide structure or a class to hang CSS on, so no stylesheet can turn
their HTML back into a deck — the structure has to be written by the author, which is what
`templates/deck.typ` is (~300 lines, four helpers: `slide`, `title-slide`, `section-slide`,
and the counter-driven number). Verify it with `--html`; the paged page count must equal the
HTML `<section class="slide">` count (that equality is the deck's overflow gate).

## Default path (touying)

1. Import and configure exactly as the template does:
   ```typst
   #import "@preview/touying:0.7.4": *
   #import themes.simple: *   // or metropolis | dewdrop | aqua | stargazer | university
   #show: simple-theme.with(
     aspect-ratio: "16-9",    // 841.89 x 473.56pt; or "4-3"
     config-info(title: [Deck title], subtitle: [One line of framing],
                 author: "Your name", date: datetime.today()),
     config-common(breakable: false, clip: true, detect-overflow: true),
   )
   ```
   The `config-common` line is the strict one-liner: 1 slide = 1 page, clipped content,
   overflow warning on stderr — still exit 0.
2. Headings are the slide model: `= Section` makes a divider slide, `== Slide title` makes a
   content slide. Kill auto dividers with `new-section-slide-fn: none`.
3. Overlays: `#pause`, `#uncover("2-")[...]`, `#only(3)[...]`, `#alternatives[a][b][c]`.
   Callback style needs `repeat`: `#slide(repeat: 3, self => [...utils.methods(self)...])` —
   omitting it silently drops revealed content (e14).
4. Speaker notes: `#speaker-note[...]` (no ghost page). Second-screen builds double page width
   (1683.78pt) — never ship that as the audience PDF.
5. Run the overflow protocol — touying overflow is rc=0:
   a. expected pages = content slides + auto dividers + planned `#pagebreak()`s;
   b. `typst compile deck.typ 'out/{p}.png'`; assert `ls out/*.png | wc -l` == expected (exit
      code is not an oracle: overflow probes exit 0 with empty stderr);
   c. grep stderr for `[touying]`, not just `overflow` — the emitted form is `warning: …
      [touying] detecting slide content overflow at page 3 (slide 3, subslide 1, content
      height: 2035.3pt, available height: 373.56pt)`;
   d. vision the first/last page and any count mismatch: furniture-less ghost pages, spill
      pages missing the title, `(ii)` continuations you never planned.
6. Handout: separate build with `handout: true`; re-run the page count on that artifact.
7. Page count = exported files. Never trust `counter(page).final()` inside touying (reported 3
   vs 5 real) or theme counters (footer showed `2 / 3` on physical page 2).

## Fail modes → fix

| `exact error` (verbatim) | fix |
|---|---|
| `panicked with: A title is required` | diatypst needs `title:` even with `first-slide: false` |
| `assertion failed: Invalid aspect ratio "16x9". Expected format: "W-H"…` | `aspect-ratio: "16-9"` |
| ``module `themes` does not contain `nonexistent` `` | themes: aqua, default, dewdrop, metropolis, simple, stargazer, university |
| `unknown variable: simple-theme` | themes are a separate import → `#import themes.simple: *` |
| ``the argument `fn` is positional`` | `#alternatives-fn(i => [...], end: 4)` — `fn` positional; `end`/`count` required |
| `unknown variable: pause` (polylux) | polylux has no `#pause` → `#uncover("2-")` / `#later`, or use touying |
| `panicked with: A note must either be a string or a raw block` | polylux pdfpc helpers are dead → raw `#metadata((t:"Note", v:"…")) <pdfpc>` or touying `#speaker-note` |
| *(no error — exit 0)* `#pause` without a theme | silently dropped → always `#show: *-theme.with(…)` and run the count gate |
| *(no error)* `#slide(repeat: n, self => …)` without `repeat` | silently empty → `repeat` is mandatory in callback style |
| `panicked with: slide 1 [Deliberately oversized hand] is 923pt taller than its body box — split the slide or trim it; never shrink the type.` | firebird's measured-box gate, opt-in `--input gate=true`; split or trim |

## Deviate safely

Free: theme, palette, aspect ratio (`"16-9"` / `"4-3"` / custom `W-H` from the 841.89pt base),
slide content, overlay choreography. Floor: keep `touying:0.7.4`; the strict `config-common`
one-liner; the page-count contract (count files, never counters); one idiom per package —
never mix polylux `#slide` with touying headings. Alternatives: **diatypst 0.9.3** only for
small fully static decks with a hard page-count gate; **polylux 0.4.0** only when minimal deps
are mandatory and you verify counts yourself; **deckz is cards, not slides**
(`unknown variable: slide`) — the slide package owns chrome, deckz only draws canvases inside
slide bodies. Escape hatch: if a theme fights the content, swap themes or use `#slide`
directly, then re-run the count gate — the floors here are overflow discipline, not aesthetics.

## Verify

`scripts/verify.sh templates/slides.typ` — **no `--html`**: a touying deck is PDF-only (its HTML
export is a text dump, see above). `scripts/verify.sh templates/deck.typ --html` — **with**
`--html`: the hand-written layer is dual-target by construction. Grep the stderr for
`[touying]` (overflow warnings land there at rc=0 — they are load-bearing) and for
`warning:`; dividers are intentionally sparse, so SPARSE lines are expected
(`VERIFY_MIN_INK=0.01` silences them). Then read EVERY `.verify/page-*.png` — or a 16-page
contact sheet (verification-loops.md §3) — and assert the page count above. For the dual-target
deck the gate is an equality: PDF pages == `<section class="slide">` count in the HTML
(measured baseline: 6 slides → 6 pages, `page set rule was ignored` the only warning).

## Deep reference

`presentations.md` §1 (decision matrix), §3 (skeletons), §4 (overflow + verification
protocol), §5 (handout/speaker notes), §6 (error → fix catalog), §7 (`{p}` export templates);
`verification-loops.md` §2 (gate blind spots), §3 (contact sheets), §4 (page-count formula).
