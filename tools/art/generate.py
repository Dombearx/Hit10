#!/usr/bin/env python3
"""Generate game art via RunPod Public Endpoints (see docs/10-grafika-runpod.md).

Usage: python3 tools/art/generate.py [--only ID[,ID]] [--model MODEL[,MODEL]] [--dry-run]
Reads RUNPOD_API_KEY from the environment (or repo-root .env). Specs: prompts.json.
Raw results go to tools/art/out/<model>/<id>_s<seed>.png (+ .json with metadata).
"""
import argparse, json, os, pathlib, sys, urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = ROOT / "tools" / "art"
REF_BASE = "https://raw.githubusercontent.com/Dombearx/Hit10/main/app/assets/emoji/"

MODELS = {
    # endpoint id, builder(spec, cfg) -> input dict
    "qwen-edit": ("qwen-image-edit-2511", lambda s, c: {
        "prompt": c["style"] + ". " + s["prompt"] if not s.get("edit_prompt") else s["edit_prompt"],
        "images": [REF_BASE + r + ".png" for r in s.get("refs", c.get("refs", []))][:3],
        "size": "1024*1024", "seed": s["seed"], "output_format": "png"}),
    "qwen": ("qwen-image-t2i", lambda s, c: {
        "prompt": c["style"] + ". " + s["prompt"], "negative_prompt": c.get("negative", ""),
        "size": "1024*1024", "seed": s["seed"], "enable_safety_checker": True}),
    "zimage": ("z-image-turbo", lambda s, c: {
        "prompt": c["style"] + ". " + s["prompt"], "size": "1024*1024",
        "seed": s["seed"], "output_format": "png", "enable_safety_checker": True}),
}


def api_key():
    k = os.environ.get("RUNPOD_API_KEY")
    if not k and (ROOT / ".env").exists():
        for line in (ROOT / ".env").read_text().splitlines():
            if line.startswith("RUNPOD_API_KEY="):
                k = line.split("=", 1)[1].strip()
    if not k:
        sys.exit("RUNPOD_API_KEY not set")
    return k


def post(endpoint, payload, key):
    req = urllib.request.Request(
        f"https://api.runpod.ai/v2/{endpoint}/runsync",
        data=json.dumps({"input": payload}).encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        return {"status": f"HTTP {e.code}", "error": e.read().decode()[:500]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only")
    ap.add_argument("--model", default="qwen")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    cfg = json.loads((HERE / "prompts.json").read_text())
    only = set(a.only.split(",")) if a.only else None
    key = None if a.dry_run else api_key()
    total = 0.0
    for spec in cfg["items"]:
        if only and spec["id"] not in only:
            continue
        for m, seed in [(m, sd) for m in a.model.split(",") for sd in spec.get("seeds", [spec.get("seed", -1)])]:
            endpoint, build = MODELS[m]
            payload = build(dict(spec, seed=seed), cfg)
            out = HERE / "out" / m / f"{spec['id']}_s{seed}.png"
            if a.dry_run:
                print(m, json.dumps(payload)); continue
            if out.exists():
                print("skip (exists)", out.relative_to(ROOT)); continue
            res = post(endpoint, payload, key)
            o = res.get("output") or {}
            if res.get("status") != "COMPLETED" or not o.get("result"):
                print("FAIL", m, spec["id"], res.get("status"), res.get("error"), file=sys.stderr)
                continue
            out.parent.mkdir(parents=True, exist_ok=True)
            urllib.request.urlretrieve(o["result"], out)
            total += o.get("cost", 0)
            out.with_suffix(".json").write_text(json.dumps(
                {"model": m, "endpoint": endpoint, "input": payload, "cost": o.get("cost"),
                 "job": res.get("id")}, indent=2))
            print(f"ok {m} {spec['id']} ${o.get('cost')} -> {out.relative_to(ROOT)}")
    print(f"total cost: ${total:.4f}")


if __name__ == "__main__":
    main()
