// Store graphics (docs/04 U-28): the 1024×500 feature graphic and phone
// screenshots with PL/EN captions, from the QA web build.
//
//   make web-qa && (cd app/build/web-qa && python3 -m http.server 8713) &
//   node tools/store/render.js
//
// Output: store/feature-{pl,en}.png (1024×500), store/screens/{pl,en}/N.png
// (phone, 1080×1920), store/screens-tablet7/{pl,en}/N.png (1200×1920) and
// store/screens-tablet10/{pl,en}/N.png (1600×2560).
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../..');
const out = path.join(root, 'store');
const font = (f) => fs.readFileSync(path.join(root, 'app/assets/fonts', f)).toString('base64');
const emoji = (n) => 'data:image/png;base64,' +
  fs.readFileSync(path.join(root, 'app/assets', n.includes('/') ? n : 'emoji/' + n) + '.png').toString('base64');
const fonts = `
  @font-face { font-family: Display; src: url(data:font/ttf;base64,${font('PaytoneOne-Regular.ttf')}); }
  @font-face { font-family: Body; font-weight: 800; src: url(data:font/ttf;base64,${font('Nunito-800.ttf')}); }`;
const url = process.env.QA_URL || 'http://localhost:8713/';

// One headline per screenshot (Play shows them as thumbnails: short, large,
// one idea each). Order matters: the first three appear in search results.
const captions = {
  pl: ['Zatrzymaj stoper dokładnie na 5.00', 'Złap Złotą Sekundę: Szał ×7',
       '14 zegarów: od dziadka po maszynę czasu', 'Umiejętności zmieniają każdą rundę',
       'Zegary zarabiają, gdy Cię nie ma', '149 osiągnięć do zdobycia',
       'Cofnij czas i wróć silniejszy'],
  en: ['Stop the watch at exactly 5.00', 'Catch the Golden Second: Frenzy ×7',
       '14 clocks, from grandpa to a time machine', 'Skills change every round',
       'Your clocks earn while you’re away', '149 achievements to unlock',
       'Rewind time, come back stronger'],
};
const taglines = { pl: 'Zatrzymasz stoper na 5.00?', en: 'Can you stop it at 5.00?' };

async function featureGraphic(browser, lang) {
  const p = await browser.newPage({ viewport: { width: 1024, height: 500 } });
  const cards = ['art/grandpa', 'art/grandma', 'art/cuckoo', 'art/watchmaker', 'art/atomic', 'art/timeMachine', 'art/schrodinger']
    .map((n, i) => `<div class="card" style="background:${['#FFD36E','#FFB38A','#9BE7C4','#FFC9DE','#D7C4FF','#FFC2A8','#E2D2FF'][i]}"><img src="${emoji(n)}"></div>`).join('');
  const icon = 'data:image/png;base64,' + fs.readFileSync(path.join(out, 'icon-512.png')).toString('base64');
  // Key content kept away from the edges: Play may crop or overlay them.
  await p.setContent(`<html><head><style>${fonts}
    body { margin:0; width:1024px; height:500px; overflow:hidden; color:#2B2D42;
           background: linear-gradient(#FFD36E, #FF8A5B); font-family: Display; }
    .icon { position:absolute; left:90px; top:64px; width:220px; height:220px; border-radius:48px;
            box-shadow: 0 10px 0 rgba(43,45,66,.25); }
    h1 { position:absolute; left:350px; top:36px; margin:0; font-size:124px; font-weight:400; }
    .tag { position:absolute; left:354px; top:196px; font-size:46px; }
    .row { position:absolute; left:60px; right:60px; bottom:44px; display:flex; gap:22px; justify-content:center; }
    .card { width:100px; height:100px; border-radius:22px; border:4px solid #2B2D42; position:relative;
            box-shadow: 0 6px 0 rgba(43,45,66,.3); overflow:hidden; }
    .card::after { content:''; position:absolute; left:0; right:0; top:0; height:40%; background:rgba(255,255,255,.3); }
    .card img { position:absolute; left:16px; top:16px; width:68px; height:68px; }
  </style></head><body>
    <img class="icon" src="${icon}"><h1>Hit5</h1><div class="tag">${taglines[lang]}</div>
    <div class="row">${cards}</div></body></html>`);
  await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: path.join(out, `feature-${lang}.png`) });
  await p.close();
}

// Devices Play takes screenshots for. The game is portrait-only and keeps a
// phone-width column on tablets (M-9), so tablet shots show exactly that.
const devices = {
  phone:    { vp: [390, 780],  canvas: [1080, 1920], dir: 'screens',          bezel: 'phone' },
  tablet7:  { vp: [600, 960],  canvas: [1200, 1920], dir: 'screens-tablet7',  bezel: 'tablet' },
  tablet10: { vp: [800, 1280], canvas: [1600, 2560], dir: 'screens-tablet10', bezel: 'tablet' },
};

