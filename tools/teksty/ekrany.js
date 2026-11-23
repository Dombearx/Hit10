'use strict';
/* Definicje ekranów. Każdy T('klucz', {zmienne}) to klikalny tekst z app_pl.arb. */

const GENS = ['grandpa', 'grandma', 'cuckoo', 'metronome', 'watchmaker', 'sprintJudge', 'stationClock', 'quartz', 'atomic', 'gps', 'pulsar', 'timeMachine', 'schrodinger', 'chronos'];
const GEN_BG = { grandpa: '#FFD36E', grandma: '#FFB38A', cuckoo: '#9BE7C4', metronome: '#B9A7FF', watchmaker: '#FFC9DE', sprintJudge: '#A7E0FF', stationClock: '#FFE29A', quartz: '#C8F2FF', atomic: '#D7C4FF', gps: '#B4D8FF', pulsar: '#FFE6A7', timeMachine: '#FFC2A8', schrodinger: '#E2D2FF', chronos: '#FFD86E' };
const SKILLS = ['power', 'fastForward', 'ticking', 'wideEye', 'combo', 'magnet', 'echo', 'bulletTime', 'luck', 'shield', 'goldenTouch'];
const SKILL_ART = { power: ['flexed_biceps', '#FFC9DE'], fastForward: ['fast_forward_button', '#A7E0FF'], ticking: ['bell', '#FFE29A'], wideEye: ['eagle', '#FFD36E'], combo: ['fire', '#FFB38A'], magnet: ['magnet', '#FFC2A8'], echo: ['speaker_high_volume', '#B9A7FF'], bulletTime: ['bullseye', '#A7D8FF'], luck: ['four_leaf_clover', '#9BE7C4'], shield: ['shield', '#B4D8FF'], goldenTouch: ['sparkles', '#FFE6A7'] };
const PERKS = ['headStart', 'muscleMemory1', 'muscleMemory2', 'muscleMemory3', 'habit1', 'habit2', 'longNap1', 'longNap2', 'deepSleep1', 'deepSleep2', 'goldRush', 'shieldRecharge', 'comboFloor', 'autoBuyer', 'daredevil', 'unlockSchrodinger', 'secondClock', 'unlockChronos'];
const PERK_ART = { headStart: 'rocket', muscleMemory1: 'brain', muscleMemory2: 'brain', muscleMemory3: 'brain', habit1: 'locked', habit2: 'locked', longNap1: 'sleeping_face', longNap2: 'sleeping_face', deepSleep1: 'bed', deepSleep2: 'bed', goldRush: 'pick', shieldRecharge: 'shield', comboFloor: 'parachute', autoBuyer: 'shopping_cart', daredevil: 'smiling_face_with_sunglasses', unlockSchrodinger: 'package', secondClock: 'stopwatch', unlockChronos: 'classical_building' };
const SYNS = ['grandparents', 'birdRhythm', 'craftsmanship', 'photoFinish', 'cosmicBeat', 'delayedTrain'];
const SEASONS = ['valentine', 'easter', 'summer', 'fiveDay', 'halloween', 'christmas', 'newYear'];
const SEASON_ART = { valentine: 'heart_with_ribbon', easter: 'hatching_chick', summer: 'sun_with_face', fiveDay: 'keycap_5', halloween: 'jack_o_lantern', christmas: 'christmas_tree', newYear: 'fireworks' };
const RULES = ['blindfold', 'inflation', 'noGold', 'shortFuse', 'precision', 'insomnia'];
const RULE_ART = { blindfold: 'see_no_evil_monkey', inflation: 'money_bag', noGold: 'glowing_star', shortFuse: 'fire', precision: 'bullseye', insomnia: 'sleeping_face' };
const DIALS = ['classic', 'wood', 'porcelain', 'brass', 'station', 'swiss', 'quartz', 'atomic', 'neon', 'cosmic', 'golden', 'rift'];
const ACH_COUNT = ['earned', 'owned', 'perfects', 'perfectStreak', 'combo', 'golden', 'prestige', 'season', 'exact', 'rounds', 'income', 'clocks', 'skillLevels', 'blindPerfects', 'playHours', 'achievements', 'daily', 'shield'];
const ACH_ART = { earned: 'coin', owned: 'grandpa', perfects: 'glowing_star', perfectStreak: 'fire', combo: 'fire', golden: 'glowing_star', prestige: 'cyclone', season: 'wrapped_gift', exact: 'bullseye', rounds: 'stopwatch', income: 'money_bag', clocks: 'stopwatch', skillLevels: 'flexed_biceps', blindPerfects: 'see_no_evil_monkey', playHours: 'sleeping_face', achievements: 'trophy', daily: 'wrapped_gift', shield: 'shield' };
const ACH_FIXED = ['mode_blind', 'mode_fast', 'mode_both', 'feat_goldenFast', 'feat_goldenFrenzy', 'feat_dailyWeek', 'feat_offlineFull', 'feat_bothClocks', 'feat_allPerks', 'feat_noHands', 'hidden_impatient', 'hidden_nap', 'hidden_almost', 'hidden_punctual', 'hidden_tenth', 'hidden_fullCollection', 'hidden_museum', 'hidden_boiledEgg', 'hidden_midnight', 'hidden_stubborn', 'hidden_atomic'];

const gArt = (id, cls) => art(id, GEN_BG[id], cls);
const sArt = (id, cls) => art(SKILL_ART[id][0], SKILL_ART[id][1], cls);
const genName = (id) => P('gen_' + id);
const short = (inner, cap, h) => frame(cap, inner, { style: `height:${h || 330}px` });
const dialMini = (dig, cls, pop, cap) => `<div class="ph-in" style="justify-content:center"><div class="g-dial" style="margin-top:34px">${pop ? `<div class="pop">${pop}</div>` : ''}<div class="dig ${cls || ''}">${dig}</div>${cap ? `<div class="cap">${cap}</div>` : ''}</div></div>`;
const statRow = (l, v) => `<div class="g-stat"><span>${l}</span><b>${v}</b></div>`;
const setRow = (l, h, ctl) => `<div class="g-set"><div><div class="l">${l}</div>${h ? `<div class="h">${h}</div>` : ''}</div>${ctl || ''}</div>`;
const sw = (on) => `<div class="g-sw ${on ? '' : 'off'}"></div>`;
const heading = (h) => `<div class="g-h">${h}</div>`;

/* ======================================================= */
group('Ekran gry');

screen('glowny', 'Ekran główny', () => {
  const main = `<div class="ph-in">${topBar()}${balance({ t: true })}
    <div class="g-row" style="margin-top:6px"><div class="g-pill teal">${img('television')}${T('adTurbo')}</div><div class="g-play">▶</div><div class="g-pill gold">${img('television')}${T('adGolden')}</div></div>
    <div style="position:relative"><div class="g-dial"><div class="dig">00.00</div><div class="cap">${T('tapToStart')}</div></div>
      <div class="g-side" style="left:-4px">${img('grandpa')}<div>04.54<br>—</div></div><div class="g-side" style="right:-4px">${img('grandma')}<div>05.06<br>—</div></div></div>
    <div class="g-combo"><b>${T('comboLabel')} ×1,55</b> 🔥<span>${T('streakLabel', { count: 3, target: 5 })}</span></div>
    <div style="text-align:center;margin-top:6px"><span class="g-pill">${T('modeBlind', { mult: 3 })}</span></div>
    <div class="g-tabs"><span class="g-tab on">${T('tabClocks')}</span><span class="g-tab">${T('tabSkills')}</span><span class="g-amt on">×1</span><span class="g-amt">×10</span><span class="g-amt">${T('buyAmountNext')}</span><span class="g-amt">${T('buyAmountMax')}</span></div>
    <div style="margin-top:8px">${card({ art: gArt('grandpa'), name: T('gen_grandpa'), sub: `${T('unitRate', { value: '3,9' })} · ${T('generatorTotal', { perSecond: '349,7/s' })}`, more: `<div class="prog">${T('milestoneProgress', { owned: 90, next: 100, mult: 2 })}</div>`, btn: btn('4,35M') })}</div></div>`;
  const modes = `<div class="ph-in">${topBar()}${balance()}
    <div style="text-align:center;margin-top:8px;display:flex;gap:6px;justify-content:center;flex-wrap:wrap">
      <span class="g-chip gold">${T('chipFrenzy', { mult: 7 })} · 0:12</span><span class="g-chip pink">${T('chipHotHand')} · 0:20</span></div>
    <div class="g-dial"><div class="dig">00.00</div><div class="cap">${T('pausedTapToPlay')}</div></div>
    <div class="g-combo"><b>${T('comboLabel')} ×1,20</b></div>
    <div style="display:flex;flex-direction:column;gap:6px;align-items:center;margin-top:10px">
      <span class="g-pill dark">${T('modeBlind', { mult: 3 })}<small>${T('modeNextRound')}</small></span>
      <span class="g-pill">${T('modeSecond')}</span><span class="g-pill">${T('modeAuto')}</span>
      <span class="g-pill" style="background:var(--lilac)">${T('loopNumber', { n: 3 })} · ${P('rule_blindfold')} + ${P('rule_noGold')}</span></div></div>`;
  const a11y = `<div class="ph-in">${topBar(true)}${balance({ tips: true })}
    <div class="g-dial"><div class="dig">00.00</div><div class="cap">${T('arenaLabel')}</div></div>
    <div style="text-align:center;margin-top:16px;display:flex;gap:8px;justify-content:center"><span class="g-pill">${T('pause')}</span><span class="g-pill">${T('resume')}</span></div>
    <p class="g-dim" style="text-align:center;margin-top:10px">Te podpisy czyta czytnik ekranu (TalkBack) i pokazują się w dymkach po przytrzymaniu.</p></div>`;
  return frame('Zwykły widok', main) + frame('Tryby, efekty, pauza, pętla', modes) + frame('Podpisy przycisków (dostępność)', a11y);
}, 'Główny ekran z grą. Kliknij dowolny tekst w makiecie, żeby go edytować po prawej. Liczby są przykładowe.');

