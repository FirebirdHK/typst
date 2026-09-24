// Imports the package by name, so the deck renders what an installed deck sees.
#import "@preview/firebird-slides:0.3.0": *

#show: firebird.with(
  title: "Crypto 101: Introduction to Cryptography and Cryptanalysis",
  subtitle: "From Caesar to one-time pads",
  course: "COMP2633 Competitive Programming in Cybersecurity I",
  authors: ("Dhairya (wylited)",),
  helpers: ("Isaac (sayako)",),
  credits: ("Course materials: Crypto 101",),
)

#title-slide()

#toc-slide()

#bio-slide("Wyli", discord: "wylited", photo: image("cat-photo.png", height: 280pt))[
  - If I were a cat, curiosity would have killed me ten times.
  - Helper · Core Member 2026.
  - #link("https://web.wyli.tech")[web.wyli.tech]
]

#section-slide("Introduction", subtitle: "What this course is, and is not", note: "Attempt every attack only inside the lab environment.")

#slide(title: "What is Cryptography?")[
  #definition[
    *Cryptography* is the mathematical science of designing algorithms and
    protocols to achieve security goals in the presence of adversaries. (NIST)
  ]

  - #strong[Etymology.] Greek _kryptos_ (hidden) + _graphein_ (to write).
  - #strong[Two halves.] Cryptography builds the locks; cryptanalysis picks them.
  - #strong[In CTFs.] We mostly do the second half: find the flaw, exploit it.
]

#slide(title: "Cryptanalysis: Attack Models")[
  + #strong[Ciphertext-only.] Only a pile of ciphertexts.
  + #strong[Known-plaintext.] Ciphertexts with their plaintexts.
  + #strong[Chosen-plaintext.] Encryptions of the attacker's own messages.
  #pause
  + #strong[Chosen-ciphertext.] Chosen plaintexts _and_ chosen ciphertexts.

  #pause
  #insight[Every classical cipher falls to a ciphertext-only attack — usually far earlier than you would hope.]
]

#slide(title: "Caesar Cipher", subtitle: "Shift every letter by k positions")[
  #cols(
    [
      #keyeq($ c = (m + k) mod 26 $, note: [encryption])

      - Key space: 26 possibilities.
      - #strong[Brute force] breaks it before your coffee cools; frequency
        analysis survives the shift.
    ],
    [
      #code(
        "for k in range(26):\n    print(k, caesar(ct, k))   # 1 of 26 is right",
        lang: "python",
        file: "break_caesar.py",
      )
    ],
    ratio: 0.85fr,
  )
]

#slide(title: "Affine Cipher: Decryption")[
  #code(
    "def decrypt(ct, a, b):\n    inv = pow(a, -1, 26)      # the whole attack\n    for ch in ct:\n        n = (inv * (ord(ch) - base(ch) - b)) % 26\n        yield chr(n + base(ch)) if ch.isalpha() else ch",
    lang: "python",
    lines: true,
  )

  Line 2 is the whole attack: when $a$ has no inverse mod 26, the cipher is not injective.
]

#slide(title: "Terminal Session")[
  #terminal(
    "$ nc chal.firebird.sh 35045
Welcome to super encryption!
Ciphertext: V20xS04xbHFXVEJZZWtaNldESTBkMlJHT1d4aWJVNDU=
> V20xS04xbHFXVEJZZWtaNldESTBkMlJHT1d4aWJVNDU=
Nope, that is not the flag.
$ python3 -c \"import base64 as b; \
      print(b.b64decode('V20xS04xbHFXVEJZZWtaNldESTBkMlJHT1d4aWJVNDU='))\"
b'Wm1KN1lqWTBYekZ6WDI0d2RGOWxibU45'
# stage 1 of 3 — keep decoding",
    title: "kali@firebird",
  )
]

#slide(title: "Never Implement Your Own Crypto")[
  #warning[
    Never invent an algorithm, and never "improve" a standard one — the 5%
    cleverness is the vulnerability, and it is always the part that breaks.
  ]

  #claim[ECB leaks equality: identical plaintext blocks give identical ciphertext.]
]

#slide(title: "One-Time Pad")[
  #keyeq($ c = m xor k, quad "with " k " random, secret, and never reused" $)

  - #strong[Perfect secrecy] holds when $k$ is uniform, as long as $m$ and $k$ are independent.
  - #strong[Reuse is fatal.] $c_1 xor c_2 = m_1 xor m_2$ — the key cancels out.
  - #strong[In practice] the pad is derived, not shipped: that is where the bugs live.
]

#slide(title: "XOR and Bitwise Operators")[
  #cols(
    [
      #data-table(
        ("Operation", "Python", "Result"),
        (
          ("AND", "a & b", "bitwise and"),
          ("OR", "a | b", "bitwise or"),
          ("XOR", "a ^ b", "bitwise exclusive or"),
          ("NOT", "~a", "bitwise complement"),
        ),
      )
    ],
    [
      #code(
        "from pwn import xor\n\nct = bytes.fromhex('666c6167')\npt = xor(ct, b'\\x01' * 4)",
        lang: "python",
        file: "xor.py",
      )

      #pill[property] XOR is its own inverse.
    ],
    ratio: 1.1fr,
  )
]

