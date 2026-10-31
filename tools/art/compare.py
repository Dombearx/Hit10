#!/usr/bin/env python3
"""Comparison sheet: current Fluent icon vs generated variants, at 160 px on card colour."""
import pathlib, sys
from PIL import Image, ImageDraw
ROOT = pathlib.Path(__file__).resolve().parents[2]
ROWS = {"grandpa": ("old_man", (0xFF, 0xD3, 0x6E)), "cuckoo": ("bird", (0x9B, 0xE7, 0xC4)),
        "quartz": ("gem_stone", (0xC8, 0xF2, 0xFF)), "atomic": ("atom_symbol", (0xD7, 0xC4, 0xFF))}
COLS = ["current", "zimage", "qwen-edit", "qwen"]
S, P, H = 160, 16, 24
sheet = Image.new("RGB", (P + len(COLS) * (S + P), H + P + len(ROWS) * (S + P)), "white")
d = ImageDraw.Draw(sheet)
for c, name in enumerate(COLS):
    d.text((P + c * (S + P), 6), name, fill="black")
for r, (gid, (emoji, bg)) in enumerate(ROWS.items()):
    for c, name in enumerate(COLS):
        x, y = P + c * (S + P), H + P + r * (S + P)
        f = ROOT / ("app/assets/emoji/%s.png" % emoji if name == "current" else f"tools/art/out/{name}/{gid}_s1010.png")
        tile = Image.new("RGB", (S, S), bg)
        im = Image.open(f).convert("RGBA")
        if name == "current":
            im = im.resize((int(S * .75),) * 2, Image.LANCZOS)
            tile.paste(im, ((S - im.width) // 2,) * 2, im)
        else:
            tile = im.convert("RGB").resize((S, S), Image.LANCZOS)
        sheet.paste(tile, (x, y))
sheet.save(sys.argv[1])
