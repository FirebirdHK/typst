// firebird-slides — slide template for the HKUST Firebird CTF team.
// Typst 0.15+ · touying 0.7.4 · 16:9 (297 × 167.0625 mm) by default, 4:3 available.

#import "@preview/touying:0.7.4": *

#import "assets/blobcats.typ": blobcat-files, blobcat-names

#let pal = (
  surface:    rgb("#FFFFFF"),
  chrome:     rgb("#E9EDEE"),
  code-bg:    luma(247),
  code-line:  luma(220),
  zebra:      luma(240),
  ink:        rgb("#496268"),  // 6.50:1 on white
  ink-strong: rgb("#2B2B2B"),  // 13.9:1 on white
  ink-muted:  rgb("#666666"),  // 5.74:1 on white
  structural: rgb("#8FA9AF"),  // never text
  hairline:   rgb("#A9BAC7"),
  fill-2:     rgb("#B6D6DD"),
  tint:       rgb("#ECFCFF"),
  ok:         rgb("#3F6B4F"),
  danger:     rgb("#A3402F"),
  // Sampled from the team's decorative rule (weird_hline.png): the plain
  // accents fill and rule only — the `-ink` variants clear 4.5:1 as text
  // (tests/contrast.typ).
  brand-a:    rgb("#1A9988"),
  brand-b:    rgb("#EB5600"),
  brand-a-ink: rgb("#0E7A6E"),
  brand-b-ink: rgb("#B8440A"),
)

// IBM Plex fonts bundled in `vendor/fonts` (SIL OFL); no programming ligatures.
#let font-sans = ("IBM Plex Sans", "SF Pro", "Helvetica Neue", "Arial")
#let font-mono = ("IBM Plex Mono", "SF Mono", "Menlo", "DejaVu Sans Mono")
#let font-serif = ("IBM Plex Serif", "New Computer Modern", "Charter", "Georgia")

#let fb-fonts = state("fb-fonts", (sans: font-sans, mono: font-mono, serif: font-serif, display: font-sans))
#let fb-mono() = fb-fonts.get().mono
#let fb-serif() = fb-fonts.get().serif
#let fb-display() = fb-fonts.get().display

#let serif(body) = context text(font: fb-serif(), body)

#let geo = (
  w:           297mm,
  h:           167.0625mm,
  w4x3:        254mm,
  h4x3:        190.5mm,
  gut:         60pt,
  pad:         20pt,
  pad-mono-x:  16pt,
  pad-mono-y:  14pt,
  pad-table-x: 12pt,
  pad-table-y: 9pt,
  brand-y:     16pt,
  rule-y:      36pt,
  title-y:     55pt,
  body-y:      91pt,
  body-bottom: 40pt,
  foot-y:      26pt,
)

#let fb-type-scale(body) = (
  body:         body,
  title:        body * 1.45,
  subtitle:     body * 0.76,
  section:      body * 2.0,
  subsection:   body * 1.76,
  cover-sub:    body * 1.0,
  lead:         body * 0.76,
  callout-head: body * 1.15,
  code:         body * 0.86,
  terminal:     body * 0.86,
  keyeq:        body * 1.0,
  quote:        body * 0.90,
  table:        body * 0.76,
  caption:      body * 0.76,
  toc-entry:    body * 1.45,
  toc-num:      body * 1.0,
  pill:         body * 0.86,
  small:        14pt,
)

#let fb-type = state("fb-type", fb-type-scale(19.5pt))
#let fb-t() = fb-type.get()

#let fb-sec-num = counter("fb-sec-num")
#let fb-section = state("fb-section", none)
#let fb-subsection = state("fb-subsection", none)
#let fb-meta = state("fb-meta", (:))

#let fb-mid = center + horizon

// measure() matches the rendered flow: Typst swallows a leading `above` at the
// start of a flow.
#let fb-over(body, w, h) = {
  let m = measure(block(width: w, body))
  if m.height <= h { 0pt } else { m.height - h }
}

#let fb-overflow-gate(over, title) = context {
  if over > 0pt and fb-meta.get().at("gate", default: false) {
    let name = if type(title) == str and title != "" { " [" + title + "]" } else { "" }
    panic(
      "slide " + str(utils.slide-counter.get().first()) + name + " is "
        + str(calc.round(over / 1pt, digits: 0))
        + "pt taller than its body box — split the slide or trim it; never shrink the type.",
    )
  }
}

#let put(x, y, w, body) = context {
  let width = if w == auto { page.width - 2 * geo.gut } else { w }
  place(top + left, dx: x, dy: y, block(width: width, body))
}

#let putb(x, w, body) = context {
  let width = if w == auto { page.width - 2 * geo.gut } else { w }
  place(bottom + left, dx: x, dy: -geo.body-bottom, block(width: width, body))
}

// On dark bands the teal half dies against slate — pass lighter colours there.
#let brand-rule(width: 22mm, height: 2pt, colors: (pal.brand-a, pal.brand-b)) = stack(
  dir: ltr, spacing: 0pt,
  rect(width: width / 2, height: height, fill: colors.at(0)),
  rect(width: width / 2, height: height, fill: colors.at(1)),
)

#let band(fill: pal.chrome, bar: true, body) = context {
  let pw = page.width
  pdf.artifact(kind: "layout")[
    #place(top + left, dx: 0pt, dy: 0pt, rect(width: pw, height: page.height, fill: fill))
    #if bar {
      place(top + left, dx: 0pt, dy: 0pt, stack(
        dir: ltr, spacing: 0pt,
        rect(width: pw / 2, height: 3pt, fill: pal.brand-a),
        rect(width: pw / 2, height: 3pt, fill: pal.brand-b),
      ))
    }
  ]
  body
}

