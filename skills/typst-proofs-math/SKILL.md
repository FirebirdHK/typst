---
name: typst-proofs-math
description: Math, proofs, and physics (base math · physica 0.9.8 · curryst 0.6.0).
---

# Math, proofs, and physics (base math · physica 0.9.8 · curryst 0.6.0)
**Trigger**: typing or porting math — LaTeX article formulas, physics expressions (`dv`/`braket`/units), or natural-deduction proof trees.
**Start from**: blank `.typ` (`templates/scratch-note.typ` when the math sits in a prose note). No math template exists; start from the probe files listed below.

## Default path
1. Math is markup, not code: bare identifiers resolve as symbols/variables. Multi-letter words need spaces (`d f`) or quotes (`"if"`); no backslash commands — `frac(a, b)`, `hat(x)`, `lim`, `lr(...)`.
2. Delimiters scale automatically — `\left\right` is **not needed**: `(a/b)` grows its parens; `(a+b)(c+d)` correctly does not over-scale. Use `lr(..., size: #150%)` where LaTeX had `\Bigl`; `floor`/`ceil`/`norm`/`abs` are built in. Spacing is class-driven — fix glue with `class("binary", …)` / `class("relation", …)`.
3. Symbol surface: `experiments/math/10-symbols-probe.typ` is the **whitelist** — if it compiles there, it is known-good. Reach for `xor`, `eq.not`, `oo`, `exists.not`, `product`, `inter`, `integral.cont`, `integral.triple`, `arrow.twohead.r`, `approx`/`equiv`/`in.not`. Raw unicode (`≠ ≈ ≤ ≥ ⊕ ∈ × ∞ α π`) compiles even when the *name* fails, but may get ORD class (no binary spacing) — prefer named symbols when glue matters.
4. Derivatives: `(d f)/(d x)`, `partial`, built-in upright `dif`; number per probe-09 forms. Accents: `hat(x)`, `bar(x)`, `caron(x)` (**not** `check`). Multi-letter accent bases must be quoted: `hat(AB)` → `unknown variable: AB`, write `hat("AB")`.
5. Numbering/refs: `#set math.equation(numbering: "(1)")` + `$ … $ <eq:x>` + `@eq:x`. Block `$ … $` stacks `sum`/`product` limits; inline keeps them small; there is no `\textstyle` switch.
6. physica when the expression is on its win list: `dv`/`dd` (TeXBook thin spaces), symbolic `pdv` with auto total-order summation, `bra`/`ket`/`braket` (lr-scaled), `tensor`, `jmat`/`hmat`/`dmat`, `Set`, `evaluated`, `vb`/`va`/`vu`, `Re`/`Im` upright. Prefer **selective imports**: `#import "@preview/physica:0.9.8": dv, pdv, dd, ket, bra`. `\qty`/`\num` are **not** physica — that is `unify`: `#qty("9.81", "meter per second squared")`; its `delimiter` is eval-spliced, so spell `delimiter: "\"to\""`.
7. Proofs: curryst is three layers — `rule` **builds data** (a dict), `prooftree` renders it, `rule-set` flows rendered trees. **Last positional = conclusion, all earlier positionals = premises** (the universe README says "first" — source and every example take it last; trust the source). Bind schemas once: `#let impl-e = rule.with(name: $scripts(->)_e$)`. Always wrap `rule-set` in `#align(center, …)`.
8. Silent traps to expect (all rc=0): `x^2^3` nests as `x^(2^3)`; inline `/` fractions still stack; physica kwargs renamed in 0.9.7 (`s:`→`style:`, `p:`→`prod:`) compile clean and render the default; forgetting `prooftree(...)` prints the rule dict as code under the real tree.

