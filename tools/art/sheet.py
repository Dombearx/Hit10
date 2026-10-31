#!/usr/bin/env python3
"""Contact sheet of raw candidates: one row per id, one column per file matching out/<model>/<id>_s*.png."""
import pathlib, sys
from PIL import Image, ImageDraw
HERE = pathlib.Path(__file__).resolve().parent
model, dest = sys.argv[1], sys.argv[2]
files = sorted(p for p in (HERE / "out" / model).glob("*_s*.png") if "_cut" not in p.name)
ids = sorted({p.name.rsplit("_s", 1)[0] for p in files})
seeds = sorted({p.stem.rsplit("_s", 1)[1] for p in files})
S, L = 200, 110
sheet = Image.new("RGB", (L + len(seeds) * S, 20 + len(ids) * S), "white")
d = ImageDraw.Draw(sheet)
for c, sd in enumerate(seeds):
    d.text((L + c * S + 4, 4), "s" + sd, fill="black")
for r, i in enumerate(ids):
    d.text((4, 20 + r * S + S // 2), i, fill="black")
    for c, sd in enumerate(seeds):
        f = HERE / "out" / model / f"{i}_s{sd}.png"
        if f.exists():
            sheet.paste(Image.open(f).convert("RGB").resize((S, S)), (L + c * S, 20 + r * S))
sheet.save(dest)