#let fb-header(course) = context {
  let t = fb-t()
  let pw = page.width
  let n = utils.slide-counter.get().first()
  let total = utils.last-slide-counter.final().first()
  let frac = a => if total <= 0 { 0% } else { calc.clamp(a / total, 0, 1) * 100% }
  let done = frac(calc.max(n - 1, 0))
  let now = frac(n) - done

  pdf.artifact(kind: "layout")[
    #place(top + left, dy: 0pt, rect(width: pw, height: 3pt, fill: pal.chrome))
    #if n > 0 {
      place(top + left, dy: 0pt, rect(width: done, height: 3pt, fill: pal.brand-a))
      place(top + left, dx: done, dy: 0pt, rect(width: now, height: 3pt, fill: pal.brand-b))
    }
    #place(top + left, dx: geo.gut, dy: geo.brand-y + 2pt, image("assets/firebird-mark.png", height: 14pt))
    #place(top + left, dx: geo.gut + 14pt + 9pt, dy: geo.brand-y + 1pt,
      text(size: t.small, weight: 600, fill: pal.ink, tracking: 0.3pt)[Firebird CTF Team])
    #if course != none {
      place(top + right, dx: -geo.gut, dy: geo.brand-y + 1pt,
        text(size: t.small, fill: pal.ink-muted, course))
    }
    #place(top + left, dy: geo.rule-y, rect(width: pw, height: 0.8pt, fill: pal.hairline))
    #place(top + left, dy: geo.rule-y, rect(width: pw / 2, height: 0.8pt, fill: pal.structural))
  ]
}

#let fb-footer(breadcrumb: true, index: true) = context {
  let t = fb-t()
  let y = page.height - geo.foot-y
  let crumbs = ()
  let sec = fb-section.get()
  let sub = fb-subsection.get()
  if sec != none { crumbs.push(sec) }
  if sub != none { crumbs.push(sub) }
  pdf.artifact(kind: "layout")[
    #if breadcrumb and crumbs.len() > 0 {
      place(top + left, dx: geo.gut, dy: y, text(size: t.small, fill: pal.ink-muted, crumbs.join("  ›  ")))
    }
    #if index {
      place(top + right, dx: -geo.gut, dy: y, text(size: t.small, fill: pal.ink-muted)[
        #utils.slide-counter.display()
        #h(3pt)#text(fill: pal.hairline)[/]#h(3pt)
        #utils.last-slide-counter.final().first()
      ])
    }
  ]
}

// touying evaluates this wrapper before layout: no states, counters or
// `measure()` here — measurement runs in `setting` at layout time.
#let slide(
  title: none,
  subtitle: none,
  center: false,
  header: true,
  footer: true,
  guide: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let st = self.store
  let t = st.t
  let meta = st.meta
  let show-guide = if guide == auto { meta.at("debug", default: false) } else { guide }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    composer: composer,
    setting: composed => setting(context {
      let t = fb-t()
      let avail-w = page.width - 2 * geo.gut
      let top-inset = geo.title-y

      let sub-w = if subtitle == none { 0pt } else { measure(text(size: t.subtitle, fill: pal.ink-muted, subtitle)).width }
      let title-avail = avail-w - sub-w - if sub-w > 0pt { 24pt } else { 0pt }
      let title-size = if title == none { t.title } else {
        let probe = measure(text(font: fb-display(), size: t.title, weight: 600, title))
        if probe.width <= title-avail { t.title } else {
          calc.max(t.title * (title-avail / probe.width) / 1pt * 1pt, t.title * 0.85)
        }
      }
      let head = block(above: 0pt, below: 0pt)[
        #if title != none or subtitle != none {
          grid(
            columns: (1fr, if sub-w > 0pt { auto } else { 0pt }),
            column-gutter: 24pt, align: (left + horizon, right + horizon),
            if title != none { text(font: fb-display(), size: title-size, weight: 600, fill: pal.ink, title) },
            if subtitle != none { text(size: t.subtitle, fill: pal.ink-muted, subtitle) },
          )
        }
        #if title != none { block(above: 0pt, below: 0pt, inset: (top: t.title * 0.32), brand-rule()) }
        #v(0.4em)
      ]
      let has-head = title != none or subtitle != none
      let head-h = if has-head { measure(block(width: avail-w, head)).height } else { 0pt }
      let free-h = page.height - top-inset - geo.body-bottom - head-h

      let over = fb-over(composed, avail-w, free-h)
      fb-overflow-gate(over, title)

      // A fixed-height block with auto width shrink-wraps; `width: 100%`
      // keeps centering on the full body box.
      let body-flow = if center {
        block(width: 100%, height: free-h)[#align(fb-mid, composed)]
      } else {
        block(width: 100%, height: free-h, composed)
      }
      block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
        #if header { fb-header(meta.at("course", default: none)) }
        #if show-guide {
          place(
            top + left, dx: geo.gut, dy: top-inset + head-h,
            rect(
              width: avail-w, height: free-h,
              stroke: (paint: pal.danger.lighten(50%), thickness: 0.6pt, dash: "dashed"),
            ),
          )
        }
        #if show-guide and over > 0pt {
          place(
            top + right, dx: -(geo.gut + 8pt), dy: top-inset + head-h + 8pt,
            rect(fill: pal.danger, radius: 4pt, inset: (x: 8pt, y: 4pt))[
              #text(size: t.small, weight: 600, fill: white)[
                OVERFLOW + #calc.round(over / 1pt, digits: 0) pt
              ]
            ],
          )
        }
        #block(
          width: 100%, height: 100%, above: 0pt, below: 0pt,
          inset: (left: geo.gut, right: geo.gut, top: top-inset, bottom: geo.body-bottom),
        )[
          #if has-head { head }
          #body-flow
        ]
        #if footer { fb-footer() }
      ]
    }),
    ..bodies,
  )
})