screen('runda', 'Wynik rundy', () => {
  const v = [
    ['05.00', 'orange', T('tierPerfect', null, { cls: 'g-pop' }), 'Trafienie idealne'],
    ['05.03', '', `<span class="g-pop great">${T('tierGreat')}</span>`, 'Bardzo blisko'],
    ['05.09', '', `<span class="g-pop good">${T('tierGood')}</span>`, 'Blisko'],
    ['04.52', '', `<span class="g-pop miss">${T('missEarly')}</span>`, 'Za wcześnie'],
    ['05.31', '', `<span class="g-pop miss">${T('missLate')}</span>`, 'Za późno'],
    ['04.86', '', `<span class="g-pop miss">${T('missClose')}</span>`, 'Pudło, ale tuż obok'],
    ['05.07', '', `<span class="g-pop small">${T('luckyBump')}</span>`, 'Szczęście podbiło wynik (umiejętność Szczęście)'],
    ['05.42', '', `<span class="g-pop small">${T('shieldSaved')}</span>`, 'Tarcza uratowała combo'],
    ['05.00', 'orange', `<span class="g-pop small">${T('springWound', { minutes: 30 })}</span>`, 'Równo 5.00 dokręca Sprężynę'],
    ['05.00', 'orange', `<span class="g-pop small">${T('springEmpty')}</span>`, 'Równo 5.00, ale zapas Sprężyny pusty'],
  ];
  return v.map(([d, c, pop, cap]) => short(dialMini(d, c, pop), cap)).join('');
}, 'Napisy, które wyskakują nad stoperem po zatrzymaniu.');

screen('zlota', 'Złota Sekunda', () => {
  return short(dialMini('00.00', '', `<span class="g-pop small">${T('goldenRound')}</span>`), 'Złota runda się zaczyna')
    + short(dialMini('05.40', '', `<span class="g-pop small miss">${T('goldenEscaped')}</span>`), 'Złota Sekunda uciekła')
    + short(dialMini('05.00', 'orange', `<span class="g-pop small">${T('goldenFrenzy', { mult: 7 })}</span>`), 'Efekt: Szał')
    + short(dialMini('05.00', 'orange', `<span class="g-pop small">${T('goldenLucky', { amount: '12,5M' })}</span>`), 'Efekt: Fart')
    + short(dialMini('05.00', 'orange', `<span class="g-pop small">${T('goldenHotHand')}</span>`), 'Efekt: Gorąca ręka')
    + short(`<div class="ph-in" style="justify-content:center;align-items:center;gap:10px"><span class="g-chip gold">${T('chipFrenzy', { mult: 7 })} · 0:12</span><span class="g-chip pink">${T('chipHotHand')} · 0:20</span></div>`, 'Plakietki trwających efektów', 200);
});

screen('reklamy-przyciski', 'Przyciski reklam', () => {
  const row = (l, r) => `<div class="g-row" style="margin:8px 0">${l}<div class="g-play">▶</div>${r}</div>`;
  const pill = (cls, label, sub) => `<div class="g-pill ${cls}">${img('television')}<div>${label}${sub ? `<small>${sub}</small>` : ''}</div></div>`;
  const inner = `<div class="ph-in">${topBar()}${balance()}
    <p class="g-dim">Zwykle:</p>${row(pill('teal', T('adTurbo')), pill('gold', T('adGolden')))}
    <p class="g-dim">Turbo trwa:</p>${row(pill('teal', T('adTurboLeft', { time: '12:30' })), pill('gold off', T('adGolden'), T('adCooldown', { time: '4:59' })))}
    <p class="g-dim">Pełny zapas Turbo / zasada pętli blokuje:</p>${row(pill('teal off', T('adTurbo'), T('adFull')), pill('gold off', T('adGolden'), T('adBlockedRule')))}
    <p class="g-dim">Reklama niedostępna (przycisk zakupu):</p><div style="text-align:center">${btn(T('adUnavailable'), 'off')}</div>
    <p class="g-dim">Po utracie combo:</p><div class="g-box gold" style="text-align:center;font-weight:800">${T('adRescue', { count: '×1,55' })} · 5</div></div>`;
  return frame('Stany przycisków', inner);
});

screen('cel', 'Następny cel', () => {
  const goal = (k, a) => `<div class="g-box" style="margin-top:8px;font:700 13px Nunito;text-align:center">${R(k, a)}</div>`;
  return frame('Pasek „Cel” pod licznikiem – wszystkie rodzaje', `<div class="ph-in">${topBar()}${balance()}
    ${goal('goalBonus', { name: genName('grandma'), have: 40, need: 50, mult: 2 })}
    ${goal('goalNewClock', { name: genName('cuckoo') })}
    ${goal('goalUnlockClock', { n: 13, have: 12, need: 25 })}
    ${goal('goalNewLoopChapter')}
    ${goal('goalNewLoop')}</div>`);
}, 'Jeden z tych tekstów pokazuje się pod licznikiem Tików jako najbliższy cel.');

screen('samouczek', 'Samouczek', () => {
  const coach = (txtH, ok, skip, cap, extra) => frame(cap, `<div class="ph-in">${topBar()}${balance()}<div class="g-dial"><div class="dig">00.00</div></div>${extra || ''}<div style="margin-top:14px">
    <div class="g-coach">${txtH}${ok ? `<div><span class="ok">${ok}</span></div>` : ''}${skip ? `<span class="skip">${T('skip')}</span><div style="clear:both"></div>` : ''}</div></div></div>`);
  return coach(T('tutorialAim'), null, true, '1. Celowanie')
    + coach(R('tutorialEarned', { cost: '15' }), null, true, '2. Pierwsze Tiki')
    + coach(T('tutorialBuy'), null, true, '3. Kup zegar')
    + coach(R('tutorialInfo', { rate: '0,1' }), T('tutorialGotIt'), true, '4. Co robi zegar')
    + coach(T('tutorialAutoStart'), T('tutorialGotIt'), false, '5. Automatyczny start')
    + coach(R('tutorialEarnedReplay'), T('tutorialGotIt'), false, 'Powtórka samouczka (z Pomocy)');
});

screen('podpowiedzi', 'Podpowiedzi', () => {
  const tip = (k, a, cap) => short(`<div class="ph-in" style="justify-content:center"><div class="g-coach">${R(k, a)}<div><span class="ok">${P('tutorialGotIt')}</span></div></div></div>`, cap, 260);
  return tip('tip_skills', null, 'Zakładka Umiejętności') + tip('tip_milestone', { need: 10 }, 'Pasek bonusu zegara') + tip('tip_modes', null, 'Tryby gry')
    + tip('tip_combo', null, 'Combo') + tip('tip_golden', null, 'Złota Sekunda') + tip('tip_prestige', null, 'Paradoks')
    + tip('tip_springs', null, 'Sprężyny') + tip('tip_challenges', null, 'Wyzwania') + tip('tip_loop', null, 'Nowa pętla (bez zasady)')
    + tip('tip_loopRule', { rule: P('rule_blindfold') }, 'Nowa pętla z zasadą Chronosa');
}, 'Jednorazowe dymki, które pokazują się, gdy gracz pierwszy raz trafi na daną rzecz.');

