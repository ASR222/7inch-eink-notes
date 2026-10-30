#!/usr/bin/env bash
# Build Boox-ready PDFs and Anki decks.
#   ./build.sh                                   → every note + every deck
#   ./build.sh "notes/DSA/Binary Search - Main.typ" "anki/DSA/Binary Search.cards.md"
#   A4=1 ./build.sh <file>                       → also "<name> (A4).pdf", a normal A4 version
#   PREVIEW=1 ./build.sh <file>                  → also PNG pages at native screen resolution (150 ppi × 2× page = 1264×1680) in preview/
set -euo pipefail
cd "$(dirname "$0")"
TYPST="${TYPST:-$(command -v typst || echo "$HOME/.local/bin/typst")}"
# optional: local.env (untracked) can set BOOX_OUT, a folder that out/ is copied to after each build
[ -f local.env ] && . ./local.env
BOOX_OUT="${BOOX_OUT:-}"

if [ $# -gt 0 ]; then files=("$@"); else
  mapfile -d '' files < <(find notes -name '*.typ' -print0; find anki -name '*.cards.md' -print0)
fi

for f in "${files[@]}"; do
  case "$f" in
    *.cards.md)
      .venv/bin/python anki/build_anki.py "$f" ;;
    *.typ)
      rel="${f#notes/}"; out="out/${rel%.typ}.pdf"
      mkdir -p "$(dirname "$out")"
      "$TYPST" compile --root . --font-path fonts "$f" "$out"
      echo "built  $out"
      if [ "${A4:-}" = 1 ]; then
        a4out="${out%.pdf} (A4).pdf"
        "$TYPST" compile --root . --font-path fonts --input paper=a4 "$f" "$a4out"
        echo "built  $a4out"
        if [ "${PREVIEW:-}" = 1 ]; then
          p="preview/${rel%.typ} (A4)"; mkdir -p "$(dirname "$p")"
          "$TYPST" compile --root . --font-path fonts --input paper=a4 --ppi 60 "$f" "$p-{0p}.png"
        fi
      fi
      if [ "${PREVIEW:-}" = 1 ]; then
        p="preview/${rel%.typ}"; mkdir -p "$(dirname "$p")"
        "$TYPST" compile --root . --font-path fonts --ppi 150 "$f" "$p-{0p}.png"
      fi ;;
  esac
done

if [ -n "$BOOX_OUT" ] && [ -d "$(dirname "$BOOX_OUT")" ]; then
  mkdir -p "$BOOX_OUT" && cp -r out/. "$BOOX_OUT/" && echo "copied to $BOOX_OUT"
fi
