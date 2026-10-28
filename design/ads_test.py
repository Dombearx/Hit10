"""Rewarded-ad impact: how much faster a player who takes every offer is
(targets A-1, A-2 in docs/03-ekonomia.md section 5).

    python3 design/ads_test.py
"""
import json, sys, copy
from multiprocessing import Pool
from collections import Counter
from sim import simulate, ADS_DEFAULT, earned_at, time_to
from pathlib import Path
b = json.load(open(Path(__file__).resolve().parent / "balance.json"))
def variant(**ch):
    a = copy.deepcopy(ADS_DEFAULT)
    for k, v in ch.items():
        a[k].update(v)
    return a
VARIANTS = {
    "accepted (A)": ADS_DEFAULT,
    "first proposal": variant(turbo={"duration": 900, "maxStock": 7200},
                              bag={"productionSeconds": 1200, "cooldown": 600},
                              golden={"cooldown": 900}),
}
SEEDS = [10, 1, 2, 3, 4]
def job(a):
    name, seed = a
    ads = None if name == "none" else VARIANTS[name]
    r = simulate(b, 8, 0.030, None, 0, seed, ads)
    return name, seed, r[5], getattr(r[0], "ad_log", [])
if __name__ == "__main__":
    jobs = [(n, s) for n in ["none", *VARIANTS] for s in SEEDS]
    with Pool(8) as p:
        res = p.map(job, jobs)
    base = {s: earned_at(log, 8 * 3600) for n, s, log, _ in res if n == "none"}
    for name in VARIANTS:
        rows = [(s, log, ads) for n, s, log, ads in res if n == name]
        tt = sorted(time_to(log, base[s]) / 3600 for s, log, _ in rows)
        ratio = sorted(earned_at(log, 8 * 3600) / base[s] for s, log, _ in rows)
        n_ads = sorted(len(ads) / 8 for _, _, ads in rows)
        kinds = Counter(k for _, _, ads in rows for _, k in ads)
        print(f"{name:36s} reaches no-ad 8h in {tt[2]:.1f} h (median; {tt[0]:.1f}-{tt[-1]:.1f})  "
              f"x{ratio[2]:.1f} earned at 8h  ads/h {n_ads[2]:.1f}  " + str({k: round(v / len(rows) / 8, 1) for k, v in kinds.items()}))
