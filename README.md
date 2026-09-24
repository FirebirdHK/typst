# firebird-slides

Deck template for the HKUST Firebird CTF team: 16:9, the team's teal/orange brand,
and the components a crypto/CTF lecture actually needs — callouts, code with a
file bar and line numbers, terminal sessions, scored challenges, tables, math — built on
touying, so overlays, speaker notes and handout mode come with the slide furniture.

It is the Typst counterpart of the team's Beamer theme (`beamerthemeFirebird.sty`),
so slides keep the same furniture:

| Beamer | here |
| --- | --- |
| header band + course line | running header, `n / total` footer, breadcrumb |
| `\begin{block}` | `#definition`, `#theorem`, `#insight`, … |
| `columns` | `#cols(left, right)` |
| `minted` | `#code(...)`, `#terminal(...)` |
| 4:3 deck | 16:9 default, `aspect: "4:3"` on request |

`examples/showcase.typ` is the source: 28 slides, a real crypto lecture followed by
a section on how to author with this template. **No build product is committed** —
each push compiles every deck and attaches the PDFs to the workflow run.

The template is a Typst package (`lib.typ`, `template/`, `typst.toml`): decks import
it by package spec rather than by relative path, its checks are Typst code, and the
working copy links into typst's package directory so a deck compiles with plain
`typst compile deck.typ` — no flags, no `--root`.

## Set up

```sh
git clone --recurse-submodules https://github.com/hkust-firebird/firebird-slides
cd firebird-slides
pkg="$(typst info 2>&1 | sed -n 's/^[[:space:]]*Package path[[:space:]]*//p')/preview/firebird-slides"
mkdir -p "$pkg" && ln -sfn "$PWD" "$pkg/0.3.0"
```

- **The clone needs its submodules**: BlobCats lives at `assets/blobcats/` and a
  missing checkout fails the compile on the first `#blobcat(...)`. An existing
  checkout catches up with `git submodule update --init`.
- **The link makes the working copy the package.** Every deck — the repo's own
  (`examples/showcase.typ`, `template/main.typ`, `tests/contrast.typ`) and the
  team's course decks — imports `@preview/firebird-slides:0.3.0`, exactly as an
  installed package does. Edits to `lib.typ` reach every deck on the next compile:
  `typst watch deck.typ` in one terminal, `lib.typ` in the editor in another, is
  the whole authoring loop. On Linux the package path is
  `${XDG_DATA_HOME:-~/.local/share}/typst/packages/preview/`.
- **Fonts**: IBM Plex ships in `vendor/fonts` (SIL OFL). If it is not installed
  system-wide, add `--font-path vendor/fonts` or set
  `TYPST_FONT_PATHS=$PWD/vendor/fonts` (CI sets that variable).

`template/main.typ` is the starter deck — copy it to start a talk. A scratch deck
for trying a component belongs in `tmp/` (gitignored), e.g. `typst watch
tmp/playground.typ`.

## Minimal deck

```typ
#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  title: "Elliptic curves without the jargon",
  subtitle: "Why a 256-bit key is not 256 bits of work",
  authors: ("Wyli (wyli)",),      // course line and date default on the cover
  helpers: ("Robin (mango)",),
  credits: ("Course materials: Crypto 101",),
)

#title-slide()
#toc-slide()

#section-slide("Groups", subtitle: "The only algebra you need today")

#slide(title: "Claim in the title, evidence in the body")[
  - One idea per line.
  - #strong[Strong] for the phrase you want remembered.
  - Inline math $c = m xor k$ flows inline.
]

#end-slide(lines: ("Next session: ...",))
```

## Overlays, notes, handout

`#pause` inside any slide body splits it into subslides — the header, progress bar
and `n / total` count the *slide*, never the overlays, so a reveal costs nothing:

```typ
#slide(title: "Why it works")[
  - The mask is public.
  #pause
  - The key never repeats.
  #speaker-note[Ask who has read the ciphertext slide again.]
]
```

