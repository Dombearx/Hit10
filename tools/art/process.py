#!/usr/bin/env python3
"""Cut out the background (BiRefNet, MIT) and export game-ready PNGs.

Usage: tools/art/.venv/bin/python tools/art/process.py
Reads tools/art/picks.json  {"<id>": "<model>/<id>_s<seed>"} and writes
app/assets/art/<id>.png (160x160 RGBA) and tools/art/out/final512/<id>.png.
Setup: python3 -m venv tools/art/.venv && tools/art/.venv/bin/pip install "rembg[cpu]" pillow
"""
import json, pathlib, sys
from PIL import Image
from rembg import new_session, remove

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = ROOT / "tools" / "art"
MARGIN = 0.06  # empty border around the subject, fraction of the side


def fit(img, side):
    box = img.getchannel("A").point(lambda a: 255 if a > 16 else 0).getbbox()
    img = img.crop(box)
    inner = round(side * (1 - 2 * MARGIN))
    scale = inner / max(img.size)
    img = img.resize((max(1, round(img.width * scale)), max(1, round(img.height * scale))), Image.LANCZOS)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(img, ((side - img.width) // 2, (side - img.height) // 2), img)
    return canvas


def main():
    picks = json.loads((HERE / "picks.json").read_text())
    only = set(sys.argv[1].split(",")) if len(sys.argv) > 1 else None
    session = new_session("birefnet-general-lite")  # full model OOMs on 7 GB RAM
    for gid, src in picks.items():
        if only and gid not in only:
            continue
        cut = remove(Image.open(HERE / "out" / f"{src}.png").convert("RGB"), session=session)
        cut.save(HERE / "out" / f"{src}_cut.png")
        (ROOT / "app/assets/art").mkdir(parents=True, exist_ok=True)
        (HERE / "out/final512").mkdir(parents=True, exist_ok=True)
        fit(cut, 160).save(ROOT / "app/assets/art" / f"{gid}.png", optimize=True)
        fit(cut, 512).save(HERE / "out/final512" / f"{gid}.png", optimize=True)
        print("ok", gid, "<-", src)


if __name__ == "__main__":
    main()
