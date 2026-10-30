// Boox Go 7 note template — page has the exact screen aspect (1264×1680 px).
// The page is drawn at 2× the physical screen size (u = 2pt) so viewers that
// rasterise at a fixed DPI still render it sharp; sizes below read as on-device points.
// Black & white e-ink: structure comes from borders, weight and labels, never colour.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.4.2"

// `--input paper=a4` builds a normal A4 print/desktop version of the same note
#let a4 = sys.inputs.at("paper", default: "boox") == "a4"
#let u = if a4 { 1.3pt } else { 2pt }
#let ink = black
#let mid = luma(80)      // secondary text (still readable on e-ink)
#let tint = luma(236)    // light fill for boxes
#let screen-w = if a4 { 210mm } else { 214.04mm }
#let screen-h = if a4 { 297mm } else { 284.48mm }
#let page-margin = if a4 { (x: 18mm, top: 18mm, bottom: 20mm) } else { (x: 7mm, top: 8mm, bottom: 12mm) }

// ---------- document setup ----------
// kind: "main" | "cheat"
// intro: content for the cover page (what this covers / big picture)
#let note(title: "", subtitle: none, subject: "", kind: "main", date: none, intro: none, body) = {
  let dense = kind == "cheat"
  let label = (main: "NOTES", cheat: "CHEAT SHEET").at(kind)

  set document(title: title + " — " + label)
  set page(
    width: screen-w, height: screen-h,
    margin: page-margin,
    footer: context {
      set text(6 * u, fill: mid)
      line(length: 100%, stroke: 0.3 * u + mid)
      v(-1.5 * u)
      [#subject · #title]
    },
  )
  set text(font: "Atkinson Hyperlegible", size: if dense { 7.4 * u } else { 8.4 * u }, fill: ink, lang: "en")
  set par(leading: if dense { 0.45em } else { 0.55em }, spacing: if dense { 0.65em } else { 0.85em }, justify: false)
  set list(indent: 1 * u, body-indent: 3 * u, spacing: if dense { 0.5em } else { 0.6em }, marker: ([•], [–], [·]))
  set enum(indent: 1 * u, body-indent: 3 * u, spacing: if dense { 0.5em } else { 0.6em })
  set strong(delta: 300)
  show math.equation: set text(font: "New Computer Modern Math", size: if dense { 7.8 * u } else { 8.8 * u })

  // headings → PDF outline (NeoReader's table of contents) and the contents page
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    block(width: 100%, above: if dense { 6 * u } else { 14 * u }, below: if dense { 4 * u } else { 6 * u }, {
      if not dense and it.numbering != none {
        text(6.5 * u, weight: "bold", tracking: 1 * u, fill: mid)[CHAPTER #counter(heading).display("1")]
        v(-3 * u)
      }
      text(if dense { 10.5 * u } else { 14 * u }, weight: "bold", it.body)
      v(-5 * u)
      line(length: 100%, stroke: 1.4 * u + ink)
    })
  }
  show heading.where(level: 2): it => block(above: if dense { 6 * u } else { 9 * u }, below: 4 * u, sticky: true,
    grid(columns: (2.2 * u, 1fr), column-gutter: 4 * u,
      rect(width: 2.2 * u, height: 1.05em, fill: ink),
      text(if dense { 8.6 * u } else { 10 * u }, weight: "bold", {
        if not dense and it.numbering != none { text(fill: mid, counter(heading).display("1.1")); h(4 * u) }
        it.body
      })))
  show heading.where(level: 3): it => block(above: 6 * u, below: 3 * u, sticky: true,
    text(if dense { 7.8 * u } else { 8.9 * u }, weight: "bold", it.body))

  // code: grayscale highlighting, left rule, light fill
  set raw(theme: "bw.tmTheme")
  show raw: set text(font: "DejaVu Sans Mono", size: if dense { 6.2 * u } else { 6.8 * u })
  show raw.where(block: false): it => box(fill: tint, inset: (x: 1.5 * u), outset: (y: 1.5 * u), radius: 1 * u, it)
  show raw.where(block: true): it => block(
    width: 100%, fill: tint, inset: (left: 4.5 * u, rest: 3.5 * u), radius: 1.5 * u,
    stroke: (left: 1.8 * u + ink), breakable: true, it)

  // tables: clean rules, bold header
  set table(stroke: (x, y) => (top: if y == 0 { 0.8 * u } else { 0.3 * u + mid }, bottom: 0.8 * u), inset: 2.8 * u)
  show table.cell.where(y: 0): strong
  show table: set par(leading: 0.45em)

  // outline (contents page)
  show outline: set text(7.6 * u)
  show outline.entry.where(level: 1): it => { v(2 * u); strong(it) }

  // cover: title, intro, contents
  block(width: 100%, {
    text(6.5 * u, weight: "bold", tracking: 1 * u, fill: mid, upper(subject) + "  ·  " + label)
    v(-3 * u)
    text(if dense { 13 * u } else { 17 * u }, weight: "bold", title)
    if subtitle != none { v(-3 * u); text(9 * u, fill: mid, subtitle) }
    if date != none { linebreak(); text(6.5 * u, fill: mid, date) }
    v(-4 * u)
    line(length: 100%, stroke: 2 * u + ink)
  })
  if not dense {
    if intro != none { intro }
    v(4 * u)
    outline(title: text(10 * u, weight: "bold")[Contents], depth: 2, indent: 6 * u)
    pagebreak()
  }
  body
}