Present the PDF as usual (each subslide is a page). For a printout or a shared
handout file, `firebird.with(..., handout: true)` collapses every overlay to its
final state — the same source, no `#if`s.

## Components

| Component | Use |
| --- | --- |
| `slide(body, title:, subtitle:, center:, header:, footer:)` | every content slide |
| `title-slide()`, `toc-slide(title:, depth: 2)`, `section-slide(title, subtitle:, note:)`, `subsection-slide(title)`, `end-slide(title:, subtitle:, lines:)` | deck furniture — the agenda lists sections `01, 02, …` with their subsections nested underneath, balanced over two columns, every entry clickable |
| `#pause`, `#uncover(2)`, `#only(2)`, `#speaker-note[...]` | touying overlays and notes — reveal bullets one at a time; `firebird(handout: true)` collapses every overlay to its final state |
| `bio-slide(name, discord: none, photo: none, title: "Speaker bio", ..)` | the speaker — photo (any image content) left, name + Discord chip, the rest of the slide is the content you pass |
| `admin-slide((..), title:, note:, qr:)` | weekly admin — attendance / exercise / homework rows with colour-coded kinds, `when:`/`where:` columns, a policy `note:` and an optional `qr:` scan card |
| `credits-slide((..), title:, note:)` | attributions — `(item, source)` pairs, source in small mono; the cover takes the short form via `firebird(credits: (..))` under the helpers |
| `challenge-slide(kind, name, deadline:, links:, body:)` | a scored item — `kind` is attendance / exercise / homework (colour-coded), `name` the challenge, `links:` render in a training.firebird.sh card; host-like strings become clickable |
| `definition`, `exercise`, `claim`, `remark`, `theorem`, `example`, `proof`, `insight`, `warning` | callouts; `callout(body, kind:, title:)` for custom labels |
| `code(src, lang:, file:, lines:, size:, gap:)` | code block; `file:` sets the title bar and infers the language, `lang:` overrides, `lines: true` numbers the lines (only when the prose points at one). Long lines soft-wrap and keep their syntax colour; code never shrinks — every snippet in a deck is one size, and one that is too tall fails the gate like any other overflow |
| `terminal(src, title:, dark:)` | shell session; `$ ` prompt, `> ` continuation, `# ` muted comment |
| `inline-code("x")`, `pill[LABEL]` | inline snippet / chip — plain `` `backticks` `` already get the chip |
| `keyeq($ c = m xor k $, note: [encryption])` | boxed equation with a note |
| `quote(attribution: [Name, *Work*])[...]` | serif block quote with a styled attribution |
| `image-slide`, `image-row`, `meme` | pictures (see the path gotcha below) |
| `data-table(headers, rows, mono: (), columns:)` | no-rules table, chrome header, zebra rows; `columns:` for lopsided content, e.g. `(auto, 1fr)` |
| `serif[...]` | the serif voice inline (block quotes already use it) |
| `blobcat("party", size: 1.15em)` | a BlobCat inline, on the text baseline |
| `blobcat-wall(names, cols: 8, size: auto)` | labelled grid of cats (default size 2.5× the body size) |
| `blobcat-list(cols: 6)` | every cat name, in columns — for browsing the pack on a scratch slide |

## Blobcats

The BlobCats are a git submodule at `assets/blobcats/`
([DuckOfDisorder/BlobCats], Apache-2.0, licence inside it) — the clone brings
them in via `--recurse-submodules`, and no script runs before a deck compiles.

```typ
Inline, on the baseline: #blobcat("party") the deploy worked
#blobcat("hyperthink", size: 96pt)          // any size, anywhere

#blobcat-wall(("party", "sip", "melt", "uwu"), cols: 4, size: 54pt)
```

Names ignore case, spaces, `_` and a leading `BlobCat`, so `"KindaSus"`,
`kinda_sus` and `blobcat_kindasus` are the same cat. A wrong name fails the
compile with the names it might have meant:

