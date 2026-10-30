// Simulated playtest: personas play the real QA web build through the
// stopwatch (human-like timing errors), the shop, ads and the golden clock,
// and log what a playtest facilitator would note. Not a replacement for real
// players — a way to find pacing holes and friction before they do.
//
//   make web-qa && (cd app/build/web-qa && python3 -m http.server 8713) &
//   node tools/playtest/playtest.js [persona…]      # default: all
//   OUT=/tmp/pt MINUTES=10 PARALLEL=2 node tools/playtest/playtest.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const URL = process.env.QA_URL || 'http://localhost:8713/';
const OUT = process.env.OUT || path.resolve(__dirname, '../../build/playtest');
const MINUTES = +(process.env.MINUTES || 10);
const PARALLEL = +(process.env.PARALLEL || 2);

// Timing (calibrated around docs/03: skilled σ = 30 ms, average 60 ms;
// real players are the open question): bias and sigma in real seconds; sigma shrinks from s0 to s1 with
// learning time constant `learn` rounds. distract: chance a round goes
// untapped. shopEvery: seconds between looks at the shop; shopMiss: chance
// that a shopping look costs the running round. strategy: cheapest | value
// | generators | hoard. golden: chance to catch a flying clock. ads: chance
// to take an available offer. tipRead: seconds before a tip is dismissed.
const PERSONAS = {
  kasia: { who: 'Kasia, 34, gra w tramwaju', bias: 0.02, s0: 0.10, s1: 0.065, learn: 40,
    distract: 0.08, shopEvery: 20, shopMiss: 0.4, strategy: 'cheapest', golden: 0.5, ads: 0.3, tipRead: 3 },
  marek: { who: 'Marek, 27, gracz rywalizujący', bias: 0.0, s0: 0.05, s1: 0.025, learn: 25,
    distract: 0.01, shopEvery: 30, shopMiss: 0.1, strategy: 'value', golden: 0.9, ads: 0, tipRead: 1 },
  zdzislaw: { who: 'Pan Zdzisław, 67, pierwszy raz w takiej grze', bias: 0.06, s0: 0.18, s1: 0.12, learn: 60,
    distract: 0.1, shopEvery: 45, shopMiss: 0.6, strategy: 'generators', golden: 0.2, ads: 0, tipRead: 8 },
  ola: { who: 'Ola, 15, niecierpliwa', bias: -0.03, s0: 0.08, s1: 0.05, learn: 30,
    distract: 0.05, shopEvery: 10, shopMiss: 0.3, strategy: 'cheapest', golden: 0.8, ads: 1, tipRead: 0.5 },
  tomek: { who: 'Tomek, 40, gra idle — wpada na chwilę', bias: 0.02, s0: 0.08, s1: 0.06, learn: 40,
    distract: 0.05, shopEvery: 15, shopMiss: 0.3, strategy: 'cheapest', golden: 0.5, ads: 1, tipRead: 2,
    sessions: [3, 'away:3600', 1.5, 'away:28800', 1.5] },
  ania: { who: 'Ania, 30, optymalizatorka, czyta wszystko', bias: 0.01, s0: 0.06, s1: 0.035, learn: 30,
    distract: 0.02, shopEvery: 25, shopMiss: 0.05, strategy: 'value', golden: 0.95, ads: 1, tipRead: 6 },
  bartek: { who: 'Bartek, 22, sceptyk, szybko się nudzi', bias: 0.02, s0: 0.09, s1: 0.06, learn: 40,
    distract: 0.15, shopEvery: 25, shopMiss: 0.5, strategy: 'hoard', golden: 0.6, ads: 0.2, tipRead: 1 },
  ewa: { who: 'Ewa, 38, mama, gra z przerwami (telefon zostaje włączony)', bias: 0.02, s0: 0.09, s1: 0.06, learn: 40,
    distract: 0.05, shopEvery: 20, shopMiss: 0.4, strategy: 'cheapest', golden: 0.5, ads: 0.5, tipRead: 2,
    sessions: [2, 'idle:150', 2, 'idle:150', 2] },
};