#let title-slide(title: auto, subtitle: auto, authors: auto, helpers: auto, credits: auto, date: auto, course: auto) = touying-slide-wrapper(self => {
  let ty = self.store.t
  let disp = self.store.fonts.display
  let (pw, ph) = utils.get-page-dimensions(self)
  let meta = if title == auto or subtitle == auto or authors == auto or helpers == auto or credits == auto or date == auto or course == auto {
    self.store.meta
  } else { (:) }
  let t  = if title == auto { meta.at("title", default: none) } else { title }
  let st = if subtitle == auto { meta.at("subtitle", default: none) } else { subtitle }
  let au = if authors == auto { meta.at("authors", default: ()) } else { authors }
  let he = if helpers == auto { meta.at("helpers", default: ()) } else { helpers }
  let cr = if credits == auto { meta.at("credits", default: ()) } else { credits }
  let dt = if date == auto { meta.at("date", default: none) } else { date }
  let co = if course == auto { meta.at("course", default: none) } else { course }

  touying-slide(
    self: self,
    block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
      #context band(bar: true)[
        #put(geo.gut, 34pt, auto)[
          #if co != none { text(size: ty.lead, weight: 600, fill: pal.ink, co) }
          #v(8pt)
          #brand-rule(width: 40mm, height: 2.4pt)
          #if t != none {
            v(14pt)
            text(font: disp, size: ty.section, weight: 600, fill: pal.ink, t)
          }
          #if st != none {
            v(10pt)
            text(size: ty.cover-sub, fill: pal.ink, st)
          }
        ]
        #place(bottom + left, dx: geo.gut, dy: -52pt, block(width: pw - 2 * geo.gut - 60pt)[
          #text(size: ty.lead, weight: 600, fill: pal.ink-strong, au.join("   ·   "))
          #if he != () and he != none {
            v(4pt)
            text(size: ty.lead, fill: pal.ink)[
              #text(size: ty.small, weight: 600, tracking: 1pt, fill: pal.ink-muted)[HELPERS]
              #h(8pt)
              #he.join("   ·   ")
            ]
          }
          #if cr != () and cr != none {
            v(4pt)
            text(size: ty.small, fill: pal.ink-muted, cr.join("   ·   "))
          }
          #if dt != none {
            v(6pt)
            text(size: ty.lead, fill: pal.ink-muted, dt)
          }
        ])
        #place(bottom + right, dx: -geo.gut, dy: -52pt, block(width: 220pt)[
          #align(center)[
            #image("assets/firebird-mark.png", height: 80pt)
            #v(10pt)
            #text(size: ty.small, weight: 600, tracking: 1pt)[
              #text(fill: pal.ink)[FIREBIRD]
              #text(fill: pal.brand-b-ink)[ CTF TEAM]
            ]
          ]
        ])
      ]
    ],
  )
})

#let toc-slide(title: "Agenda", depth: 2) = touying-slide-wrapper(self => {
  let t = self.store.t
  let disp = self.store.fonts.display
  touying-slide(
    self: self,
    block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
      #fb-header(self.store.meta.at("course", default: none))
      #put(geo.gut, geo.title-y, auto)[
        #text(font: disp, size: t.section, weight: 600, fill: pal.ink, title)
        #v(12pt)
        #brand-rule(width: 34mm, height: 2.4pt)
      ]
      #block(height: 100%, inset: (left: geo.gut, right: geo.gut, top: geo.title-y + t.section * 1.9, bottom: geo.body-bottom))[
        // Hand-built from the outlined headings: `outline` does not flow
        // across columns.
        #context {
          let hs = query(heading).filter(h => h.outlined != false and h.level <= depth)
          let groups = ()
          let lines = 0
          for h in hs {
            if h.level == 1 {
              groups.push((h, ()))
              lines += 1
            } else if groups.len() > 0 {
              let n = groups.len() - 1
              groups.at(n) = (groups.at(n).at(0), groups.at(n).at(1) + (h,))
              lines += 1
            }
          }
          let half = calc.ceil(lines / 2)
          let cols = ((), ())
          let filled = 0
          for (i, g) in groups.enumerate() {
            let gl = 1 + g.at(1).len()
            if filled >= 0 and filled > 0 and filled + gl > half and cols.at(0).len() > 0 {
              let room = half - filled
              if room >= 2 and g.at(1).len() > 0 {
                let take = calc.min(room - 1, g.at(1).len())
                cols.at(0).push((i, (g.at(0), g.at(1).slice(0, take))))
                if take < g.at(1).len() {
                  cols.at(1).push((i, (g.at(0), g.at(1).slice(take)), true))
                }
              } else {
                cols.at(1).push((i, g))
              }
              filled = -1000
            } else if filled >= 0 {
              cols.at(0).push((i, g))
              filled += gl
            } else {
              cols.at(1).push((i, g))
            }
          }
          let entry(ig) = link(ig.at(1).at(0).location(), grid(
            columns: (auto, 1fr), column-gutter: 18pt, align: top,
            text(size: t.toc-num, weight: 600, fill: pal.structural,
              numbering("01", ig.at(0) + 1)),
            text(size: t.toc-entry, weight: 600, fill: pal.ink, ig.at(1).at(0).body),
          ))
          let sub(h) = link(h.location(), block(
            inset: (left: 66pt), above: 0.35em, below: 0pt,
            text(size: t.body, fill: pal.ink-muted, h.body),
          ))
          let cell(gs) = stack(
            dir: ttb, spacing: 1em,
            ..gs.map(g => stack(
              dir: ttb, spacing: 0.55em,
              ..(if g.len() > 2 { () } else { (entry(g),) }),
              ..g.at(1).at(1).map(sub),
            )),
          )
          grid(
            columns: (1fr, 1fr), column-gutter: 64pt, align: top + left,
            cell(cols.at(0)),
            if cols.at(1).len() > 0 { cell(cols.at(1)) },
          )
        }
      ]
      #fb-footer(breadcrumb: false)
    ],
  )
})