async function scenes(browser, lang, device) {
  const [W, H] = device.vp;
  const p = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 2,
    isMobile: true, hasTouch: true, locale: lang === 'pl' ? 'pl-PL' : 'en-US' });
  // Flutter's accessibility tree gives buttons and texts DOM boxes to find
  // them by label, so the same script works on every screen size.
  const ready = async () => {
    await p.waitForFunction(() => window.hit10Qa, null, { timeout: 20000 });
    await p.waitForTimeout(800);
    await p.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await p.waitForTimeout(500);
  };
  const tapText = async (text) => {
    const at = await p.evaluate((t) => {
      const e = [...document.querySelectorAll('flt-semantics')]
        .filter((e) => (e.getAttribute('aria-label') || e.textContent || '').trim() === t).pop();
      if (!e) return null;
      const b = e.getBoundingClientRect();
      return [b.x + b.width / 2, b.y + b.height / 2];
    }, text);
    if (at) await p.touchscreen.tap(at[0], at[1]);
    return at != null;
  };
  // The daily-bonus and offline sheets expose only their icon to the
  // accessibility tree: tap down the middle below the icon until the sheet
  // is gone. Their main button comes first (the ad offer sits below it).
  const dialogIcon = () => p.evaluate(() => {
    const e = document.querySelector('flt-semantics[role="dialog"] flt-semantics[role="img"]');
    if (!e) return null;
    const b = e.getBoundingClientRect();
    return b.y + b.height / 2;
  });
  const closeDialog = async () => {
    const y = await dialogIcon();
    if (y == null) return;
    for (let d = 120; d <= 420; d += 16) {
      await p.touchscreen.tap(W / 2, y + d); await p.waitForTimeout(250);
      if (await dialogIcon() == null) return;
    }
  };
  // The header's icon buttons, in the centred column (max 560 wide).
  const x0 = Math.max(0, (W - 560) / 2), cw = Math.min(W, 560);
  const trophy = [x0 + 29, 25], paradox = [x0 + cw - 29, 25];
  const t = (pl, en) => (lang === 'pl' ? pl : en);
  const q = (f, a) => p.evaluate(f, a);
  await p.goto(url); await ready();
  await q(() => window.hit10Qa.wipe()); await p.reload(); await ready();
  // A mid-game save: a dozen clocks, some skills, numbers a player sees
  // after a few days (billions, not the late game's "aa").
  await q(() => { const h = window.hit10Qa;
    h.setup(JSON.stringify({ tutorialDone: true, playSeconds: 4000, perfects: 300,
      tipsSeen: ['golden', 'prestige', 'skills', 'combo', 'notifyAsked', 'modes'] }));
    h.grant(5e13);
    for (const [g, n] of [['grandpa', 90], ['grandma', 75], ['cuckoo', 60], ['metronome', 50], ['watchmaker', 40],
      ['sprintJudge', 30], ['stationClock', 25], ['quartz', 20], ['atomic', 15], ['gps', 10], ['pulsar', 6],
      ['timeMachine', 3], ['schrodinger', 1]]) h.buy(g, n);
    h.setSkill('power', 4); h.setSkill('combo', 3); h.setSkill('bulletTime', 2); h.setSkill('wideEye', 2);
    h.previewSeason(''); // store screenshots show no seasonal event
  });
  // Save and reload: the dozens of achievement and milestone toasts the
  // purchases queued are gone, the unlocks stay.
  await p.waitForTimeout(1500);
  await q(() => window.hit10Qa.save()); await p.waitForTimeout(500);
  await p.reload(); await ready();
  await q(() => window.hit10Qa.previewSeason('')); await p.waitForTimeout(2000);
  // The reload counts as a new day: collect the daily bonus sheet.
  await closeDialog(); await p.waitForTimeout(3000);
  const shots = [];
  const snap = async () => shots.push(await p.screenshot());
  const round = async (target, wait) => {
    // A tap right after a result is ignored for a moment: tap until it runs.
    await p.waitForFunction(() => {
      const s = JSON.parse(window.hit10Qa.state());
      if (s.phase !== 'running') window.hit10Qa.tapNow();
      return JSON.parse(window.hit10Qa.state()).phase === 'running';
    }, null, { timeout: 10000, polling: 100 });
    await q((v) => window.hit10Qa.tapAt(v), target);
    // Freeze the moment the result appears; the next round would start
    // 0.7 s later (R-RUNDA-6), faster than a DPR-2 screenshot.
    await p.waitForFunction(() => {
      const r = JSON.parse(window.hit10Qa.state()).phase === 'result';
      if (r) window.hit10Qa.freeze(true);
      return r;
    }, null, { timeout: 30000, polling: 5 });
    await p.waitForTimeout(wait);
  };
  const thaw = () => q(() => window.hit10Qa.freeze(false));
  // A warm-up hit first: its first-PERFECT achievement toast must not end
  // up in screenshot 1.
  await round(5.0, 200); await thaw(); await p.waitForTimeout(4500);
  // 1: a PERFECT hit (retried until it is one), once the burst has settled
  // enough to see the dial; the result is frozen meanwhile.
  for (let i = 0; i < 8; i++) {
    await round(5.0, 1800);
    const s = JSON.parse(await q(() => window.hit10Qa.state()));
    if (Math.abs(s.lastError ?? 1) < 0.01) break;
    await thaw(); await p.waitForTimeout(1200);
  }
  await snap(); await thaw();
  await p.waitForTimeout(4500);
  // 2: Frenzy from the Golden Second, again retried until a PERFECT.
  await q(() => window.hit10Qa.effect('frenzy', 40)); await p.waitForTimeout(1200);
  for (let i = 0; i < 8; i++) {
    await round(5.0, 30);
    const s = JSON.parse(await q(() => window.hit10Qa.state()));
    if (Math.abs(s.lastError ?? 1) < 0.005) break;
    await thaw(); await p.waitForTimeout(1500);
  }
  await snap(); await thaw();
  await q(() => window.hit10Qa.effect('frenzy', 0));
  await p.waitForTimeout(3000);
  // 3: the shop scrolled down to the late clocks, once the self-starting
  // round has run out and the clock waits again (no dimmed arena).
  await p.waitForFunction(() => JSON.parse(window.hit10Qa.state()).phase === 'waiting',
    null, { timeout: 60000, polling: 200 });
  await p.waitForTimeout(800);
  await p.mouse.move(W / 2, H * 0.87); await p.mouse.wheel(0, 4000); await p.waitForTimeout(1200);
  await snap();
  await p.mouse.wheel(0, -4000); await p.waitForTimeout(600);
  // 4: skills tab.
  await tapText(t('Umiejętności', 'Skills')); await p.waitForTimeout(1000); await snap();
  await tapText(t('Zegary', 'Clocks')); await p.waitForTimeout(600);
  // 5: back after a night away: the offline earnings sheet.
  await q(() => window.hit10Qa.awayFor(8 * 3600)); await p.waitForTimeout(2500); await snap();
  await closeDialog(); await p.waitForTimeout(500);
  await q(() => window.hit10Qa.collectOffline()); await p.waitForTimeout(4000);
  // 6: achievements (top-left trophy).
  await p.touchscreen.tap(...trophy); await p.waitForTimeout(1500); await snap();
  await p.touchscreen.tap(W / 2, 12); await p.waitForTimeout(1000); // the barrier closes it
  // 7: the paradox sheet.
  await q(() => window.hit10Qa.setup(JSON.stringify({ earnedTotal: 2e12, shards: 40 })));
  await p.waitForTimeout(6000); // let the achievement toasts pass
  await p.touchscreen.tap(...paradox); await p.waitForTimeout(1000); await snap();
  await p.close();
  return shots;
}

