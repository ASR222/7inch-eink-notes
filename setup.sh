#!/usr/bin/env bash
# One-time setup on a new machine: Typst, Python venv (genanki + markdown), Typst packages.
# Linux / WSL x86_64. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v typst >/dev/null && [ ! -x "$HOME/.local/bin/typst" ]; then
  echo "installing typst → ~/.local/bin"
  mkdir -p "$HOME/.local/bin"
  tmp="$(mktemp -d)"
  curl -sSfL -o "$tmp/typst.tar.xz" https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
  tar -xf "$tmp/typst.tar.xz" -C "$tmp"
  cp "$tmp"/typst-x86_64-unknown-linux-musl/typst "$HOME/.local/bin/"
  rm -rf "$tmp"
fi

if [ ! -x .venv/bin/python ]; then
  echo "creating .venv"
  if command -v uv >/dev/null; then
    uv venv -q .venv && uv pip install -q --python .venv/bin/python genanki markdown
  else
    python3 -m venv .venv && .venv/bin/pip install -q genanki markdown
  fi
fi

# Claude Code reads CLAUDE.md; keep it local (gitignored) and point it at AGENTS.md
[ -f CLAUDE.md ] || echo '@AGENTS.md' > CLAUDE.md

# compiling the template once downloads the fletcher / cetz packages into the Typst cache
./build.sh "notes/DSA/Binary Search - Cheat Sheet.typ" >/dev/null
echo "setup ok — try: ./build.sh"