// State and counter updates run inside the content: touying evaluates this
// wrapper before layout, where an update in code position is discarded.
#let section-slide(title, subtitle: none, note: none) = touying-slide-wrapper(self => {
  let t = self.store.t
  let disp = self.store.fonts.display
  touying-slide(
    self: self,
    config: utils.merge-dicts(
      config-page(fill: pal.ink),
      config-common(zero-margin-header: false, zero-margin-footer: false),
    ),
    block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
      #fb-section.update(title)
      #fb-subsection.update(none)
      #counter(heading).step()
      #context band(fill: pal.ink, bar: false)[
        #put(geo.gut, 140pt, auto)[
          #text(size: t.small, weight: 600, tracking: 1pt, fill: pal.tint,
                 context numbering("01", fb-sec-num.get().at(0, default: 0) + 1))
          #v(10pt)
          #heading(level: 1, outlined: true, title)
          #v(14pt)
          #brand-rule(width: 34mm, height: 2.4pt, colors: (pal.tint, pal.brand-b))
          #if subtitle != none {
            v(16pt)
            text(size: t.cover-sub, fill: pal.tint, subtitle)
          }
        ]
        #context place(top + left, dy: 0pt, rect(width: page.width, height: 3pt, fill: pal.brand-b))
        #if note != none {
          putb(geo.gut, auto,
            text(size: 18pt, fill: pal.tint, note))
        }
        #place(bottom + right, dx: -geo.gut, dy: -geo.body-bottom,
          text(size: t.small, fill: pal.tint, tracking: 0.3pt)[Firebird CTF Team])
      ]
    ],
  )
})

#let subsection-slide(title) = touying-slide-wrapper(self => {
  let t = self.store.t
  let disp = self.store.fonts.display
  touying-slide(
    self: self,
    block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
      #fb-subsection.update(title)
      #put(geo.gut, 148pt, auto)[
        #text(size: t.cover-sub, weight: 600, fill: pal.ink-muted,
               context if fb-section.get() == none { "" } else { fb-section.get() })
        #v(8pt)
        #brand-rule(width: 30mm, height: 2.4pt)
        #v(14pt)
        #heading(level: 2, outlined: true, title)
      ]
    ],
  )
})

#let pill(body) = context box(
  fill: pal.chrome, radius: 4pt, inset: (x: 8pt, y: 2pt), outset: (y: 2pt),
  text(size: fb-t().pill, weight: 600, fill: pal.ink, body),
)

#let bio-slide(name, discord: none, photo: none, title: "Speaker bio", body) = slide(
  title: title,
)[
  #context {
    let t = fb-t()
    grid(
      columns: (if photo != none { auto } else { 0pt }, 1fr),
      column-gutter: if photo != none { 30pt } else { 0pt },
      align: (left + horizon, horizon),
      if photo != none {
        block(above: 0pt, below: 0pt, radius: 8pt, clip: true, photo)
      },
      block(above: 0pt, below: 0pt)[
        #text(size: t.title, weight: 600, fill: pal.ink, name)
        #if discord != none {
          h(10pt)
          pill(text(font: fb-mono(), size: t.pill, "@" + discord))
        }
        #v(0.8em)
        #body
      ],
    )
  }
]

#let fb-admin-kind-color(kind) = {
  let k = lower(kind)
  if k.contains("attend") { pal.brand-a-ink }
  else if k.contains("ex") or k.contains("lab") { pal.brand-b-ink }
  else if k.contains("hw") or k.contains("home") or k.contains("ps") or k.contains("problem") or k.contains("due") { pal.ink }
  else { pal.ink-muted }
}
#let fb-admin-body(items, note, qr, qr-caption) = context {
  let mono = fb-mono()
  let t = fb-t()
  let rows = items.map(it => (
    text(font: mono, size: t.small, weight: 600, fill: fb-admin-kind-color(it.kind), upper(it.kind)),
    text(size: t.body, fill: pal.ink-strong, it.what),
    if it.at("when", default: none) != none {
      text(font: mono, size: t.small, fill: pal.ink, it.when)
    },
    if it.at("where", default: none) != none {
      text(size: t.small, fill: pal.ink-muted, it.where)
    },
  ))
  let table-block = block(width: 100%, above: 0pt, below: 0pt)[
    #table(
      columns: (auto, 1fr, auto, auto),
      align: (left, left, right, right),
      inset: (x: geo.pad-table-x, y: 11pt),
      stroke: none,
      fill: (col, row) => if calc.even(row) { pal.tint },
      ..rows.flatten(),
    )
  ]
  let qr-card = if qr != none {
    block(width: 178pt, radius: 4pt, stroke: 1pt + pal.code-line, above: 0pt, below: 0pt)[
      #block(width: 100%, fill: pal.code-bg, inset: (x: 16pt, y: 13pt), below: 0pt)[
        #show image: set image(width: 100%)
        #align(center, qr)
      ]
      #block(width: 100%, inset: (x: 8pt, y: 7pt), above: 0pt)[
        #align(center, text(size: t.caption, fill: pal.ink-muted, qr-caption))
      ]
    ]
  }
  grid(
    columns: if qr != none { (1fr, auto) } else { (1fr,) },
    column-gutter: 44pt,
    align: (top, horizon),
    table-block,
    if qr != none { qr-card } else { [] },
  ) + if note != none {
    v(10pt) + text(size: t.small, fill: pal.ink-muted, note)
  } else { [] }
}
#let admin-slide(items, title: "This week", note: none, qr: none, qr-caption: "Scan for attendance") = slide(
  title: title, center: true, [#fb-admin-body(items, note, qr, qr-caption)],
)

