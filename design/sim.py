#!/usr/bin/env python3
"""Design-time balance simulator for Hit10.

Reads design/balance.json and plays one run with a greedy bot that always buys
whatever pays itself back soonest. Prints when each generator is first bought,
when skills are levelled, income per hour and the Chronons a prestige would
give. Use it after every change to balance.json:

    python3 design/sim.py                 # active player, 8 h
    python3 design/sim.py --idle-after 10 # taps 10 min, then only buys
    python3 design/sim.py --hours 12 --sigma 0.05 --chronons 30

The game gets a Dart port of this (docs/05-technika.md, T-4); this file stays
as the reference the port is checked against (docs/06, section 1.2).
"""
import argparse
import json
import math
import random
from pathlib import Path

HERE = Path(__file__).resolve().parent


def p_within(w, sigma):
    """P(|x| < w) for x ~ N(0, sigma)."""
    if sigma <= 0:
        return 1.0
    return math.erf(w / (sigma * math.sqrt(2)))


def avg_streak(inc, p_miss, cap):
    """Mean combo streak over renewal cycles: grows by inc per round up to cap,
    drops to 0 on a miss (probability p_miss per round)."""
    if inc <= 0:
        return 0.0
    if p_miss <= 1e-12:
        return cap
    q = 1 - p_miss
    k_cap = max(1, math.ceil(cap / inc))
    total = sum(q ** k * inc * k for k in range(1, k_cap))
    total += cap * q ** k_cap / (1 - q)
    return p_miss * total


