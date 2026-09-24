# firebird-slides: author a complete lecture deck, end to end

You are building a finished lecture deck for the HKUST Firebird CTF training
(COMP2633) on the `firebird-slides` Typst template — the same way
`typst-crypto101` and `typst-crypto102` were built. That means the whole
artifact, not a skeleton: deck source per section, figures, assets carried over
from the source material, per-section speaker notes with verified solves,
challenges placed at the right slide positions, gates green, and every rendered
page visually checked. You do the work with parallel subagents and you verify
with vision, because compile-clean is not the same as looking right.

## PART 0 — Fill this in first

Before any work starts, ask the lecturer for exactly these blanks and nothing
else. Do not invent answers, do not ask extra questions; if a field can be
derived from the source material (for example by reading last year's deck),
propose the derived value and move on.

1. **Course** — code and name (default: COMP2633 Competitive Programming in
   Cybersecurity I).
2. **Session** — number, title, subtitle, and the date it is taught.
3. **People** — author(s) and helper(s) as `Name (discord-handle)`, plus the
   credit line for the source material (propose one derived from the source;
   the existing decks credit the original designer by name).
4. **Source material** — what to port: last year's deck, a `.pptx`, or LaTeX,
   and where it lives. If both a pptx and a previous Typst deck exist, say
   which one wins on conflicts.
5. **Lesson plan** — ordered sections; for each section, slide-level flow
   bullets ("define CBC, walk the figure, worked example, code") and a minute
   budget. The budgets must sum to the session's length.
6. **Challenges table** — one row per scored item:

   | id | kind | name | flavor quote | description | deadline (HKT) | links / files |
   |----|------|------|--------------|-------------|----------------|---------------|

   kind is attendance / exercise / homework. Platform ids, `nc` endpoints and
   file URLs come from the lecturer's table; never guess an id or a deadline.
   Typical shape: 1 attendance, up to 2 exercises, up to 2 homeworks — less is
   fine.
7. **Attendance-flag policy** — the fixed slide text (default: "In each
   training lesson we will release an attendance flag in the slides or Zoom.
   You will have 3 days' time to input the flag into the training platform to
   prove that you have (at least) viewed the slides and the Zoom recording."),
   and whether this session is Track A, Track B, or both.
8. **Difficulty ceiling** — the level challenges may reach (default:
   challenging-puzzle, never research-level) and, for the slides, what to cut
   first when time runs short and what must never be cut.
9. **Assets** — figures, images, blobcats to reuse from the source material,
   and anything new that must be drawn.
10. **Platform URLs** — training platform, file server, challenge host, Discord
    channel (defaults: `training.firebird.sh`, `files.firebird.sh`,
    `chal.firebird.sh`, `#comp2633`).

## Standing rules

Every rule below was learned by being corrected; treat each as non-negotiable.

- **Spawn subagents first.** Before you read anything yourself, fan out recon
  and build work in one batch. Waiting until you "understand the codebase"
  first is the failure mode this rule exists to prevent. Even a two-minute
  task goes to a subagent.
- **Stay parallel, event-driven.** Each section is an independent topic that
  advances through stages (draft, gate-clean, vision-passed) on its own. Never
  barrier-wait for all sections before advancing one; never let a stalled
  section block the others. See the Workflow section.
- **Verify every computed number.** Any ciphertext, modulus, timing figure, or
  attack output that appears on a slide or in a solve is re-derived in Python
  (bignum for RSA-style math) and re-checked before it ships. Tag verified
  values "(verified)" in speaker notes. An unverified number does not get
  taught.
- **No flags in slides. Ever.** Challenge slides carry kind, name, description,
  deadline, and links; the attendance flag is revealed live in the lecture or
  recording, not printed. Flags and full solves live only in
  `speaker-notes/` markdown (a dedicated challenges note may contain them).
- **Speaker notes are per-section markdown files**, not Typst. One
  `speaker-notes/NN-<name>.md` per section, organized per slide, each entry
  using SAY (what to say), ASK (question plus expected answer), WATCH (where
  students stumble), NEXT (what the next slide is), TIME (minutes).
  `00-overview.md` holds the framing, the timing budget, and an ordered cut
  list. Do not use `#speaker-note[...]` for deck-level notes.
- **Deadlines in HKT only.** "Sat Oct 10, 23:59 HKT" — no UTC pairs on slides.
- **One idea per slide; split, never shrink.** If content does not fit the
  body box, split into a `(k/N)` continuation slide. Never shrink type, never
  hand-tune padding — spacing is the template's job. Keep the page count
  proportional to the minute budgets: past sessions land near one page per
  minute of lecture.
- **Faithful to the source, improved where it is weak.** Port what the source
  actually teaches, in its order and with its images. Where the source is
  thin — a skipped proof, a hand-wave — add the math or a deeper treatment,
  and push real depth into an appendix section rather than the main flow.
  Do not insert topics the source never taught.
- **Write like a lecturer, not a language model.** Match the source deck's
  voice; fixed grammar where the original had typos. Vary sentence length;
  no rule-of-three, no chains of short declarative sentences, no passive
  hedge-everything tone. Use `*bold*` and `_italic_` markup (not `#strong`),
  real Typst math (`$c = m xor k$`, `$x != y$` — never ASCII `^` or `!=` in
  prose), and markdown tables via `data-table`, never ad hoc grids. Callouts
  sparingly: at most one per slide, at the end — a callout on every slide
  makes all of them useless.
- **Blobcats sparingly.** One or two per section, where a joke lands; the pack
  is the `assets/blobcats` submodule of the template repo, with
  `assets/blobcats.typ` as the name table.
- **Gates before beauty.** `typst compile --input gate=true main.typ` must
  exit clean, and `--input debug=true` renders the body boxes for inspection.
  A slide the gate rejects is split, not shrunk.
- **Vision-check rendered pages.** Compile to PNG per page and have a vision
  subagent inspect each against the checklist (below). Compile-green slides
  have shipped with off-center challenge slides, overlapping text, and broken
  agendas before; only eyes catch that. Prove any suspected template bug with
  a minimal repro before claiming it — Typst is finicky, so demand real
  evidence.
- **Deck repo is separate from the template repo.** The deck is its own
  repository importing `@preview/firebird-slides`; never write lecture
  content into `typst-firebird`, and never edit the template to make one
  deck compile.
- **Reuse the source's images.** Copy figures and pictures from the source
  deck into `assets/` rather than substituting stock images; keep blobcat
  setup identical to the existing decks.
- **Keep the deck repo pure Typst and uncluttered.** One command compiles it;
  no HTML, no build scripts beyond the page-index generator, no committed
  PDFs, no decision-diary documentation. `build/` and PDFs are gitignored.
  Commit and push only when the lecturer says so.

## Scaffold

Create the deck as a new repository with this layout (sections count up from
`00`; keep names short and lowercase):

```
<deck>/
├── main.typ
├── sections/
│   ├── 00-opening.typ
│   ├── 01-<section>.typ
│   └── ...
├── speaker-notes/
│   ├── 00-overview.md
│   ├── 01-<section>.md
│   └── 99-page-index.md        # generated, see Definition of done
├── figures/                    # one #let per figure, shared constants in common.typ
├── assets/                     # images from the source deck, blobcats/, blobcats.typ
├── .omp/skills/                # typst skills copied from the template repo's skills/
├── scripts/gen-page-index.py   # page number <-> slide map for the notes
└── README.md
```

`main.typ` is real from the first commit — it compiles and shows the deck's
actual metadata and section list:

```typst
#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  course: "COMP2633 Competitive Programming in Cybersecurity I",
  title: "Crypto 102",
  subtitle: "Cryptanalysis: Symmetric Ciphers and Their Attacks",
  authors: ("Dhairya (wylited)",),
  helpers: ("Isaac (sayako)",),
  credits: ("Course materials originally designed by Tom and previous Firebird members.",),
  date: "Oct 2, 2026",
)

#title-slide()
#bio-slide("Dhairya", discord: "wylited",
  photo: image("assets/cat-photo.png", height: 280pt))[
  - One or two lines of bio the lecturer supplies.
]
#toc-slide(title: "Content", depth: 1)

#section-slide("Modes of Operation")
#include "sections/00-opening.typ"
#include "sections/02-modes-ecb.typ"

#end-slide(title: "Thanks!", subtitle: "Questions?", lines: (
  "Next: Crypto 103 — RSA",
  "Discord: #comp2633",
))
```

A section file imports the package itself (`#include` does not share the
includer's scope) and uses the real components:

```typst
#import "@preview/firebird-slides:0.3.0": *

#slide(title: "Claim in the title, evidence in the body")[
  - *Bold* for the phrase to remember; real math: $P_i = D_K(C_i) xor C_(i-1)$.
  - `#pause` splits a slide into overlays when a reveal helps.

  #insight[One callout per slide, at the end.]
]

#challenge-slide(
  "exercise",
  "Padding Oracle",
  deadline: "Sat Oct 10, 23:59 HKT",
  links: ("training.firebird.sh/challenges?id=96",),
  body: [Short flavor description from the challenges table.],
)
```

Component quick map: `slide(title:, subtitle:, center:)` for content;
`title-slide`, `toc-slide(depth:)`, `section-slide`, `subsection-slide`,
`end-slide(lines:)` for furniture; `challenge-slide(kind, name, deadline:,
links:)` for scored items; `admin-slide(items, note:, qr:)` for weekly admin;
`code(src, file:, lang:, lines:)`, `terminal(src)`, `keyeq`, `data-table`,
`cols(left, right, ratio:)`; callouts `definition exercise claim remark
theorem example proof insight warning`; `blobcat("name")`; `image-row`.
Image paths resolve in the file that calls `image()` — build `image-row`
arguments yourself.

## Workflow

Work in stages, and keep every section moving independently.

**Stage 0 — recon and scaffold, in parallel.** In one batch: spawn scouts on
the source material (extract the full lesson as an outline with per-section
flow, list every figure and asset worth carrying over, note the source's
voice and quirks), a scout on the template (component API from the showcase,
the design rules, the gotchas), and land the scaffold yourself at the same
time. The scouts write their findings to files (`tmp-analysis/`) so section
agents can read them instead of re-reading the source. While the scouts run,
install the typst skills into the deck repo — copy each
`<typst-firebird>/skills/<name>/SKILL.md` to `.omp/skills/<name>/SKILL.md`
(the skills ship with the template repo checkout, not with the installed
package) — so every section agent picks up `typst-slides` (deck authoring),
`typst-code-listings`, `typst-figure`, `typst-plot`, `typst-proofs-math` and
`typst-verify` (verification loops); `typst-author` routes to the rest of the
catalogue.

**Stage 1 — one subagent per section.** Fan out one agent per section in a
single batch. Each gets: the section's flow bullets and minute budget, the
standing rules that bite at section level (one idea per slide, verified math,
voice, callout discipline, no flags), the component API, the path to the
recon notes, and its slice of the source material. Sections reference only
their own file; nobody edits `main.typ` except the integration owner.

**Stage 2 — integration.** One owner wires section includes into `main.typ`,
compiles with the gate, fixes cross-section fallout (duplicate labels, shared
figure names, inconsistent terminology), and keeps the gate log of every
overflowing slide routed back to the owning section agent by file and slide
title.

**Stage 3 — verification fan-out.** Render every page to PNG
(`typst compile --format png --pages N main.typ out-N.png` per page) and spawn
vision subagents to check each against the checklist: nothing overflows the
body box or the page, titles clear the header, challenge and admin slides are
centered, tables render as tables, math renders as math (no ASCII operators,
no raw markup leaking), images load and are not squashed, no flag string
anywhere. Route every defect back to the section's agent with the page
number, fix, re-render, re-check.

**Stage 4 — notes and challenges.** Speaker notes and challenge solves go
through their own pass: re-run every solve script against the real challenge
source, confirm every TIME entry, sum the budgets against the session length.

On an agent harness with a `/parallelize` command, use it: topics are the
sections, stages are draft, gate-clean, vision-passed; advance per topic on
each completion event, never in barrier waves. On any other harness, spawn
all section agents in one `task[]` batch and advance each section as its
results arrive.

## Definition of done

- `typst compile --input gate=true main.typ` exits clean; `--input debug=true`
  output reviewed; both deck and template untouched by one-off hacks.
- Every rendered page has passed a vision check against the checklist, with
  defects fixed and re-checked — not just compile-green.
- Speaker notes exist for every section in `speaker-notes/*.md` (SAY / ASK /
  WATCH / NEXT / TIME per slide), `00-overview.md` carries the timing budget
  and cut list, the TIME entries sum to the session's minutes, and
  `99-page-index.md` is regenerated from the final PDF
  (`uv run --with pdfminer.six scripts/gen-page-index.py`).
- Every challenge slide matches the PART 0 platform table: id, name, deadline
  in HKT, links and files; every solve was executed locally end-to-end; flags
  appear only inside `speaker-notes/`, never in any `.typ` file; the
  attendance flag appears nowhere in the deck source.
- Slide prose survives a read-aloud pass: it sounds like the source deck's
  lecturer, not like a model.
- The deck repo README states what the deck is, the three build commands
  (plain, gate, debug), the layout, and the conventions — accurate, present
  tense, no design-diary.
- Nothing is committed or pushed without the lecturer's go-ahead.