#let fb-credits-body(entries, note) = context {
  let mono = fb-mono()
  let t = fb-t()
  let table-block = block(width: 100%, above: 0pt, below: 0pt)[
    #table(
      columns: (1fr, auto),
      align: (left, right),
      inset: (x: geo.pad-table-x, y: 11pt),
      stroke: none,
      fill: (col, row) => if calc.even(row) { pal.tint },
      ..entries.map(((item, source)) => (
        text(size: t.body, fill: pal.ink-strong, item),
        text(font: mono, size: t.small, fill: pal.ink-muted, source),
      )).flatten(),
    )
  ]
  table-block + if note != none {
    v(10pt) + text(size: t.small, fill: pal.ink-muted, note)
  } else { [] }
}
#let credits-slide(entries, title: "Credits", note: none) = slide(
  title: title, center: true, [#fb-credits-body(entries, note)],
)

#let end-slide(title: "Thanks!", subtitle: "Questions?", lines: ()) = touying-slide-wrapper(self => {
  let t = self.store.t
  let disp = self.store.fonts.display
  touying-slide(
    self: self,
    config: config-page(fill: pal.ink),
    block(width: 100%, height: 100%, above: 0pt, below: 0pt, breakable: false)[
      #context band(fill: pal.ink, bar: false)[
        #put(geo.gut, 130pt, auto)[
          #text(font: disp, size: t.section, weight: 600, fill: pal.tint, title)
          #if subtitle != none {
            v(6pt)
            text(size: t.cover-sub, fill: pal.tint, subtitle)
          }
          #v(16pt)
          #brand-rule(width: 40mm, height: 2.4pt, colors: (pal.tint, pal.brand-b))
        ]
        #context place(top + left, dy: 0pt, rect(width: page.width, height: 3pt, fill: pal.brand-b))
        #if lines.len() > 0 {
          putb(geo.gut, auto,
            text(size: t.lead, fill: pal.tint, lines.join("\n")))
        }
        #place(bottom + right, dx: -geo.gut, dy: -geo.body-bottom,
          text(size: t.small, weight: 600, fill: pal.tint, tracking: 1pt)[FIREBIRD CTF TEAM])
      ]
    ],
  )
})

#let cols(a, b, ratio: 1fr, gutter: 40pt, align: top) = grid(
  columns: (ratio, 1fr), column-gutter: gutter, align: align, a, b,
)

#let fb-kinds = (
  definition: (accent: pal.brand-a, head-ink: pal.brand-a-ink),
  exercise:   (accent: pal.brand-a, head-ink: pal.brand-a-ink),
  claim:      (accent: pal.brand-a, head-ink: pal.brand-a-ink),
  remark:     (accent: pal.brand-a, head-ink: pal.brand-a-ink),
  theorem:    (accent: pal.ink, head-ink: pal.ink),
  example:    (accent: pal.ink, head-ink: pal.ink),
  proof:      (accent: pal.ink, head-ink: pal.ink),
  insight:    (accent: pal.ink, head-ink: pal.ink),
)

#let callout(body, kind: "definition", title: auto) = context {
  let t = fb-t()
  let k = fb-kinds.at(kind)
  block(
    width: 100%, breakable: false, above: 0.8em, below: 0.8em,
    stroke: (left: 2.5pt + k.accent),
    inset: (left: 16pt, right: 2pt, top: 2pt, bottom: 2pt),
  )[
    #text(size: t.callout-head, weight: 600, fill: k.head-ink,
          if title == auto { upper(kind.first()) + kind.slice(1) } else { title })
    #v(0.3em)
    #body
  ]
}

#let warning(body, title: "Warning") = context block(
  width: 100%, breakable: false, above: 0.8em, below: 0.8em,
  stroke: (left: 2.5pt + pal.danger),
  inset: (left: 16pt, right: 2pt, top: 2pt, bottom: 2pt),
)[
  #text(size: fb-t().callout-head, weight: 600, fill: pal.danger, title)
  #v(0.3em)
  #body
]

#let definition(body, ..a) = callout(kind: "definition", ..a, body)
#let exercise(body, ..a)   = callout(kind: "exercise", ..a, body)
#let claim(body, ..a)      = callout(kind: "claim", ..a, body)
#let remark(body, ..a)     = callout(kind: "remark", ..a, body)
#let theorem(body, ..a)    = callout(kind: "theorem", ..a, body)
#let example(body, ..a)    = callout(kind: "example", ..a, body)
#let proof(body, ..a)      = callout(kind: "proof", ..a, body)
#let insight(body, ..a)    = callout(kind: "insight", ..a, body)

