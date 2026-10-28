#!/usr/bin/env python3
"""Synthesises the three music loops in app/assets/audio/ (docs/04 U-13).

calm    — the everyday loop: tick-tock woodblocks, soft bass, marimba tune
frenzy  — Frenzy: faster, kick and snare, running arpeggios
golden  — golden round: bells and shimmer in F Lydian

Like the effects, everything comes from oscillators and noise, so the music
belongs to the project. Each loop is a whole number of bars and note tails
wrap around to the start, so it repeats without a seam. Deterministic.

    python3 tools/sfx/music.py
"""
import numpy as np

from generate import SR, save

rng = np.random.default_rng(1010)


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def adsr(n, a=0.005, d=0.1, s=0.6, r=0.1, hold=None):
    """Attack-decay-sustain-release over n samples; release starts at hold."""
    x = np.arange(n) / SR
    hold = n / SR - r if hold is None else hold
    e = np.where(x < a, x / a, 1.0)
    e = np.where((x >= a) & (x < a + d), 1 - (1 - s) * (x - a) / d, e)
    e = np.where(x >= a + d, s, e)
    rel = np.clip((x - hold) / r, 0, 1)
    return e * (1 - rel)


def tone(freq, dur, partials, env):
    x = np.arange(int(dur * SR)) / SR
    w = sum(a * np.sin(2 * np.pi * freq * k * x) for k, a in partials)
    return w * env(len(x))


SOFT_SQUARE = ((1, 1), (3, 0.22), (5, 0.08), (7, 0.03))
TRIANGLE = ((1, 1), (3, -0.11), (5, 0.04))
MARIMBA = ((1, 1), (4, 0.35), (9.2, 0.08))
BELL = ((1, 1), (2.0, 0.6), (3.01, 0.3), (4.2, 0.18), (5.4, 0.08))


def perc_env(decay):
    return lambda n: np.exp(-decay * np.arange(n) / SR) * np.clip(
        np.arange(n) / (0.002 * SR), 0, 1)


class Track:
    def __init__(self, bpm, bars):
        self.beat = 60 / bpm
        self.n = int(round(bars * 4 * self.beat * SR))
        self.buf = np.zeros(self.n)

    def put(self, beat, sound, gain=1.0):
        """Adds sound at beat; whatever runs past the end wraps to the start."""
        k = int(round(beat * self.beat * SR)) % self.n
        end = k + len(sound)
        if end <= self.n:
            self.buf[k:end] += sound * gain
        else:
            first = self.n - k
            self.buf[k:] += sound[:first] * gain
            rest = sound[first:]
            while len(rest):
                take = min(len(rest), self.n)
                self.buf[:take] += rest[:take] * gain
                rest = rest[take:]


def woodblock(freq, decay=60):
    x = np.arange(int(0.08 * SR)) / SR
    s = np.sin(2 * np.pi * freq * x) + 0.4 * np.sin(2 * np.pi * freq * 2.7 * x)
    return s * np.exp(-decay * x)


def kick():
    x = np.arange(int(0.35 * SR)) / SR
    f = 50 + 90 * np.exp(-25 * x)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-9 * x)


def snare():
    x = np.arange(int(0.2 * SR)) / SR
    body = np.sin(2 * np.pi * 190 * x) * np.exp(-30 * x)
    hiss = np.convolve(rng.uniform(-1, 1, len(x)), np.ones(4) / 4, "same")
    hiss *= np.exp(-22 * x)
    return 0.5 * body + 0.6 * hiss


def hat():
    x = np.arange(int(0.05 * SR)) / SR
    h = rng.uniform(-1, 1, len(x))
    h = np.diff(h, prepend=0)  # crude high-pass
    return h * np.exp(-70 * x)


def chord_tones(root, quality):
    third = 3 if quality == "m" else 4
    return [root, root + third, root + 7]


def pad(chord, dur, gain=1.0):
    env = lambda n: adsr(n, a=0.25, d=0.3, s=0.7, r=0.4)  # noqa: E731
    return sum(tone(midi(m), dur, SOFT_SQUARE, env) for m in chord) * gain