screen('toasty', 'Wyskakujące okienka u góry', () => {
  const top = (h, cap) => short(`<div class="ph-in">${topBar()}${balance()}</div><div class="over top">${h}</div>`, cap, 260);
  return top(toast(art('trophy', '#FFE29A', 'sm'), T('achievementUnlocked'), P('ach_perfects', { count: 100 })), 'Nowe osiągnięcie')
    + top(toast(art('trophy', '#FFE29A', 'sm'), T('achievementsUnlocked', { count: 3 }), P('ach_perfects', { count: 100 })), 'Kilka osiągnięć naraz')
    + top(toast(gArt('grandpa', 'sm'), T('milestoneToast', { name: P('upg_grandpa_1') }), T('milestoneTitle', { generator: genName('grandpa'), mult: 2 })), 'Nowy bonus zegara')
    + top(toast(gArt('cuckoo', 'sm'), T('synergyToast'), P('syn_birdRhythm')), 'Synergia')
    + top(toast(art('sun_with_face', '#FFE29A', 'sm'), T('dialToast'), P('dial_wood')), 'Nowa tarcza')
    + top(toast(gArt('chronos', 'sm'), T('loopBonusToast'), T('loopBonusToastBody', { count: 1 })), 'Bonus Chronosa w pętli');
});

screen('komunikaty', 'Komunikaty na dole ekranu', () => {
  const sn = (h, cap) => short(`<div class="ph-in">${topBar()}${balance()}</div>${h}`, cap, 250);
  return sn(snack(T('saveCorrupt')), 'Uszkodzony zapis')
    + sn(snack(T('updateReady'), { action: T('updateRestart') }), 'Gotowa aktualizacja')
    + sn(snack(P('chGreat', { n: 10 }), { title: T('challengeDone'), action: T('challengeOpen'), art: art('bullseye', '#FFE29A', 'sm') }), 'Wyzwanie ukończone')
    + sn(snack(R('challengeCarry', { what: `+1,2M ${P('tikiLabel')} · ${P('challengeCarrySprings', { count: 2 })}` }) + `<br>${R('challengeCarrySprings', { count: 2 })}`), 'Nagrody z wczoraj')
    + sn(snack(R('challengeBonusPaid', { amount: '5M' })), 'Premia za wszystkie wyzwania')
    + sn(snack(R('seasonCompleted', { name: P('season_christmas'), amount: '50M' })), 'Sezon ukończony')
    + sn(snack(T('settingsExportDone')), 'Eksport zapisu')
    + sn(snack(T('settingsImportBad')), 'Zły kod importu')
    + sn(snack(T('settingsCloudNothing')), 'Brak zapisu w chmurze');
});

screen('reklama-po', 'Po obejrzeniu reklamy', () => {
  const sn = (k, a, cap) => short(`<div class="ph-in">${topBar()}${balance()}</div>${snack(R(k, a))}`, cap, 230);
  return sn('adDoneTurbo', { time: '30:00' }, 'Turbo') + sn('adDoneGolden', null, 'Złota Sekunda') + sn('adDoneBag', null, 'Worek Tików')
    + sn('adDoneRescue', null, 'Ratunek combo') + sn('adDoneOffline', null, 'Podwójny dochód offline') + sn('adDoneSpring', null, 'Sprężyna')
    + sn('adNoReward', null, 'Reklama przerwana') + sn('adShowFailed', null, 'Reklama się nie wyświetliła');
});

/* ======================================================= */
group('Sklep');

screen('zegary-lista', 'Lista zegarów', () => {
  const list = `<div class="ph-in" style="padding-top:20px">
    <div class="g-tabs" style="margin:0 0 10px"><span class="g-tab on">${T('tabClocks')}</span><span class="g-tab">${T('tabSkills')}</span></div>
    ${card({ art: gArt('grandpa'), name: T('gen_grandpa'), sub: `${T('unitRate', { value: '3,9' })} · ${T('generatorTotal', { perSecond: '349,7/s' })}`, more: `<div class="prog">${T('milestoneProgress', { owned: 90, next: 100, mult: 2 })}</div>`, btn: btn('4,35M') })}
    ${card({ art: gArt('grandma'), name: T('gen_grandma'), sub: `${T('unitRate', { value: '24,2' })} · ${T('generatorTotal', { perSecond: '1,81K/s' })}`, more: `<div class="prog">${T('milestoneMax')}</div>`, btn: btn('3,57M') })}
    ${card({ art: gArt('timeMachine'), name: T('gen_timeMachine'), sub: T('generatorEarnsEach', { value: '86,5M/s' }), desc: T('gen_timeMachine_desc'), btn: btn('14,0T') })}
    ${card({ art: art('locked', '#ddd'), name: T('lockedName'), sub: T('lockedHint'), btn: btn('???', 'off') })}
    ${card({ art: art('money_bag', '#FFE6A7'), name: R('adBag', { minutes: 30 }), btn: btn('📺', 'gold') })}</div>`;
  return frame('Zakładka Zegary', list);
}, 'Karty zegarów: kupiony, z maksymalnym bonusem, jeszcze niekupiony (z opisem), zablokowany oraz worek za reklamę.');

screen('zegar-szczegoly', 'Szczegóły zegara', () => {
  const bonus = (i, cnt, m, on) => `<div class="g-box" style="${on ? '' : 'opacity:.55'}"><div style="font-weight:800">${T('generatorBonusLine', { count: cnt, name: P(`upg_grandpa_${i}`), mult: m })}</div><div class="g-quote">${P(`upg_grandpa_${i}_desc`)}</div></div>`;
  const c = `<div style="text-align:center">${gArt('grandpa', 'big')}<div class="f-d" style="font-size:22px;margin-top:6px">${T('gen_grandpa')}</div><div class="g-quote">${T('gen_grandpa_desc')}</div>
    <div style="margin-top:6px">${T('generatorEarnsEach', { value: '3,9' })}</div><div>${T('generatorTotal', { perSecond: '349,7/s' })}</div></div>
    ${heading(T('generatorBonuses'))}${bonus(1, 10, 2, true)}${bonus(2, 25, 2, true)}${bonus(3, 50, 2, false)}
    ${heading(T('generatorSynergies'))}<div class="g-box"><div style="font-weight:800">${T('generatorSynergyOn', { name: P('syn_grandparents') })}</div><div class="g-dim">${T('generatorSynergyEffect', { pct: '1', other: genName('grandma') })}</div></div>
    <div class="g-box"><div style="font-weight:800">???</div><div class="g-dim">${T('generatorSynergyNeeds', { need: 25, a: genName('grandpa'), aOwned: 90, b: genName('cuckoo'), bOwned: 12 })}</div></div>`;
  return overSheet(T('gen_grandpa'), c, 'Okno po dotknięciu zegara', { h: '94%' });
}, 'Nazwy i opisy bonusów (ulepszeń) wszystkich zegarów edytujesz w Katalog → Ulepszenia zegarów.');