#let fb-langs = (
  "py": "python", "python": "python", "sh": "sh", "bash": "sh", "zsh": "sh",
  "typ": "typst", "c": "c", "h": "c", "cpp": "cpp", "cc": "cpp", "rs": "rust",
  "js": "javascript", "ts": "typescript", "go": "go", "rb": "ruby", "java": "java",
  "sql": "sql", "json": "json", "yml": "yaml", "yaml": "yaml", "toml": "toml",
  "sage": "python", "hs": "haskell", "lua": "lua", "php": "php", "asm": "asm",
)

#let fb-lang-of(lang, file) = {
  if lang != none { return lang }
  if file == none { return none }
  let parts = file.split(".")
  if parts.len() < 2 { return none }
  fb-langs.at(parts.last(), default: none)
}

// One soft-wrapped `raw(block: true)`: a wrapped continuation stays one
// logical line and keeps its line number.
#let code(
  src,
  lang: none,
  file: none,
  lines: false,
  size: auto,
  gap: 0.62,
) = context {
  let mono = fb-mono()
  let t = fb-t()
  let lang = fb-lang-of(lang, file)
  let base = if size == auto { t.code } else { size }
  block(
    width: 100%, radius: 4pt, stroke: 1pt + pal.code-line,
    above: 0.8em, below: 0.8em,
  )[
    #if file != none {
      block(
        width: 100%, fill: pal.chrome, below: 0pt,
        inset: (x: geo.pad-mono-x, y: 8pt),
        grid(
          columns: (1fr, auto),
          text(font: mono, size: t.small, fill: pal.ink, weight: 600, file),
          if lang != none { text(size: t.small, fill: pal.ink-muted, lang) },
        ),
      )
    }
    #block(width: 100%, fill: pal.code-bg, above: 0pt,
           inset: (x: geo.pad-mono-x, y: geo.pad-mono-y))[
      #{
        set par(leading: gap * base)
        show raw: set text(font: mono, size: base, fill: pal.ink-strong)
        // A show rule only reaches content in its own block scope — it must
        // sit beside the `raw` call, not inside an `if`.
        show raw.line: it => {
          if lines {
            box(width: 1.9em, align(right,
              text(size: base - 1pt, fill: pal.ink-muted, tracking: 0pt, str(it.number))))
            h(0.3em)
          }
          it.body
        }
        raw(src, lang: lang, block: true)
      }
    ]
  ]
}

#let terminal(src, title: none, size: auto, dark: false, gap: 0.55) = context {
  let mono = fb-mono()
  let t = fb-t()
  let base = if size == auto { t.terminal } else { size }
  let bg = if dark { rgb("#223034") } else { pal.code-bg }
  let fg = if dark { rgb("#DCE9EC") } else { pal.ink-strong }
  let cmd = if dark { white } else { pal.ink-strong }
  let out = if dark { rgb("#9FB4B9") } else { pal.ink-muted }
  let chrome-bg = if dark { rgb("#1B272B") } else { pal.chrome }
  let chrome-ink = if dark { rgb("#93AAB0") } else { pal.ink }

  block(
    width: 100%, radius: 4pt, fill: bg,
    stroke: 1pt + (if dark { rgb("#31434A") } else { pal.code-line }),
    above: 0.8em, below: 0.8em,
  )[
    #if title != none {
      block(
        width: 100%, fill: chrome-bg, below: 0pt,
        inset: (x: geo.pad-mono-x, y: 8pt),
        text(font: mono, size: t.small, fill: chrome-ink, title),
      )
    }
    #block(width: 100%, above: 0pt, inset: (x: geo.pad-mono-x, y: geo.pad-mono-y))[
      #text(font: mono, size: base, fill: fg,
        stack(dir: ttb, spacing: gap * base, ..src.split("\n").map(line => {
          if line.starts-with("$ ") {
            block(width: 100%)[#text(fill: pal.ink, weight: 600, "$ ")#text(fill: cmd, line.slice(2))]
          } else if line.starts-with("> ") {
            block(width: 100%)[#text(fill: pal.ink, "> ")#text(fill: cmd, line.slice(2))]
          } else if line.starts-with("# ") {
            block(width: 100%)[#text(fill: out, style: "italic", line)]
          } else {
            block(width: 100%)[#text(fill: out, line)]
          }
        })))
    ]
  ]
}
#let inline-code(src) = context box(
  // No `raw`: Typst hardcodes raw at 0.8em and nothing outside can override it.
  fill: pal.zebra, radius: 4pt, inset: (x: 3pt, y: 1pt), baseline: 8%,
)[
  #text(font: fb-mono(), fill: pal.ink-strong, src)
]

#let fb-challenge-links(links) = context block(
  width: 100%, radius: 4pt, stroke: 1pt + pal.code-line, above: 0pt, below: 0pt,
)[
  #block(
    width: 100%, fill: pal.chrome, below: 0pt,
    inset: (x: geo.pad-mono-x, y: 8pt),
    text(size: fb-t().small, weight: 600, fill: pal.ink, tracking: 0.3pt)[training.firebird.sh],
  )
  #block(
    width: 100%, fill: pal.code-bg, above: 0pt,
    inset: (x: geo.pad-mono-x, y: geo.pad-mono-y),
  )[
    #set text(font: fb-mono(), size: fb-t().terminal, fill: pal.ink-strong)
    #for l in links [
      #if not l.contains(" ") and l.contains(".") [
        #link("https://" + l)[#l]
      ] else [
        #l
      ]\
    ]
  ]
]