const rnd = (() => { let s = 12345; return () => (s = (s * 16807) % 2147483647) / 2147483647; })();
const gauss = () => Math.sqrt(-2 * Math.log(rnd() + 1e-12)) * Math.cos(2 * Math.PI * rnd());
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function play(browser, key) {
  const P = PERSONAS[key];
  const page = await browser.newPage({ viewport: { width: 390, height: 844 }, isMobile: true, hasTouch: true, locale: 'pl-PL' });
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  const q = (f, a) => page.evaluate(f, a);
  const state = async () => JSON.parse(await q(() => window.hit10Qa.state()));
  await page.goto(URL);
  await page.waitForFunction(() => window.hit10Qa, null, { timeout: 30000 });
  await q(() => window.hit10Qa.wipe()); await page.reload();
  await page.waitForFunction(() => window.hit10Qa, null, { timeout: 30000 });
  await sleep(1000);

  const log = { persona: key, who: P.who, events: [], samples: [], purchases: [], errors };
  const t0 = Date.now();
  const now = () => (Date.now() - t0) / 1000;
  const ev = (what, extra = {}) => log.events.push({ t: +now().toFixed(1), what, ...extra });
  let rounds = 0, lastRoundSeen = -1, tappedRound = -1, lastShop = 0, lastSample = 0, tipSince = null;
  let noTapRun = 0, bestCombo = 0, comboBreaks = 0, lastCombo = 0;
  let waitStart = null, longestWait = 0; // nothing affordable in the shop
  const firsts = {};
  const shotAt = new Set([60, 300, 590]);

  // Sessions: numbers are minutes of play; 'away:N' leaves the app for N s
  // (closed: offline income); 'idle:N' puts the phone down with the app on.
  const plan = P.sessions || [MINUTES];
  for (const step of plan) {
    if (typeof step === 'string') {
      const [kind, secs] = step.split(':');
      if (kind === 'away') {
        await q((s) => window.hit10Qa.awayFor(s), +secs); await sleep(1500);
        const s = await state();
        ev('back after ' + Math.round(secs / 60) + ' min away', { offline: Math.round(s.pendingOffline || 0) });
        if (s.pendingOffline) {
          const ads = JSON.parse(await q(() => window.hit10Qa.ads()));
          if (ads.includes('offline') && rnd() < P.ads) { await q(() => window.hit10Qa.watchAd('offline')); ev('watched ad: offline x2'); }
          else await q(() => window.hit10Qa.collectOffline());
        }
      } else {
        const before = await state();
        ev('phone down, app open', { secs: +secs });
        await sleep(+secs * 1000);
        const after = await state();
        ev('phone back', { roundsMissed: after.rounds - before.rounds, comboBefore: before.combo, comboAfter: after.combo });
      }
      continue;
    }
    const end = now() + step * 60;
    while (now() < end) {
      const s = await state();
      if (s.rounds !== lastRoundSeen) {
        // A round just finished: note how it went.
        if (lastRoundSeen >= 0) {
          rounds++;
          log.rounds = log.rounds || [];
          log.rounds.push([+now().toFixed(1), s.lastError == null ? null : +s.lastError.toFixed(3)]);
          if (s.combo < lastCombo && lastCombo >= 3) { comboBreaks++; ev('combo lost', { from: lastCombo }); }
        }
        lastRoundSeen = s.rounds;
      }
      bestCombo = Math.max(bestCombo, s.combo); lastCombo = s.combo;
      // Tutorial: the persona reads, then moves on.
      if (s.tutorial === 'grandpaInfo') {
        await sleep(P.tipRead * 1000); await q(() => window.hit10Qa.setup(JSON.stringify({ tutorialDone: true })));
        ev('tutorial finished');
      }
      if (s.tip) {
        if (tipSince === null) { tipSince = now(); ev('tip shown', { tip: s.tip }); }
        else if (now() - tipSince > P.tipRead) { await q(() => window.hit10Qa.dismissTip()); tipSince = null; }
      }
      // Golden clock.
      if (s.goldenVisible > 0 && !log._goldenSeen) {
        log._goldenSeen = true;
        if (rnd() < P.golden) { await sleep(600 + rnd() * 1200); await q(() => window.hit10Qa.catchGolden()); ev('caught golden clock'); }
        else ev('missed golden clock');
      }
      if (s.goldenVisible <= 0) log._goldenSeen = false;
      // The stopwatch: start a round if waiting; tap once per running round.
      if (s.phase === 'waiting') await q(() => window.hit10Qa.tapNow());
      // Rounds are told apart by their start time: a skipped round (no
      // touch) doesn't count in s.rounds.
      if (s.phase === 'running' && tappedRound !== s.roundStart) {
        tappedRound = s.roundStart;
        let skip = rnd() < P.distract;
        // Shopping now pulls the eyes off the dial.
        if (now() - lastShop >= P.shopEvery) {
          lastShop = now();
          if (rnd() < P.shopMiss) skip = true;
          const shop = JSON.parse(await q(() => window.hit10Qa.shop()));
          const bought = await shopFor(q, P, shop, s);
          for (const b of bought) {
            log.purchases.push({ t: +now().toFixed(1), ...b });
            const k = b.kind + ':' + b.id;
            if (!firsts[k]) { firsts[k] = now(); ev('first ' + b.kind + ' ' + b.id, { cost: Math.round(b.cost) }); }
          }
          const cheapest = Math.min(...shop.map((i) => i.cost));
          const s2 = await state();
          if (cheapest > s2.tiki) { if (waitStart === null) waitStart = now(); }
          else if (waitStart !== null) { longestWait = Math.max(longestWait, now() - waitStart); waitStart = null; }
          // Ads.
          const ads = JSON.parse(await q(() => window.hit10Qa.ads()));
          for (const a of ads) {
            if (a === 'offline' || a === 'rescue') continue;
            if (rnd() < P.ads * 0.5) { await q((o) => window.hit10Qa.watchAd(o), a); ev('watched ad: ' + a); }
          }
        }
        if (skip) log.skipped = (log.skipped || 0) + 1;
        if (!skip) {
          const sigma = P.s1 + (P.s0 - P.s1) * Math.exp(-rounds / P.learn);
          const off = P.bias + sigma * gauss();
          await q(([t, o]) => window.hit10Qa.tapAt(t, o), [5.0, off]);
        }
      }
      // Combo rescue offer right after a big loss.
      const ads = s.phase === 'result' ? JSON.parse(await q(() => window.hit10Qa.ads())) : [];
      if (ads.includes('rescue') && rnd() < P.ads) { await q(() => window.hit10Qa.watchAd('rescue')); ev('watched ad: rescue'); }
      if (now() - lastSample >= 30) {
        lastSample = now();
        log.samples.push({ t: Math.round(now()), tiki: s.tiki, passive: s.passive, rounds: s.rounds,
          byTier: s.byTier, combo: s.combo, owned: s.owned, skills: s.skills, achievements: s.achievements });
      }
      for (const at of shotAt) {
        if (now() >= at) { shotAt.delete(at); await page.screenshot({ path: path.join(OUT, `${key}-${at}s.png`) }); }
      }
      await sleep(150);
    }
  }
  if (waitStart !== null) longestWait = Math.max(longestWait, now() - waitStart);
  const s = await state();
  delete log._goldenSeen;
  log.summary = {
    playedMin: +(now() / 60).toFixed(1), rounds: s.rounds, byTier: s.byTier, tiki: s.tiki, passive: s.passive,
    owned: s.owned, skills: s.skills, upgrades: s.upgrades, achievements: s.achievements,
    goldenCaught: s.goldenCaught, bestCombo, comboBreaks, longestNothingToBuySec: Math.round(longestWait),
    purchases: log.purchases.length, skipped: log.skipped || 0,
  };
  await page.screenshot({ path: path.join(OUT, `${key}-end.png`) });
  fs.writeFileSync(path.join(OUT, `${key}.json`), JSON.stringify(log, null, 1));
  await page.close();
  console.log(key, JSON.stringify(log.summary));
}