screen('umiejetnosci', 'Lista umiejętności', () => {
  const sk = (id, sub, b) => card({ art: sArt(id), name: T('skill_' + id), sub, btn: b });
  const list = `<div class="ph-in" style="padding-top:20px">
    <div class="g-tabs" style="margin:0 0 10px"><span class="g-tab">${T('tabClocks')}</span><span class="g-tab on">${T('tabSkills')}</span></div>
    ${sk('power', T('skillEffect', { label: P('skill_power_label'), now: '×1,4', next: '×1,6' }), btn('1,5M', '', T('skillBuyLevel', { level: 4 })))}
    ${sk('magnet', T('skillOdds', { tier: P('oddsPerfect'), now: 8, next: 11 }), btn('2,1M', '', T('skillBuyLevel', { level: 2 })))}
    ${sk('wideEye', T('skillOddsMax', { tier: P('oddsGreatOrBetter'), now: 40 }), btn(T('skillMaxed'), 'off'))}
    ${sk('ticking', T('skillEffectMax', { label: P('skill_ticking_label'), now: P('on') }), btn(T('skillMaxed'), 'off'))}
    ${sk('luck', `${P('skill_luck_label')}: ${T('inHundred', { n: 5 })}`, btn('900K'))}
    ${card({ art: art('locked', '#ddd'), name: T('lockedName'), sub: R('skillLockedHint', { price: '1,5M' }), btn: btn('???', 'off') })}</div>`;
  const extra = `<div class="ph-in" style="padding-top:20px">${sk('bulletTime', T('skillOdds', { tier: P('oddsHits'), now: 60, next: 64 }), btn('5M'))}
    ${sk('goldenTouch', R('perfectNow', { amount: '1,2M' }), btn('5M'))}
    ${sk('echo', R('perfectNowSeconds', { amount: '1,2M', seconds: '3,2' }), btn('5M'))}
    ${sk('ticking', `${P('skill_ticking_label')}: ${T('off')} / ${T('on')}`, btn('5M'))}</div>`;
  return frame('Zakładka Umiejętności', list) + frame('Inne opisy efektu', extra);
});

screen('umiejetnosc-szczegoly', 'Szczegóły umiejętności', () => {
  const c = (variant) => `<div style="text-align:center">${sArt('power', 'big')}<div class="f-d" style="font-size:22px;margin-top:6px">${T('skill_power')}</div>
    <div>${T('skillLevel', { level: 3, max: 10 })}</div></div>
    <p style="margin:8px 0 4px">${R('skill_power_desc')}</p><p class="g-dim" style="margin:0 0 8px">${R('skill_power_info')}</p>
    <div class="g-box" style="font-weight:800">${T('skillEffect', { label: P('skill_power_label'), now: '×1,4', next: '×1,6' })}</div>
    <div class="g-box lilac" style="font-size:13px">${variant === 1 ? R('skillKeptInfo', { kept: 1, share: 50 }) : variant === 2 ? R('skillKeptHabit') : R('skillKeptNone')}</div>
    <div style="text-align:center;margin:10px 0">${variant === 1 ? `<span class="g-pill">${T('skillHabitAdd', { used: 1, slots: 2 })}</span>` : variant === 2 ? `<span class="g-pill">${T('skillHabitRemove')}</span>` : `<span class="g-pill">${T('skillHabitMove', { skill: P('skill_magnet') })}</span>`}</div>
    <div style="text-align:center">${btn('1,5M', 'wide', T('skillBuyLevel', { level: 4 }))}</div>`;
  return overSheet(T('skill_power'), c(1), 'Po paradoksie część poziomów zostaje', { h: '94%' })
    + overSheet(T('skill_power'), c(2), 'W slocie Nawyku', { h: '94%' })
    + overSheet(T('skill_power'), c(3), 'Bez Pamięci mięśniowej / pełne sloty', { h: '94%' });
}, 'Nazwy, opisy i dopiski wszystkich umiejętności edytujesz w Katalog → Umiejętności.');

/* ======================================================= */
group('Okna');

screen('powitanie', 'Powrót do gry', () => {
  const offline = (capped) => `<div class="g-box" style="text-align:center"><div style="font:28px Paytone">+12,5M</div><div>${T('offlineBody', { duration: '9 godz. 12 min' })}</div>${capped ? `<div class="g-dim">${T('offlineCapped', { duration: '8 godz.' })}</div>` : ''}</div>`;
  const daily = (grace) => `<div class="g-box gold" style="text-align:center;margin-top:8px"><div class="f-d" style="font-size:18px">${T('dailyTitle')}</div><div>${T('dailyDay', { day: 4, total: 7 })}</div>
    <div style="font:24px Paytone;margin:4px 0">+3,2M</div>${grace ? `<div style="font-size:13px;font-weight:800">${T('dailyGrace')}</div>` : ''}<div class="g-dim">${T('dailyHint', { total: 7 })}</div></div>`;
  const dlg = (title, body, both) => ({ art: art('wrapped_gift', '#FFE29A', 'big'), title, extra: body, btns: btn(both ? T('collectAll') : T('collect'), 'wide') + btn(T('adDouble'), 'gold wide') });
  return overDialog(dlg(T('offlineTitle'), offline(true)), 'Tylko dochód offline (z limitem)')
    + overDialog(dlg(T('dailyTitle'), daily(true)), 'Tylko dzienna premia')
    + overDialog(dlg(T('welcomeTitle'), offline(false) + daily(false) + `<p style="font-weight:800;margin:10px 0 0">${T('welcomeSeason', { season: P('season_christmas') })}</p>`, true), 'Oba naraz + trwa sezon');
});

screen('zgody', 'Zgody i pytania', () => {
  return overDialog({ art: art('bell', '#FFE29A', 'big'), title: T('notificationAsk'), body: R('notificationAskBody'), btns: btn(T('notificationAskYes'), 'wide') + link(T('notificationAskNo')) }, 'Powiadomienia')
    + overDialog({ art: art('bar_chart', '#B4D8FF', 'big'), title: T('statsAskTitle'), body: R('statsAskBody'), btns: btn(T('statsAskYes'), 'wide') + link(T('statsAskNo')) }, 'Statystyki anonimowe');
});

screen('chmura', 'Zapis w chmurze', () => overDialog({ art: art('package', '#B4D8FF', 'big'), title: T('cloudOfferTitle'),
  body: `<div style="text-align:left">${R('cloudOfferBody', { cloudTime: '31 godz.', cloudEarned: '3,4B', localTime: '12 godz.', localEarned: '1,25M' })}</div>`,
  btns: btn(T('cloudLoad'), 'wide') + link(T('cloudKeep')) }, 'Znaleziono lepszy zapis w Google Play Gry'));

screen('reklama-oferta', 'Oferty reklam', () => {
  const offer = (artH, title, reward, detail) => `<div style="text-align:center">${artH}<div class="f-d" style="font-size:22px;margin-top:8px">${title}</div>
    <div style="font:20px Paytone;color:var(--orangeText);margin:6px 0">${reward}</div><div style="white-space:pre-line">${detail}</div>
    <p class="g-dim">${T('adOfferHow')}</p>${btn(T('adWatch'), 'wide')}${link(T('adNotNow'))}</div>`;
  const o = { h: 'auto', frame: {} };
  return overSheet('', offer(art('high_voltage', '#B8F0E6', 'big'), T('adOfferTurboTitle'), T('adOfferTurboReward', { mult: 2, minutes: 30 }), `${R('adOfferTurboDetail', { hours: 4 })}\n${T('adOfferTurboStock', { time: '12:30' })}`), 'Turbo', o)
    + overSheet('', offer(art('glowing_star', '#FFE6A7', 'big'), T('adOfferGoldenTitle'), T('adOfferGoldenReward'), R('adOfferGoldenDetail')), 'Złota Sekunda', o)
    + overSheet('', offer(art('money_bag', '#FFE6A7', 'big'), T('adOfferBagTitle'), '+1,2M', R('adOfferBagDetail', { minutes: 30 })), 'Worek Tików', o);
});

screen('sezon', 'Wydarzenie sezonowe', () => {
  const body = (done) => `<p>${T('seasonUntil', { date: '27 grudnia' })}</p><p>${R('seasonHow')}</p>
    <div class="g-box" style="display:flex;justify-content:space-between"><span>🎁 ${P('season_christmas_items')}</span><b>3/5</b></div>
    <div class="g-box" style="display:flex;justify-content:space-between"><span>🎯 ${T('seasonHits')}</span><b>40/50</b></div>
    <p style="font-weight:800">${done ? R('seasonDone', { name: P('season_christmas') }) : R('seasonReward', { amount: '50M', name: P('season_christmas') })}</p>`;
  return overDialog({ art: art('christmas_tree', '#C9F1D6', 'big'), title: T('season_christmas'), extra: body(false), btns: btn(T('seasonStart'), 'wide') }, 'W trakcie')
    + overDialog({ art: art('christmas_tree', '#C9F1D6', 'big'), title: T('season_christmas'), extra: body(true), btns: btn(P('seasonStart'), 'wide') }, 'Ukończone');
}, 'Nazwy i przedmioty wszystkich sezonów edytujesz w Katalog → Sezony.');

