# 7-inch e-ink study notes: instructions for your AI agent

This file is for the AI coding agent you use with this repo (Claude Code, Codex, Cursor, …). Claude Code users get a local `CLAUDE.md` from `./setup.sh` that imports this file. If you write notes by hand without an agent, you can ignore it.

The user pastes study material (text, photos of paper notes and diagrams, remarks). You turn it into:
1. **Main notes PDF**: a detailed summary built for recall, readable on a Boox Go 7 (7", black & white e-ink, no stylus).
2. **Cheat sheet PDF**: dense, with one diagram per section.
3. **Anki deck (.apkg)**: retrieval practice. There is **no** retrieval PDF.

**Before writing anything, read `STYLE.md`.** It holds the user's preferences and the layout rules learned from previews, and it overrides any default taste. Use `notes/System Design/01 Foundations - Main.typ` and `- Cheat Sheet.typ` as the reference for what good output looks like.

## First run on a new machine
If `~/.local/bin/typst` or `.venv/` is missing, run `./setup.sh` once. It installs Typst, creates the Python venv (genanki + markdown) and downloads the Typst diagram packages.

## Workflow for each paste
1. Work out the **Subject** and **Topic**. A course part with several chapters becomes one book, e.g. `01 Foundations`, `02 …`, with each chapter as a `=` heading. Ask only if you really can't tell.
2. Write the files the user asks for (default: all three):
   - `notes/<Subject>/<Topic> - Main.typ`: `#show: note.with(title:, subtitle:, subject:, kind: "main", date:, intro: [...])`. Every chapter opens with `#glance[...]`, followed by sections that use bullets, tables, `#hook[...]` analogies and mnemonics, and redrawn diagrams (`#fig` + fletcher).
   - `notes/<Subject>/<Topic> - Cheat Sheet.typ`: `kind: "cheat"`. Each `=` section has short notes and then **one `#fig` flowchart or diagram** summarising that section.
   - `anki/<Subject>/<Topic>.cards.md`: the format is in the docstring of `anki/build_anki.py`. One idea per card, and each question must make sense on its own.
3. **Source errors:** write the correct fact straight into the notes, with no "correction" box and no mention of the source. List what you corrected **once in your chat reply**.
4. Keep the user's own remarks in `#mine[...]`.
5. Build with previews: `PREVIEW=1 ./build.sh "<file>" ...`. **Look at every PNG in `preview/`**, fix overflow, bad breaks, overlapping diagram labels and wrapped code, then rebuild. When it's clean, `rm -rf preview`.
6. Tell the user where the files landed: `out/<Subject>/…`, with decks in `out/Anki/…`. If `BOOX_OUT` is set (env var or `local.env`), `build.sh` also copies `out/` there.
7. If the user states a style preference, add it to **Preferences** in `STYLE.md`, and change `template/boox.typ` if it applies to every note.

## Files
| Path | What |
|---|---|
| `template/boox.typ` | Page setup (2× Go 7 screen, 1264×1680 aspect), fonts, headings, the building blocks (`glance`, `defn`, `key`, `formula`, `pitfall`, `mine`, `example`, `hook`, `qa`, `fig`) |
| `template/bw.tmTheme` | Grayscale code highlighting |
| `fonts/` | Atkinson Hyperlegible (body). Code uses DejaVu Sans Mono; maths uses Typst's built-in New Computer Modern Math |
| `anki/build_anki.py` | `.cards.md` → `.apkg` (stable IDs, so re-importing updates cards instead of duplicating them) |
| `build.sh` | Builds notes and decks. `PREVIEW=1` writes PNGs; `A4=1` also writes an A4 copy |
| `README.md` | User guide: sending to the Boox, shelves, Anki for beginners |