// ---------- building blocks (keep these few and light) ----------
#let _tag(t) = box(fill: ink, inset: (x: 2.5 * u, y: 1.6 * u), outset: (y: 0.4 * u), radius: 1 * u,
  text(5.6 * u, weight: "bold", fill: white, tracking: 0.6 * u, upper(t)))

// Definition: thin border, term inline
#let defn(term, body) = block(width: 100%, breakable: false, stroke: 0.7 * u + ink, radius: 1.5 * u, inset: 4 * u,
  [#_tag("def") #h(2 * u) *#term* — #body])

// Key idea: thick left bar — the thing to remember
#let key(body) = block(width: 100%, breakable: false, stroke: (left: 3 * u + ink), inset: (left: 5 * u, y: 1.5 * u),
  [#_tag("key") #h(2 * u) #body])

// Formula: thick border, centred
#let formula(name: none, body) = block(width: 100%, breakable: false, stroke: 1.2 * u + ink, radius: 1.5 * u, inset: 4 * u, {
  if name != none { _tag(name) }
  align(center, body)
})

// Pitfall / common mistake / correction: dashed border
#let pitfall(body) = block(width: 100%, breakable: false, stroke: (paint: ink, thickness: 0.8 * u, dash: "dashed"), radius: 1.5 * u, inset: 4 * u,
  [#_tag("⚠ careful") #h(2 * u) #body])

// The user's own remark (from their notes) — dotted, italic
#let mine(body) = block(width: 100%, breakable: false, stroke: (paint: ink, thickness: 0.7 * u, dash: "dotted"), radius: 1.5 * u, inset: 4 * u,
  [#_tag("my note") #h(2 * u) #emph(body)])

// Chapter-at-a-glance: grey box at the start of a chapter — read this to recall the whole chapter
#let glance(body) = block(width: 100%, breakable: false, fill: tint, stroke: 1 * u + ink, radius: 1.5 * u, inset: 5 * u, {
  _tag("at a glance"); v(-1 * u); body
})

// Lightweight extras (no boxes)
#let example(body) = [*Example:* #body]
#let hook(body) = [*↳ Remember:* #emph(body)]   // memory hook / mnemonic / analogy
#let qa(q, a) = block(width: 100%, breakable: false, inset: (y: 1 * u), grid(columns: (auto, 1fr), column-gutter: 4 * u, row-gutter: 3 * u,
  text(weight: "bold", "Q"), strong(q),
  text(weight: "bold", "A"), a))

// Figure wrapper for diagrams
#let fig(caption: none, body) = block(width: 100%, breakable: false, inset: (y: 3 * u), {
  set text(0.88em)
  align(center, body)
  if caption != none { v(-1 * u); align(center, text(6.5 * u, fill: mid, emph(caption))) }
})
