# Working in this repo

Guidance for anyone — human or agent — editing this template. The README is the
reference for *using* it; this file is the short list of things that will bite you
while *changing* it.

## What this is

A Typst slide-deck template for the HKUST Firebird CTF team: `lib.typ` is the whole
library (palette, geometry, type scale, entrypoint `firebird(...)`, every component,
and the two layout gates), `template/` is the starter deck, and
`examples/showcase.typ` is the 28-slide demonstration deck that doubles as the
component documentation.

The slide layer is a **touying 0.7.4 theme**, not hand-rolled page machinery: pages,
subslides (`#pause`), counters, speaker notes and handout mode are touying's, and
`firebird(...)` is `touying-slides` configured with firebird's geometry, chrome and
gates. touying's own `detect-overflow` is off — our `fb-over` gate is stricter and
names the slide.

## The repo *is* the package

`typst.toml` at the root declares `firebird-slides`, and every deck in the repo
imports it by name:

#import "@preview/firebird-slides:0.3.0": *
```

That resolves to the working copy through a symlink into typst's package directory
(README → "Working on the template"). The consequences are load-bearing:

- **No relative imports, and no `--root`, anywhere.** A deck compiles with
  `typst compile deck.typ`, from any directory, exactly as a deck that installed the
  package does — that is the point: the repo is checked the way a user uses it.
- If a deck fails with "package not found", the symlink is missing or stale; nothing
  else in the repo is involved.
- Typst refuses to read outside the *project root*, which defaults to the input
  file's directory. This is why nothing here reaches into a parent directory.

## Verify with these, not by eye

```sh
typst compile --input gate=true examples/showcase.typ
typst compile --input gate=true template/main.typ
typst compile tests/contrast.typ
```

Add `--font-path vendor/fonts` (or `TYPST_FONT_PATHS=$PWD/vendor/fonts`) if IBM Plex
is not installed on the machine; CI sets that variable. Clone with
`--recurse-submodules` — BlobCats is a submodule and a missing checkout fails the
compile on the first `#blobcat(...)`. All three exit 0 when clean.

The gates are Typst code in `lib.typ`, switched on by the `firebird(gate:)` parameter
or `--input gate=true`, and they fail the compile with the slide named:
`debug: true` (or `--input debug=true`) draws the dashed body box and stamps the
overflow badge — both are drawn by the chrome block in `slide()`, the one place
`place` is anchored to the slide; nested inside a body it lands off the slide.
`gate` reports *every* offending slide in one compile (Typst collects the panics).
Both inputs are independent of the deck's front matter: a deck that sets neither
still gates.

A slide that is too full gets **split or trimmed** — never shrunk. Type size and body
budget are the deck's whole look, so a shrink is a defect, not a fix. Code and
terminals render at the deck's code size, full stop: there is no shrink code path
and therefore no way for a snippet to quietly get smaller.

## There is no script, and that is deliberate

Typst 0.15 has no filesystem write API, no directory listing and no subprocess, and
WASM plugins get no FS either; `--root` sandboxes *reads*. So the only things that
could never be Typst were: installing the package, installing fonts, and listing the
BlobCats directory. All three are now something other than a host program:

- the package link is one documented `ln -s` (README), which is also the upstream
  local-development workflow;
- fonts are a `--font-path`/`TYPST_FONT_PATHS` or a copy into the system font dir;
- the cat name table is committed data in `assets/blobcats.typ`, one line per cat.

**Do not add a script back for something one command does.** If you genuinely need a
host program, it has to buy more than it costs: say so here, and keep it out of the
way of `typst compile deck.typ`, which must keep working with no flags and no setup.

## Standing instructions

Strict rules from the maintainer. Follow them in every session, and when the
maintainer issues a new strict rule, add it here so other agents follow it too.

- **Visual changes are verified by a vision model.** Render the affected pages
  (`typst compile --format png`) and have a vision subagent (e.g. glm-5.3-flash)
  inspect them before reporting done. Measurement beats eyeballing.
- **Code is not commented.** Names and structure carry the meaning; a comment is
  allowed only for a fact the code cannot express — a Typst 0.15/touying bug, a
  licence attribution, a non-obvious external constraint.
- **Docs are present tense** and cover only what exists now — no history, no
  migration notes, no "how we got here".
- **Use subagents liberally**, even for two-minute jobs; parallel beats serial.

## Authoring conventions

- **Spacing is the template's job — one rhythm, 0.8 em.** Paragraphs, blocks, every
  boxed component's `above`/`below`, and the title→body gap are all 0.8 em, and
  Typst collapses adjacent spacings to the max. A deck must never hand-space with
  `#v(...)` or `#align` gymnastics — hand-spacing is what makes a deck look uneven.
  Inside boxes the padding is absolute: 20 pt prose, 16 × 14 pt mono, 12 × 9 pt
  tables (tokens in `geo`).
- **Boxed components must pin their children's `above`/`below` to 0pt** (callout
  head/body, code file bar/body, terminal title/body): the global block spacing
  otherwise opens a ~17 pt seam *inside* the box.
- **Lists hang at the margin** — markers align with prose and box edges, text hangs
  in by 0.6 em. Don't re-indent lists.
- **One idea per slide.** ~11 single-line bullets, 12 lines of code with a file
  bar, or an 8-row table (321 pt body budget at the default sizes). Over budget →
  split the slide.
- **Every snippet gets `file:` (or `lang:`).** `lines:` defaults to false; turn it on
  only when the prose points at a specific line.
