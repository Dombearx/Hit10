'use strict';
/* Hit5 – edytor tekstów PL. Stan, renderowanie ICU, pomocnicze klocki makiet, panel edycji. */

const S = { order: [], pl: {}, en: {}, drafts: {}, file: '', checked: {} };
const isOk = (k) => k in S.checked;
async function setChecked(keys, val) {
  const changes = {};
  for (const k of keys) { changes[k] = !!val; if (val) S.checked[k] = 'teraz'; else delete S.checked[k]; }
  refreshChecks();
  try {
    const r = await fetch('/api/checked', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ changes }) });
    if (!r.ok) throw new Error(r.status);
    S.checked = await r.json();
  } catch (e) { status('Nie udało się zapisać znacznika „sprawdzone”: ' + e.message, false); }
  refreshChecks();
}
function refreshChecks() {
  document.querySelectorAll('.ed[data-k]').forEach((ed) => {
    const ok = isOk(ed.dataset.k); ed.classList.toggle('ok', ok);
    const cb = ed.querySelector('input[data-check]'); if (cb) cb.checked = ok;
  });
  if (CUR) {
    const keys = CUR.keys || [], n = keys.filter(isOk).length;
    const h = document.querySelector('#checkHead');
    if (h) h.innerHTML = checkHeadHtml(keys, n);
  }
  const all = S.order.length, done = S.order.filter(isOk).length;
  const p = document.querySelector('#progress');
  if (p) p.innerHTML = `Sprawdzone <b>${done}</b> / ${all}<i style="width:${all ? (done * 100 / all) : 0}%"></i>`;
  clearTimeout(refreshChecks.t); refreshChecks.t = setTimeout(buildNav, 50);
}
function checkHeadHtml(keys, n) {
  const all = keys.length && n === keys.length;
  return `<span class="cprog ${all ? 'full' : ''}">${all ? '✓ ' : ''}Sprawdzone ${n}/${keys.length}</span>
    <button data-check-all="${all ? 0 : 1}">${all ? 'Odznacz cały ekran' : 'Zaznacz cały ekran'}</button>
    <button data-next-todo title="Przejdź do następnego ekranu z niesprawdzonymi tekstami">Następny niesprawdzony →</button>`;
}
const SCREENS = [];
const GROUPS = [];
let CUR = null;          // aktualny ekran
let CUR_KEYS = null;     // klucze zbierane podczas renderowania
let KEY_SCREENS = {};    // klucz -> [id ekranów]
let FOCUS_KEY = null;
const LS = 'hit5-teksty-drafts';

/* ---------------- dane ---------------- */
const txt = (k) => (k in S.drafts ? S.drafts[k] : S.pl[k]);
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const PH_RE = /(?<![=\w])\{(\w+)(?=[,}])/g;
const phs = (s) => new Set([...String(s || '').matchAll(PH_RE)].map((m) => m[1]));
function bracesOk(s) { let d = 0; for (const c of s) { if (c === '{') d++; else if (c === '}' && --d < 0) return false; } return d === 0; }
function problem(k) {
  const v = txt(k);
  if (!bracesOk(v)) return 'Nawiasy { } się nie domykają.';
  const want = phs(S.en[k] ?? S.pl[k]), got = phs(v);
  const miss = [...want].filter((p) => !got.has(p)), extra = [...got].filter((p) => !want.has(p));
  if (!miss.length && !extra.length) return null;
  return 'Zmienne się nie zgadzają' + (miss.length ? ' · brakuje: ' + miss.map((p) => `{${p}}`).join(' ') : '') + (extra.length ? ' · nieznane: ' + extra.map((p) => `{${p}}`).join(' ') : '');
}

