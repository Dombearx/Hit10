#!/usr/bin/env python3
"""Generate game art via RunPod Public Endpoints or OpenRouter (see docs/10-grafika-runpod.md).

Usage: python3 tools/art/generate.py [--only ID[,ID]] [--model MODEL[,MODEL]] [--spec FILE] [--dry-run]
MODEL: qwen | qwen-edit | zimage (RunPod, RUNPOD_API_KEY) or or:<openrouter-model-id>,
e.g. or:google/gemini-3.1-flash-image (OpenRouter, OPENROUTER_API_KEY).
Keys come from the environment or repo-root .env. Specs: prompts.json
(icons), story_prompts.json (story illustrations, 16:9).
Raw results go to tools/art/out/<model>/<id>_s<seed>.png (+ .json with metadata);
for OpenRouter <model> is the id with "/" replaced by "_", e.g. out/or_google_gemini-3.1-flash-image/.
"""
import argparse, base64, json, os, pathlib, sys, urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = ROOT / "tools" / "art"
REF_BASE = "https://raw.githubusercontent.com/Dombearx/Hit10/main/app/assets/art/"

def full(s, c):
    """Style, the cast (story scenes), then the item's own prompt."""
    cast = c.get("characters")
    return c["style"] + ". " + (cast + ". " if cast else "") + s["prompt"]


MODELS = {
    # endpoint id, builder(spec, cfg) -> input dict
    "qwen-edit": ("qwen-image-edit-2511", lambda s, c: {
        "prompt": full(s, c) if not s.get("edit_prompt") else s["edit_prompt"],
        "images": [REF_BASE + r + ".png" for r in s.get("refs", c.get("refs", []))][:3],
        "size": c.get("size", "1024*1024"), "seed": s["seed"], "output_format": "png"}),
    "qwen": ("qwen-image-t2i", lambda s, c: {
        "prompt": full(s, c), "negative_prompt": c.get("negative", ""),
        "size": c.get("size", "1024*1024"), "seed": s["seed"], "enable_safety_checker": True}),
    "zimage": ("z-image-turbo", lambda s, c: {
        "prompt": full(s, c), "size": c.get("size", "1024*1024"),
        "seed": s["seed"], "output_format": "png", "enable_safety_checker": True}),
}


ASPECTS = ["1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"]


def aspect(c):
    """OpenRouter takes an aspect ratio, not a size: explicit or nearest to cfg size."""
    if c.get("aspect_ratio"):
        return c["aspect_ratio"]
    w, h = (int(x) for x in c.get("size", "1024*1024").split("*"))
    return min(ASPECTS, key=lambda a: abs(int(a.split(":")[0]) / int(a.split(":")[1]) - w / h))


def openrouter_payload(model, s, c):
    """Chat-completions request with image output; refs (if any) go in as image URLs."""
    text = s["edit_prompt"] if s.get("edit_prompt") and s.get("refs") else full(s, c)
    if c.get("negative"):
        text += ". Avoid: " + c["negative"]
    content = [{"type": "text", "text": text}] + [
        {"type": "image_url", "image_url": {"url": REF_BASE + r + ".png"}}
        for r in s.get("refs", [])][:3]
    p = {"model": model, "messages": [{"role": "user", "content": content}],
         "modalities": ["image", "text"], "image_config": {"aspect_ratio": aspect(c)}}
    if s["seed"] != -1:
        p["seed"] = s["seed"]
    return p


def api_key(name="RUNPOD_API_KEY"):
    k = os.environ.get(name)
    if not k and (ROOT / ".env").exists():
        for line in (ROOT / ".env").read_text().splitlines():
            if line.startswith(name + "="):
                k = line.split("=", 1)[1].strip().strip("'\"")
    k = (k or "").strip().strip("'\"")
    if not k:
        sys.exit(f"{name} not set")
    return k


def post_openrouter(payload, key):
    """Returns (png bytes or None, cost, generation id, error)."""
    req = urllib.request.Request(
        "https://openrouter.ai/api/v1/chat/completions", data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json",
                 "X-Title": "Hit10 art"})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            res = json.load(r)
    except urllib.error.HTTPError as e:
        return None, 0, None, f"HTTP {e.code} {e.read().decode()[:500]}"
    if res.get("error"):
        return None, 0, res.get("id"), str(res["error"])[:500]
    msg = (res.get("choices") or [{}])[0].get("message") or {}
    imgs = msg.get("images") or []
    if not imgs:
        return None, 0, res.get("id"), "no image in response: " + str(msg.get("content"))[:300]
    url = imgs[0]["image_url"]["url"]
    return base64.b64decode(url.split(",", 1)[1]), (res.get("usage") or {}).get("cost", 0), res.get("id"), None


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
    ap.add_argument("--spec", default="prompts.json")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    cfg = json.loads((HERE / a.spec).read_text())
    only = set(a.only.split(",")) if a.only else None
    models = a.model.split(",")
    keys = {} if a.dry_run else {
        n: api_key(n) for n in {"OPENROUTER_API_KEY" if m.startswith("or:") else "RUNPOD_API_KEY"
                                for m in models}}
    total = 0.0
    for spec in cfg["items"]:
        if only and spec["id"] not in only:
            continue
        for m, seed in [(m, sd) for m in models for sd in spec.get("seeds", [spec.get("seed", -1)])]:
            if m.startswith("or:"):
                payload = openrouter_payload(m[3:], dict(spec, seed=seed), cfg)
                out = HERE / "out" / m.replace(":", "_").replace("/", "_") / f"{spec['id']}_s{seed}.png"
            else:
                endpoint, build = MODELS[m]
                payload = build(dict(spec, seed=seed), cfg)
                out = HERE / "out" / m / f"{spec['id']}_s{seed}.png"
            if a.dry_run:
                print(m, json.dumps(payload)); continue
            if out.exists():
                print("skip (exists)", out.relative_to(ROOT)); continue
            if m.startswith("or:"):
                png, cost, gen, err = post_openrouter(payload, keys["OPENROUTER_API_KEY"])
                if err:
                    print("FAIL", m, spec["id"], err, file=sys.stderr); continue
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(png)
                total += cost or 0
                out.with_suffix(".json").write_text(json.dumps(
                    {"model": m, "endpoint": "openrouter", "input": payload, "cost": cost,
                     "job": gen}, indent=2))
                print(f"ok {m} {spec['id']} ${cost} -> {out.relative_to(ROOT)}")
                continue
            res = post(endpoint, payload, keys["RUNPOD_API_KEY"])
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