class Game:
    def __init__(self, b, chronons=0):
        self.b = b
        self.skills = {s["id"]: s for s in b["skills"]}
        self.lvl = {s["id"]: 0 for s in b["skills"]}
        self.gens = [g for g in b["generators"] if "requiresPerk" not in g]
        self.n = {g["id"]: 0 for g in self.gens}
        self.gen_upg = {g["id"]: 0 for g in self.gens}  # how many tier upgrades bought
        self.syn = set()
        self.bank = 0.0
        self.earned = 0.0
        self.chronons = chronons
        self.streak = 0
        self.frenzy_until = -1
        self.turbo_until = -1
        self.turbo_mult = 1
        self.shield = 0
        self.shield_progress = 0
        self.base_ev = {g["id"]: self.ev_rate(g["sigma"], base=True) for g in self.gens}

    # -- windows and grading -------------------------------------------------
    def windows(self, base=False):
        t = {x["id"]: x["window"] for x in self.b["tiers"]}
        if base:
            return t
        we = 1 + self.skill("wideEye") * self.lvl["wideEye"]
        return {
            "perfect": t["perfect"] + self.skill("magnet") * self.lvl["magnet"],
            "great": t["great"] * we,
            "good": t["good"] * we,
        }

    def skill(self, sid):
        return self.skills[sid]["perLevel"]

    def tier_probs(self, sigma, base=False):
        w = self.windows(base)
        pp = p_within(w["perfect"], sigma)
        pg = p_within(w["great"], sigma) - pp
        pd = p_within(w["good"], sigma) - pp - pg
        if not base:
            bump = self.skill("luck") * self.lvl["luck"]
            pp, pg, pd = pp + pg * bump, pg * (1 - bump) + pd * bump, pd * (1 - bump)
        return pp, pg, pd

    def ev_rate(self, sigma, base=False):
        r = {x["id"]: x["reward"] for x in self.b["tiers"]}
        pp, pg, pd = self.tier_probs(sigma, base)
        return pp * r["perfect"] + pg * r["great"] + pd * r["good"]

    # -- income ----------------------------------------------------------------
    def global_mult(self, t=None):
        """t=None means "no temporary effects" (used for decisions and
        reports); passing the current time applies Frenzy/Turbo."""
        m = 1 + self.chronons * self.b["prestige"]["bonusPerChronon"]
        if t is None:
            return m
        if t < self.frenzy_until:
            m *= self.b["golden"]["effects"][0]["multiplier"]
        if t < self.turbo_until:
            m *= self.turbo_mult
        return m

    def gen_rate(self, g, extra_n=None, extra_upg=None, extra_syn=None):
        gid = g["id"]
        n = self.n[gid] + (1 if extra_n == gid else 0)
        if n == 0:
            return 0.0
        upg = self.gen_upg[gid] + (1 if extra_upg == gid else 0)
        mult = self.b["generatorUpgrades"]["multiplier"] ** upg
        syns = self.syn | ({extra_syn} if extra_syn else set())
        for s in self.b["synergies"]:
            if s["id"] in syns:
                if s["a"] == gid:
                    mult *= 1 + s["aPerB"] * self.n.get(s["b"], 0)
                if s["b"] == gid:
                    mult *= 1 + s["bPerA"] * self.n.get(s["a"], 0)
        window_gain = self.ev_rate(g["sigma"]) / self.base_ev[gid] if self.base_ev[gid] else 1
        return n * g["baseRate"] * mult * window_gain

    def passive(self, t=None, **extra):
        return sum(self.gen_rate(g, **extra) for g in self.gens) * self.global_mult(t)

    def round_seconds(self):
        r = self.b["round"]
        ff = 1 + self.skill("fastForward") * self.lvl["fastForward"]
        slow = 1 - self.skill("bulletTime") * self.lvl["bulletTime"]
        before_zone = r["target"] - r["bulletZone"] - r["fastForwardEnd"]
        return r["fastForwardEnd"] / ff + before_zone + r["bulletZone"] / slow + r["resultPause"]

    def active_income(self, sigma_real, passive):
        """Expected active income per second (analytic, used for buy decisions)."""
        slow = 1 - self.skill("bulletTime") * self.lvl["bulletTime"]
        pp, pg, pd = self.tier_probs(sigma_real * slow)
        tiers = {x["id"]: x for x in self.b["tiers"]}
        power = 1 + self.skill("power") * self.lvl["power"]
        cap = self.b["combo"]["baseCap"] + self.skill("combo") * self.lvl["combo"]
        p_miss = 1 - (pp + pg + pd)
        inc = 2 * pp + pg
        if self.lvl["shield"]:
            p_miss = p_miss * max(0.0, 1 - (inc / 10) / max(1e-9, p_miss))
        combo = 1 + self.b["combo"]["multiplierPerStep"] * avg_streak(inc, p_miss, cap)
        ev = (pp * tiers["perfect"]["reward"] + pg * tiers["great"]["reward"] + pd * tiers["good"]["reward"])
        echo_s = self.skill("echo") * self.lvl["echo"]
        echo = echo_s * (pp + pg * tiers["great"]["echoShare"] + pd * tiers["good"]["echoShare"]) * passive
        return (ev * power + echo) * combo / self.round_seconds()

    # -- shop ---------------------------------------------------------------------
    def candidates(self):
        gu = self.b["generatorUpgrades"]
        for g in self.gens:
            gid = g["id"]
            yield ("gen", gid, g["baseCost"] * self.b["generatorCostGrowth"] ** self.n[gid])
            k = self.gen_upg[gid]
            if k < len(gu["thresholds"]) and self.n[gid] >= gu["thresholds"][k]:
                yield ("upg", gid, g["baseCost"] * gu["costMultipliers"][k])
        for s in self.b["synergies"]:
            if s["id"] not in self.syn and self.n[s["a"]] and self.n[s["b"]]:
                yield ("syn", s["id"], s["cost"])
        for sid, s in self.skills.items():
            if sid == "ticking":
                continue  # quality of life, no income effect
            if self.lvl[sid] < s["maxLevel"]:
                yield ("skill", sid, s["baseCost"] * s["costGrowth"] ** self.lvl[sid])

    def golden_strength(self, sigma_real):
        slow = 1 - self.skill("bulletTime") * self.lvl["bulletTime"]
        pp, pg, pd = self.tier_probs(sigma_real * slow)
        ts = self.b["golden"]["tierStrength"]
        boost = 1 + self.skill("goldenTouch") * self.lvl["goldenTouch"]
        return (pp * ts["perfect"] + pg * ts["great"] + pd * ts["good"]) * boost

    def golden_interval(self):
        gold = self.b["golden"]
        mean = (gold["intervalMin"] + gold["intervalMax"]) / 2
        return mean * (1 - self.skill("goldenTouch") * self.lvl["goldenTouch"])

    def total_income(self, sigma, idle, **extra):
        p = self.passive(**extra)
        if idle:
            return p
        total = p + self.active_income(sigma, p)
        eff = {e["id"]: e for e in self.b["golden"]["effects"]}
        s, iv = self.golden_strength(sigma), self.golden_interval()
        fr = eff["frenzy"]
        frenzy_share = fr["weight"] * fr["duration"] * s / iv
        lucky = eff["lucky"]["weight"] * eff["lucky"]["productionSeconds"] * s * p / iv
        return total * (1 + (fr["multiplier"] - 1) * frenzy_share) + lucky

    def gain_of(self, kind, key, sigma, idle):
        before = self.total_income(sigma, idle)
        if kind == "gen":
            after = self.total_income(sigma, idle, extra_n=key)
        elif kind == "upg":
            after = self.total_income(sigma, idle, extra_upg=key)
        elif kind == "syn":
            after = self.total_income(sigma, idle, extra_syn=key)
        else:
            if idle and key not in ("wideEye", "magnet", "luck"):
                return 0
            self.lvl[key] += 1
            after = self.total_income(sigma, idle)
            self.lvl[key] -= 1
        return after - before

    def buy(self, kind, key, cost):
        self.bank -= cost
        if kind == "gen":
            self.n[key] += 1
        elif kind == "upg":
            self.gen_upg[key] += 1
        elif kind == "syn":
            self.syn.add(key)
        else:
            self.lvl[key] += 1


