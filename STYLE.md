# Note style: rules the agent follows when making notes

This is a living file. When the user says "I like / don't like X", record it under **Preferences** and apply it to every future note.

## Preferences (the user's; the defaults were tuned on a Boox Go 7)
- Notes are read on a **Boox Go 7 (black & white, 7")**, with no stylus. Highlighting is done in NeoReader.
- The user writes short notes and draws diagrams on paper, then pastes text, photos and remarks. The agent turns them into polished notes.
- Subjects: code, maths, formulae, diagrams, plain text. The user saves a lot of material as **Q&A**.
- Language: short sentences and plain words. Bold only the words worth remembering.
- The user's own remarks go in `#mine[...]` boxes, so they stay visibly "theirs".
- **Dense pages** (feedback 2026-10-22): the first sample's text was too big and too many page turns were needed. Body is now ≈8.4pt on-device. Don't go bigger.
- **Fewer boxes**: the labels help, but use them sparingly. Use at most ~1 box per section, and prefer plain bold text, tables and `#hook[...]` lines.
- **Main notes are a detailed summary built for recall.** Each chapter opens with an `#glance[...]` box that lets the user recall the whole chapter at a glance, followed by sections that use bullets, tables, analogies and mnemonics (`#hook`).
- Every main note has an **intro and contents page**: pass `intro: [...]`, and the contents list is generated from the headings.
- **Corrections stay out of the notes** (feedback 2026-10-22): when the source is wrong, write the correct fact directly in the notes with no "correction" box or mention of the source, and list the corrections once in the chat reply.
- **No page numbers** in the footer; NeoReader shows them already.
- **Cheat sheet: every section ends with a diagram** (feedback 2026-10-22): after the short notes of each `=` section, add one `#fig` flowchart or diagram that represents the whole section, for ultra-fast lookup. Use decision flows, pipelines, concept maps or ladders, and decisions are bold boxes ending in "?" (not diamonds).
- **No Retrieval PDF on the Boox.** Retrieval practice happens in Anki only.
- **A4 version on request** (2026-10-29): `A4=1 ./build.sh <file>` also writes `<name> (A4).pdf`, a normal A4 print/desktop copy of the same note (template reads `--input paper=a4`).
- When the pasted material is one course part with several chapters, make **one book per part** (`01 Foundations`, `02 …`), with each chapter as a `=` heading.

## What to produce per topic
| File | Purpose |
|---|---|
| `notes/<Subject>/<Topic> - Main.typ` | Full notes: explanation, diagrams, examples, pitfalls, recap |
| `notes/<Subject>/<Topic> - Cheat Sheet.typ` | Dense: formulas, templates, tables, traps, plus one diagram per section. No prose. |
| `anki/<Subject>/<Topic>.cards.md` | Same Q&A (plus extras) as a tap-to-import Anki deck |

Only make the files the user asks for. If they don't say, make all three.

## Building blocks (template/boox.typ)
Boxes: `#glance[...]` (chapter start) · `#defn[term][body]` · `#key[...]` · `#formula(name: "...")[$ ... $]` · `#pitfall[...]` (real pitfalls only, not source corrections) · `#mine[...]`
No box: `#example[...]` · `#hook[...]` · `#qa[q][a]` · `#fig(caption: [...])[ diagram ]`
Sizes inside the template use `u` (= 2pt) because the page is drawn at 2× the screen size; in diagrams use strokes of ~1.4pt and spacing of 10–25mm.

## Layout rules (learned from previews)
- Code lines: **≤ 65 characters** in main notes, ≤ 70 in cheat sheets, or they wrap badly. Put long comments on their own line.
- Escape `~` as `\~` in Typst text (an unescaped `~` is a non-breaking space).
- Tables: always use `table.header(...)`, so the header never sits alone at the bottom of a page.
- Diagrams: fletcher with `node-shape: rect` (or `fletcher.shapes.pill` / `cylinder` for users / storage), at most ~7 nodes per row, labels on edges (`label-side`) rather than in their own node. Redraw the user's paper diagrams cleanly; embed the photo only if redrawing would lose information.
- Avoid `fletcher.shapes.diamond`: text overflows it, and enlarging it flips the arrowheads. Use `stroke: 2pt` rect nodes for decisions.
- In diagram labels, `*X*yz` (bold in the middle of a word) is invalid Typst. Use `#strong[X]yz`.
- Black and white only. Use borders, weight and labels, never colour.
- Anki: one idea per question, short answers, and the question must make sense on its own (name the topic in it).
- Check pages with `PREVIEW=1 ./build.sh <file>` and look at the PNGs before handing over.