```
blobcat: no cat named "hyperthik"; did you mean: hyperthink. `#blobcat-list()` in a scratch document lists all 209 names.
```

`assets/blobcats.typ` is the name table — key → file, one line per cat — and it has to
exist because Typst cannot list a directory: it is what turns `"hyperthink"` into
`assets/blobcats/PNGs/BlobCats/BlobCat_Hyperthink.png` and what makes "did you mean"
possible. A new cat from upstream means adding one line to the
table; a line whose file is missing fails the compile loudly.

[DuckOfDisorder/BlobCats]: https://github.com/DuckOfDisorder/BlobCats

## Design rules

Reach for these before inventing a layout; they are what makes a deck read as one
deck.

- **One idea per slide.** Measured body box (16:9): 112 → 433.6 pt, so **321 pt**
  — about 11 single-line bullets, 12 lines of code with a file bar, or an 8-row
  table. The 4:3 page is 540 pt tall and keeps the same absolute title/bottom
  geometry, so it holds ~66 pt more. If it does not fit, split the slide — do not
  shrink the type.
- **Type scale** (all derived from `body-size`, default 19.5 pt): slide title
  1.45× (28 pt), section/cover 2× (39 pt), subsection 1.76× (34 pt), callout head
  1.15× (22.4 pt), code 0.86× (16.8 pt), captions/tables 0.76×, chrome floor 14 pt. Nothing
  below 13.5 pt. Sparse chrome pages (agenda, dividers, cover) deliberately run
  larger than the body — they carry less.
- **Padding.** Page gutters 60 pt, header row at 16 pt, title 19 pt below the
  header hairline, footer 26 pt from the bottom edge. Inside boxes: 20 pt for
  prose (callouts, key equations), 16 × 14 pt for mono (code, terminals),
  12 × 9 pt for tables.
- **Spacing is the template's job, and there is one rhythm.** Line pitch is
  0.78 em of leading; paragraphs and blocks sit on 0.95 em and the `above`/`below`
  of every boxed component on 0.8 em, and Typst collapses adjacent spacings to the
  max — so a deck never needs `#v(...)` between elements, and no gap can double up.
- **Lists hang at the margin.** Bullet and number glyphs start at the same left
  edge as prose and boxed components; only the text is inset, so stacked bullets
  and callouts share one column.
- **Colour discipline.** `ink` (teal-gray) is the body text, `brand-a`/`brand-b`
  fills are for rules, bars and pills only — accent text uses the `-ink` variants,
  which clear 4.5:1. `tests/contrast.typ` asserts every pair.
- **Callouts.** One minimal shape: a large head in the kind's accent above a
  body indented by a thin accent bar on the left — no fills or bands. Light kinds
  (`definition`, `exercise`, `claim`, `remark`) quote or restate; dark kinds
  (`theorem`, `example`, `proof`, `insight`) state a result. One callout per slide,
  at the end. `warning` is the same shape in the danger accent.
- **Code.** Every snippet needs `file:` (or `lang:`) so the reader knows the
  language, and `lines: true` only when the prose points at a specific line.

## Verifying your deck

`debug` draws the body box (the budget above) on every content slide and stamps a red
badge with the number of points it overflows by. `gate` is the same measurement turned
into a compile error, which is what makes the rule enforceable rather than advisory:

```
error: panicked with: slide 23 [Ciphers] is 19pt taller than its body box —
split the slide or trim it; never shrink the type.
```

Both live in `lib.typ`, so they need no extra file, no `--root` and no host program:
any deck that imports the package is gated by compiling it with `--input gate=true`
(`gate: true` in `firebird.with(...)` does the same). A deck with several bad slides
reports all of them in one run. Run it before you present; CI runs it on every push.

The check measures each body with Typst's `measure()` at its natural size — code and
terminals never shrink, so a snippet that is too tall is simply an overflow like any
other. The type scale and the body budget are the deck's whole look, and shrinking
either is what makes a deck look uneven.

## What CI does

