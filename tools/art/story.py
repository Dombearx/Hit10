#!/usr/bin/env python3
"""Export picked story illustrations into the app (docs/10, U-33).

Usage: python3 tools/art/story.py [id ...]
Reads tools/art/story_picks.json {"<id>": "<model>/<id>_s<seed>"} and writes
app/assets/story/<id>.jpg (1280x720, cropped to 16:9). Needs Pillow only.
The game shows a picture as soon as its file is in app/assets/story/; until
then a placeholder scene stands in (lib/ui/widgets/story_art.dart).
"""
import json, pathlib, sys
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = ROOT / "tools" / "art"
OUT = ROOT / "app" / "assets" / "story"
W, H = 1280, 720


def main():
    picks = json.loads((HERE / "story_picks.json").read_text())
    only = set(sys.argv[1:])
    OUT.mkdir(parents=True, exist_ok=True)
    for sid, src in picks.items():
        if only and sid not in only:
            continue
        img = Image.open(HERE / "out" / f"{src}.png").convert("RGB")
        # Centre crop to 16:9, then scale.
        k = min(img.width / W, img.height / H)
        cw, ch = round(W * k), round(H * k)
        left, top = (img.width - cw) // 2, (img.height - ch) // 2
        img = img.crop((left, top, left + cw, top + ch)).resize((W, H), Image.LANCZOS)
        dst = OUT / f"{sid}.jpg"
        img.save(dst, quality=85, optimize=True, progressive=True)
        print("ok", dst.relative_to(ROOT), f"{dst.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
