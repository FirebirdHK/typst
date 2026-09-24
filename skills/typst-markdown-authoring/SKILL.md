---
name: typst-markdown-authoring
description: Markdown → Typst with cmarker (0.1.10 · Typst 0.15.1).
---

# Markdown → Typst with cmarker (0.1.10 · Typst 0.15.1)
**Trigger**: a `.md` file stays live (GitHub renders it) and must also typeset through Typst; or the source is markdown that needs Typst-only features.
**Start from**: blank wrapper `.typ` — host styling from `templates/scratch-note.typ`. The markdown stays authoritative; cmarker is a transpiler (md → Typst source text → `eval`), not a filter.

## Default path
1. Pin the imports — the `.with(...)` bundle below fails without them: `#import "@preview/cmarker:0.1.10"`, `#import "@preview/mitex:0.2.7": mitex` (math), `#import "@preview/cheq:0.3.1"` (task lists). Missing one → `r19-skeleton.typ:8:8: error: unknown variable: mitex`.
2. Bind every silent-default option once, render through the wrapper:
```typst
#let cm = cmarker.render.with(
  math: mitex,                               // default none → literal $…$ (silent)
  task-list-marker: checked => if checked { cheq.checked-sym() } else { cheq.unchecked-sym() },
  scope: (image: (source, ..args) => image(source, ..args)),  // else lib.typ:413 file-not-found
  h1-level: 2,                               // reserve `=` for the wrapper document
  set-document-title: false,                 // required inside box/frame (E-TITLE)
)
#set heading(numbering: "1.")                // else [@heading-ref] → cannot reference heading without numbering
#cm(read("chapter.md"))
```
3. Front matter: `#let (meta, body) = cmarker.render-with-metadata(read("post.md"), metadata-block: "frontmatter-yaml")` → `meta.title/author/tags`, body with the `---` block consumed. Without `metadata-block:` **only the closing `---` fence forms a setext H2** — the opening fence renders as a lone divider (`show-source` shows `== title: leaked?`; rc=0, absurd).
4. Three style levers, increasing power: (a) show rules on emitted elements — cmarker emits real `heading`/`table`/`quote`/`raw`/`footnote.entry`/`list`/`link`; wrap `it`, never rebuild `raw(...)` inside `#show raw` (`maximum show rule depth exceeded`). (b) `scope:` overrides the functions cmarker *calls* — args must sink named params (`heading: (..args) => …` works; `(level: ..args)` is a hard `expected expression`). (c) `html:` maps a tag → content in the *same* call; unknown tags vanish silently.
5. Math callback contract: `math: mitex` works bare (it sinks `block:`). A custom callback **must** name its param `block` with a default: `(block, s)` → `missing argument: s`; `(source, block)` → ``the argument `block` is positional``; calling `block(...)` inside → `expected function, found boolean` (param shadows the builtin) → `std.block(...)`.
6. Debug loop: any error mentioning `lib.typ:413` → re-run the same call with `show-source: true`; it swaps `eval` for `raw(rendered, block: true, lang: "typ")` and is safe even when eval would fail. The eval boundary erases markdown line numbers — `show-source` is the workaround, not a fix.
7. Typst-only instructions ride in HTML comments: `<!--raw-typst …-->` is injected as markup when `raw-typst: true` (default) — **must be preceded by a newline**; `<!--typst-begin-exclude--> … <!--typst-end-exclude-->` strips the block from the Typst render only. `raw-typst: false` neutralizes rather than prints: `A <!--raw-typst #box(x) --> B` → `A  B`.
8. One-shot md→typst conversion is pandoc's job (README says so): `pandoc -f gfm -t typst`; fragments need `#let horizontalrule = line(start:(25%,0%), end:(75%,0%))`; `--standalone` needs `-M mainfont="Libertinus Serif"` (`-M font=` does nothing). Extract cmarker's emitted Typst with `show-source: true` + `typst compile --features html --format html …` → single `<pre>`, byte-exact payload.
9. GFM-fidelity claims → three-way diff (cmarker / GitHub / pandoc gfm): bare autolinks, `> [!NOTE]`, `:rocket:`, single-tilde `~x~`, markdown-in-HTML all drift.