screen('potwierdzenia', 'Potwierdzenia', () => {
  return overDialog({ body: R('prestigeConfirm1'), row: btn(T('cancel'), 'off') + btn(T('yes')) }, 'Paradoks – pytanie 1')
    + overDialog({ body: R('prestigeConfirm2'), row: btn(P('cancel'), 'off') + btn(P('yes')) }, 'Paradoks – pytanie 2')
    + overDialog({ body: R('settingsImportConfirm'), extra: `<div class="field">${T('settingsImportHint')}</div>`, row: btn(P('cancel'), 'off') + btn(T('settingsImport')) }, 'Import zapisu')
    + overDialog({ body: R('settingsResetConfirm1'), row: btn(P('cancel'), 'off') + btn(T('settingsReset')) }, 'Reset – pytanie 1')
    + overDialog({ body: R('settingsResetConfirm2', { word: P('resetWord') }), extra: `<div class="field">${T('resetWord')}</div>`, row: btn(P('cancel'), 'off') + btn(P('settingsReset')) }, 'Reset – wpisz słowo');
});

/* ======================================================= */
group('Ekrany');

screen('paradoks', 'Paradoks', () => {
  const perk = (id, state) => card({ art: art(PERK_ART[id], '#E2D2FF', 'sm'), name: T('perk_' + id), desc: R('perk_' + id + '_desc'),
    more: state === 'req' ? `<div class="g-dim">${T('perkRequires', { name: P('perk_muscleMemory1') })}</div>` : '',
    btn: state === 'owned' ? btn(T('perkOwned'), 'off') : btn('3', state === 'req' ? 'off' : '') });
  const main = `<div style="text-align:center">${art('cyclone', '#E2D2FF', 'big')}</div>
    <p style="text-align:center;margin:6px 0">${R('prestigeChronons', { count: 12, mult: '×2,2' })}<br>${R('prestigeShards', { count: 3 })}</p>
    <div class="g-box lilac" style="text-align:center"><div class="f-d" style="font-size:20px">${R('prestigeGain', { count: 4 })}</div><div>${T('prestigeGainMult', { from: '×2,2', to: '×2,6' })}</div></div>
    <div style="text-align:center;margin:10px 0">${btn(T('prestigeButton'), 'wide')}</div>
    ${heading(T('perksTitle'))}${perk('headStart', 'owned')}${perk('muscleMemory2', 'req')}
    ${heading(T('prestigeHabitTitle', { used: 1, slots: 2 }))}`;
  const none = `<div style="text-align:center">${art('cyclone', '#E2D2FF', 'big')}</div><p style="text-align:center">${R('prestigeChronons', { count: 0, mult: '×1' })}</p>
    <div class="g-box lilac" style="text-align:center">${R('prestigeNext', { amount: '1,5B' })}</div>`;
  const pending = `<div style="text-align:center;margin-top:30px">${art('cyclone', '#E2D2FF', 'big')}<div class="f-d" style="font-size:22px;margin:10px 0">${R('prestigePendingTitle', { count: 4 })}</div>
    <p>${R('prestigePendingBody')}</p>${btn(T('prestigeStartRun'), 'wide')}</div>`;
  return overSheet(T('prestigeTitle'), main, 'Można zrobić paradoks', { h: '94%' }) + overSheet(T('prestigeTitle'), none, 'Za mało, żeby zrobić paradoks', { h: '70%' })
    + overSheet(T('prestigeTitle'), pending, 'Po paradoksie (przed startem nowego biegu)', { h: '80%' });
}, 'Wszystkie perki z opisami są w Katalog → Perki paradoksu.');

screen('osiagniecia', 'Osiągnięcia', () => {
  const tile = (n, name, lock) => `<div class="g-tile ${lock ? 'lock' : ''}">${art(n, '#FFE29A', 'sm')}${name}</div>`;
  const c = `<p style="text-align:center;font-weight:800">${T('achievementsSummary', { count: 37, total: 120, percent: 37 })}</p>
    <div class="g-grid">${tile('glowing_star', P('ach_perfects', { count: 100 }))}${tile('fire', P('ach_combo', { count: '×2' }))}${tile('coin', P('ach_earned', { amount: '1M' }))}
    ${tile('red_question_mark', T('hiddenAchievement'), 1)}${tile('locked', T('undiscoveredAchievement'), 1)}${tile('trophy', P('ach_achievements', { count: 10 }))}</div>`;
  return overSheet(T('achievementsTitle'), c, 'Ekran osiągnięć', { h: '80%' });
}, 'Nazwy i opisy wszystkich osiągnięć są w Katalog → Osiągnięcia.');

screen('statystyki', 'Statystyki', () => {
  const c = `${statRow(T('statEarnedRun'), '12,5T')}${statRow(T('statEarnedTotal'), '39,5T')}${statRow(T('statRounds'), '4 210')}
    ${statRow(T('tierPerfect'), '9%')}${statRow(T('tierGreat'), '22%')}${statRow(T('tierGood'), '31%')}${statRow(`${T('missEarly')} / ${T('missLate')}`, '38%')}
    ${statRow(`${T('statTypical')} (${T('statTypicalHint')})`, T('ms', { value: '41,2' }))}${statRow(`${T('statMeanError')} (${T('statMeanHint')})`, P('ms', { value: '-8,1' }))}
    ${statRow(T('statAccidental'), '12')}${statRow(T('statBestStreak'), '7')}${statRow(T('statBestCombo'), '×2,4')}${statRow(T('statGolden'), '58')}
    ${statRow(T('statPlayTime'), '14 godz.')}${statRow(T('statPrestiges'), '6')}${statRow(T('statLoop'), '2')}${statRow(T('statChronons'), '12')}
    ${heading(T('statMultTitle'))}${statRow(T('statMultChronons', { count: 12 }), '×2,2')}${statRow(T('statMultAchievements', { count: 37 }), '×1,37')}
    ${statRow(T('statMultLevels'), '×1,5')}${statRow(T('statMultTurbo'), '×2')}${statRow(T('statMultTotal'), '×9,0')}`;
  return overSheet(T('statsTitle'), c, 'Statystyki', { h: '97%' });
});

screen('pomoc', 'Pomoc', () => {
  const sec = (n, t, b) => `<div class="g-box"><div style="display:flex;gap:8px;align-items:center">${art(n, '#FFE29A', 'sm')}<b class="f-d" style="font-weight:400;font-size:16px">${t}</b></div><div style="font-size:13.5px;margin-top:6px;white-space:pre-line">${b}</div></div>`;
  const res = [R('help_res_tiki'), R('help_res_chronon'), R('help_res_shard'), R('help_res_spring')].join('<br>');
  const a = [sec('chronos', T('help_goal_t'), R('help_goal')), sec('stopwatch', T('help_round_t'), R('help_round')), sec('coin', T('help_tiki_t'), R('help_tiki')),
    sec('money_bag', T('help_res_t'), res), sec('shopping_cart', T('help_clocks_t'), R('help_clocks')), sec('fire', T('help_combo_t'), R('help_combo')),
    sec('sparkles', T('help_upgrades_t'), R('help_upgrades')), sec('flexed_biceps', T('help_skills_t'), R('help_skills'))].join('');
  const b = [sec('glowing_star', T('help_golden_t'), R('help_golden')), sec('bullseye', T('help_challenges_t'), R('help_challenges')), sec('see_no_evil_monkey', T('help_modes_t'), R('help_modes')),
    sec('wrapped_gift', T('help_season_t'), R('help_season')), sec('cyclone', T('help_prestige_t'), R('help_prestige'))].join('');
  const c = [sec('gear', T('help_springs_t'), R('help_springs')), sec('classical_building', T('help_loop_t'), R('help_loop')), sec('sun_with_face', T('help_dials_t'), R('help_dials')),
    sec('red_question_mark', T('help_icons_t'), R('help_icons')), `<div class="g-box" style="text-align:center;opacity:.6">🔒 ${T('helpLocked')}</div>`,
    `<div style="text-align:center;margin-top:10px"><span class="g-pill">${T('helpReplay')}</span></div>`].join('');
  const o = { full: true, frame: { cls: 'auto' } };
  return frame('Część 1', `<div class="ph-in" style="position:relative">${sheet(T('helpTitle'), a, { full: true })}</div>`, { cls: 'auto' })
    + frame('Część 2', `<div class="ph-in" style="position:relative">${sheet(T('helpTitle'), b, { full: true })}</div>`, { cls: 'auto' })
    + frame('Część 3', `<div class="ph-in" style="position:relative">${sheet(T('helpTitle'), c, { full: true })}</div>`, { cls: 'auto' });
}, 'Sekcje pomocy odblokowują się w trakcie gry; zablokowane pokazują napis z kłódką.');