def calm():
    # F – Dm – B♭ – C, then Gm – C – F – F; 100 BPM, 16 bars.
    t = Track(bpm=100, bars=16)
    prog = [(53, ""), (50, "m"), (46, ""), (48, ""),
            (43, "m"), (48, ""), (53, ""), (53, "")] * 2
    # A gentle tune from chord tones and the F major pentatonic.
    penta = [65, 67, 69, 72, 74, 77, 79, 81]
    rhythm = [0, 1, 1.5, 2.5, 3]  # beats within a bar
    prev = 2
    for bar, (root, q) in enumerate(prog):
        b0 = bar * 4
        # Tick-tock on every beat: the clock never stops.
        for i in range(4):
            t.put(b0 + i, woodblock(1800 if i % 2 == 0 else 1250), 0.16)
        # Bass: root on 1 and 3, fifth before 3.
        for beat, m in [(0, root - 12), (1.5, root - 5), (2, root - 12), (3.5, root)]:
            t.put(b0 + beat, tone(midi(m), 0.6, TRIANGLE,
                                  lambda n: adsr(n, d=0.2, s=0.5, r=0.15)), 0.5)
        t.put(b0, pad(chord_tones(root + 12, q), 4 * t.beat), 0.07)
        # Melody: rests every fourth bar so the tune breathes.
        if bar % 4 == 3:
            continue
        for beat in rhythm:
            step = rng.choice([-2, -1, 1, 1, 2])
            prev = int(np.clip(prev + step, 0, len(penta) - 1))
            m = penta[prev]
            t.put(b0 + beat, tone(midi(m), 0.5, MARIMBA, perc_env(9)), 0.32)
    return t.buf


def frenzy():
    # Same progression a tone up, 150 BPM, 16 bars of drive.
    t = Track(bpm=150, bars=16)
    prog = [(55, ""), (52, "m"), (48, ""), (50, "")] * 4
    for bar, (root, q) in enumerate(prog):
        b0 = bar * 4
        for i in range(4):
            t.put(b0 + i, kick(), 0.7)
            t.put(b0 + i + 0.5, hat(), 0.12)
        t.put(b0 + 1, snare(), 0.35)
        t.put(b0 + 3, snare(), 0.35)
        # Driving eighth-note bass.
        for i in range(8):
            m = root - 12 if i % 2 == 0 else root
            t.put(b0 + i / 2, tone(midi(m), 0.22, SOFT_SQUARE,
                                   lambda n: adsr(n, d=0.08, s=0.5, r=0.05)), 0.33)
        # Sixteenth-note arpeggio up and down the chord.
        arp = chord_tones(root + 24, q) + [root + 36]
        order = arp + arp[-2:0:-1]
        for i in range(16):
            m = order[i % len(order)]
            t.put(b0 + i / 4, tone(midi(m), 0.14, SOFT_SQUARE, perc_env(18)), 0.16)
        t.put(b0, pad(chord_tones(root + 12, q), 4 * t.beat), 0.05)
    return t.buf


def golden():
    # F Lydian shimmer: F – G – Em – F(maj7), 120 BPM, 8 bars.
    t = Track(bpm=120, bars=8)
    prog = [(53, ""), (55, ""), (52, "m"), (53, "")] * 2
    for bar, (root, q) in enumerate(prog):
        b0 = bar * 4
        t.put(b0, pad(chord_tones(root + 12, q), 4 * t.beat), 0.08)
        t.put(b0, tone(midi(root - 12), 2 * t.beat, TRIANGLE,
                       lambda n: adsr(n, a=0.02, d=0.5, s=0.5, r=0.3)), 0.45)
        t.put(b0 + 2, tone(midi(root - 5), 2 * t.beat, TRIANGLE,
                           lambda n: adsr(n, a=0.02, d=0.5, s=0.5, r=0.3)), 0.4)
        # Bells: a rising figure each bar, an octave higher every other bar.
        tones = chord_tones(root + 24 + (12 if bar % 2 else 0), q) + [root + 35]
        for i, m in enumerate(tones):
            t.put(b0 + i * 0.75, tone(midi(m), 1.6, BELL, perc_env(3.5)), 0.2)
        # Sparkle: soft high pings on the off-beats.
        for i in range(8):
            if i % 2:
                m = tones[(i + bar) % len(tones)] + 12
                t.put(b0 + i / 2, tone(midi(m), 0.4, ((1, 1), (2, 0.2)), perc_env(12)), 0.07)
        for i in range(4):
            t.put(b0 + i, woodblock(2200, decay=90), 0.08)
    return t.buf


if __name__ == "__main__":
    save("music_calm", calm(), gain=0.7)
    save("music_frenzy", frenzy(), gain=0.7)
    save("music_golden", golden(), gain=0.7)