#let challenge-slide(
  kind,
  name,
  deadline: none,
  links: (),
  body: none,
) = slide(title: none, center: true)[
  #align(center)[
    #block(width: 80%, inset: (x: geo.pad))[
    #align(center)[
      #context {
        let t = fb-t()
        text(size: t.small, weight: 600, tracking: 1pt, fill: fb-admin-kind-color(kind), upper(kind))
      }
      #context v(8pt)
      #context text(size: fb-t().title, weight: 600, fill: pal.ink, name)
      #if deadline != none [
        #context v(6pt)
        #context text(size: fb-t().subtitle, fill: pal.ink-muted)[due #deadline]
      ]
      #context v(0.8em)
      #align(center, context brand-rule(width: 34mm, height: 2.4pt))
      #if body != none [
        #context v(0.8em)
        #align(left, body)
      ]
    ]
    #context v(0.8em)
    #align(center, fb-challenge-links(links))
    ]
  ]
]

#let keyeq(body, note: none) = context {
  let t = fb-t()
  let eq = text(size: t.keyeq, body)
  let nt = if note == none { none } else { text(size: t.table, fill: pal.ink-muted, note) }
  block(
    width: 100%, fill: pal.tint, stroke: 1.5pt + pal.structural, radius: 6pt,
    inset: (x: geo.pad, y: 16pt), above: 0.8em, below: 0.8em,
  )[
    #layout(area => {
      if nt == none {
        align(center, eq)
      } else if measure(eq).width + 24pt + measure(nt).width <= area.width {
        grid(
          columns: (auto, 1fr), column-gutter: 24pt, align: horizon,
          eq, align(right, nt),
        )
      } else {
        align(center, block[
          #eq
          #v(8pt)
          #nt
        ])
      }
    })
  ]
}

#let image-slide(content, caption: none, title: none, height: 250pt) = slide(title: title, center: true)[
  #block(width: 100%)[
      #show image: set image(height: height)
      #align(center, content)
      #if caption != none {
        v(10pt)
        align(center, context text(size: fb-t().caption, fill: pal.ink-muted, caption))
      }
  ]
]

#let meme(content, caption: none) = image-slide(content, caption: caption, height: 260pt)

#let image-row(images, captions: (), height: 160pt, gutter: 28pt) = context grid(
  columns: images.len(), column-gutter: gutter, align: horizon,
  ..images.enumerate().map(((i, img)) => align(center, block(width: 100%)[
    #show image: set image(height: height)
    #img
    #if i < captions.len() {
      v(10pt)
      text(size: fb-t().caption, fill: pal.ink-muted, captions.at(i))
    }
  ])),
)

#let blobcat-key(name) = lower(str(name).replace(regex("[^A-Za-z0-9]"), "").replace(regex("(?i)^blobcat"), ""))

#let blobcat(name, size: 1.15em, baseline: 18%) = {
  let key = blobcat-key(name)
  let file = blobcat-files.at(key, default: none)
  if file == none {
    let head = if key.len() >= 3 { key.slice(0, 3) } else { key }
    let hits = blobcat-names.filter(k =>
      k.contains(key) or key.contains(k)
        or (k.len() >= 3 and k.slice(0, 3) == head))
    panic(
      "blobcat: no cat named \"" + str(name) + "\""
        + if hits.len() > 0 { "; did you mean: " + hits.slice(0, calc.min(8, hits.len())).join(", ") } else { "" }
        + ". `#blobcat-list()` in a scratch document lists all " + str(blobcat-names.len()) + " names.",
    )
  }
  box(baseline: baseline, image(file, height: size))
}

#let blobcat-wall(names, cols: 8, size: auto, labels: true, gap: 20pt) = context {
  let mono = fb-mono()
  let t = fb-t()
  let cat = if size == auto { t.body * 2.5 } else { size }
  grid(
    columns: cols, column-gutter: gap, row-gutter: gap, align: horizon + center,
    ..names.map(n => block(width: 100%)[
      #align(center, blobcat(n, size: cat))
      #if labels {
        v(4pt)
        align(center, text(font: mono, size: t.small, fill: pal.ink-muted, n))
      }
    ]),
  )
}

#let blobcat-list(cols: 6, size: 13.5pt) = context {
  let mono = fb-mono()
  block(width: 100%)[
    #set text(font: mono, size: size, fill: pal.ink-strong)
    #columns(cols, gutter: 24pt)[
      #for n in blobcat-names [#n \ ]
    ]
  ]
}

#let data-table(headers, rows, size: auto, align: auto, columns: auto, zebra: true, mono: ()) = context {
  let monofont = fb-mono()
  let size = if size == auto { fb-t().table } else { size }
  block(
  width: 100%, above: 0.8em, below: 0.8em,
)[
  #set text(size: size)
  #table(
    columns: if columns == auto { headers.len() } else { columns },
    align: if align == auto { (left,) * headers.len() } else { align },
    inset: (x: geo.pad-table-x, y: geo.pad-table-y),
    stroke: none,
    fill: (col, row) => {
      if row == 0 { pal.chrome } else if zebra and calc.odd(row) { pal.tint } else { none }
    },
    table.header(..headers.map(h => text(weight: 600, fill: pal.ink, h))),
    ..rows.enumerate().map(((i, r)) => r.map(c => {
      if type(c) == str and mono.contains(i) {
        text(font: monofont, size: size - 1pt, fill: pal.ink-strong, c)
      } else if type(c) == str {
        text(fill: pal.ink-strong, c)
      } else { c }
    })).flatten(),
  )
  ]
}

