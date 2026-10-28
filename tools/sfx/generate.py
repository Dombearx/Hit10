#!/usr/bin/env python3
"""Synthesises every sound effect in app/assets/audio/ (docs/04 U-13).

All sounds are generated here from oscillators and noise, so they belong to
the project and need no licence. Deterministic: re-running produces the same
files. Requires numpy and ffmpeg (libvorbis).

    python3 tools/sfx/generate.py
"""
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np

SR = 44100
OUT = Path(__file__).resolve().parents[2] / "app" / "assets" / "audio"
rng = np.random.default_rng(10)


def t(dur):
    return np.arange(int(SR * dur)) / SR


def env(n, attack=0.004, decay=6.0):
    """Fast attack, exponential decay (per second)."""
    x = np.arange(n) / SR
    a = np.clip(x / attack, 0, 1)
    return a * np.exp(-decay * x)


def bell(freq, dur, decay=5.0, partials=((1, 1), (2.0, 0.5), (3.01, 0.25), (4.2, 0.12))):
    x = t(dur)
    s = sum(a * np.sin(2 * np.pi * freq * m * x) for m, a in partials)
    return s * env(len(x), decay=decay)


def mix(*parts):
    n = max(int(offset * SR) + len(p) for offset, p in parts)
    out = np.zeros(n)
    for offset, p in parts:
        k = int(offset * SR)
        out[k:k + len(p)] += p
    return out


def lowpass(x, cutoff):
    a = np.exp(-2 * np.pi * cutoff / SR)
    y = np.zeros_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def noise(dur):
    return rng.uniform(-1, 1, int(SR * dur))


def note(name):
    names = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
    octave = int(name[-1])
    semis = names[name[0]] + (1 if "#" in name else 0) + 12 * (octave - 4) - 9
    return 440.0 * 2 ** (semis / 12)


def save(name, x, gain=0.8):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    pcm = (x * 32767).astype(np.int16)
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as d:
        w = Path(d) / "x.wav"
        with wave.open(str(w), "wb") as f:
            f.setnchannels(1)
            f.setsampwidth(2)
            f.setframerate(SR)
            f.writeframes(pcm.tobytes())
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", str(w), "-c:a", "libvorbis",
             "-q:a", "5", str(OUT / f"{name}.ogg")],
            check=True,
        )
    print(f"{name}.ogg  {len(x) / SR:.2f}s")


def perfect():
    # Major chord arpeggio with sparkle on top.
    c = mix(
        (0.00, bell(note("C6"), 0.9, 4)),
        (0.04, bell(note("E6"), 0.85, 4) * 0.8),
        (0.08, bell(note("G6"), 0.8, 4) * 0.7),
        (0.12, bell(note("C7"), 0.7, 5) * 0.6),
    )
    sparkle = mix(*[
        (0.1 + 0.05 * i, bell(note("C8") * (1 + 0.06 * i), 0.15, 25) * 0.25)
        for i in range(5)
    ])
    return mix((0, c), (0, sparkle))


def great():
    return mix((0, bell(note("G6"), 0.55, 6)), (0.03, bell(note("D7"), 0.45, 7) * 0.5))


def good():
    return bell(note("E6"), 0.18, 22, partials=((1, 1), (2, 0.3)))


def miss():
    x = t(0.3)
    f = 190 * np.exp(-6 * x) + 70
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * env(len(x), 0.002, 12)
    thump = lowpass(noise(0.08), 400) * env(int(SR * 0.08), 0.001, 40) * 2
    return mix((0, body), (0, thump))


def coins():
    parts = []
    for i, f in enumerate([2600, 3100, 2850, 3400]):
        parts.append((0.045 * i, bell(f, 0.2, 18, partials=((1, 1), (2.76, 0.4), (5.4, 0.2))) * (1 - 0.15 * i)))
    return mix(*parts)


def tick():
    click = noise(0.02) * env(int(SR * 0.02), 0.0005, 300)
    return mix((0, click), (0, bell(2200, 0.03, 120, partials=((1, 1),)) * 0.6))


def start():
    return bell(note("C6"), 0.12, 30, partials=((1, 1), (2, 0.2))) * 0.6


def whoosh():
    n = noise(0.45)
    x = t(0.45)
    sweep = np.zeros_like(n)
    acc = 0.0
    for i, v in enumerate(n):
        cutoff = 300 + 3500 * (1 - x[i] / 0.45)
        a = np.exp(-2 * np.pi * cutoff / SR)
        acc = (1 - a) * v + a * acc
        sweep[i] = acc
    shape = np.sin(np.pi * x / 0.45) ** 2
    return sweep * shape


def buy():
    return mix((0, coins() * 0.7), (0.0, bell(note("A6"), 0.25, 12) * 0.6))


def combo_break():
    parts = [(0.03 * i, bell(1800 - 300 * i, 0.12, 30, partials=((1, 1), (2.3, 0.5)))) for i in range(4)]
    return mix(*parts, (0, lowpass(noise(0.15), 2000) * env(int(SR * 0.15), 0.001, 25)))


if __name__ == "__main__":
    for name, fn in [
        ("perfect", perfect), ("great", great), ("good", good), ("miss", miss),
        ("coins", coins), ("tick", tick), ("start", start), ("whoosh", whoosh),
        ("buy", buy), ("combo_break", combo_break),
    ]:
        save(name, fn())
