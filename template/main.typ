#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  title: "Title of the talk",
  subtitle: "One line on what the audience gets",
  course: "COMP2633 Competitive Programming in Cybersecurity I",
  authors: ("Your Name (handle)",),
  helpers: ("TA Name (handle)",),
  date: "2026-09-20",
)

#title-slide()

#toc-slide()

#section-slide("First section", subtitle: "What this part establishes")

#slide(title: "Claim in the title, evidence in the body")[
  - Bullets carry the argument, one idea per line.
  - #strong[Strong] for the phrase you want remembered.
  - Inline math keeps its Computer Modern look: $c = m + k mod 26$.

  #definition[#strong[Cipher.] A pair of algorithms ... ]
]

#slide(title: "Two columns: math and code")[
  #cols(
    [
      #keyeq($ c = (m + k) mod 26 $, note: [the whole cipher])

      - The key space is the security claim.
      - 26 shifts is not a key space.
    ],
    [
      #code(
        "for k in range(26):\n    print(k, caesar(ct, k))",
        lang: "python",
        file: "break_caesar.py",
      )
    ],
    ratio: 0.85fr,
  )
]

#slide(title: "Terminal sessions")[
  #terminal(
    "$ nc chal.firebird.sh 35045
Ciphertext: Vm0wZDFKNVQwTlRLd01UUT0=
> give me the flag
Nope, that is not the flag.",
    title: "kali@firebird",
  )
]

#slide(title: "Pictures")[
  // Typst resolves image paths relative to this deck, not to the package.
  #image-row(
    (image("assets/example.png"), image("assets/example.png")),
    captions: ("Left panel", "Right panel"),
    height: 128pt,
  )

  - Captions sit under the images and wrap with them.
]

#admin-slide(
  (
    (kind: "attend", what: "Scan the QR before you sit down", when: "by 18:30"),
    (kind: "exercise", what: "Break the Caesar ciphertext", when: "Wed 23:59", where: "BOT"),
    (kind: "hw", what: "Problem set 1", when: "Sep 28", where: "Canvas"),
  ),
  title: "This week",
  note: [Late work: −20 % per day.],
)

#slide(title: "Summary")[
  - What you should remember, in three to five lines.

  #exercise[Something the audience can try before the next session.]
]

#end-slide(
  lines: (
    "Next session: ...",
    "Slides and solutions: firebird.ust.hk/crypto101",
  ),
)
