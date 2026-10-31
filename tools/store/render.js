// Store graphics (docs/04 U-28): the 1024×500 feature graphic and phone
// screenshots with PL/EN captions, from the QA web build.
//
//   make web-qa && (cd app/build/web-qa && python3 -m http.server 8713) &
//   node tools/store/render.js
//
// Output: store/feature-1024x500.png, store/screens/{pl,en}/N.png
// (1080×1920, Play's 9:16).
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

const captions = {
  pl: ['Zatrzymaj stoper na 5.00!', 'Zatrudnij dziadka, babcię… i Chronosa',
       'Złap złoty zegarek', 'Szał! Wszystko razy więcej', 'Ulepszenia i umiejętności',
       'Cofnij czas, wróć silniejszy'],
  en: ['Stop the watch at 5.00!', 'Hire grandpa, grandma… and Chronos',
       'Catch the golden clock', 'Frenzy! Everything multiplied', 'Upgrades and skills',
       'Rewind time, come back stronger'],
};

async function featureGraphic(browser) {
  const p = await browser.newPage({ viewport: { width: 1024, height: 500 } });
  const cards = ['art/grandpa', 'art/grandma', 'art/cuckoo', 'art/watchmaker', 'art/atomic', 'art/timeMachine', 'art/schrodinger']
    .map((n, i) => `<div class="card" style="background:${['#FFD36E','#FFB38A','#9BE7C4','#FFC9DE','#D7C4FF','#FFC2A8','#E2D2FF'][i]}"><img src="${emoji(n)}"></div>`).join('');
  const icon = 'data:image/png;base64,' + fs.readFileSync(path.join(out, 'icon-512.png')).toString('base64');
  await p.setContent(`<html><head><style>${fonts}
    body { margin:0; width:1024px; height:500px; overflow:hidden; color:#2B2D42;
           background: linear-gradient(#FFD36E, #FF8A5B); font-family: Display; }
    .icon { position:absolute; left:70px; top:70px; width:220px; height:220px; border-radius:48px;
            box-shadow: 0 10px 0 rgba(43,45,66,.25); }
    h1 { position:absolute; left:330px; top:40px; margin:0; font-size:120px; font-weight:400; }
    .tag { position:absolute; left:336px; top:200px; font-size:44px; }
    .row { position:absolute; left:60px; right:60px; bottom:40px; display:flex; gap:22px; justify-content:center; }
    .card { width:100px; height:100px; border-radius:22px; border:4px solid #2B2D42; position:relative;
            box-shadow: 0 6px 0 rgba(43,45,66,.3); overflow:hidden; }
    .card::after { content:''; position:absolute; left:0; right:0; top:0; height:40%; background:rgba(255,255,255,.3); }
    .card img { position:absolute; left:16px; top:16px; width:68px; height:68px; }
  </style></head><body>
    <img class="icon" src="${icon}"><h1>Hit5</h1><div class="tag">5.00 — trafisz? · can you?</div>
    <div class="row">${cards}</div></body></html>`);
  await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: path.join(out, 'feature-1024x500.png') });
  await p.close();
}