def simulate(b, hours, sigma, idle_after, chronons, seed, ads=None):
    """ads: None, or a dict of rewarded-ad offers the player always takes
    when off cooldown (see ADS_DEFAULT)."""
    rnd = random.Random(seed)
    g = Game(b, chronons)
    ad_log = []
    next_ad = {"bag": 0.0, "golden": 0.0, "rescue": 0.0}
    if ads:
        g.turbo_mult = ads["turbo"]["multiplier"]
    gold = b["golden"]
    t = 0.0
    next_golden = rnd.uniform(gold["intervalMin"], gold["intervalMax"])
    first_gen, skill_log, hourly, buys, earned_log = {}, [], [], [], []
    tiers = {x["id"]: x for x in b["tiers"]}
    next_hour = 3600
    while t < hours * 3600:
        idle = idle_after is not None and t >= idle_after * 60
        dt = g.round_seconds() if not idle else 5.0
        passive = g.passive(t)
        gain = passive * dt
        if not idle:
            slow = 1 - g.skill("bulletTime") * g.lvl["bulletTime"]
            err = abs(rnd.gauss(0, sigma * slow))
            w = g.windows()
            tier = "perfect" if err < w["perfect"] else "great" if err < w["great"] else "good" if err < w["good"] else None
            if tier in ("great", "good") and rnd.random() < g.skill("luck") * g.lvl["luck"]:
                tier = "perfect" if tier == "great" else "great"
            cap = b["combo"]["baseCap"] + g.skill("combo") * g.lvl["combo"]
            if tier is None:
                if g.shield > 0:
                    g.shield -= 1
                elif ads and g.streak >= ads["rescue"]["minStreak"] and t >= next_ad["rescue"]:
                    next_ad["rescue"] = t + ads["rescue"]["cooldown"]
                    ad_log.append((t, "rescue"))
                else:
                    g.streak = 0
            else:
                g.streak = min(cap, g.streak + tiers[tier]["comboStep"])
                g.shield_progress += tiers[tier]["comboStep"]
                while g.shield_progress >= 10:
                    g.shield_progress -= 10
                    g.shield = min(g.lvl["shield"], g.shield + 1)
                combo = 1 + b["combo"]["multiplierPerStep"] * g.streak
                power = 1 + g.skill("power") * g.lvl["power"]
                hit = tiers[tier]["reward"] * power * g.global_mult(t)
                hit += g.skill("echo") * g.lvl["echo"] * tiers[tier]["echoShare"] * passive
                gain += hit * combo
            if t >= next_golden:
                gt = 1 - g.skill("goldenTouch") * g.lvl["goldenTouch"]
                next_golden = t + rnd.uniform(gold["intervalMin"], gold["intervalMax"]) * gt
                if tier is not None:
                    strength = gold["tierStrength"][tier] * (1 + g.skill("goldenTouch") * g.lvl["goldenTouch"])
                    eff = rnd.choices(gold["effects"], weights=[e["weight"] for e in gold["effects"]])[0]
                    if eff["id"] == "frenzy":
                        g.frenzy_until = max(g.frenzy_until, t) + eff["duration"] * strength
                    elif eff["id"] == "lucky":
                        gain += strength * min(passive * eff["productionSeconds"], g.bank * eff["bankFraction"])
        if ads and not idle:
            tb = ads["turbo"]
            if g.turbo_until - t < 60:
                g.turbo_until = min(max(g.turbo_until, t) + tb["duration"], t + tb["maxStock"])
                ad_log.append((t, "turbo"))
            if t >= next_ad["bag"]:
                gain += g.passive() * ads["bag"]["productionSeconds"]
                next_ad["bag"] = t + ads["bag"]["cooldown"]
                ad_log.append((t, "bag"))
            if t >= next_ad["golden"]:
                next_golden = t
                next_ad["golden"] = t + ads["golden"]["cooldown"]
                ad_log.append((t, "golden"))
        g.bank += gain
        g.earned += gain
        t += dt
        # buy greedily: best payback first, as long as we can afford it
        while True:
            best = None
            for kind, key, cost in g.candidates():
                d = g.gain_of(kind, key, sigma, idle)
                if d <= 0:
                    continue
                score = cost / d + max(0.0, cost - g.bank) / max(1e-9, g.total_income(sigma, idle))
                if best is None or score < best[0]:
                    best = (score, kind, key, cost)
            if best is None or best[3] > g.bank:
                break
            _, kind, key, cost = best
            g.buy(kind, key, cost)
            buys.append(t)
            if kind == "gen" and key not in first_gen:
                first_gen[key] = t
            if kind == "skill":
                skill_log.append((t, key, g.lvl[key]))
        earned_log.append((t, g.earned))
        if t >= next_hour:
            base = g.passive()
            hourly.append((t / 3600, base, g.total_income(sigma, idle) - base, g.earned))
            next_hour += 3600
    g.ad_log = ad_log
    return g, first_gen, skill_log, hourly, buys, earned_log