screen('ustawienia', 'Ustawienia', () => {
  const seg = (opts, on) => `<div class="g-seg">${opts.map((o, i) => `<span class="${i === on ? 'on' : ''}">${o}</span>`).join('')}</div>`;
  const a = `${setRow(T('settingsSound'), '', sw(1))}${setRow(T('settingsMusic'), '', sw(1))}${setRow(T('settingsHaptics'), '', sw(0))}
    ${setRow(T('settingsNotifications'), T('settingsNotificationsHint'), sw(1))}
    ${setRow(T('settingsLanguage'), seg([T('languageSystem'), 'Polski', 'English'], 0))}
    ${setRow(T('settingsNotation'), seg([T('notationShort'), T('notationScientific')], 0))}
    ${setRow(T('settingsReduceMotion'), T('settingsReduceMotionHint'), sw(0))}
    ${setRow(T('themeTitle'), T('themeHint') + seg([T('themeAuto'), T('themeClassic'), P('season_christmas')], 0))}
    ${setRow(T('settingsCalibration', { offset: '+12 ms' }), T('settingsCalibrationHint', { offset: '+12 ms' }), '›')}`;
  const b = `${heading(T('settingsCloud'))}<div class="g-dim">${T('settingsCloudOn')} / ${T('settingsCloudOff')}</div>
    <div style="display:flex;flex-wrap:wrap;gap:6px;margin:8px 0"><span class="g-pill">${T('settingsCloudConnect')}</span><span class="g-pill">${T('settingsCloudRestore')}</span></div>
    ${heading(T('settingsSave'))}<div style="display:flex;gap:6px;flex-wrap:wrap"><span class="g-pill">${T('settingsExport')}</span><span class="g-pill">${T('settingsImport')}</span><span class="g-pill pink">${T('settingsReset')}</span></div>
    ${heading(T('settingsOther'))}${setRow(T('settingsAnalytics'), T('settingsAnalyticsHint'), sw(1))}${setRow(T('settingsPrivacyPolicy'), '', '›')}${setRow(T('settingsAdPrivacy'), '', '›')}${setRow(T('settingsCredits'), '', '›')}
    <div class="g-box" style="margin-top:10px;font-size:12px"><b>${T('appTitle')}</b><br>${T('creditsLegalese')}</div>`;
  return overSheet(T('settingsTitle'), a, 'Górna część', { h: '96%' }) + overSheet(T('settingsTitle'), b, 'Dolna część', { h: '96%' });
});

screen('kalibracja', 'Kalibracja dotyku', () => {
  const big = (t) => `<div class="g-dial" style="width:170px;height:170px"><div class="dig" style="font-size:36px">05.00</div><div class="cap">${t}</div></div>`;
  const start = `<p>${R('calibIntro')}</p><p>${T('calibCurrent', { offset: '+12 ms' })}</p>${btn(T('calibStart'), 'wide')}`;
  const run = `${big(T('calibTapHint'))}<p style="text-align:center">${T('calibNoTap')}</p>`;
  const res = `<p style="font-weight:800">${T('calibResultLate', { ms: 38 })}</p><p class="g-dim">${T('calibResultEarly', { ms: 21 })}<br>${T('calibResultZero')}</p><p style="font-size:14px">${T('calibUnreliable')}</p>
    <div style="display:flex;flex-direction:column;gap:10px">${btn(T('calibApply', { offset: '+38 ms' }), 'wide')}${btn(T('calibRepeat'), 'gold wide')}${btn(T('calibReset'), 'off wide')}</div>`;
  return overSheet(T('calibTitle'), start, 'Start', { h: '70%' }) + overSheet(T('calibTitle'), run, 'W trakcie', { h: '70%' }) + overSheet(T('calibTitle'), res, 'Wynik (trzy możliwe zdania)', { h: '90%' });
});

screen('wyzwania', 'Wyzwania', () => {
  const ch = (k, a, act, p) => `<div class="g-box" style="display:flex;gap:8px;align-items:center">${art('bullseye', '#FFE29A', 'sm')}<div style="flex:1"><div style="font-weight:800;font-size:14px">${R(k, a)}</div><div class="g-bar"><i style="width:${p}%"></i></div></div>${act}</div>`;
  const reroll = `<span title="" style="font-size:20px">🎲</span>`;
  const c = `${heading(T('challengesToday'))}<div class="g-dim">${T('challengesRerollHint')} / ${T('challengesNewTomorrow')}</div>
    ${ch('chGreat', { n: 10 }, btn(T('collect')), 100)}${ch('chStreak', { n: 5 }, `<b>✓ ${T('challengeClaimed')}</b>`, 100)}${ch('chJackpot', { n: 3 }, reroll, 30)}
    <div class="g-dim" style="text-align:right">🎲 = ${T('challengeReroll')}</div>
    <div class="g-box gold" style="text-align:center;font-weight:800">${T('challengeBonus', { done: 2, total: 3 })} · ${T('challengeBonusDone')}</div>
    ${heading(T('challengesWeek'))}<div class="g-dim">${T('challengesDaysLeft', { days: 3 })}</div>${ch('chGolden', { n: 5 }, '', 40)}`;
  const kinds = ['chGreat', 'chStreak', 'chJackpot', 'chPerfectWindow', 'chPerfect', 'chHitEarnings', 'chBuyClocks', 'chMilestones', 'chSkillLevels', 'chGolden', 'chSpring'];
  const all = kinds.map((k) => ch(k, { n: 5, amount: '5M', hours: 2 }, '', 50)).join('');
  return overSheet(T('challengesTitle'), c, 'Ekran wyzwań', { h: '96%' }) + catFrame('Wszystkie rodzaje wyzwań', all)
    + catFrame('Liczby w odmianie (1 / 3 / 5)', [1, 3, 5].map((n) => ch('chBuyClocks', { n }, '', 50) + ch('chGolden', { n }, '', 50)).join('') + [1, 3, 5].map((d) => `<div class="g-dim">${T('challengesDaysLeft', { days: d })}</div>`).join(''));
}, 'Teksty z odmianą liczby (1 zegar / 3 zegary / 5 zegarów) mają zapis {n, plural, …}. Zmieniaj tylko słowa w nawiasach klamrowych, np. few{{n} zegary}.');

screen('sprezyny', 'Sprężyny i mistrzostwo', () => {
  const lvl = (id) => `<div class="g-box" style="display:flex;gap:8px;align-items:center">${gArt(id, 'sm')}<div style="flex:1"><b>${genName(id)}</b>
    <div style="font-size:13px">${T('clockLevelLine', { level: 4, max: 10, mult: '×1,8' })}</div><div class="g-dim">${T('clockLevelTitleAt', { level: 5, title: '???' })}</div></div>${btn(T('clockLevelUp', { cost: 3 }), '')}</div>`;
  const c = `<p style="text-align:center;font:18px Paytone">${R('springsFull', { max: 5 })}<br><span class="g-dim">${T('springsNext', { time: '5 godz. 40 min' })}</span></p>
    <p style="font-size:13.5px">${R('springsIntro', { mult: '×1,2' })}</p><div class="g-box mint">${R('springsRefund', { count: 4 })} <span class="g-chip">${P('tutorialGotIt')}</span></div>
    <div class="g-box"><b>${T('springsReserveTitle')}</b><div>${T('springsReserve', { time: '20 min', max: '1 godz.' })}</div><div class="g-dim">${R('springsReserveHow', { time: '10 min', refill: '6 godz.' })}<br>${R('springsReserveEmpty', { time: '2 godz.' })}</div>
      <div style="margin-top:6px;display:flex;gap:8px;align-items:center">${btn(T('adSpring'), 'gold')}<span class="g-dim">${T('adSpringLeft', { left: 2, max: 3 })}</span></div></div>
    ${heading(T('clockLevelTitle'))}${lvl('grandpa')}<div class="g-box"><b>${genName('chronos')}</b> · <span class="g-dim">${T('clockLevelMax')}</span></div><p class="g-dim">${T('springsNoClocks')}</p>`;
  const badge = `<div class="ph-in" style="justify-content:center;gap:10px;align-items:center"><span class="g-chip">${SPRING_SVG} ${T('springsBadgeHits', { count: 3, hits: 1 })}</span>
    <span class="g-chip">${T('springsBadgeHits', { count: 3, hits: 4 })}</span><span class="g-chip">${T('springsBadgeHits', { count: 3, hits: 0 })}</span>
    <span class="g-chip">${T('springsBadgeFull', { count: 5 })}</span><span class="g-chip gold">${T('springsBadgeMax')}</span></div>`;
  return overSheet(T('springsTitle'), c, 'Ekran Sprężyn', { h: '97%' }) + short(badge, 'Plakietka Sprężyn na ekranie gry (z podpisem)', 420);
}, 'Tytuły mistrzów (stopnie 5 i 10) dla każdego zegara są w Katalog → Tytuły mistrzów.');