async function scenes(browser, lang) {
  const p = await browser.newPage({ viewport: { width: 390, height: 780 }, deviceScaleFactor: 2,
    isMobile: true, hasTouch: true, locale: lang === 'pl' ? 'pl-PL' : 'en-US' });
  const ready = () => p.waitForFunction(() => window.hit10Qa, null, { timeout: 20000 }).then(() => p.waitForTimeout(800));
  const q = (f, a) => p.evaluate(f, a);
  await p.goto(url); await ready();
  await q(() => window.hit10Qa.wipe()); await p.reload(); await ready();
  const rich = async () => {
    await q(() => { const h = window.hit10Qa;
      h.setup(JSON.stringify({ tutorialDone: true, playSeconds: 4000, perfects: 300,
        tipsSeen: ['golden', 'prestige', 'skills', 'combo', 'notifyAsked'] }));
      h.grant(5e9);
      for (const [g, n] of [['grandpa', 60], ['grandma', 50], ['cuckoo', 40], ['metronome', 30], ['watchmaker', 25], ['sprintJudge', 15], ['stationClock', 5]]) h.buy(g, n);
      h.setSkill('power', 4); h.setSkill('combo', 3); h.setSkill('bulletTime', 2); h.setSkill('wideEye', 2);
      h.previewSeason(''); // store screenshots show no seasonal event
    });
    await p.waitForTimeout(1500);
  };
  await rich();
  const shots = [];
  const snap = async () => shots.push(await p.screenshot());
  const round = async (t, wait) => {
    // A tap right after a result is ignored for a moment: tap until it runs.
    await p.waitForFunction(() => {
      const s = JSON.parse(window.hit10Qa.state());
      if (s.phase !== 'running') window.hit10Qa.tapNow();
      return JSON.parse(window.hit10Qa.state()).phase === 'running';
    }, null, { timeout: 10000, polling: 100 });
    await q((t) => window.hit10Qa.tapAt(t), t);
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
  // 1: a PERFECT hit (retried until it is one), once the burst has settled
  // enough to see the dial; the result is frozen meanwhile.
  for (let i = 0; i < 8; i++) {
    await round(5.0, 1800);
    const s = JSON.parse(await q(() => window.hit10Qa.state()));
    if (Math.abs(s.lastError ?? 1) < 0.01) break;
    await thaw(); await p.waitForTimeout(1200);
  }
  await snap(); await thaw();
  await p.waitForTimeout(1500);
  // 2: the shop full of clocks.
  await p.mouse.wheel(0, 0); await snap();
  // 3: the golden clock in flight.
  // Summon until it is in the air (a just-finished round may swallow it).
  await p.waitForFunction(() => {
    window.hit10Qa.summonGolden();
    return JSON.parse(window.hit10Qa.state()).goldenVisible > 0;
  }, null, { timeout: 15000, polling: 300 });
  await p.waitForTimeout(2200);
  await snap();
  // 4: Frenzy.
  await q(() => window.hit10Qa.effect('frenzy', 20)); await p.waitForTimeout(1200);
  await round(5.0, 30); await snap(); await thaw();
  await p.waitForTimeout(1500);
  // 5: skills tab.
  await p.getByText(lang === 'pl' ? 'Umiejętności' : 'Skills', { exact: true }).first().click().catch(() => {});
  await p.touchscreen.tap(140, 540); await p.waitForTimeout(800); await snap();
  // 6: the paradox sheet.
  await q(() => window.hit10Qa.setup(JSON.stringify({ earnedTotal: 2e12, shards: 40 })));
  await p.waitForTimeout(3500); // let the achievement toasts pass
  await p.touchscreen.tap(360, 26); await p.waitForTimeout(1000); await snap();
  await p.close();
  return shots;
}

async function frame(browser, shot, caption, file) {
  const p = await browser.newPage({ viewport: { width: 1080, height: 1920 } });
  const img = 'data:image/png;base64,' + shot.toString('base64');
  await p.setContent(`<html><head><style>${fonts}
    body { margin:0; width:1080px; height:1920px; overflow:hidden;
           background: linear-gradient(#FFD36E, #FF8A5B); }
    .cap { position:absolute; left:60px; right:60px; top:70px; text-align:center; color:#2B2D42;
           font-family: Display; font-size:78px; line-height:1.1; }
    .phone { position:absolute; left:155px; top:330px; width:770px; height:1540px; border-radius:64px;
             border:14px solid #2B2D42; overflow:hidden; box-shadow: 0 24px 0 rgba(43,45,66,.25);
             background:#2B2D42; }
    .phone img { width:100%; height:100%; display:block; }
  </style></head><body><div class="cap">${caption}</div>
    <div class="phone"><img src="${img}"></div></body></html>`);
  await p.evaluate(() => document.fonts.ready);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  await p.screenshot({ path: file });
  await p.close();
}

(async () => {
  const browser = await chromium.launch();
  await featureGraphic(browser);
  for (const lang of ['pl', 'en']) {
    const shots = await scenes(browser, lang);
    for (let i = 0; i < shots.length; i++) {
      await frame(browser, shots[i], captions[lang][i], path.join(out, 'screens', lang, `${i + 1}.png`));
    }
  }
  await browser.close();
  console.log('store graphics written');
})();