## Fail modes → fix
| Exact string / symptom | Fix |
|---|---|
| ``error: unknown variable: cdot`` (+ hint ``try adding spaces between each letter: `c d o t` ``) | use `times`/`ast`/`bullet`/`circle`/`dot` (all compile) |
| `error: unknown variable: oplus` / `neq` / `infty` / `nexists` / `prod` | `xor` / `eq.not` / `oo` / `exists.not` / `product` |
| `error: unknown symbol modifier` (`plus.circle`, `angle.l`, `dot.small`, `arrows.squiggly`) | `plus.o`, `chevron.l/r`, `dot.double`, `arrow.r.squiggly` |
| `error: unknown variable: <name>` for the whole relation row (`sim`, `simeq`, `leq`, `implies`, `land`, `notin`, …) | the compiling row: `~`, `approx`, `equiv`, `approx.eq`, `tilde.eq`, `in.not`, `<=`, `>=`, `->`, `and`, `or` — relearn it, don't patch it |
| ``error: module `sym` does not contain `iiint` `` | math-mode `integral.triple`; only the first missing member is named — probe each |
| `error: unclosed delimiter` (`lr(] x [)`, prose `]`/`align*`) | pair/escape delimiters; backtick LaTeX-ish prose and comments |
| `error: expected "normal", "punctuation", "opening", "closing", "fence", "large", "relation", "unary", "binary", or "vary"` | exact class kinds — `class("binary", …)`; `vary` = the contextual minus |
| `error: invalid delimiter: ","` / `error: unexpected argument: delims` | geometric delimiters only; param is singular `delim:` |
| `hat(AB)` → `error: unknown variable: AB` (hint suggests `` `A B` `` / `"AB"`) | `hat("AB")` or `hat(A B)` |
| `error: unknown variable: set` / `error: unresolved import` (`eval`, `gradient`, `divergence`) | `Set(1, 2)`; `evaluated(...)`; removed in 0.9.2/0.9.5 |
| `array index out of bounds (index: -1, len: 0) and no default value was specified` (curryst L16) | zero positionals — write `ax($Gamma tack p$)`, never `rule(name: [ax])` |
| `(rc=0)` physica `dv(f, x, s: "horizontal")` renders stacked default | `..args` sinks swallow renamed/misspelled kwargs — spell `style:` and diff the render against a control |

## Deviate safely
- **Free**: symbol choice among compiling aliases, delimiter styles, numbering patterns, base-vs-physica per expression, `rule.with(name:)` schema naming, `vertical-spacing`/`min-premise-spacing` knobs (2–6pt reads well).
- **Measured floors**: `hat("AB")` quoting; conclusion **last** in `rule(...)`; `dir` ∈ {`btt`,`ttb`}; nesting `#text(size:…)`/`fill` around a prooftree is fine (measurement happens at layout time); physica `..args` sinks mean **green compile proves nothing** about `style:`/`prod:`/`d:`/`total:`/`compact:` — diff against a spelled-out control. Pin `equate 0.3.3` if used (0.2.1 panics under auto-page + numbering); never `metro 0.3.0` on 0.15.1 (`unknown variable: kelvin` at import).
- **Escape hatches**: one inline axiom mid-sentence → hand-rolled math bar `$overline(#box($Gamma tack p$)$)` beats a package round-trip; one fixed micro-rule in a caption → a 6-line `stack` is fine if you accept a left-aligned name; `\boxed`/`\substack`/per-line `\tag`/`\boldsymbol` have no base equivalent — package territory, not a defect in your source.

## Verify
`scripts/verify.sh <file>.typ` → read `.verify/page-*.png`. Also sweep the corpus: `for f in experiments/math/*.typ; do typst compile "$f" || echo FAIL "$f"; done` → **21 OK / 0 FAIL**. Vision-check in PNGs (text extraction misses some): physica stacked-vs-horizontal (e01 control), `union`/`inter` limits beside `sum`/`product` stacking, slash-frac stacking, `x^2^3` nesting, and curryst bars — centered conclusion, name hung right, no dict repr under the tree. Silent class (dict repr, content pass-through, mis-labeled positional swap) is only catchable by vision.

## Deep reference
`base-math.md` — §2.1 symbol failure catalog, §2.2 `class(...)` kinds, §3 error catalog, §4.1 LaTeX port table, §4.2 visual divergence, §4.3 gaps. `physica.md` — §2 feature map, §3.2 derivative idioms, §5.1 hard errors, §5.2 the silent wrong-output family, §7 when NOT to use. `curryst.md` — §2.1 API quick reference, §3.1 typography knobs, §4 error catalog, §7 when to hand-roll. Probes: `experiments/math/10-symbols-probe.typ`, `experiments/physica/errors/`, `experiments/curryst/09-errors.typ`.