/* ---------------- ICU (to, czego używa gen_l10n) ---------------- */
function parseICU(s) {
  let i = 0;
  const ws = () => { while (i < s.length && /\s/.test(s[i])) i++; };
  function msg(inner) {
    const out = []; let buf = '';
    while (i < s.length) {
      const c = s[i];
      if (c === '{') {
        const save = i; const a = arg();
        if (a) { if (buf) out.push(buf); buf = ''; out.push(a); } else { i = save + 1; buf += '{'; }
      } else if (c === '}' && inner) break;
      else { buf += c; i++; }
    }
    if (buf) out.push(buf);
    return out;
  }
  function arg() {
    i++; ws();
    let name = ''; while (i < s.length && /\w/.test(s[i])) name += s[i++];
    ws();
    if (!name) return null;
    if (s[i] === '}') { i++; return { arg: name }; }
    if (s[i] !== ',') return null;
    i++; ws(); let type = ''; while (i < s.length && /\w/.test(s[i])) type += s[i++]; ws();
    if (s[i] !== ',') return null;
    i++; const opts = {};
    while (i < s.length) {
      ws(); if (s[i] === '}') { i++; return { arg: name, type, opts }; }
      let sel = ''; while (i < s.length && s[i] !== '{' && !/\s/.test(s[i])) sel += s[i++];
      ws(); if (s[i] !== '{') return null;
      i++; opts[sel] = msg(true); if (s[i] !== '}') return null; i++;
    }
    return null;
  }
  return msg(false);
}
function plCat(n) {
  if (!Number.isInteger(n)) return 'other';
  if (n === 1) return 'one';
  const m10 = n % 10, m100 = n % 100;
  if (m10 >= 2 && m10 <= 4 && !(m100 >= 12 && m100 <= 14)) return 'few';
  return 'many';
}
function renderParts(parts, args, html) {
  let o = '';
  for (const p of parts) {
    if (typeof p === 'string') { o += html ? esc(p).replace(/\n/g, '<br>') : p; continue; }
    const has = Object.prototype.hasOwnProperty.call(args, p.arg);
    let v = has ? args[p.arg] : undefined;
    if (typeof v === 'function') v = v();
    if (!p.type) {
      if (v === undefined) o += html ? `<i class="ph">{${esc(p.arg)}}</i>` : `{${p.arg}}`;
      else o += html ? `<span class="arg">${esc(v)}</span>` : String(v);
      continue;
    }
    if (p.type === 'plural') {
      const n = Number(String(v ?? 2).replace(',', '.').replace(/[^\d.-]/g, '')) || 0;
      const pick = p.opts['=' + n] || p.opts[plCat(n)] || p.opts.other || Object.values(p.opts)[0] || [];
      o += renderParts(pick, args, html);
    } else {
      const pick = p.opts[String(v)] || p.opts.other || Object.values(p.opts)[0] || [];
      o += renderParts(pick, args, html);
    }
  }
  return o;
}
function icu(s, args, html) {
  try { return renderParts(parseICU(String(s ?? '')), args || {}, html); } catch (e) { return html ? esc(s) : s; }
}

/* ---------------- ikony zasobów (jak ResText w grze) ---------------- */
const SHARD_SVG = '<svg class="ri" viewBox="0 0 20 20"><path d="M10 0.5 L12.4 7.6 L19.5 10 L12.4 12.4 L10 19.5 L7.6 12.4 L0.5 10 L7.6 7.6Z" fill="#9b6bff" stroke="#2B2D42" stroke-width="1.2"/></svg>';
const SPRING_SVG = '<svg class="ri" viewBox="0 0 20 20"><path d="M4 4 h12 M4 16 h12 M5 4 C15 6,15 8,5 9 C15 10,15 12,5 13 C15 14,15 15,6 16" fill="none" stroke="#2B2D42" stroke-width="2" stroke-linecap="round"/></svg>';
const RES_RE = /(?<!\p{L})(?:(Tik(?:i|ów|a|ach|om|ami)?)|(Chronon(?:y|ów|u|a|ami|om|ach)?)|(Okruch(?:y|ów|a|ami|om|ach)?(?: czasu)?)|(Sprężyn(?:a|y|ę|ą|ie|om|ami|ach)?))(?!\p{L})(?: ✦)?|✦/gu;
function resIcons(html) {
  return html.split(/(<[^>]+>)/).map((part) => part.startsWith('<') ? part : part.replace(RES_RE, (m, t, c, sh, sp) => {
    if (t) return `<img class="ri" src="/assets/art/coin.png">${m}`;
    if (c) return `<img class="ri" src="/assets/art/cyclone.png">${m}`;
    if (sh) return SHARD_SVG + m.replace(' ✦', '');
    if (sp) return SPRING_SVG + m;
    return SHARD_SVG;
  })).join('');
}

