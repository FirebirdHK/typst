# firebird-slides

A presentation template and theme for the HKUST Firebird CTF team internal
training. Built on [touying](https://touying-typ.github.io/).

Every component is rendered in [`examples/showcase.typ`](examples/showcase.typ)
and documented with images in [`USAGE.md`](USAGE.md).

![The showcase deck's cover slide](docs/img/slide-01.png)

## Quick setup

```sh
git clone --recurse-submodules https://github.com/FirebirdHK/typst
cd typst
pkg="$(typst info 2>&1 | sed -n 's/^[[:space:]]*Package path[[:space:]]*//p')/preview/firebird-slides"
mkdir -p "$pkg" && ln -sfn "$PWD" "$pkg/0.3.0"
```

The submodules bring the BlobCats art; an existing clone catches up with
`git submodule update --init`. The link makes the working copy the package, so
edits to `lib.typ` reach every deck on the next compile. If IBM Plex is not
installed system-wide, add `--font-path vendor/fonts` — see [Fonts](#fonts).

## Minimal deck

Copy [`template/main.typ`](template/main.typ), or start from this:

```typ
#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  title: "Elliptic curves without the jargon",
  subtitle: "Why a 256-bit key is not 256 bits of work",
  authors: ("Wyli (wyli)",),
  helpers: ("Robin (mango)",),
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

## Compiling

```sh
typst compile deck.typ        # PDF next to the source
typst watch deck.typ          # recompile on save
```

Decks import the package by name, so this works from any directory with no
flags. The showcase built from the latest `main`:
[showcase.pdf](https://github.com/FirebirdHK/typst/releases/download/latest/showcase.pdf).

## Configuration

`firebird.with(...)` sets up the whole deck:

| Parameter | Default | Controls |
| --- | --- | --- |
| `title`, `subtitle` | `none` | cover title; `title` also names the deck in metadata |
| `course` | `"COMP2633 …"` | right side of the running header |
| `authors`, `helpers` | `()` | cover lines — presenter(s), then helper(s) |
| `credits` | `()` | short attributions under the helpers on the cover |
| `date` | `auto` | today's date; pass any content to pin it |
| `aspect` | `"16:9"` | or `"4:3"` |
| `body-size` | `19.5pt` | the whole type scale derives from it |
| `sans`, `mono`, `serif` | IBM Plex stacks | font stacks per voice |
| `display` | `"sans"` | `"serif"` moves cover, section and slide titles to the serif voice |
| `raw-theme` | `"assets/firebird.tmTheme"` | syntax-highlighting theme for code |
| `debug`, `gate` | `auto` | same as `--input debug=true` / `gate=true` (see [Verifying](#verifying-your-deck)) |
| `handout` | `false` | collapses every overlay to its final state |

## Overlays

`#pause` splits a slide into subslides; `#uncover(n)`, `#only(n)` and
`#speaker-note[…]` place content per step; `firebird.with(handout: true)`
collapses every overlay. Everything else is
[touying's](https://touying-typ.github.io/).

## Components

| Component | Use |
| --- | --- |
| `slide(body, title:, subtitle:, center:, header:, footer:)` | every content slide |
| `title-slide()`, `toc-slide()`, `section-slide()`, `subsection-slide()`, `end-slide()` | deck furniture |
| `bio-slide(name, discord:, photo:)` | the speaker |
| `admin-slide(items, title:, note:, qr:)` | weekly attendance / exercise / homework schedule |
| `credits-slide(entries, title:, note:)` | attributions |
| `challenge-slide(kind, name, deadline:, links:)` | a scored challenge with its links card |
| `definition`, `exercise`, `claim`, `remark`, `theorem`, `example`, `proof`, `insight`, `warning` | callouts |
| `code(src, lang:, file:, lines:)` | syntax-highlighted code with a file bar |
| `terminal(src, title:)` | a shell session |
| `cols(a, b, ratio:)` | two columns — prose beside code or a figure |
| `keyeq($ … $, note:)` | the one equation that matters, boxed |
| `quote(attribution:)` | serif block quote |
| `data-table(headers, rows, columns:, mono:)` | no-rules table, zebra rows |
| `image-slide()`, `image-row()`, `meme()` | pictures, with captions |
| `inline-code("x")`, `pill[LABEL]` | inline snippet / chip |
| `serif[…]` | the serif voice inline |

Rendered examples: [USAGE.md](USAGE.md).

## Blobcats

[BlobCats](https://github.com/DuckOfDisorder/BlobCats) (Apache-2.0) ship as a
git submodule; `#blobcat("party")` puts one on the text baseline:

```typ
Deploy succeeded #blobcat("party")
#blobcat-wall(("party", "sip", "melt", "uwu"), cols: 4, size: 54pt)
```

Names ignore case, spaces, `_` and a leading `BlobCat`; a wrong name fails the
compile with its best guesses. `#blobcat-list()` lists all 209.

## Verifying your deck

`--input debug=true` draws the body box and overflow badges; `--input
gate=true` fails the compile, naming the slide. The three checks CI runs:

```sh
typst compile --input gate=true examples/showcase.typ
typst compile --input gate=true template/main.typ
typst compile tests/contrast.typ
```

Contributing: [CONTRIBUTING.md](CONTRIBUTING.md).

## Fonts

One family, three voices, bundled in `vendor/fonts` (SIL OFL):

| Voice | Family | Used for |
| --- | --- | --- |
| sans | **IBM Plex Sans** | body, titles, callout heads, tables |
| mono | **IBM Plex Mono** | code, terminals, file names |
| serif | **IBM Plex Serif** | block quotes, `#serif[…]` accents |

```sh
typst compile --font-path vendor/fonts deck.typ   # per command
TYPST_FONT_PATHS=$PWD/vendor/fonts typst watch deck.typ
cp vendor/fonts/*/*.ttf ~/Library/Fonts/          # system-wide
```

`display: "serif"` moves the titles to the serif voice.
