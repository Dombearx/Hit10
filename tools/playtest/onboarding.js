// Onboarding playtest: personas start a fresh game and play through the
// tutorial and the first tips (docs/02 R-TUT-1/2) in the real QA web build.
// Logs when each coach mark shows, how long it stays, how it closes, and
// where the bubble sits against its target, the dial and the combo meter.
//
//   make web-qa && (cd app/build/web-qa && python3 -m http.server 8713) &
//   MINUTES=6 PARALLEL=4 node tools/playtest/onboarding.js [persona…]
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const URL = process.env.QA_URL || 'http://localhost:8713/';
const OUT = process.env.OUT || path.resolve(__dirname, '../../build/onboarding');
const MINUTES = +(process.env.MINUTES || 6);
const PARALLEL = +(process.env.PARALLEL || 4);

// react: s before acting on a "do this" prompt. read: s to read a bubble.
// close: chance to close a tip with × after reading (else it is ignored and
// the persona just plays on). follow: chance to do what a tip says.
const PERSONAS = {
  kasia: { who: 'Kasia, 34, tramwaj', bias: 0.02, s0: 0.10, s1: 0.065, learn: 40, distract: 0.08,
    shopEvery: 20, shopMiss: 0.4, react: 2, read: 3, close: 0.5, follow: 0.6, golden: 0.5 },
  marek: { who: 'Marek, 27, rywalizujący', bias: 0.0, s0: 0.05, s1: 0.025, learn: 25, distract: 0.01,
    shopEvery: 30, shopMiss: 0.1, react: 1, read: 1, close: 0.9, follow: 0.5, golden: 0.9 },
  zdzislaw: { who: 'Pan Zdzisław, 67, pierwszy raz', bias: 0.06, s0: 0.18, s1: 0.12, learn: 60, distract: 0.1,
    shopEvery: 45, shopMiss: 0.6, react: 5, read: 9, close: 0.2, follow: 0.9, golden: 0.2 },
  ola: { who: 'Ola, 15, niecierpliwa', bias: -0.03, s0: 0.08, s1: 0.05, learn: 30, distract: 0.05,
    shopEvery: 10, shopMiss: 0.3, react: 0.5, read: 0.5, close: 1, follow: 0.3, golden: 0.8 },
  ania: { who: 'Ania, 30, czyta wszystko', bias: 0.01, s0: 0.06, s1: 0.035, learn: 30, distract: 0.02,
    shopEvery: 25, shopMiss: 0.05, react: 2, read: 5, close: 0.3, follow: 1, golden: 0.95 },
  bartek: { who: 'Bartek, 22, nie czyta dymków', bias: 0.02, s0: 0.09, s1: 0.06, learn: 40, distract: 0.15,
    shopEvery: 25, shopMiss: 0.5, react: 4, read: 0.3, close: 0, follow: 0.1, golden: 0.6 },
};

const rnd = (() => { let s = 4242; return () => (s = (s * 16807) % 2147483647) / 2147483647; })();
const gauss = () => Math.sqrt(-2 * Math.log(rnd() + 1e-12)) * Math.cos(2 * Math.PI * rnd());
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const overlap = (a, b) => a && b && a.l < b.l + b.w && b.l < a.l + a.w && a.t < b.t + b.h && b.t < a.t + a.h;