/* ---------------- przykładowe wartości zmiennych ---------------- */
const plain = (k, a) => icu(txt(k), Object.assign({}, DEF, a || {}), false);
const DEF = {
  amount: '1,25M', count: 3, n: 5, value: '12,5K', cost: '250', date: '14 lutego', day: 4, days: 7, done: 2, total: 7,
  duration: '2 godz. 15 min', from: '×2', to: '×2,5', generator: () => plain('gen_grandpa'), have: '40', need: '50',
  hits: 3, hours: 2, minutes: 30, kept: '3', label: () => plain('skill_power_label'), left: 2, level: 3, max: 10,
  mult: '×1,5', ms: 12, name: () => plain('gen_grandpa'), next: '×1,6', now: '×1,4', offset: '+12 ms', other: () => plain('gen_grandma'),
  owned: '40', pct: '10', perSecond: '1,2K/s', percent: 42, price: '1,5M', rate: '0,8', refill: '5 min', rule: () => plain('rule_blindfold'),
  season: () => plain('season_christmas'), seconds: '3,2', share: '50', skill: () => plain('skill_power'), slots: 2, used: 1, target: 5,
  tier: () => plain('oddsPerfect'), time: '4:59', title: 'Mistrz', what: '+1,2M Tiki', word: () => plain('resetWord'),
  localEarned: '1,25M', cloudEarned: '3,4B', localTime: 'dziś, 14:02', cloudTime: 'wczoraj, 21:40',
  a: () => plain('gen_grandpa'), b: () => plain('gen_grandma'), aOwned: '10', bOwned: '5',
};

/* ---------------- klocki makiet ---------------- */
// T: tekst z pliku, klikalny. a = argumenty, o = {res:true, cls:''}
function T(k, a, o) {
  if (!(k in S.pl)) return `<span class="t err" title="Brak klucza ${esc(k)}">[${esc(k)}]</span>`;
  if (CUR_KEYS && !CUR_KEYS.includes(k)) CUR_KEYS.push(k);
  let h = icu(txt(k), Object.assign({}, DEF, a || {}), true);
  if (o && o.res) h = resIcons(h);
  const cls = ['t'];
  if (k in S.drafts) cls.push('chg');
  if (k === FOCUS_KEY) cls.push('sel');
  if (o && o.cls) cls.push(o.cls);
  return `<span class="${cls.join(' ')}" data-k="${k}">${h}</span>`;
}
const R = (k, a) => T(k, a, { res: true });       // z ikonami zasobów
const P = (k, a) => plain(k, a);                    // sam tekst (np. jako argument)
const img = (n) => `<img src="/assets/art/${n}.png" alt="">`;
const art = (n, bg, cls) => `<div class="g-art ${cls || ''}" style="background:${bg || '#FFE29A'}">${img(n)}</div>`;
const has = (k) => k in S.pl;