screen('tarcze', 'Tarcze stopera', () => {
  const tile = (id, st) => `<div class="g-tile ${st === 'lock' ? 'lock' : ''}">${art('sun_with_face', st === 'on' ? '#FFC300' : '#FFE29A', 'sm')}${st === 'lock' ? T('dialLocked', { amount: '1T' }) : st === 'seal' ? T('dialLockedSeal') : T('dial_' + id)}</div>`;
  const c = `<p class="g-dim">${T('dialHint')}</p><p style="font-weight:800">${T('dialProgress', { have: '39,5T', need: '100T' })}</p>
    <div class="g-grid">${tile('classic', 'on')}${tile('wood')}${tile('porcelain')}${tile('brass', 'lock')}${tile('rift', 'seal')}<div class="g-tile lock">???</div></div>
    <p class="g-quote" style="text-align:center;margin-top:12px">${T('dial_classic_desc')}</p>`;
  return overSheet(T('help_dials_t'), c, 'Wybór tarczy', { h: '80%' })
    + catFrame('Wszystkie tarcze', DIALS.map((d) => card({ art: art('sun_with_face', '#FFE29A', 'sm'), name: T('dial_' + d), desc: T('dial_' + d + '_desc') })).join(''));
});

/* ======================================================= */
group('Fabuła');

screen('prolog', 'Prolog', () => overDialog({ art: gArt('chronos', 'big'), title: T('prologue_t'),
  body: `<div class="g-story" style="text-align:left">${R('prologue')}</div>`, extra: `<div class="g-box gold" style="margin-top:10px;font-weight:800">${R('prologueGoal')}</div>`, btns: btn(T('prologueGo'), 'wide') },
'Na samym początku gry', { cls: 'auto' }));

screen('koniec-petli', 'Koniec pętli', () => {
  const c = `<div style="text-align:center">${gArt('chronos', 'big')}<div class="f-d" style="font-size:24px;margin:8px 0 2px">${T('loopEndTitle')}</div>
    <div class="g-dim">${T('loopNumber', { n: 1 })} · ${T('loopEndStats', { time: '41 godz.', count: 6 })}</div></div>
    <div class="g-box" style="margin-top:10px"><div class="g-dim">${T('loopRewardChapter')}</div><b>${T('chronicleChapter', { n: 1 })}: ${P('chapter_1_t')}</b><div class="g-story" style="font-size:13px;max-height:90px;overflow:hidden">${P('chapter_1')}</div></div>
    <div class="g-box gold"><div class="g-dim">${T('loopRewardSeal')}</div><b>${P('seal_blindfold')}</b><div style="font-size:13px">${P('seal_blindfold_desc')}</div><div style="font-weight:800;font-size:13px">${T('loopRewardDial', { name: P('dial_wood') })}</div></div>
    <div class="g-box lilac"><div class="g-dim">${T('loopNextTitle')}</div><b>${P('rule_inflation')}</b><div style="font-size:13px">${P('rule_inflation_desc')}</div><div class="g-quote">${P('rule_inflation_quote')}</div><div class="g-dim">${T('loopNextSeal')}</div></div>
    <div class="g-box lilac" style="font-size:14px">${T('loopNextFree')}</div>
    <p style="font-size:13px">${R('loopStayHint', { left: 3 })}</p>${btn(T('loopStart'), 'wide')}${link(T('loopStay'))}`;
  return frame('Po kupieniu Chronosa', `<div class="ph-in" style="position:relative">${sheet('', c, { full: true })}</div>`, { cls: 'auto' });
}, 'Okno po ukończeniu pętli. Rozdział, pieczęć i zasada zależą od numeru pętli – ich teksty są w Rozdziały oraz Zasady i pieczęcie.');

screen('nowa-petla', 'Nowa pętla – potwierdzenie', () => overDialog({ art: gArt('chronos', 'big'), title: T('loopConfirmTitle'), body: R('loopConfirmResets'),
  extra: `<div class="g-box mint" style="margin-top:10px;text-align:left">${R('loopConfirmKeeps')}</div>`, btns: btn(T('loopConfirmYes'), 'wide') + link(T('loopConfirmNo')) }, 'Pytanie przed nową pętlą', { cls: 'auto' }));

screen('kronika', 'Kronika', () => {
  const c = `<div class="g-box lilac"><b>${T('loopNumber', { n: 3 })}</b> · ${T('loopGoal')}<div class="g-dim">${T('loopGoalDone')}</div><div class="g-dim">${T('chronicleLoopTime', { time: '12 godz.', count: 2 })}</div></div>
    <div class="g-box"><div class="g-dim">${T('loopRuleLabel')}</div><b>${P('rule_blindfold')}</b><div style="font-size:13px">${P('rule_blindfold_desc')}</div></div>
    ${heading(T('chroniclePick'))}<div class="g-dim">${T('chroniclePickHint')}</div>
    <div style="margin:8px 0">${btn(P('loopStart'), 'wide')}</div>
    ${heading(T('chronicleChapters'))}<div class="g-box"><b>${T('chroniclePrologue')}</b><div class="g-story" style="font-size:13px;max-height:60px;overflow:hidden">${P('prologue')}</div></div>
    <div class="g-box"><b>${P('chronicleChapter', { n: 1 })}: ${P('chapter_1_t')}</b></div><div class="g-box"><b>${P('chronicleChapter', { n: 2 })}: ???</b><div class="g-dim">${T('chronicleChapterLocked', { n: 2 })}</div></div>
    ${heading(T('chronicleSeals'))}<div class="g-box gold"><b>${P('seal_blindfold')}</b> · ${T('chronicleBest', { time: '9 godz.' })}</div><div class="g-box"><b>???</b><div class="g-dim">${T('chronicleSealLocked')}</div></div>`;
  const chip = `<div class="ph-in" style="justify-content:center;align-items:center;gap:8px"><div class="g-box lilac" style="text-align:center"><b>${T('chronicleTitle')}</b><br>${P('loopNumber', { n: 3 })} · ${P('loopGoal')}</div></div>`;
  return overSheet(T('chronicleTitle'), c, 'Ekran Kroniki', { h: '97%' }) + short(chip, 'Przycisk Kroniki w menu', 240);
});

screen('rozdzialy', 'Rozdziały', () => {
  let h = '';
  for (let n = 1; n <= 7; n++) h += catFrame(`Rozdział ${n}`, `<div class="f-d" style="font-size:20px">${P('chronicleChapter', { n })}: ${T(`chapter_${n}_t`)}</div><div class="g-story" style="margin-top:8px">${R(`chapter_${n}`)}</div>`);
  return catFrame('Prolog', `<div class="f-d" style="font-size:20px">${T('prologue_t')}</div><div class="g-story" style="margin-top:8px">${R('prologue')}</div>`) + h;
}, 'Cała fabuła w kolejności. Rozdział odblokowuje się po każdej ukończonej pętli.');

screen('zasady', 'Zasady i pieczęcie', () => RULES.map((r) => catFrame(P('rule_' + r), `
  <div class="g-box lilac"><div class="g-dim">${P('loopRuleLabel')}</div><div style="display:flex;gap:8px;align-items:center">${art(RULE_ART[r], '#E2D2FF', 'sm')}<b class="f-d" style="font-weight:400;font-size:17px">${T('rule_' + r)}</b></div>
    <div style="margin-top:4px">${R('rule_' + r + '_desc')}</div><div class="g-quote">${T('rule_' + r + '_quote')}</div></div>
  <div class="g-box gold"><div class="g-dim">${P('loopRewardSeal')}</div><div style="display:flex;gap:8px;align-items:center">${art(RULE_ART[r], '#FFD86E', 'sm')}<b class="f-d" style="font-weight:400;font-size:17px">${T('seal_' + r)}</b></div>
    <div style="margin-top:4px">${R('seal_' + r + '_desc')}</div></div>`)).join(''),
'Każda zasada Chronosa utrudnia pętlę; po jej ukończeniu dostajesz pieczęć z premią.');

