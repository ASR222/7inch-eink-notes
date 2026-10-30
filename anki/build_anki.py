"""Turn anki/<Subject>/<Topic>.cards.md into a tap-to-import .apkg deck.

Card file format:
    deck: DSA::Binary Search
    tags: dsa binary-search

    Q: question (Markdown; $inline$ and $$display$$ math; ``` code blocks)
    A: answer, may span several lines

    Q: next question ...

IDs are derived from the deck name and question text, so re-importing an
updated deck updates existing cards instead of duplicating them.
"""
import hashlib
import re
import sys
from pathlib import Path

import genanki
import markdown

ROOT = Path(__file__).resolve().parent.parent

CSS = """
.card { font-family: "Atkinson Hyperlegible", Arial, sans-serif; font-size: 22px;
        color: #000; background: #fff; text-align: left; line-height: 1.45; padding: 4px 6px; }
.q { font-weight: bold; font-size: 24px; }
hr#answer { border: 0; border-top: 2px solid #000; margin: 14px 0; }
code { font-family: "DejaVu Sans Mono", monospace; font-size: 0.85em; background: #eee; padding: 0 3px; }
pre { background: #eee; border-left: 4px solid #000; padding: 8px; white-space: pre-wrap; }
pre code { background: none; padding: 0; }
strong { font-weight: 800; }
.tags { color: #555; font-size: 14px; margin-top: 18px; }
"""

MODEL = genanki.Model(
    1607392319,  # fixed: never change, or all cards get duplicated on re-import
    "Boox Q&A",
    fields=[{"name": "Question"}, {"name": "Answer"}],
    templates=[{
        "name": "Card 1",
        "qfmt": '<div class="q">{{Question}}</div>',
        "afmt": '<div class="q">{{Question}}</div><hr id="answer">{{Answer}}<div class="tags">{{Tags}}</div>',
    }],
    css=CSS,
)


def stable_id(text: str) -> int:
    return int(hashlib.sha1(text.encode()).hexdigest()[:12], 16) % (1 << 31)


def to_html(src: str) -> str:
    # protect math from Markdown, then hand it to Anki's MathJax
    stash = []

    def keep(m, display):
        stash.append(("\\[" + m.group(1) + "\\]") if display else ("\\(" + m.group(1) + "\\)"))
        return f"\x00{len(stash) - 1}\x00"

    src = re.sub(r"\$\$(.+?)\$\$", lambda m: keep(m, True), src, flags=re.S)
    src = re.sub(r"(?<!\\)\$(.+?)(?<!\\)\$", lambda m: keep(m, False), src)
    html = markdown.markdown(src.strip(), extensions=["fenced_code", "tables", "sane_lists"])
    return re.sub(r"\x00(\d+)\x00", lambda m: stash[int(m.group(1))], html)


def parse(path: Path):
    text = path.read_text()
    head, _, body = text.partition("\n\n")
    meta = dict(line.split(":", 1) for line in head.splitlines() if ":" in line)
    deck = meta["deck"].strip()
    tags = meta.get("tags", "").split()
    cards = re.findall(r"^Q:(.*?)^A:(.*?)(?=^Q:|\Z)", body, flags=re.S | re.M)
    return deck, tags, [(q.strip(), a.strip()) for q, a in cards]


def build(path: Path) -> Path:
    deck_name, tags, cards = parse(path)
    deck = genanki.Deck(stable_id(deck_name), deck_name)
    for q, a in cards:
        deck.add_note(genanki.Note(model=MODEL, fields=[to_html(q), to_html(a)], tags=tags,
                                   guid=genanki.guid_for(deck_name, q)))
    rel = path.relative_to(ROOT / "anki")
    out = ROOT / "out" / "Anki" / (str(rel).removesuffix(".cards.md") + ".apkg")
    out.parent.mkdir(parents=True, exist_ok=True)
    genanki.Package(deck).write_to_file(out)
    print(f"built  {out.relative_to(ROOT)}  ({len(cards)} cards)")
    return out


if __name__ == "__main__":
    paths = [Path(p).resolve() for p in sys.argv[1:]] or sorted((ROOT / "anki").rglob("*.cards.md"))
    for p in paths:
        build(p)