function frame(cap, inner, o) {
  o = o || {};
  return `<div class="frame">${cap ? `<div class="cap">${cap}</div>` : ''}<div class="ph-frame ${o.cls || ''}" style="${o.style || ''}">${inner}</div></div>`;
}
// tło gry (uproszczone) pod okienkiem
function gameBg(extra) {
  return `<div class="ph-in">${topBar()}${balance()}<div class="g-dial"><div class="dig">00.00</div></div>${extra || ''}</div>`;
}
function topBar(tips) {
  const ic = (n, k, gold) => `<div class="g-ic ${gold ? 'gold' : ''}">${img(n)}${tips ? `<span class="tip">${T(k)}</span>` : ''}</div>`;
  return `<div class="g-top"><div>${ic('trophy', 'achievementsTitle')}${ic('bar_chart', 'statsTitle')}</div><div>${ic('red_question_mark', 'helpTitle')}${ic('gear', 'settingsTitle')}${ic('cyclone', 'prestigeTitle', true)}</div></div>`;
}
function balance(o) {
  o = o || {};
  return `<div class="g-bal" style="${o.tips ? 'margin-top:22px' : ''}"><span class="big">39,5T</span><span class="lab">${o.t ? T('tikiLabel') : 'Tiki'}</span>
    <div class="ps">${o.t ? T('perSecond', { value: '129M' }) : '129M/s'}</div>${o.t ? `<div class="jp">${T('jackpotPrice', { amount: '1,00B', target: '5.00' })}</div>` : ''}</div>`;
}
function dialog(o) {
  return `<div class="g-dialog">${o.art || ''}${o.title ? `<div class="ttl">${o.title}</div>` : ''}${o.body ? `<div class="txt">${o.body}</div>` : ''}${o.extra || ''}
    ${o.btns ? `<div class="btns">${o.btns}</div>` : ''}${o.row ? `<div class="row2">${o.row}</div>` : ''}</div>`;
}
function overDialog(o, cap) { return frame(cap, `<div class="dimmed bgabs">${gameBg()}</div><div class="flow-in center">${dialog(o)}</div>`, { cls: 'flow' }); }
function sheet(title, content, o) {
  o = o || {};
  return `<div class="g-sheet ${o.full ? 'full' : ''}" style="${o.h ? `height:${o.h}` : ''}"><div class="handle"></div><div class="sh-h"><div class="ttl">${title}</div><div class="x">✕</div></div><div class="sc">${content}</div></div>`;
}
function overSheet(title, content, cap, o) {
  o = o || {};
  return frame(cap, `<div class="dimmed bgabs">${gameBg()}</div><div class="flow-in bottom">${sheet(title, content, o)}</div>`, { cls: 'flow' });
}
const btn = (label, cls, sub) => `<div class="g-btn ${cls || ''}">${sub ? `<small>${sub}</small>` : ''}${label}</div>`;
const link = (label) => `<div class="g-link">${label}</div>`;
const toast = (artHtml, kick, title, body) => `<div class="g-toast">${artHtml || ''}<div>${kick ? `<div class="kick">${kick}</div>` : ''}<div class="tt">${title}</div>${body ? `<div class="tb">${body}</div>` : ''}</div></div>`;
const snack = (text, o) => { o = o || {}; return `<div class="g-snack ${o.static ? 'static' : ''}">${o.art || ''}<div class="tx">${o.title ? `<small>${o.title}</small>` : ''}${text}</div>${o.action ? `<div class="act">${o.action}</div>` : ''}</div>`; };
// mała karta ze zrzutem kontekstu: tło gry + element w miejscu
function gameWith(inner, cap, o) { return frame(cap, `<div class="ph-in">${topBar()}${balance()}<div class="g-dial"><div class="dig">00.00</div></div></div>${inner}`, o); }
function card(o) {
  return `<div class="g-card" style="${o.style || ''}">${o.art || ''}<div class="body">${o.name ? `<div class="name">${o.name}</div>` : ''}${o.sub ? `<div class="sub">${o.sub}</div>` : ''}${o.desc ? `<div class="desc">${o.desc}</div>` : ''}${o.more || ''}</div>${o.btn || ''}</div>`;
}
// lista "katalogowa" – auto-wysokość
function catFrame(cap, inner, o) { return frame(cap, `<div class="ph-in" style="background:var(--paper)">${inner}</div>`, Object.assign({ cls: 'auto' }, o || {})); }

/* ---------------- rejestr ekranów ---------------- */
function group(name) { GROUPS.push(name); }
function screen(id, title, render, note) { SCREENS.push({ id, title, render, note, group: GROUPS[GROUPS.length - 1] }); }

function renderScreen(sc) {
  CUR_KEYS = [];
  let html = '';
  try { html = sc.render(); } catch (e) { html = `<pre style="color:#c0392b">${esc(e.stack || e)}</pre>`; console.error(e); }
  const keys = CUR_KEYS; CUR_KEYS = null;
  return { html, keys };
}

function computeCoverage() {
  KEY_SCREENS = {};
  for (const sc of SCREENS) {
    if (sc.dynamic) continue;
    const { keys } = renderScreen(sc);
    sc.keys = keys;
    for (const k of keys) (KEY_SCREENS[k] = KEY_SCREENS[k] || []).push(sc.id);
  }
  const rest = S.order.filter((k) => !KEY_SCREENS[k]);
  const restSc = SCREENS.find((s) => s.id === 'pozostale');
  restSc.restKeys = rest;
  const { keys } = renderScreen(restSc);
  restSc.keys = keys;
  for (const k of keys) (KEY_SCREENS[k] = KEY_SCREENS[k] || []).push(restSc.id);
}