async function play(browser, key) {
  const P = PERSONAS[key];
  const page = await browser.newPage({ viewport: { width: 360, height: 740 }, isMobile: true, hasTouch: true, locale: 'pl-PL' });
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  const q = (f, a) => page.evaluate(f, a);
  await page.goto(URL);
  await page.waitForFunction(() => window.hit10Qa, null, { timeout: 60000 });
  await q(() => window.hit10Qa.wipe()); await page.reload();
  await page.waitForFunction(() => window.hit10Qa, null, { timeout: 60000 });
  await sleep(1500);
  const state = async () => JSON.parse(await q(() => window.hit10Qa.state()));
  const coach = async () => JSON.parse(await q(() => window.hit10Qa.coach()));

  const t0 = Date.now();
  const now = () => (Date.now() - t0) / 1000;
  const marks = []; // {id, shown, play, closed, how, layout}
  const events = [];
  const ev = (what, extra = {}) => events.push({ t: +now().toFixed(1), what, ...extra });
  let cur = null, measured = false, acted = false, decided = false;
  let tappedRound = -1, lastShop = 0, rounds = 0, lastRounds = -1;

  const end = MINUTES * 60;
  while (now() < end) {
    const s = await state();
    const c = await coach();
    if (s.rounds !== lastRounds) { if (lastRounds >= 0) rounds++; lastRounds = s.rounds; }
    // ------------------------------------------------ which mark is up --
    const id = c.step !== 'done' ? 'tutorial-' + c.step : c.tip ? 'tip-' + c.tip : null;
    if (id !== (cur && cur.id)) {
      if (cur) {
        cur.closed = +now().toFixed(1);
        cur.secs = +(cur.closed - cur.shown).toFixed(1);
        cur.playSecs = +(c.playSeconds - cur.play).toFixed(1);
        cur.how = cur.how || (acted ? 'after action' : 'by itself');
      }
      cur = id ? { id, shown: +now().toFixed(1), play: c.playSeconds } : null;
      if (cur) marks.push(cur);
      measured = false; acted = false; decided = false;
    }
    if (cur && !measured && now() - cur.shown > 0.7) {
      measured = true;
      const b = c.bubble, t = c.target, a = c.arena;
      // The dial: a circle in the arena's middle.
      const dial = a && { l: a.l + a.w / 2 - Math.min(a.w, a.h) * 0.36, t: a.t + a.h / 2 - Math.min(a.w, a.h) * 0.36,
        w: Math.min(a.w, a.h) * 0.72, h: Math.min(a.w, a.h) * 0.72 };
      const pinned = (c.pinnedTo || '').replace(/.*coach-([\w-]+).*/, '$1');
      cur.layout = {
        pinnedTo: pinned || null,
        onScreen: !!b && b.l >= 0 && b.t >= 0 && b.l + b.w <= 360 && b.t + b.h <= 740,
        coversTarget: pinned !== 'arena' && overlap(b, t),
        gapToTarget: b && t && pinned !== 'arena' ? Math.round(b.t > t.t ? b.t - (t.t + t.h) : t.t - (b.t + b.h)) : null,
        coversDial: overlap(b, dial),
        coversCombo: overlap(b, c.combo),
        bubble: b && { t: Math.round(b.t), h: Math.round(b.h) },
      };
      await page.screenshot({ path: path.join(OUT, `${key}-${String(marks.length).padStart(2, '0')}-${cur.id}.png`) });
    }
    // --------------------------------------------- reacting to a mark --
    if (cur && measured && !decided && now() - cur.shown > P.read) {
      decided = true;
      if (cur.id === 'tutorial-buyGrandpa') {
        await sleep(P.react * 1000);
        if ((await q(([k, i]) => window.hit10Qa.buyAny(k, i), ['gen', 'grandpa'])) === 'ok') { acted = true; ev('bought grandpa (prompted)'); }
      } else if (cur.id === 'tutorial-grandpaInfo') {
        if (rnd() < P.close) { await q(() => window.hit10Qa.tutorialOk()); cur.how = 'OK'; }
      } else if (cur.id.startsWith('tip-')) {
        const tip = cur.id.slice(4);
        if (rnd() < P.follow && tip === 'skills') { await q(() => window.hit10Qa.openSkills()); acted = true; ev('opened skills (prompted)'); }
        else if (rnd() < P.follow && tip === 'upgrade') {
          const shop = JSON.parse(await q(() => window.hit10Qa.shop()));
          const u = shop.filter((i) => i.kind === 'upg' || i.kind === 'syn').sort((a, b) => a.cost - b.cost)[0];
          if (u && u.cost <= s.tiki) { await q(([k, i]) => window.hit10Qa.buyAny(k, i), [u.kind, u.id]); acted = true; ev('bought upgrade (prompted)'); }
        } else if (rnd() < P.close) { await q(() => window.hit10Qa.dismissTip()); cur.how = '×'; }
      }
    }
    // -------------------------------------------------------- golden --
    if (s.goldenVisible > 0 && !play._g) {
      play._g = true;
      if (rnd() < P.golden) { await sleep(700 + rnd() * 1200); await q(() => window.hit10Qa.catchGolden()); ev('caught golden'); }
    }
    if (s.goldenVisible <= 0) play._g = false;
    // ---------------------------------------------------------- rounds --
    if (s.phase === 'waiting') await q(() => window.hit10Qa.tapNow());
    if (s.phase === 'running' && tappedRound !== s.roundStart) {
      tappedRound = s.roundStart;
      let skip = rnd() < P.distract;
      // Shop looks only after the tutorial (before it, the prompt leads).
      if (s.tutorial === 'done' && now() - lastShop >= P.shopEvery) {
        lastShop = now();
        if (rnd() < P.shopMiss) skip = true;
        let tiki = s.tiki;
        for (let n = 0; n < 4; n++) {
          const shop = JSON.parse(await q(() => window.hit10Qa.shop()));
          const it = shop.filter((i) => i.cost <= tiki).sort((a, b) => a.cost - b.cost)[0];
          if (!it || (await q(([k, i]) => window.hit10Qa.buyAny(k, i), [it.kind, it.id])) !== 'ok') break;
          tiki -= it.cost;
          ev('bought ' + it.kind + ' ' + it.id);
        }
      }
      if (!skip) {
        const sigma = P.s1 + (P.s0 - P.s1) * Math.exp(-rounds / P.learn);
        await q(([t, o]) => window.hit10Qa.tapAt(t, o), [5.0, P.bias + sigma * gauss()]);
      }
    }
    await sleep(150);
  }
  if (cur && !cur.closed) { cur.closed = null; cur.how = 'still open at the end'; }
  const s = await state();
  const out = { persona: key, who: P.who, marks, events, errors,
    end: { rounds: s.rounds, tiki: Math.round(s.tiki), passive: s.passive, owned: s.owned, skills: s.skills, tutorial: s.tutorial } };
  fs.writeFileSync(path.join(OUT, `${key}.json`), JSON.stringify(out, null, 1));
  await page.close();
  console.log(`\n== ${key}: ${P.who}`);
  for (const m of marks) {
    const L = m.layout || {};
    console.log(`  ${String(m.shown).padStart(6)}s  ${m.id.padEnd(22)} ${m.secs == null ? '   –  ' : String(m.secs).padStart(5) + 's'}  ${String(m.how || '').padEnd(14)}`
      + ` pin=${L.pinnedTo} gap=${L.gapToTarget} ${L.onScreen ? '' : 'OFFSCREEN '}${L.coversTarget ? 'COVERS-TARGET ' : ''}${L.coversDial ? 'covers-dial ' : ''}${L.coversCombo ? 'covers-combo' : ''}`);
  }
  if (errors.length) console.log('  errors:', errors.slice(0, 3));
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