/* ======================================================= */
group('Katalog');

screen('zegary-katalog', 'Zegary', () => catFrame('Wszystkie zegary – nazwa i opis', GENS.map((g) => card({ art: gArt(g), name: T('gen_' + g), desc: T('gen_' + g + '_desc') })).join('')),
  'Opis widać na karcie niekupionego zegara i w jego szczegółach.');

screen('ulepszenia', 'Ulepszenia zegarów', () => GENS.map((g) => catFrame(genName(g), `<div style="display:flex;gap:8px;align-items:center;margin-bottom:8px">${gArt(g, 'sm')}<b class="f-d" style="font-weight:400;font-size:18px">${genName(g)}</b></div>`
  + [1, 2, 3, 4, 5, 6, 7, 8].map((i) => `<div class="g-box"><div style="font-weight:800">${i}. ${T(`upg_${g}_${i}`)}</div><div class="g-quote">${R(`upg_${g}_${i}_desc`)}</div></div>`).join(''))).join(''),
'Bonusy zegarów (co 10, 25, 50… sztuk). Nazwa pokazuje się w okienku „Nowy bonus” i w szczegółach zegara, opis – w szczegółach.');

screen('mistrzowie', 'Tytuły mistrzów', () => catFrame('Stopień 5 i 10 mistrzostwa każdego zegara', GENS.map((g) => `<div class="g-box"><div style="display:flex;gap:8px;align-items:center">${gArt(g, 'sm')}<b>${genName(g)}</b></div>
  <div style="margin-top:6px"><b>5:</b> ${T(`master_${g}_5`)}<div class="g-quote">${T(`master_${g}_5_desc`)}</div></div>
  <div style="margin-top:6px"><b>10:</b> ${T(`master_${g}_10`)}<div class="g-quote">${T(`master_${g}_10_desc`)}</div></div></div>`).join('')),
'Tytuł pokazuje się na ekranie Sprężyn i jako nazwa osiągnięcia mistrzostwa.');

screen('umiejetnosci-katalog', 'Umiejętności', () => SKILLS.map((s) => catFrame(P('skill_' + s), `<div style="display:flex;gap:10px;align-items:center">${sArt(s)}<b class="f-d" style="font-weight:400;font-size:20px">${T('skill_' + s)}</b></div>
  <div class="g-box" style="margin-top:8px"><div class="g-dim">Opis</div>${R('skill_' + s + '_desc')}</div>
  <div class="g-box"><div class="g-dim">Więcej (w szczegółach)</div>${R('skill_' + s + '_info')}</div>
  <div class="g-box"><div class="g-dim">Nazwa efektu (np. „${P('skill_' + s + '_label')}: ×1,4 → ×1,6”)</div>${T('skill_' + s + '_label')}</div>`)).join(''));

screen('perki', 'Perki paradoksu', () => catFrame('Wszystkie perki', PERKS.map((p) => card({ art: art(PERK_ART[p], '#E2D2FF', 'sm'), name: T('perk_' + p), desc: R('perk_' + p + '_desc') })).join('')));

screen('synergie', 'Synergie', () => catFrame('Nazwy synergii', SYNS.map((s) => `<div class="g-box"><b>${T('syn_' + s)}</b></div>`).join('')),
  'Nazwa synergii pokazuje się w szczegółach zegara i w okienku „Synergia”.');

screen('sezony', 'Sezony', () => catFrame('Wydarzenia sezonowe', SEASONS.map((s) => card({ art: art(SEASON_ART[s], '#FFE29A', 'sm'), name: T('season_' + s), sub: T('season_' + s + '_items') })).join('')),
  'Nazwa wydarzenia i nazwa zbieranych przedmiotów. Na razie w grze są włączone tylko Boże Narodzenie i Sylwester (docs/02 §14) – pozostałe teksty czekają na powrót tych wydarzeń.');

screen('osiagniecia-lista', 'Osiągnięcia', () => {
  const a = (n, name, desc) => card({ art: art(n, '#FFE29A', 'sm'), name, desc });
  const counted = ACH_COUNT.map((c) => {
    const args = { count: c === 'combo' ? '×2' : c === 'earned' || c === 'income' ? '1M' : 100, amount: '1M', generator: genName('grandpa'), name: P('season_christmas') };
    return a(ACH_ART[c], T('ach_' + c, args), R('ach_' + c + '_desc', args));
  }).join('') + a('grandpa', P('master_grandpa_5'), T('ach_mastery_desc', { generator: genName('grandpa'), level: 5 }));
  const fixed = ACH_FIXED.map((f) => a(f.startsWith('hidden') ? 'red_question_mark' : 'trophy', T('ach_' + f), R('ach_' + f + '_desc'))).join('');
  return catFrame('Osiągnięcia z progami (liczba się zmienia)', counted) + catFrame('Specjalne i ukryte', fixed);
});

screen('powiadomienia-tel', 'Powiadomienia telefonu', () => {
  const n = (t, b) => `<div class="g-notif">${img('stopwatch')}<div><div class="app">${P('appTitle')} · teraz</div><b>${t}</b>${b}</div></div>`;
  return frame('Ekran blokady', `<div class="ph-in lock-bg" style="gap:10px"><div class="clock">9:41</div>
    ${n(T('notificationTitle'), R('notificationOfflineBody'))}${n(T('notificationDailyTitle', { day: 4, days: 7 }), R('notificationDailyBody'))}${n(T('notificationReserveTitle'), R('notificationReserveBody'))}</div>`);
});

/* ======================================================= */
group('Inne');

screen('drobne', 'Drobne i techniczne', () => {
  const row = (k, a, note) => `<div class="lp"><div><code>${k}</code>${note ? `<div class="g-dim">${note}</div>` : ''}</div><div>${T(k, a)}</div></div>`;
  return `<div class="list-plain">
    ${row('appTitle', null, 'Nazwa aplikacji pod ikoną')}
    ${row('decimalSeparator', null, 'Separator dziesiętny w liczbach (przecinek)')}
    ${row('durationM', { minutes: 45 }, 'Czas: same minuty')}${row('durationH', { hours: 3 }, 'Czas: pełne godziny')}${row('durationHm', { hours: 2, minutes: 15 }, 'Czas: godziny i minuty')}
    ${row('ms', { value: '12,5' }, 'Milisekundy w statystykach')}
    ${row('yes')}${row('no')}${row('cancel')}${row('ok')}${row('skip', null, 'Pomiń samouczek')}${row('collect')}
    ${row('on', null, 'Efekt umiejętności włączony')}${row('off', null, 'Efekt umiejętności wyłączony')}${row('inHundred', { n: 5 })}
    ${row('oddsPerfect', null, 'Wstawiane do „Twoje {tier}…”')}${row('oddsGreatOrBetter')}${row('oddsHits')}
    ${row('cost', { value: '250' })}
    ${row('diagSeason', null, 'Panel diagnostyczny (tylko testy)')}${row('diagSeasonNone')}
  </div>`;
}, 'Teksty, które nie mają własnego okna albo są wstawiane do innych zdań.');

screen('nieuzywane', 'Nieużywane w kodzie', () => {
  const ks = ['tagline', 'ownedCount', 'upgradesTitle', 'upgradeRequires', 'buy', 'comingSoon', 'statTiers', 'clockLevelLocked', 'dialTitle', 'loopTitle', 'loopNoRule', 'chronicleOpen'].filter(has);
  return `<div class="list-plain">${ks.map((k) => `<div class="lp"><code>${k}</code><div>${T(k)}</div></div>`).join('')}</div>`;
}, 'Te teksty są w pliku, ale gra ich obecnie nigdzie nie wyświetla. Nie trzeba ich poprawiać.');

screen('pozostale', 'Pozostałe teksty', function () {
  const ks = this.restKeys || [];
  if (!ks.length) return '<p>Wszystkie teksty z pliku są pokazane na którymś ekranie. 🎉</p>';
  return `<div class="list-plain">${ks.map((k) => `<div class="lp"><code>${k}</code><div>${T(k)}</div></div>`).join('')}</div>`;
}, 'Teksty z pliku, których nie ma na żadnej makiecie powyżej (lista tworzy się automatycznie).');