/* ---------------- UI ---------------- */
const $ = (s) => document.querySelector(s);
function buildNav() {
  let h = '', g = null;
  for (const sc of SCREENS) {
    if (sc.group !== g) { g = sc.group; h += `<h4>${esc(g)}</h4>`; }
    const keys = sc.keys || [], n = keys.length;
    const ch = keys.filter((k) => k in S.drafts).length;
    const ok = keys.filter(isOk).length;
    const badge = n && ok === n ? '<i class="done">✓</i>' : `<i>${ok ? `${ok}/` : ''}${n}</i>`;
    h += `<a href="#${sc.id}" data-id="${sc.id}" class="${CUR && CUR.id === sc.id ? 'on' : ''} ${n && ok === n ? 'isdone' : ''}"><span>${esc(sc.title)}</span><span>${ch ? `<i class="ch" title="niezapisane zmiany">${ch}</i> ` : ''}${badge}</span></a>`;
  }
  $('#nav').innerHTML = h;
}
function show(id, focusKey) {
  const sc = SCREENS.find((s) => s.id === id) || SCREENS[0];
  CUR = sc;
  if (focusKey !== undefined) FOCUS_KEY = focusKey;
  drawStage();
  drawEditor();
  buildNav();
  if (location.hash.slice(1) !== sc.id) history.replaceState(null, '', '#' + sc.id);
  $('#stage').scrollTop = 0;
  if (FOCUS_KEY) setTimeout(() => focusEditor(FOCUS_KEY, true), 30);
}
function drawStage() {
  const { html, keys } = renderScreen(CUR);
  CUR.keys = keys;
  $('#stage').innerHTML = `<div class="stage-h"><h2>${esc(CUR.title)}</h2></div>${CUR.note ? `<p class="stage-note">${CUR.note}</p>` : '<p class="stage-note"></p>'}<div class="frames">${html}</div>`;
}
let redrawT = 0;
function redrawSoon() {
  clearTimeout(redrawT);
  redrawT = setTimeout(() => {
    const st = $('#stage'); const top = st.scrollTop;
    drawStage(); st.scrollTop = top;
  }, 60);
}
function drawEditor() {
  const keys = CUR.keys || [];
  let h = `<div class="eh"><h3>Teksty na tym ekranie</h3><span>${keys.length}</span></div><div id="checkHead" class="checkhead">${checkHeadHtml(keys, keys.filter(isOk).length)}</div>`;
  for (const k of keys) h += editorItem(k);
  if (!keys.length) h += '<p class="g-dim">Brak tekstów.</p>';
  $('#editor').innerHTML = h;
  $('#editor').querySelectorAll('textarea').forEach(autoSize);
}
function editorItem(k) {
  const v = txt(k), changed = k in S.drafts, err = changed ? problem(k) : null;
  const vars = [...phs(S.en[k] ?? S.pl[k])];
  const others = (KEY_SCREENS[k] || []).filter((id) => id !== CUR.id);
  return `<div class="ed ${changed ? 'changed' : ''} ${err ? 'bad' : ''} ${k === FOCUS_KEY ? 'focus' : ''} ${isOk(k) ? 'ok' : ''}" data-k="${k}">
    <div class="ed-h"><label class="chk" title="Oznacz jako sprawdzone"><input type="checkbox" data-check="${k}" ${isOk(k) ? 'checked' : ''}>sprawdzone</label><code title="Klucz w app_pl.arb (kliknij, żeby skopiować)">${esc(k)}</code>${changed ? '<span class="badge">zmienione</span>' : ''}
      ${others.length ? `<span class="also" title="${esc(others.map((id) => SCREENS.find((s) => s.id === id)?.title).join(', '))}">też na ${others.length} ${others.length === 1 ? 'innym ekranie' : 'innych ekranach'}</span>` : ''}
      ${changed ? `<button data-revert="${k}" title="Przywróć tekst z pliku">↺ cofnij</button>` : ''}</div>
    <textarea data-k="${k}" rows="1" spellcheck="true" lang="pl">${esc(v)}</textarea>
    ${changed ? `<div class="ed-was">${esc(S.pl[k])}</div>` : ''}
    ${S.en[k] !== undefined ? `<div class="ed-en"><b>EN</b>${esc(S.en[k])}</div>` : ''}
    ${vars.length ? `<div class="ed-vars">Zmienne (muszą zostać): ${vars.map((p) => `<span data-ins="{${p}}">{${p}}</span>`).join('')}</div>` : ''}
    <div class="ed-err">${err ? esc(err) : ''}</div></div>`;
}
function autoSize(t) { t.style.height = 'auto'; t.style.height = t.scrollHeight + 2 + 'px'; }
function focusEditor(k, scroll) {
  FOCUS_KEY = k;
  document.querySelectorAll('.ed.focus').forEach((e) => e.classList.remove('focus'));
  document.querySelectorAll('.t.sel').forEach((e) => e.classList.remove('sel'));
  document.querySelectorAll(`.t[data-k="${CSS.escape(k)}"]`).forEach((e) => e.classList.add('sel'));
  const ed = document.querySelector(`.ed[data-k="${CSS.escape(k)}"]`);
  if (!ed) return;
  ed.classList.add('focus');
  if (scroll) ed.scrollIntoView({ block: 'center', behavior: 'smooth' });
  const ta = ed.querySelector('textarea');
  ta.focus({ preventScroll: true });
}
function refreshItem(k) {
  const ed = document.querySelector(`.ed[data-k="${CSS.escape(k)}"]`);
  if (!ed) return;
  const changed = k in S.drafts, err = changed ? problem(k) : null;
  ed.classList.toggle('changed', changed); ed.classList.toggle('bad', !!err);
  ed.querySelector('.ed-err').textContent = err || '';
  const h = ed.querySelector('.ed-h');
  if (changed && !h.querySelector('.badge')) h.querySelector('code').insertAdjacentHTML('afterend', '<span class="badge">zmienione</span>');
  if (!changed) h.querySelector('.badge')?.remove();
  if (changed && !h.querySelector('[data-revert]')) h.insertAdjacentHTML('beforeend', `<button data-revert="${k}" title="Przywróć tekst z pliku">↺ cofnij</button>`);
  if (!changed) h.querySelector('[data-revert]')?.remove();
  let was = ed.querySelector('.ed-was');
  if (changed && !was) { ed.querySelector('textarea').insertAdjacentHTML('afterend', `<div class="ed-was">${esc(S.pl[k])}</div>`); }
  if (!changed && was) was.remove();
}
function setDraft(k, v) {
  if (v === S.pl[k]) delete S.drafts[k]; else S.drafts[k] = v;
  persist(); refreshItem(k); updateCounts(); redrawSoon();
}
function persist() { try { localStorage.setItem(LS, JSON.stringify(S.drafts)); } catch (e) { /* bez pamięci – trudno */ } }
function updateCounts() {
  const n = Object.keys(S.drafts).length;
  $('#cnt').textContent = n;
  const bad = Object.keys(S.drafts).filter(problem).length;
  $('#btnSave').disabled = n === 0;
  $('#btnSave').textContent = bad ? `Zapisz do kodu (${n - bad} z ${n})` : 'Zapisz do kodu';
  clearTimeout(updateCounts.t);
  updateCounts.t = setTimeout(buildNav, 200);
}
function status(msg, ok) { const el = $('#status'); el.textContent = msg; el.style.color = ok === false ? '#ffb4b4' : ''; }