#slide(title: "Frequency Analysis")[
  #image-row(
    (image("assets/frequency-plain.png"), image("assets/frequency-shift3.png")),
    captions: ("Plaintext: E is the tallest bar", "The same text, Caesar-shifted by 3"),
    height: 148pt,
  )

  - The shape of the histogram survives a substitution cipher.
  - #strong[The tell.] A flat histogram means someone used a one-time pad.
]

#meme(image("assets/meme.png", height: 252pt), caption: [When the challenge says “custom encryption scheme”.])

#slide(title: "Question", center: true)[
  #block(width: 100%)[
    #text(size: 32pt, fill: pal.ink, "How many keys does a 26-letter substitution cipher have?")
    #text(size: 18pt, fill: pal.ink-muted, "And how many does your laptop try per second?")
  ]
]

#challenge-slide(
  "attendance",
  "Check-in: show_up_2026",
  deadline: "today 23:59 HKT",
  links: ("training.firebird.sh/challenges?id=73",),
  body: [_Attendance is 1 point and the deadline is strict — the flag comes from the lecture, not the slides._],
)

#subsection-slide("Block Ciphers")

#slide(title: "Design Principles")[
  #quote(attribution: [Bruce Schneier, *Applied Cryptography*, 2nd ed., 1996])[
    Anyone can design a cipher that they themselves cannot break.
  ]

  #blobcat("salute")
]

#slide(title: "Summary")[
  - #strong[Encoding ≠ encryption.] Base64 is a transport format, not a lock.
  - #strong[Key space is the whole game.] 26 shifts is not a key space.
  - #strong[Structure survives substitution.] Frequency analysis exploits that.
  - #strong[Never roll your own crypto.] Use the primitive; do not improvise it.

  #exercise[Decrypt the stage-1 ciphertext from the terminal slide — how many decodes before it stops changing?]
]

#section-slide("Using this template", subtitle: "The parts you will actually touch")

#slide(title: "Anatomy of a slide")[
  #cols(
    [
      #code(
        "#slide(title: \"Caesar Cipher\")[\n  #cols(\n    [#keyeq($c=(m+k) mod 26$)],\n    [#code(src, lang: \"py\")],\n  )\n]",
        lang: "typst",
        file: "deck.typ",
      )
    ],
    [
      - The #strong[title] is the claim; the body is the evidence.
      - `slide` takes its body first, so a trailing `[ ... ]` just works.
      - `cols` is the workhorse: prose beside a figure or a snippet.
    ],
    ratio: 1.35fr,
  )
]

#slide(title: "Cheat sheet: pick the component, not a workaround")[
  #data-table(
    ("You want to show", "Reach for"),
    (
      ("a claim plus its argument", "slide + bullets"),
      ("prose beside a figure or code", "cols"),
      ("a quoted definition, claim or exercise", "definition / claim / exercise"),
      ("a shell session", "terminal"),
      ("an equation that matters", "keyeq"),
      ("a table without grid lines", "data-table"),
      ("a reaction", "blobcat"),
    ),
    columns: (1.25fr, 1fr),
    mono: (),
  )
]

#slide(title: "Keeping slides honest")[
  #code(
    "$ typst watch --input debug=true deck.typ\n$ typst compile --input gate=true deck.typ",
    lang: "sh",
  )

  - #strong[debug] draws the box and the badge.
  - #strong[gate] fails the compile, naming the slide.
  - 10 bullets, 11 code lines. Split, never shrink.
]

#slide(title: "Blobcats", subtitle: "blobcat(\"party\") — anywhere text goes")[
  Inline, on the baseline: #blobcat("party") deploy succeeded
  #blobcat("party")

  #blobcat-wall(
    ("party", "coffee", "hyperthink", "derpy", "nom", "sip", "melt", "wink",
     "think", "sad", "wave", "chefsKiss", "thumbsup", "hug", "peek", "uwu"),
    cols: 8, size: 40pt, gap: 16pt,
  )

  #text(size: 0.8em, fill: pal.ink-muted)[
    209 cats; `#blobcat-list()` names them all.
  ]
]

#slide(title: "Where things live")[
  #data-table(
    ("Path", "What it is"),
    (
      ("lib.typ", "palette, geometry, every component, the gate"),
      ("assets/", "cats, name table, theme, mark"),
      ("template/main.typ", [the starter deck (#inline-code("copy me"))]),
      ("tests/contrast.typ", "colour and type-size audit"),
      ("examples/showcase.typ", "this deck"),
    ),
    columns: (auto, 1fr),
    mono: (0,),
  )

  #text(size: 0.8em, fill: pal.ink-muted)[Everything is documented in README.md.]
]

#admin-slide((
  (kind: "attend", what: "Scan the QR before you sit down", when: "by 18:30"),
  (kind: "exercise", what: "Caesar speedrun — decrypt without the key", when: "Wed 23:59", where: "HKSecAI BOT"),
  (kind: "hw", what: "Problem set 1 — classical ciphers", when: "Sep 28", where: "Canvas"),
), title: "This week", note: [Late work: −20 % per day, floor 0.])

#credits-slide((
  ("Deck template", "firebird-slides · Firebird CTF team"),
  ("BlobCats pack", "DuckOfDisorder · Apache-2.0"),
  ("IBM Plex fonts", "Mike Abbink · SIL OFL"),
), title: "Credits", note: [Every vendored asset keeps its licence beside it.])

#end-slide(lines: ("Next session: block ciphers, SPN, and why ECB leaks pictures.", "Course materials: firebird.ust.hk/crypto101"))