/// One look at the shop: what this persona buys.
async function shopFor(q, P, shop, s) {
  const bought = [];
  let tiki = s.tiki;
  const pick = () => {
    const can = shop.filter((i) => i.cost <= tiki && !(P.strategy === 'generators' && i.kind === 'skill'));
    if (!can.length) return null;
    if (P.strategy === 'hoard') {
      const big = can.filter((i) => i.cost * 3 <= tiki);
      return big.sort((a, b) => b.cost - a.cost)[0] || null;
    }
    if (P.strategy === 'value') {
      const pref = (i) => ({ upg: 0, syn: 1, skill: 2, gen: 3 }[i.kind]);
      return can.sort((a, b) => pref(a) - pref(b) || b.cost - a.cost)[0];
    }
    return can.sort((a, b) => a.cost - b.cost)[0];
  };
  for (let n = 0; n < 6; n++) {
    const it = pick();
    if (!it) break;
    const r = await q(([k, id]) => window.hit10Qa.buyAny(k, id), [it.kind, it.id]);
    if (r !== 'ok') break;
    bought.push(it);
    tiki -= it.cost;
    shop = JSON.parse(await q(() => window.hit10Qa.shop()));
  }
  return bought;
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const keys = process.argv.slice(2).length ? process.argv.slice(2) : Object.keys(PERSONAS);
  const browser = await chromium.launch();
  const queue = [...keys];
  await Promise.all(Array.from({ length: PARALLEL }, async () => {
    while (queue.length) await play(browser, queue.shift()).catch((e) => console.log('ERR', e.message));
  }));
  await browser.close();
})();