#let firebird(
  body,
  title: none,
  subtitle: none,
  course: "COMP2633 Competitive Programming in Cybersecurity I",
  authors: (),
  helpers: (),
  credits: (),
  date: auto,
  aspect: "16:9",
  debug: auto,
  gate: auto,
  handout: false,
  body-size: 19.5pt,
  sans: font-sans,
  mono: font-mono,
  serif: font-serif,
  display: "sans",
  raw-theme: "assets/firebird.tmTheme",
  ..args,
) = {
  let (pw, ph) = if aspect == "4:3" { (geo.w4x3, geo.h4x3) } else { (geo.w, geo.h) }
  let debug-on = if debug == auto {
    sys.inputs.at("debug", default: "false") in ("true", "1", "yes")
  } else { debug }
  let gate-on = if gate == auto {
    sys.inputs.at("gate", default: "false") in ("true", "1", "yes")
  } else { gate }
  let date-text = if date == auto {
    datetime.today().display("[month repr:long] [day], [year]")
  } else { date }

  let t = fb-type-scale(body-size)
  let display-font = if display == "serif" { serif } else { sans }

  show: touying-slides.with(
    config-page(width: pw, height: ph, margin: 0pt, fill: pal.surface),
    config-common(
      slide-fn: slide,
      breakable: false,
      clip: true,
      detect-overflow: false,
      handout: handout,
      // The page preamble re-seeds the firebird states from the store on
      // every page, idempotently — the first slide's `measure()` sees the
      // real type scale, not the defaults.
      page-preamble: self => hide[
        #fb-fonts.update(self.store.fonts)
        #fb-type.update(self.store.t)
        #fb-meta.update(self.store.meta)
      ],
    ),
    config-colors(
      primary: pal.brand-a,
      primary-light: pal.brand-a.lighten(40%),
      primary-dark: pal.brand-a.darken(20%),
      neutral-lightest: pal.surface,
      neutral-darkest: pal.ink,
    ),
    config-info(
      title: title,
      subtitle: subtitle,
      author: authors,
      date: date-text,
      institution: course,
    ),
    config-store(
      t: t,
      fonts: (sans: sans, mono: mono, serif: serif, display: display-font),
      meta: (
        title: title, subtitle: subtitle, course: course, authors: authors,
        helpers: helpers, credits: credits,
        date: date-text, debug: debug-on, gate: gate-on, aspect: aspect,
      ),
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: sans, size: body-size, fill: pal.ink, lang: "en", region: "hk")
        set par(leading: 0.78em, justify: false, linebreaks: "optimized", first-line-indent: 0pt, spacing: 0.95em)
        set block(spacing: 0.95em)

        show footnote: it => text(size: t.small, fill: pal.ink-muted, [ (#it.body)])
        show footnote.entry: it => none
        let bullet = body-size * 0.30
        set list(
          indent: 0pt, body-indent: body-size * 0.6, spacing: body-size * 0.78, tight: false,
          marker: box(width: bullet * 1.6, height: bullet * 2.3)[
            #place(dx: 0pt, dy: bullet * 1.0,
              polygon(fill: pal.ink, (0pt, 0pt), (bullet, bullet * 0.57), (0pt, bullet * 1.14)))
          ],
        )
        set enum(
          indent: 0pt, body-indent: body-size * 0.6, spacing: body-size * 0.78, tight: false,
          numbering: (..n) => text(fill: pal.ink, weight: 600, n.pos().map(str).join(".") + "."),
        )
        set terms(indent: 0pt, spacing: body-size * 0.78, tight: false)

        show heading.where(level: 1): it => {
          fb-sec-num.step()
          block(above: 0pt, below: 0pt)[
            #text(font: display-font, size: t.section, weight: 600, fill: pal.tint, it.body)
          ]
        }
        show heading.where(level: 2): it => block(above: 0pt, below: 0pt)[
          #text(font: display-font, size: t.subsection, weight: 600, fill: pal.ink, it.body)
        ]

        // No show rule on `emph`: it drops the native italic styling
        // (typst 0.15 quirk).
        show strong: it => text(weight: 600, it)
        // Typst 0.13+ draws no link underline by default.
        show link: set text(fill: pal.brand-a-ink)
        show link: it => underline(it, stroke: 0.75pt, offset: 1.4pt)
        show figure.caption: set text(size: t.caption, fill: pal.ink-muted)
        show quote: it => block(
          width: 100%, above: 0.8em, below: 0.8em,
          inset: (left: geo.pad * 0.8), stroke: (left: 3pt + pal.structural),
        )[
          #set text(font: serif, size: t.quote, style: "italic", fill: pal.ink)
          #it.body
          #if it.attribution != none [
            #block(above: 0.35em, align(right,
              text(size: t.caption, style: "normal", fill: pal.ink-muted, [-- #it.attribution])))
          ]
        ]

        set raw(theme: raw-theme, tab-size: 2)
        show raw.where(block: true): set text(font: mono, size: t.code, fill: pal.ink-strong)
        // Inline `raw` ignores the inherited text font.
        show raw.where(block: false): it => box(
          fill: pal.zebra, radius: 3pt, inset: (x: 3pt, y: 1pt), outset: (y: 1pt),
          text(font: mono, fill: pal.ink-strong, it),
        )

        set table(stroke: none, inset: (x: 10pt, y: 7pt), align: horizon)
        show table.cell.where(y: 0): set table.cell(fill: pal.chrome)
        show table.cell.where(y: 0): set text(weight: 600, fill: pal.ink)
        show table.hline: set line(stroke: 0.8pt + pal.structural)
        show table.cell.where(y: 1): set table.cell(stroke: (bottom: 0.4pt + pal.hairline))

        body
      },
    ),
    ..args,
  )

  body
}