/* ---------------- zapis ---------------- */
async function saveAll() {
  const keys = Object.keys(S.drafts).filter((k) => !problem(k));
  if (!keys.length) { status('Popraw błędy zmiennych przed zapisem.', false); return; }
  const changes = {};
  for (const k of keys) changes[k] = { old: S.pl[k], new: S.drafts[k] };
  $('#btnSave').disabled = true; status('Zapisuję…');
  try {
    const r = await fetch('/api/save', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ changes }) });
    const j = await r.json();
    if (!r.ok) throw new Error(j.error || r.status);
    for (const k of j.saved) { S.pl[k] = S.drafts[k]; delete S.drafts[k]; }
    persist();
    const probs = Object.entries(j.problems || {});
    status(probs.length ? `Zapisano ${j.saved.length}, odrzucono ${probs.length}` : `Zapisano ${j.saved.length} ${j.saved.length === 1 ? 'tekst' : 'tekstów'} do ${S.file}`, !probs.length);
    if (probs.length) openModal(`<h3>Część zmian nie została zapisana</h3>${probs.map(([k, m]) => `<div class="row"><code>${esc(k)}</code><div>${esc(m)}</div></div>`).join('')}<div class="bar"><button data-close>OK</button></div>`);
  } catch (e) {
    status('Błąd zapisu: ' + e.message, false);
  }
  updateCounts(); drawStage(); drawEditor(); buildNav();
}
function openModal(h) { const m = $('#modal'); m.innerHTML = `<div class="box">${h}</div>`; m.hidden = false; }
function closeModal() { $('#modal').hidden = true; }
function showChanges() {
  const ks = Object.keys(S.drafts);
  const rows = ks.map((k) => {
    const err = problem(k); const where = (KEY_SCREENS[k] || [])[0];
    return `<div class="row"><code>${esc(k)}</code> ${where ? `<a href="#${where}" data-go="${where}" data-key="${k}">pokaż</a>` : ''} <a href="#" data-revert="${k}">cofnij</a>
      <div class="old">${esc(S.pl[k])}</div><div class="new">${esc(S.drafts[k])}</div>${err ? `<div class="ed-err">${esc(err)}</div>` : ''}</div>`;
  }).join('');
  openModal(`<h3>Niezapisane zmiany (${ks.length})</h3>${rows || '<p>Brak zmian.</p>'}
    <div class="bar">${ks.length ? '<button data-revert-all>Cofnij wszystkie</button>' : ''}<button data-close>Zamknij</button>${ks.length ? '<button class="primary" data-save>Zapisz do kodu</button>' : ''}</div>`);
}

