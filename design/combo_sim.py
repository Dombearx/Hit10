"""Combo redesign: how often players sit at the max multiplier.

Compares the current combo (streak +3/+2/+1, miss resets) with proposed
multiplier ladders (PERFECT raises, GREAT holds, GOOD lowers, ...), for
several accuracies and three stages of the game (skill levels).

    python3 design/combo_sim.py            # full table
    python3 design/combo_sim.py --trials 100

Numbers from app/assets/balance.json (tiers, combo, skills, jackpot).
"""

import argparse
import json
import math
import random
from dataclasses import dataclass, field
from pathlib import Path

B = json.loads((Path(__file__).parent.parent / "app/assets/balance.json").read_text())
TIER = {t["id"]: t for t in B["tiers"]}
SK = {s["id"]: s for s in B["skills"]}
STEP = B["combo"]["multiplierPerStep"]  # 0.05
BASE_CAP = B["combo"]["baseCap"]  # 5
JACKPOT = B["jackpot"]["window"]  # 0.010, never widened
ROUND_S = 5.0  # mid-game round, seconds, incl. result pause (5.7 → 3.7)


@dataclass
class Stage:
    name: str
    magnet: int
    wide_eye: int
    bullet: int
    luck: int
    combo: int
    shield: int
    fast_shield: bool = False

    def windows(self, mode="skill"):
        if mode == "base":
            return TIER["perfect"]["window"], TIER["great"]["window"], TIER["good"]["window"]
        we = 1 + SK["wideEye"]["perLevel"] * self.wide_eye
        cb = 1 / (1 - SK["bulletTime"]["perLevel"] * self.bullet)
        if mode == "noCB":
            cb = 1
        p = TIER["perfect"]["window"] + SK["magnet"]["perLevel"] * self.magnet
        g = TIER["great"]["window"] * we
        d = TIER["good"]["window"] * we
        return min(p, g) * cb, g * cb, d * cb

    @property
    def cap(self):
        return BASE_CAP + round(SK["combo"]["perLevel"] * self.combo)

    @property
    def luck_p(self):
        return SK["luck"]["perLevel"] * self.luck


STAGES = [
    Stage("start", 0, 0, 0, 0, 0, 0),
    Stage("early", 3, 4, 3, 0, 4, 1),
    Stage("mid", 8, 8, 8, 5, 9, 3),
    Stage("late", 15, 15, 15, 15, 15, 5, fast_shield=True),
]

# (sigma, bias) like real players: late taps, docs/14 §5.
PLAYERS = [(0.020, 0.0), (0.035, 0.005), (0.050, 0.010), (0.100, 0.020), (0.150, 0.030)]


def tier_of(e, w, luck, rng):
    a = abs(e)
    p, g, d = w
    if a < p:
        t = "P"
    elif a < g:
        t = "G"
    elif a < d:
        t = "D"
    else:
        return "M"
    if luck and t in "GD" and rng.random() < luck:
        t = "P" if t == "G" else "G"
    return t


@dataclass
class Rule:
    name: str
    delta: dict  # tier -> steps; None = reset to 0
    jackpot: object = None  # extra steps for an exact 5.00, "max" = to cap
    shield_blocks: str = "M"  # tiers a Shield charge protects from
    miss: object = None  # None = reset, float = keep that share of steps
    scale_to_cap: bool = False  # steps are 1/5 of the cap (any cap fills in ~5 PERFECTs)
    old: bool = False  # current game: the streak grows beyond the cap
    recharge_hits: int = 10
    win: str = "skill"  # windows the combo grades with: skill / noCB (no Zimna krew) / base  # new rules: +1 Shield charge per N hits without a miss


RULES = [
    Rule("teraz (+3/+2/+1, pudło 0)", {"P": 3, "G": 2, "D": 1}, old=True),
    # Proposals graded with the skill windows (what the player sees).
    Rule("A: P+1 Ś0 D-1 pudło 0", {"P": 1, "G": 0, "D": -1}, jackpot=2),
    Rule("A, Tarcza też na DOBRZE", {"P": 1, "G": 0, "D": -1}, jackpot=2, shield_blocks="MD"),
    Rule("B: P+1 Ś0 D0 pudło 0", {"P": 1, "G": 0, "D": 0}, jackpot=2),
    Rule("B, 5.00 = max", {"P": 1, "G": 0, "D": 0}, jackpot="max"),
    Rule("B, pudło -50%", {"P": 1, "G": 0, "D": 0}, jackpot=2, miss=0.5),
    # The multiplier grades with narrower windows than the payout.
    Rule("D: B bez Zimnej krwi, 5.00 = max", {"P": 1, "G": 0, "D": 0}, jackpot="max", win="noCB"),
    Rule("F: B okna bazowe, 5.00 = max", {"P": 1, "G": 0, "D": 0}, jackpot="max", win="base"),
    Rule("G: A okna bazowe, 5.00 = max", {"P": 1, "G": 0, "D": -1}, jackpot="max", win="base"),
]


@dataclass
class Out:
    frac: float = 0  # mean (multiplier - 1) / (max - 1)
    at_max: float = 0  # share of rounds at max
    mult: float = 0  # mean multiplier
    to_max: list = field(default_factory=list)  # rounds from 0 to max