`.github/workflows/build.yml` runs on every push and pull request: it installs typst
0.15.1, checks out the BlobCats submodule, links the repository into the package
directory, compiles the showcase and the starter deck with `--input gate=true`,
compiles `tests/contrast.typ` (whose assertions are the colour audit), and attaches
the three PDFs to the run as the `decks` artifact.
A deck that overflows fails the build, with the slide named in the log. No
shell scripts, no Python, no website, nothing committed back to the branch.

The same three commands are the whole check locally:

```sh
typst compile --input gate=true examples/showcase.typ
typst compile --input gate=true template/main.typ
typst compile tests/contrast.typ
```

Editing the template itself (rather than a deck)? `AGENTS.md` is the short list of what
will bite you — absolute vertical geometry, `show`-rule scope, the typst 0.15 traps, the
numeric gates — and it is what an AI agent reads before touching `lib.typ`.

## Gotchas

- **Image paths resolve where `image()` is written.** Typst resolves paths per
  file, so build the image yourself — `#image-row((image("assets/a.png"),))` —
  and the path is relative to *your* deck. The component cannot do it for you.
- **`$x$` is inline math, `$ x $` is a displayed equation.** Spaces inside the
  dollars turn a symbol in a sentence into a centred block.
- **XOR is `xor` (or `plus.o`), not `\xor`.** In Typst, `\xor` is logical or (∨);
  `$a xor b$` gives ⊕.
- **Footnotes are inlined.** `#footnote[x]` renders as a small parenthetical where
  you wrote it, because a page footnote would land in the footer band.
- **`raw` ignores inherited fonts.** Syntax-highlighted code takes its font from
  the theme, which is why `code()`/`inline-code()` set it with a `show raw` rule;
  pass `mono:` to `firebird.with(...)` to change the stack for a whole deck.
- **The syntax theme is a file** (`assets/firebird.tmTheme`); Typst has no named themes.

## Fonts

The deck ships one type family in three voices, bundled in `vendor/fonts`
(SIL OFL) so every machine renders it the same. Each voice carries the four
faces the deck uses — regular, italic, semibold, semibold italic:

| voice | family | used for |
| --- | --- | --- |
| sans | **IBM Plex Sans** | body, titles, callout heads, tables |
| mono | **IBM Plex Mono** | code, terminals, challenge links, file names |
| serif | **IBM Plex Serif** | block quotes, `#serif[...]` accents |

Typst reads fonts from the system, from `--font-path`, and from `TYPST_FONT_PATHS`.
Pick one:

```sh
typst compile --font-path vendor/fonts deck.typ   # per command, nothing installed
TYPST_FONT_PATHS=$PWD/vendor/fonts typst watch deck.typ
cp vendor/fonts/*/*.ttf ~/Library/Fonts/          # or install them once, system-wide
```

One superfamily keeps prose and code visually related, and Plex Mono has no
programming ligatures, so `->` and `!=` never merge into a glyph a reader has to
decode. Math stays on Typst's New Computer Modern. A
missing family falls through the stack (`sans`, `mono`, `serif` defaults) to a
platform font, so a deck never breaks — it just looks less like this one.

`display: "serif"` moves the cover, section and slide titles into the serif voice;
`serif`/`sans`/`mono` accept any font stack:

```typ
#show: firebird.with(display: "serif", mono: ("Cascadia Mono", "Consolas"))
```

## Layout internals

```
page 297 × 167.06 mm (841.89 × 473.56 pt)
  ├ progress bar     y 0–3 pt   (teal done · orange current · #E9EDEE track)
  ├ header           y 16 pt    mark + "Firebird CTF Team" · course
  ├ hairline         y 36 pt
  ├ title            y 55 pt    28 pt / 600 — 19 pt below the hairline (subtitle right-aligned on the same line)
  ├ body box         112 → 433.6 pt on a title-only slide; the measured title
  │                            block (title, brand rule, gap) decides the real top/budget
  └ footer           y 26 pt from the bottom: breadcrumb · n / total
```