async function frame(browser, shot, caption, file, device) {
  const [cw, ch] = device.canvas;
  const k = ch / 1920; // everything scales with the canvas height
  const cap = Math.round(330 * k), devH = ch - cap - Math.round(50 * k);
  const devW = Math.round(devH * device.vp[0] / device.vp[1]);
  const tablet = device.bezel === 'tablet';
  const border = Math.round((tablet ? 20 : 14) * k), radius = Math.round((tablet ? 48 : 64) * k);
  const p = await browser.newPage({ viewport: { width: cw, height: ch } });
  const img = 'data:image/png;base64,' + shot.toString('base64');
  await p.setContent(`<html><head><style>${fonts}
    body { margin:0; width:${cw}px; height:${ch}px; overflow:hidden;
           background: linear-gradient(#FFD36E, #FF8A5B); }
    .cap { position:absolute; left:${70 * k}px; right:${70 * k}px; top:0; height:${cap}px; display:flex;
           align-items:center; justify-content:center; text-align:center; color:#2B2D42;
           font-family: Display; font-size:${84 * k}px; line-height:1.08; text-wrap:balance; }
    .dev { position:absolute; left:${(cw - devW) / 2}px; top:${cap}px; width:${devW - 2 * border}px;
           height:${devH - 2 * border}px; border-radius:${radius}px; border:${border}px solid #2B2D42;
           overflow:hidden; box-shadow: 0 ${24 * k}px 0 rgba(43,45,66,.25); background:#2B2D42; }
    .dev img { width:100%; height:100%; display:block; }
  </style></head><body><div class="cap">${caption}</div>
    <div class="dev"><img src="${img}"></div></body></html>`);
  await p.evaluate(() => document.fonts.ready);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  await p.screenshot({ path: file });
  await p.close();
}

(async () => {
  // `node render.js tablet7 tablet10` renders only those devices.
  const only = process.argv.slice(2);
  const browser = await chromium.launch();
  for (const lang of ['pl', 'en']) {
    if (!only.length) await featureGraphic(browser, lang);
    for (const [name, device] of Object.entries(devices)) {
      if (only.length && !only.includes(name)) continue;
      const shots = await scenes(browser, lang, device);
      for (let i = 0; i < shots.length; i++) {
        await frame(browser, shots[i], captions[lang][i], path.join(out, device.dir, lang, `${i + 1}.png`), device);
      }
    }
  }
  await browser.close();
  console.log('store graphics written');
})();