def fmt(x):
    for div, suf in ((1e15, "aa"), (1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")):
        if abs(x) >= div:
            return f"{x / div:.2f}{suf}"
    return f"{x:.2f}"


def report(b, a, res):
    g, first_gen, skill_log, hourly, _, _ = res
    pr = b["prestige"]
    mode = f"active sigma={a.sigma * 1000:.0f} ms"
    if a.idle_after is not None:
        mode += f", idle after {a.idle_after:g} min"
    print(f"Run: {a.hours} h, {mode}, chronons={a.chronons}\n")
    print("First of each generator:")
    for gid, t in first_gen.items():
        print(f"  {gid:14s} {t / 60:7.1f} min")
    print("\nSkill levels (time reached):")
    by_skill = {}
    for t, sid, lv in skill_log:
        by_skill.setdefault(sid, []).append(f"{lv}@{t / 60:.0f}m")
    for sid, ls in by_skill.items():
        print(f"  {sid:12s} " + " ".join(ls))
    print("\nHour  passive/s   active/s   earned     chronons-if-prestige")
    for h, p, act, e in hourly:
        ch = int((e / pr["divisor"]) ** pr["exponent"]) if e > 0 else 0
        print(f"{h:4.0f}  {fmt(p):>9s}  {fmt(act):>9s}  {fmt(e):>9s}  {ch}")
    print("\nOwned:", {k: v for k, v in g.n.items() if v})


def earned_at(log, t):
    return max((e for tt, e in log if tt <= t), default=0.0)


def time_to(log, target):
    return next((tt for tt, e in log if e >= target), float("inf"))


def _run(args):
    b, hours, sigma, idle_after, chronons, seed = args
    return simulate(b, hours, sigma, idle_after, chronons, seed)


def check(b, seed):
    """Run the scenarios behind targets B-1..B-10 (docs/03-ekonomia.md)."""
    from multiprocessing import Pool
    scen = {
        "skilled": (b, 8, 0.030, None, 0, seed),
        "casual": (b, 8, 0.060, None, 0, seed),
        "idle": (b, 8, 0.030, 10, 0, seed),
        "run2": (b, 6, 0.030, None, 20, seed),
    }
    with Pool(len(scen)) as pool:
        res = dict(zip(scen, pool.map(_run, scen.values())))
    pr = b["prestige"]
    sk, ca, idl, r2 = res["skilled"], res["casual"], res["idle"], res["run2"]
    fg = sk[1]
    hr = 3600
    e6 = earned_at(sk[5], 6 * hr)
    ratio = {round(h): act / p for h, p, act, e in sk[3] if p > 0}
    later = [ratio[h] for h in range(2, 9) if h in ratio]
    idle_hours = [sum(1 for t in idl[4] if h * hr <= t < (h + 1) * hr) for h in range(8)]
    lv = sk[0].lvl
    rows = [
        ("B-1", "first grandpa (min)", fg.get("grandpa", 1e9) / 60, lambda v: v <= 2),
        ("B-2", "first watchmaker (min)", fg.get("watchmaker", 1e9) / 60, lambda v: 15 <= v <= 40),
        ("B-3", "first atomic (h)", fg.get("atomic", 1e9) / hr, lambda v: 1.5 <= v <= 4),
        ("B-4", "first time machine (h)", fg.get("timeMachine", 1e9) / hr, lambda v: v > 6),
        ("B-5", "chronons at 6 h", int((e6 / pr["divisor"]) ** pr["exponent"]), lambda v: 15 <= v <= 30),
        ("B-6a", "active/passive hour 1", ratio.get(1, 0), lambda v: v >= 1),
        ("B-6b", "active/passive h2-8 (min..max)", (min(later), max(later)), lambda v: v[0] >= 1.5 and v[1] <= 5),
        ("B-7", "casual/skilled earned 8 h", earned_at(ca[5], 8 * hr) / earned_at(sk[5], 8 * hr), lambda v: v >= 0.4),
        ("B-8", "idle/active earned 8 h", earned_at(idl[5], 8 * hr) / earned_at(sk[5], 8 * hr), lambda v: v >= 0.01),
        ("B-8b", "idle: buys in each hour", idle_hours, lambda v: min(v) >= 1),
        ("B-9", "run2 (20 ch) reaches run1@6h (h)", time_to(r2[5], e6) / hr, lambda v: v <= 4.5),
        ("B-10", "skills never bought", [k for k, v in lv.items() if v == 0 and k != "ticking"], lambda v: not v),
    ]
    ok_all = True
    for rid, name, val, ok in rows:
        good = ok(val)
        ok_all &= good
        if isinstance(val, float):
            shown = f"{val:.3g}"
        elif isinstance(val, tuple):
            shown = " .. ".join(f"{x:.2f}" for x in val)
        else:
            shown = str(val)
        print(f"{'PASS' if good else 'FAIL'}  {rid:5s} {name:34s} {shown}")
    print("\nskilled skill levels at 8 h:", lv)
    return ok_all


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--balance", default=str(HERE / "balance.json"))
    ap.add_argument("--hours", type=float, default=8)
    ap.add_argument("--sigma", type=float, default=0.030, help="player timing spread in seconds")
    ap.add_argument("--idle-after", type=float, default=None, metavar="MIN",
                    help="tap only for the first MIN minutes, then only buy")
    ap.add_argument("--chronons", type=int, default=0)
    ap.add_argument("--seed", type=int, default=10)
    ap.add_argument("--check", action="store_true", help="evaluate targets B-1..B-10")
    a = ap.parse_args()
    b = json.loads(Path(a.balance).read_text())
    if a.check:
        raise SystemExit(0 if check(b, a.seed) else 1)
    report(b, a, simulate(b, a.hours, a.sigma, a.idle_after, a.chronons, a.seed))


if __name__ == "__main__":
    main()


# Rewarded-ad offers as accepted in docs/02-rozgrywka.md §13 (variant A in 03 §5).
ADS_DEFAULT = {
    "turbo": {"multiplier": 2, "duration": 1800, "maxStock": 14400},
    "bag": {"productionSeconds": 300, "cooldown": 1800},
    "rescue": {"minStreak": 15, "cooldown": 900},
    "golden": {"cooldown": 1800},
}