## Fail modes → fix
| Exact string / symptom | Fix |
|---|---|
| `lib.typ:413:9: error: file not found (searched at …/cmarker/0.1.10/…)` / `lib.typ:242:40: error: file not found …` | image (or `<img>`) without `scope:` — eval re-roots paths into the package cache; add the `image` scope closure |
| `file not found (…/0.1.10/https:/…)` + `hint: network access is not supported` | remote image URL — download the asset; no compile-time fetch |
| `document set rules are not allowed inside of containers` | `h1-level: 0` title path inside `box`/`block` → `set-document-title: false` or hoist `#set document` |
| `expected comma` + ``expected keyword `in` `` (both @413:9) | syntax error inside `<!--raw-typst …-->` — fix the comment or `raw-typst: false` |
| ``label `<shared>` occurs multiple times in the document`` | two renders sharing a slug — set `label-prefix:` per file from the start (collisions deferred: define is rc=0, first `[@ref]` blows up) |
| `cannot reference heading without numbering` @413:9 | host lacks `#set heading(numbering: …)` — cmarker makes labels, not numbering policy |
| `…typ:2:57: error: expected function, found boolean` (your file) | `block(...)` inside the callback is the bool param → `std.block(...)` |
| (rc=0) output shows literal `$e^{i\pi} + 1 = 0$` | `math: none` default — pin `math: mitex` or a callback |
| (rc=0) `• [ ] todo` in bullets | `task-list-marker: none` default — supply cheq or any `bool => content` |
| (rc=0) `== title: leaked?` heading | missing `metadata-block:` — use `render-with-metadata` |
| (rc=0) custom tag vanished, body kept, no warning | register the tag in the `html:` dict of the same call |
| (rc=0) `: My caption` as its own paragraph | table captions unsupported (issue #69) — hand-build `<figure>/<figcaption>` |

## Deviate safely
- **Free**: wrapper styling, `h1-level`, prefix strategy, your own `scope:`/`html:` callbacks, pandoc-vs-cmarker choice. Trivial md with no math/images/tasks may skip the `.with(...)` bundle — but then you own the defaults.
- **Measured floors**: pin `:0.1.10`; `math`/`task-list-marker`/image-`scope` are *silent* traps when unset — if call sites can't pin them via `.with(...)`, don't route content through cmarker; raw-typst blocks need the preceding newline; hard errors all report at `lib.typ:413` with zero markdown line info.
- **Escape hatches**: markdown that must survive GFM *and* carry Typst instructions → `raw-typst` comments; HTML with no handler → `html:` entry, or pre-render it outside cmarker (this chapter measures no `--svg` pre-render path — the extraction route is `show-source` + `--format html`); conversion-and-discard md → pandoc, not cmarker.

## Verify
`scripts/verify.sh <wrapper>.typ` (add `--html` if the doc also exports HTML). rc=0 then PyMuPDF text-extract or vision-read the `.verify/page-*.png` for the silent class: literal `$…$`, `• [ ]`, `== title:` leaks, vanished tags, `: caption` paragraphs. On any `lib.typ:413` error: re-run with `show-source: true` and read the emitted markup. GFM claims need the three-way diff, not one compiler.

## Deep reference
`cmarker.md` — §2.1 skeleton (imports), §2.4 math callback contract, §2.5 front-matter/`metadata-block`, §3 behavior table (✓/✗/⚠ per construct), §4 raw-Typst rules, §5 error catalog (hard vs silent), §6 pandoc lane. Probes: `experiments/cmarker/02-math.typ`, `06-html-raw.typ`, `09-errors/`, `review-probes/r19-skeleton.typ`.
