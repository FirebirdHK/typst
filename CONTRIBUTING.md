# Contributing

Two kinds of change land here: **decks** built on the package, and **the
template itself** (`lib.typ`, components, chrome). Both are checked the same
way, and neither needs anything beyond typst and the [quick
setup](README.md#quick-setup).

## Checks

Every change must pass the three gates:

```sh
typst compile --input gate=true examples/showcase.typ
typst compile --input gate=true template/main.typ
typst compile tests/contrast.typ
```

- `gate=true` measures every slide body and fails the compile when one is
  taller than its body box, naming the slide. A too-full slide is split or
  trimmed — never shrunk; the type size and body budget are the deck's look.
- `debug=true` draws the same body box with an overflow badge, for finding the
  offender while writing: `typst watch --input debug=true deck.typ`.
- `tests/contrast.typ` asserts every foreground/background colour pair at
  every size it is used at; add a pair there when you add a colour.

All three exit 0 when clean. Run them before pushing; a deck that overflows
fails CI with the slide named in the log.

## What CI does

`.github/workflows/build.yml` runs on every push and pull request:

1. installs typst 0.15.1 (the pinned version, `typst.toml`'s `compiler`);
2. checks out the BlobCats submodule recursively;
3. links the checkout into a package directory via `TYPST_PACKAGE_PATH`, so
   the decks import `@preview/firebird-slides` the way an installed package
   does;
4. runs the three checks above;
5. uploads the three PDFs to the run as the `decks` artifact.

No build product is committed: PDFs land on the run, and the slide images in
`docs/img/` are regenerated on purpose when the showcase changes.

## Changing the template

Read [`AGENTS.md`](AGENTS.md) first — it is the short list of what will bite
you: absolute vertical geometry, `show`-rule scope, the typst 0.15 and touying
traps, the numeric gates. The conventions that matter most:

- **Versions are pinned** — typst 0.15.1, touying 0.7.4. Do not bump either as
  part of unrelated work; a bump moves the gates' overflow numbers and is a
  change of its own, with all three gates green on the new version.
- **No host scripts.** Typst has no filesystem write, directory listing or
  subprocess, and the repo is checked the way a user uses it: any deck
  compiles with `typst compile deck.typ`, no flags. What one command does
  stays a documented command.
- **A component that can overflow a slide belongs behind `measure()`** — that
  is what keeps the gates' numbers true for every deck, not just the showcase.
- **Code is not commented.** Names and structure carry the meaning; a comment
  is allowed only for a fact the code cannot express — a Typst/touying bug, a
  licence attribution, a non-obvious external constraint.
- **Docs are present tense** and cover only what exists now. Component
  changes update [USAGE.md](USAGE.md) and the [README](README.md) in the same
  PR.
- **Vendored assets keep their licence** beside them and a line in `LICENSE`
  (BlobCats: Apache-2.0, in its submodule; IBM Plex: SIL OFL, in
  `vendor/fonts/`).

## Refreshing the slide gallery

`docs/img/` renders one PNG per page of the showcase. After changing anything
the showcase renders, re-render and commit:

```sh
typst compile --font-path vendor/fonts --format png --ppi 144 \
  examples/showcase.typ "docs/img/slide-{0p}.png"
```

Pages shift when slides are added or removed, so check the diff: images are
named by page, and a renumbered page moves files.

## Sending the change

One change per PR — a component, a doc rewrite, a version bump — with the
three gates green in the description. Deck contributions (lecture material)
start a discussion in an issue first: they usually belong in a course repo
that imports this package, not here.