def play(rule, stage, sigma, bias, rounds, rng):
    w = stage.windows(rule.win)
    cap = 5 if rule.scale_to_cap else stage.cap
    unit = stage.cap / 5 if rule.scale_to_cap else 1
    maxc = stage.cap  # in multiplier steps
    charges = stage.shield
    prog = 0
    c = 0.0
    frac = at_max = mult = 0
    since_zero = 0
    to_max = []
    rech = (7 if stage.fast_shield else 10)
    for _ in range(rounds):
        e = rng.gauss(bias, sigma)
        t = tier_of(e, w, stage.luck_p, rng)
        jack = abs(e) < JACKPOT
        if rule.old:
            if t == "M":
                if charges:
                    charges -= 1
                    prog = 0
                else:
                    c = 0
            else:
                d = rule.delta[t]
                c += d
                if stage.shield:
                    prog += d
                    while prog >= rech and charges < stage.shield:
                        charges += 1
                        prog -= rech
                    if charges >= stage.shield:
                        prog = 0
            m = min(c, maxc)
        else:
            protected = t in rule.shield_blocks and charges and (t == "M" or rule.delta[t] < 0)
            if protected:
                charges -= 1
                prog = 0
            elif t == "M":
                c = 0 if rule.miss is None else math.floor(c * rule.miss)
            else:
                c += rule.delta[t]
                if jack and rule.jackpot == "max":
                    c = cap
                elif jack and rule.jackpot:
                    c += rule.jackpot
            if t != "M" and stage.shield and not protected:
                prog += 1
                if prog >= (7 if stage.fast_shield else rule.recharge_hits) and charges < stage.shield:
                    charges += 1
                    prog = 0
            c = max(0, min(c, cap))
            m = c * unit
        m = min(m, maxc)
        if m <= 0:
            since_zero = 0
        else:
            since_zero += 1
        if m >= maxc:
            at_max += 1
            if since_zero:
                to_max.append(since_zero)
                since_zero = -10**9  # count each climb once
        frac += m / maxc
        mult += 1 + STEP * m
    return frac / rounds, at_max / rounds, mult / rounds, to_max


def run(trials, rounds, seed=1):
    rng = random.Random(seed)
    res = {}
    for st in STAGES:
        for sigma, bias in PLAYERS:
            for r in RULES:
                f = a = m = 0
                climbs = []
                for _ in range(trials):
                    o = play(r, st, sigma, bias, rounds, rng)
                    f += o[0]; a += o[1]; m += o[2]; climbs += o[3]
                climbs.sort()
                med = climbs[len(climbs) // 2] if climbs else None
                res[(st.name, sigma, r.name)] = (f / trials, a / trials, m / trials, med)
    return res


def odds(st, sigma, bias, n=200000, seed=2):
    rng = random.Random(seed)
    w = st.windows()
    cnt = {"P": 0, "G": 0, "D": 0, "M": 0}
    j = 0
    for _ in range(n):
        e = rng.gauss(bias, sigma)
        cnt[tier_of(e, w, st.luck_p, rng)] += 1
        j += abs(e) < JACKPOT
    return {k: v / n for k, v in cnt.items()}, j / n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--trials", type=int, default=200)
    ap.add_argument("--rounds", type=int, default=360)  # ~30 min of play
    a = ap.parse_args()

    print("## Okna i szanse (PERFEKT / ŚWIETNIE / DOBRZE / pudło, 5.00)\n")
    for st in STAGES:
        p, g, d = st.windows()
        print(f"**{st.name}**: okna ±{p*1000:.0f}/{g*1000:.0f}/{d*1000:.0f} ms, "
              f"limit combo {st.cap} (×{1+STEP*st.cap:.2f}), Tarcze {st.shield}, Szczęście {st.luck_p:.0%}\n")
        print("| σ | P | Ś | D | pudło | 5.00 |\n|---|---|---|---|---|---|")
        for s, b in PLAYERS:
            o, j = odds(st, s, b)
            print(f"| {s*1000:.0f} ms | {o['P']:.0%} | {o['G']:.0%} | {o['D']:.0%} | {o['M']:.0%} | {j:.0%} |")
        print()

    res = run(a.trials, a.rounds)
    print("## Czas na maksymalnym mnożniku (% rund) · średni mnożnik względem dziś\n")
    for st in STAGES:
        print(f"### {st.name} (limit ×{1+STEP*st.cap:.2f})\n")
        head = "| reguła | " + " | ".join(f"σ {s*1000:.0f}" for s, _ in PLAYERS) + " |"
        print(head)
        print("|---" * (len(PLAYERS) + 1) + "|")
        for r in RULES:
            cells = []
            for s, _ in PLAYERS:
                f, at, m, med = res[(st.name, s, r.name)]
                base = res[(st.name, s, RULES[0].name)][2]
                rel = (m / base - 1) * 100
                cells.append(f"{at:.0%} · {rel:+.0f}%" if r is not RULES[0] else f"{at:.0%} · ×{m:.2f}")
            print(f"| {r.name} | " + " | ".join(cells) + " |")
        print()


if __name__ == "__main__":
    main()
