// Palette + type QA: the compile fails below WCAG thresholds or projector
// size minimums.
#import "@preview/firebird-slides:0.3.0": pal, geo, font-sans, font-mono

#let lum(color) = {
  let c = rgb(color.to-hex())      // named/gray colors expose only 2 components
  let (ra, ga, ba, _) = c.components()
  let (r, g, b) = (float(ra), float(ga), float(ba))
  let f(s) = if s <= 0.03928 { s / 12.92 } else { calc.pow((s + 0.055) / 1.055, 2.4) }
  0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)
}

#let ratio(a, b) = {
  let (x, y) = (lum(a), lum(b))
  if x < y { (y + 0.05) / (x + 0.05) } else { (x + 0.05) / (y + 0.05) }
}

#let shown(c) = c.to-hex()
#let txt(s) = text(font: font-mono, size: 12pt, s)

#let pairs = (
  ("body on surface",           pal.ink,        pal.surface,    4.5),
  ("muted on surface",          pal.ink-muted,  pal.surface,    4.5),
  ("strong on surface",         pal.ink-strong, pal.surface,    7.0),
  ("body on chrome (header)",   pal.ink,        pal.chrome,     4.5),
  ("muted on chrome",           pal.ink-muted,  pal.chrome,     4.5),
  ("tint on dark band",         pal.tint,       pal.ink,        4.5),
  ("callout title on light head", pal.ink-strong, pal.fill-2,   4.5),
  ("white on dark band",        white,          pal.ink,        4.5),
  ("link teal on surface",      pal.brand-a-ink, pal.surface,   4.5),
  ("orange ink on surface",     pal.brand-b-ink, pal.surface,   4.5),
  // syntax colours: the values in firebird.tmTheme, on the raw background
  ("code keyword (teal)",       rgb("#0E7A6E"),  pal.code-bg,    4.5),
  ("code string (orange)",      rgb("#B8440A"),  pal.code-bg,    4.5),
  ("code number (blue)",        rgb("#2F6E8F"),  pal.code-bg,    4.5),
  ("code function (blue)",      rgb("#17697E"),  pal.code-bg,    4.5),
  ("code comment",              rgb("#5F7178"),  pal.code-bg,    4.5),
  ("code foreground",           rgb("#3F4E54"),  pal.code-bg,    7.0),
  ("danger on surface",         pal.danger,     pal.surface,    4.5),
  ("danger on chrome",          pal.danger,     pal.chrome,     4.5),
  ("code body on code bg",      pal.ink-strong, pal.code-bg,    7.0),
  ("line numbers on code bg",   pal.ink-muted,  pal.code-bg,    4.5),
  ("structural chrome (rules)", pal.structural, pal.surface,    1.5),
)

// Typst closures cannot mutate outer bindings.
#let results = pairs.map(((label, fg, bg, min)) => {
  let r = ratio(fg, bg)
  (label: label, fg: fg, bg: bg, r: r, min: min, ok: r >= min)
})
#let failures = results.filter(x => not x.ok).map(x =>
  x.label + ": " + str(calc.round(x.r, digits: 2)) + " < " + str(x.min))

#let rows = results.map(x => (
  x.label, shown(x.fg), shown(x.bg), str(calc.round(x.r, digits: 2)),
  if x.ok { text(fill: pal.brand-a, weight: 600, "pass") } else { text(fill: pal.danger, weight: 600, "FAIL") },
))

// Projector-size minimums: nothing smaller than 13.5 pt on a 297 mm-wide page.
#let sizes = (
  ("body", 18pt, 18pt),
  ("caption / footer", 14pt, 13.5pt),
  ("code (comfortable)", 15.5pt, 15pt),
  ("code (minimum)", 13.5pt, 13.5pt),
  ("slide title", 23.9pt, 23pt),
  ("cover / section title", 31.7pt, 31pt),
)
#let size-failures = sizes.filter(((name, size, min)) => size < min).map(((name, size, min)) =>
  name + " is " + str(size) + ", below " + str(min))
#let failures = failures + size-failures

#set page(width: 297mm, height: 170mm, margin: 18mm, fill: pal.surface)
#set text(font: font-sans, size: 13.5pt, fill: pal.ink)

= Contrast and size audit

#context txt("page " + str(page.width / 1mm) + "mm × " + str(page.height / 1mm) + "mm · body " + str(geo.body-y / 1pt) + "pt top, " + str(geo.body-bottom / 1pt) + "pt bottom inset")

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: (x: 8pt, y: 4pt),
  stroke: none,
  ..((("pair", "fg", "bg", "ratio", "WCAG AA"),), ..rows).map(r => r.map(c => if type(c) == str { txt(c) } else { c })).flatten(),
)

#if failures.len() > 0 {
  v(10pt)
  for f in failures { block(txt(text(fill: pal.danger, "FAIL: " + f))) }
}
#assert(failures.len() == 0, message: "QA failures: " + failures.join("; "))