/* ---------------- wyszukiwanie ---------------- */
function norm(s) { return String(s).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/ł/g, 'l'); }
function search(q) {
  const box = $('#results');
  if (!q.trim()) { box.hidden = true; return; }
  const n = norm(q);
  const hits = S.order.filter((k) => norm(k).includes(n) || norm(txt(k)).includes(n) || norm(S.en[k] || '').includes(n)).slice(0, 60);
  box.innerHTML = hits.map((k, i) => {
    const sid = (KEY_SCREENS[k] || [])[0]; const sc = SCREENS.find((s) => s.id === sid);
    return `<div data-k="${k}" class="${i === 0 ? 'on' : ''}"><small>${esc(sc ? sc.title : '')}</small><code>${esc(k)}</code><br>${esc(txt(k)).slice(0, 160)}</div>`;
  }).join('') || '<div>Nic nie znaleziono.</div>';
  box.hidden = false;
}
function goKey(k) {
  const sid = (KEY_SCREENS[k] || [])[0] || 'pozostale';
  $('#results').hidden = true; $('#q').value = '';
  show(sid, k);
}

/* ---------------- start ---------------- */
async function boot() {
  const r = await fetch('/api/data');
  const d = await r.json();
  Object.assign(S, { order: d.order, pl: d.pl, en: d.en, file: d.file });
  try { S.checked = await (await fetch('/api/checked')).json(); } catch (e) { S.checked = {}; }
  try {
    const saved = JSON.parse(localStorage.getItem(LS) || '{}');
    for (const [k, v] of Object.entries(saved)) if (k in S.pl && v !== S.pl[k]) S.drafts[k] = v;
  } catch (e) { /* nic */ }
  computeCoverage();
  updateCounts();
  if (Object.keys(S.drafts).length) status(`Przywrócono ${Object.keys(S.drafts).length} niezapisanych zmian z poprzedniej sesji.`);
  show(location.hash.slice(1) || SCREENS[0].id);
  refreshChecks();

  $('#nav').addEventListener('click', (e) => { const a = e.target.closest('a[data-id]'); if (a) { e.preventDefault(); FOCUS_KEY = null; show(a.dataset.id); } });
  window.addEventListener('hashchange', () => { const id = location.hash.slice(1); if (!CUR || id !== CUR.id) show(id); });
  $('#stage').addEventListener('click', (e) => { const t = e.target.closest('.t[data-k]'); if (t) { e.preventDefault(); e.stopPropagation(); focusEditor(t.dataset.k, true); } });
  $('#stage').addEventListener('mouseover', (e) => {
    const t = e.target.closest('.t[data-k]');
    document.querySelectorAll('.ed.hover').forEach((x) => x.classList.remove('hover'));
    if (t) document.querySelector(`.ed[data-k="${CSS.escape(t.dataset.k)}"]`)?.classList.add('hover');
  });
  const ed = $('#editor');
  ed.addEventListener('input', (e) => { const ta = e.target.closest('textarea[data-k]'); if (!ta) return; autoSize(ta); setDraft(ta.dataset.k, ta.value); });
  ed.addEventListener('focusin', (e) => {
    const ta = e.target.closest('textarea[data-k]'); if (!ta) return;
    const k = ta.dataset.k; if (FOCUS_KEY === k) return;
    FOCUS_KEY = k;
    document.querySelectorAll('.ed.focus').forEach((x) => x.classList.remove('focus'));
    ta.closest('.ed').classList.add('focus');
    document.querySelectorAll('.t.sel').forEach((x) => x.classList.remove('sel'));
    const spans = document.querySelectorAll(`.t[data-k="${CSS.escape(k)}"]`);
    spans.forEach((x) => x.classList.add('sel'));
    if (spans[0]) {
      const st = $('#stage').getBoundingClientRect(), b = spans[0].getBoundingClientRect();
      if (b.top < st.top || b.bottom > st.bottom) spans[0].scrollIntoView({ block: 'center', behavior: 'smooth' });
    }
  });
  ed.addEventListener('change', (e) => { const cb = e.target.closest('input[data-check]'); if (cb) setChecked([cb.dataset.check], cb.checked); });
  ed.addEventListener('click', (e) => {
    const ca = e.target.closest('[data-check-all]');
    if (ca) { setChecked(CUR.keys || [], ca.dataset.checkAll === '1'); return; }
    if (e.target.closest('[data-next-todo]')) {
      const i = SCREENS.indexOf(CUR);
      const order = SCREENS.slice(i + 1).concat(SCREENS.slice(0, i + 1));
      const next = order.find((s) => (s.keys || []).some((k) => !isOk(k)));
      if (next) { FOCUS_KEY = null; show(next.id); const k = next.keys.find((x) => !isOk(x)); if (k) setTimeout(() => focusEditor(k, true), 60); }
      else status('Wszystko sprawdzone! 🎉');
      return;
    }
    const rv = e.target.closest('[data-revert]');
    if (rv) { const k = rv.dataset.revert; delete S.drafts[k]; persist(); const ta = ed.querySelector(`textarea[data-k="${CSS.escape(k)}"]`); ta.value = S.pl[k]; autoSize(ta); refreshItem(k); updateCounts(); redrawSoon(); return; }
    const ins = e.target.closest('[data-ins]');
    if (ins) {
      const ta = ins.closest('.ed').querySelector('textarea');
      const s = ta.selectionStart ?? ta.value.length, en = ta.selectionEnd ?? s;
      ta.value = ta.value.slice(0, s) + ins.dataset.ins + ta.value.slice(en); ta.focus();
      ta.selectionStart = ta.selectionEnd = s + ins.dataset.ins.length; autoSize(ta); setDraft(ta.dataset.k, ta.value);
    }
    const code = e.target.closest('.ed-h code');
    if (code) navigator.clipboard?.writeText(code.textContent);
  });
  $('#btnSave').addEventListener('click', saveAll);
  $('#btnChanges').addEventListener('click', showChanges);
  $('#modal').addEventListener('click', (e) => {
    if (e.target.id === 'modal' || e.target.closest('[data-close]')) return closeModal();
    if (e.target.closest('[data-save]')) { closeModal(); return saveAll(); }
    if (e.target.closest('[data-revert-all]')) { if (confirm('Cofnąć wszystkie niezapisane zmiany?')) { S.drafts = {}; persist(); updateCounts(); closeModal(); show(CUR.id); } return; }
    const rv = e.target.closest('[data-revert]');
    if (rv) { e.preventDefault(); delete S.drafts[rv.dataset.revert]; persist(); updateCounts(); showChanges(); drawStage(); drawEditor(); return; }
    const go = e.target.closest('[data-go]');
    if (go) { e.preventDefault(); closeModal(); show(go.dataset.go, go.dataset.key); }
  });
  const q = $('#q');
  q.addEventListener('input', () => search(q.value));
  q.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') { q.value = ''; search(''); q.blur(); }
    if (e.key === 'Enter') { const f = $('#results div.on[data-k]') || $('#results div[data-k]'); if (f) goKey(f.dataset.k); }
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault(); const items = [...document.querySelectorAll('#results div[data-k]')]; if (!items.length) return;
      let i = items.findIndex((x) => x.classList.contains('on')); items[i]?.classList.remove('on');
      i = (i + (e.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length; items[i].classList.add('on'); items[i].scrollIntoView({ block: 'nearest' });
    }
  });
  $('#results').addEventListener('mousedown', (e) => { const d = e.target.closest('div[data-k]'); if (d) { e.preventDefault(); goKey(d.dataset.k); } });
  q.addEventListener('blur', () => setTimeout(() => { $('#results').hidden = true; }, 150));
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 's') { e.preventDefault(); saveAll(); }
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); q.focus(); q.select(); }
    if (e.key === 'Escape' && !$('#modal').hidden) closeModal();
  });
  window.addEventListener('beforeunload', (e) => { if (Object.keys(S.drafts).length) { e.preventDefault(); e.returnValue = ''; } });
}