- **Callouts.** Minimal shape only: accent head + thin left bar, no fills. Light
  kinds (`definition`, `exercise`, `claim`, `remark`) quote or restate; dark kinds
  (`theorem`, `example`, `proof`, `insight`) state a result. One per slide, last.
- **Colour.** `pal.ink` is body text. `brand-a`/`brand-b` fills are for rules, bars and
  pills; accent *text* uses the `-ink` variants, which clear 4.5:1. `tests/contrast.typ`
  asserts every pair — add new pairs there when you add a colour.
- **Vertical geometry is absolute**, so `title-y`/`body-bottom` are not derived from the
  page size: a new aspect ratio needs those re-derived, not just a paper swap.
- Components take **content**, not paths (`#image-row((image("a.png"),))`), because
  Typst resolves `image()` paths in the file where it is written.
- **A new component that can overflow a slide belongs behind `measure()`** — that is
  what makes the deck's capacity numbers true for every deck, not just this one.

## BlobCats

`assets/blobcats/` is the [BlobCats] git submodule (Apache-2.0, licence at its
root; the PNGs live under `PNGs/BlobCats/`) and `assets/blobcats.typ` is the
name table that `#blobcat` resolves against. The table has to exist — Typst
cannot list a directory — and it is what turns `"hyperthink"` into a path and
powers "did you mean". Keys are the lowercase filename with `BlobCat` and the
separators dropped; adding a cat means adding one line. `#blobcat-list()` renders every
name, which is how you browse the pack without leaving Typst. Clone with
`--recurse-submodules` or run `git submodule update --init`.

[BlobCats]: https://github.com/DuckOfDisorder/BlobCats

## Typst 0.15 traps

- A `show` rule only reaches content in its **own block scope** — a `show raw.line:` inside
  an `if` does not affect a `raw(...)` call written after it.
- `layout(area => ...)` in a body that is not height-constrained reports the *whole
  page's* remaining height, so any shrink-to-fit built on it never fires. The
  template therefore has no shrink path at all: code renders at the deck's code
  size and a too-tall block is an ordinary overflow.
- `measure()` does not collect metadata, so a marker emitted from inside it is safe and
  will not double-report.
- `show raw.line: it => grid(...)` makes each line block-level, so `block(spacing:)` is
  added on top of `par.leading` — zero the block spacing and drive the pitch with `par.leading`.
- Never pre-wrap source text per line: `raw(line)` per line destroys syntax highlighting.
  Emit one `raw(block: true)` and let Typst soft-wrap; `raw.line` numbers logical lines only.
- `raw` ignores inherited fonts — use `show raw: set text(font:, size:)`. A tmTheme's
  `fontFamily` is ignored; only `foreground`/`fontStyle` work.
- No ternary; `$ x $` is display math and `$x$` is inline; XOR is `xor`/`plus.o` (`\xor` is ∨).
- Closures cannot mutate outer bindings — fold, do not `push`.
- Any `state.get()` forces `context` on the enclosing component, including lazily-taken
  branches such as a table cell closure.
- `text()` has no `leading`; `block()` has no `align`; `pad()` has no width/height;
  `place()` has no width — use `put(x, y, w, body)`. A `block` with a fixed height
  and auto width shrink-wraps, silently defeating `align(center)` inside it — pin
  `width: 100%` wherever children must center.
- `calc.min/max/clamp` reject lengths: divide by `1pt`, clamp, multiply back.
- `counter.reset()` is `update(0)`; `counter.final()` is an array; `outline.entry` fields
  are only `level`/`element`/`fill`.
- A panic message built with `+` must not depend on `str()` of content — only a real
  string is safe to quote back. The gates report the slide number and the `title:` when
  it is a string.

## touying traps

- The `touying-slide-wrapper(self => …)` callback runs **pre-layout**: no
  `state.get()`, no `counter.get()`, no `measure()`, no `page.width` there. Read
  config from `self` (`self.store`, `utils.get-page-dimensions(self)`) and do all
  measuring inside the `setting:` closure, which runs at layout time.
- Touying **wraps stray non-slide content into a slide**: anything before the first
  `#slide` materialises a phantom first page with the chrome on it. Never emit
  leading document content from `firebird(...)`.
- Touying **drops `start-part` on the outer call**, so even `hide[…]` seeds at the
  document top vanish. Seed per-page through `config-common(page-preamble:)`
  instead — it realizes in the page header, before any slide's `measure()`.
- `#pause` et al. are marks created by slide calls: **never call a slide function
  inside a `context`** ("unsupported mark" at layout).
- Component config must be merged through touying's own dicts (`config-page`,
  `config-common`, `config-store`, …); a slide-level override is the named
  `config:` argument, not a positional one.
- Our states (`fb-type`, `fb-fonts`, `fb-meta`) still exist because components have
  no `self`; the page preamble re-seeds them from the store every page, which is
  idempotent under pause-repetition.

## Version policy

typst is pinned to **0.15.1** and touying to **0.7.4** (`.github/workflows/build.yml`,
`typst.toml`'s `compiler`, `lib.typ`'s import). Do not bump either as part of
unrelated work: rendering is not byte-reproducible between versions and the gates
are numeric, so a version bump moves the overflow numbers and must be a change of
its own, with the three gate commands green on the new version before it lands.

## Adding third-party assets

Anything vendored must keep its licence alongside it and be listed in `LICENSE`: the
BlobCats submodule carries its Apache-2.0 licence at its root and the bundled fonts
are SIL OFL.
Keep the attribution comment in `assets/blobcats.typ` — it is the only place a reader of
the *installed package* sees it.
