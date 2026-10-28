#!/usr/bin/env python3
"""Checks store/listing.md against Play's length limits."""
import re
import sys
from pathlib import Path

text = (Path(__file__).resolve().parents[2] / "store" / "listing.md").read_text()
ok = True
for lang in re.split(r"^## ", text, flags=re.M)[1:]:
    title = lang.splitlines()[0]
    name = re.search(r"\*\*(?:Nazwa|Name):\*\* (.+)", lang).group(1)
    short = re.search(r"\*\*(?:Krótki opis|Short description):\*\* (.+)", lang).group(1)
    full = re.split(r"\*\*(?:Pełny opis|Full description):\*\*\n", lang)[1].strip()
    for label, value, limit in [("name", name, 30), ("short", short, 80), ("full", full, 4000)]:
        n = len(value)
        flag = "OK " if n <= limit else "TOO LONG"
        ok &= n <= limit
        print(f"{title:14} {label:6} {n:5}/{limit}  {flag}")
sys.exit(0 if ok else 1)
