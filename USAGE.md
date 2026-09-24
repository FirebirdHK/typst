# Usage

Everything the template can do, with a rendered example for each. The source of
every image is [`examples/showcase.typ`](examples/showcase.typ) — open it beside
this file and the mapping is one-to-one.

## Deck setup

A deck is one `#show:` line; every page after it is the talk.

```typ
#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  title: "Crypto 101",
  subtitle: "From Caesar to one-time pads",
  authors: ("Dhairya (wylited)",),
)
```

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
| `debug`, `gate` | `auto` | same as `--input debug=true` / `gate=true` (see [Verifying](README.md#verifying-your-deck)) |
| `handout` | `false` | collapses every overlay to its final state |

## Slides

`slide()` is the workhorse: `title:` is the claim, the body is the evidence,
`subtitle:` sits right-aligned on the title line, `center: true` centers the
body, and `header:`/`footer:` swap the chrome on that one slide.

![A centered slide](docs/img/slide-17.png)

The deck furniture — one call each, all reading their content from the setup
above unless overridden:

![Title slide](docs/img/slide-01.png)

![Agenda](docs/img/slide-02.png)

![Section divider](docs/img/slide-04.png)

![Subsection divider](docs/img/slide-19.png)

![End slide](docs/img/slide-31.png)

`bio-slide(name, discord:, photo:, body)` — the presenter, photo left:

![Speaker bio](docs/img/slide-03.png)

`challenge-slide(kind, name, deadline:, links:, body)` — a scored item; `kind`
is `"attendance"`, `"exercise"` or `"homework"` and drives the colour, `links:`
render as a clickable card:

![Challenge slide](docs/img/slide-18.png)

`admin-slide(items, title:, note:, qr:)` — the weekly schedule; each item is a
`(kind:, what:, when:, where:)` dictionary with the same three kinds:

![Admin slide](docs/img/slide-29.png)

`credits-slide(entries, title:, note:)` — `(item, source)` pairs, source in
small mono:

![Credits slide](docs/img/slide-30.png)

## Writing on slides

`cols(left, right, ratio:, gutter:)` puts prose beside a snippet or figure; this
is the template's signature layout:

![Two columns: equation and code](docs/img/slide-09.png)

Code renders at the deck's code size, never smaller. `file:` sets the title bar
and infers the language, `lang:` overrides it, `lines: true` numbers lines —
only when the prose points at one:

![Code with line numbers](docs/img/slide-10.png)

![A shell snippet](docs/img/slide-26.png)

`terminal(src, title:)` renders a session: `$ ` prompt, `> ` continuation,
`# ` muted comment:

![Terminal session](docs/img/slide-11.png)

Callouts — one shape, an accent head over a bar-indented body. Light kinds
(`definition`, `exercise`, `claim`, `remark`) quote or restate; dark kinds
(`theorem`, `example`, `proof`, `insight`) state a result; `warning` is the
shape in the danger accent. One per slide, last:

![Definition callout](docs/img/slide-05.png)

![Warning and claim](docs/img/slide-12.png)

![Summary with an exercise](docs/img/slide-21.png)

`keyeq($ … $, note:)` boxes the one equation that matters:

![Key equation](docs/img/slide-13.png)

`quote(attribution:)[…]` — serif block with a styled source:

![Quote](docs/img/slide-20.png)

`data-table(headers, rows, columns:, mono:)` — no rules, chrome header, zebra
rows; `` `backticks` `` in cells become chips, `pill[LABEL]` for a coloured one:

![Table and pills](docs/img/slide-14.png)

Pictures: `image-slide(content, caption:, title:)`, `image-row(images,
captions:, height:)`, `meme(content, caption:)` — components take content, not
paths, so build each image at the call site
(`#image-row((image("a.png"), image("b.png")))`):

![Image row with captions](docs/img/slide-15.png)

![Meme](docs/img/slide-16.png)

Anatomy of the pieces together — `cols` with a `code` file bar:

![Anatomy of a slide](docs/img/slide-23.png)

Diagrams come from any package on the Universe — here `@preview/fletcher`,
coloured straight from the theme's `pal`:

![A fletcher diagram: the key feeding encrypt and decrypt](docs/img/slide-24.png)

## Overlays, notes, handout

`#pause` inside a slide body splits it into subslides; `#uncover(n)` and
`#only(n)` place content at a specific step, `#speaker-note[…]` never shows.
The header, progress bar and `n / total` count the slide, not the overlay:

```typ
#slide(title: "Cryptanalysis: Attack Models")[
  + #strong[Ciphertext-only.] Only a pile of ciphertexts.
  + #strong[Known-plaintext.] Ciphertexts with their plaintexts.
  + #strong[Chosen-plaintext.] Encryptions of the attacker's own messages.
  #pause
  + #strong[Chosen-ciphertext.] Chosen plaintexts _and_ chosen ciphertexts.

  #pause
  #insight[Every classical cipher falls to a ciphertext-only attack — usually far earlier than you would hope.]
]
```

The three pages that source produces:

![Overlay step 1](docs/img/slide-06.png)

![Overlay step 2](docs/img/slide-07.png)

![Overlay step 3](docs/img/slide-08.png)

Present the PDF as usual — each subslide is a page — or set
`firebird.with(handout: true)` to collapse every overlay to its final state
with no `#if`s.

Everything beyond these — `#meanwhile`, slide functions, PPTX/HTML export,
theming hooks — is touying's, and this template inherits it:
[touying documentation](https://touying-typ.github.io/).

## Blobcats

![Blobcat wall](docs/img/slide-27.png)

```typ
Inline, on the baseline: #blobcat("party") deploy succeeded
#blobcat-wall(("party", "sip", "melt", "uwu"), cols: 4, size: 54pt)
```

Names ignore case, spaces, `_` and a leading `BlobCat` — `"KindaSus"`,
`kinda_sus` and `blobcat_kindasus` are the same cat. A wrong name fails the
compile with its best guesses; `#blobcat-list()` renders every one of the 209
names on a scratch slide.

## Typst notes

- **Image paths resolve where `image()` is written.** Pass content to the
  component — `#image-row((image("assets/a.png"),))` — with the path relative
  to your deck.
- **`$x$` is inline math, `$ x $` is display math.** Spaces inside the dollars
  turn a symbol in a sentence into a centred block.
- **XOR is `xor` (or `plus.o`), not `\xor`** — in Typst, `\xor` is logical or (∨).
- **Footnotes render inline** where you write them, as a small parenthetical; a
  page footnote would land in the footer band.
- **`raw` ignores inherited fonts** — the template sets the mono stack with a
  `show raw` rule; change the stack for a deck with `firebird.with(mono: …)`.

## Repo layout

![Where things live](docs/img/slide-28.png)

Authoring a full lecture on top of the template? [`template/main.typ`](template/main.typ)
is the starter deck to copy; editing the template itself starts with
[CONTRIBUTING](CONTRIBUTING.md).

## The rest of the showcase

The section the deck uses to teach itself:

![Section divider for the template tour](docs/img/slide-22.png)

![Cheat sheet](docs/img/slide-25.png)
