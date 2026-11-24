// What the game holds after everything is unlocked (docs/13). From app/:
//
//   dart run tool/late_game_report.dart [--sessions 3] [--minutes 11]
//       [--sigma 0.04] [--after 24] [--part 1,2,3,4]
//
// The player is `idle_sim.dart`'s: a few sessions a day, offline income in
// between (doubled by an ad), paradoxes, perks, Mainsprings.
//   1. plays until every perk and every clock bonus is seen, then --after
//      more days, and counts what was new before and after that day;
//   2. at the end: what each source of bonus is worth in income;
//   3. how fast Mainsprings wind under the current and other caps;
//   4. from that state: how long a fresh run with the Chronons kept takes
//      under a few restrictions (why challenges inside a paradox fail);
//   5. the Time Loops of docs/13 on the game's own rules: a new game played
//      through the story's loops, how long each takes.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/economy.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/sim/simulator.dart';

const perkOrder = [
  'headStart',
  'deepSleep1',
  'longNap1',
  'muscleMemory1',
  'goldRush',
  'daredevil',
  'shieldRecharge',
  'autoBuyer',
  'deepSleep2',
  'longNap2',
  'unlockSchrodinger',
  'comboFloor',
  'muscleMemory2',
  'habit1',
  'secondClock',
  'habit2',
  'muscleMemory3',
  'unlockChronos',
];

String n(double v) => formatNumber(v);
String pct(double v) => '${(v * 100).toStringAsFixed(v.abs() < 0.1 ? 1 : 0)}%';

GameState clone(GameState s) =>
    decodeSave(encodeSave(SaveData(s, Settings()))).state;

/// The idle player of `idle_sim.dart`, one day at a time.
class Player {
  Player(
    this.b,
    this.s, {
    required this.sessions,
    required this.minutes,
    required this.sigma,
    this.offlineAd = true,
    this.paradoxAt = 1.0,
    this.paradoxes = true,
    this.spendSprings = true,
    this.offline = true,
    this.unlock = true,
    this.loops = false,
    this.stayDays = 2,
  });

  /// Plays the Time Loops: goes for the goal clock's perks first and
  /// starts the next loop once every bonus of the goal clock is paid, or
  /// [stayDays] after the goal.
  final bool loops;
  final double stayDays;

  /// Stays the full [stayDays] even once every bonus is paid (docs/17).
  bool forceStay = false;

  /// One line per finished loop: number, rules, days and hours played to
  /// the goal and to the exit, paradoxes, mastery tiers at its start.
  final loopLog = <String>[];
  var _loopStartDay = 0.0;
  var _loopStartHours = 0.0;
  var _loopTiersAtStart = 0;
  double? _goalDay;
  double? _goalHours;

  static const _rushPerks = [
    'headStart',
    'deepSleep1',
    'longNap1',
    'muscleMemory1',
    'autoBuyer',
    'deepSleep2',
    'longNap2',
    'unlockSchrodinger',
    'unlockChronos',
  ];

  int get _tiers => s.clockLevels.values.fold(0, (a, x) => a + x);

  void _loopStep(GameEngine e, double days, int nowMs) {
    if (e.checkLoop().goalReached) {
      _goalDay = days;
      _goalHours = playHours;
    }
    if (!loops || !s.loopGoal) return;
    final all =
        s.loopBonusPaid >= e.econ.milestoneThresholds(b.loops.goal).length;
    if ((forceStay || !all) && days - (_goalDay ?? days) < stayDays) return;
    String d(double v) => v.toStringAsFixed(1);
    loopLog.add(
      '${'${s.loop}'.padLeft(4)}  ${(s.loopRules.isEmpty ? '—' : s.loopRules.join('+')).padRight(10)}'
      '${d(_goalDay! - _loopStartDay).padLeft(11)}'
      '${d(_goalHours! - _loopStartHours).padLeft(8)}'
      '${d(days - _loopStartDay).padLeft(11)}'
      '${'${s.loopPrestiges}'.padLeft(11)}'
      '${'${s.loopBonusPaid}'.padLeft(9)}'
      '${'$_loopTiersAtStart'.padLeft(14)}',
    );
    e.startLoop(nowMs);
    _loopStartDay = days;
    _loopStartHours = playHours;
    _loopTiersAtStart = _tiers;
    _goalDay = null;
    _goalHours = null;
  }

  final Balance b;
  final GameState s;

  /// Called after every session (its purchases done), with the day.
  void Function(GameState s, double day, double passive)? onSession;
  final int sessions;
  final double minutes;
  final double sigma;
  final bool offlineAd;
  final double paradoxAt;
  final bool paradoxes;
  final bool spendSprings;
  final bool offline;
  final bool unlock;
  late final all = buildAchievements(b);

  final seenBonuses = <String>{};
  final firstClock = <String, double>{}; // id → play hours of this object
  final firstClockDay = <String, double>{};
  final earnedRunAt = <double, double>{}; // target → play hours
  final earnedRunDay = <double, double>{}; // target → days
  double? allBonusesAt;
  double? allPerksDay;
  double? allBonusesDay;
  final chronosBonusDay = <int, double>{}; // bonuses of Chronos → days
  var paradoxCount = 0;
  var levelsBought = 0;
  var titles = 0;
  var playHours = 0.0;
  var day = 0;
  final day0 = DateTime(2026, 11, 2, 8);
  List<double> runTargets = const [];

  int get bonusTotal => b.generators.length * 8;

  String? _bestLevel(GameEngine e) {
    String? best;
    var bestScore = 0.0;
    final before = e.econ.passive();
    for (final g in b.generators) {
      if (!e.econ.clockLevelable(g.id)) continue;
      final lv = e.econ.clockLevel(g.id);
      s.clockLevels[g.id] = lv + 1;
      var gain = e.econ.passive() - before;
      s.clockLevels[g.id] = lv;
      if (b.springs.titleLevels.contains(lv + 1)) gain += before * 0.01;
      final score = gain / e.econ.clockLevelCost(g.id)!;
      if (score > bestScore) {
        bestScore = score;
        best = g.id;
      }
    }
    return best;
  }

  void _mark(Simulator sim, double hours, double days) {
    for (final g in b.generators) {
      if ((s.owned[g.id] ?? 0) > 0) {
        firstClock.putIfAbsent(g.id, () => hours);
        firstClockDay.putIfAbsent(g.id, () => days);
      }
      for (var i = 0; i < sim.econ.milestonesReached(g.id); i++) {
        seenBonuses.add('${g.id}#$i');
      }
    }
    if (b.generators.any((g) => g.id == 'chronos')) {
      for (var k = 1; k <= sim.econ.milestonesReached('chronos'); k++) {
        chronosBonusDay.putIfAbsent(k, () => days);
      }
    }
    for (final t in runTargets) {
      if (s.earnedThisRun >= t) {
        earnedRunAt.putIfAbsent(t, () => hours);
        earnedRunDay.putIfAbsent(t, () => days);
      }
    }
    if (seenBonuses.length >= bonusTotal) {
      allBonusesAt ??= hours;
      allBonusesDay ??= days;
    }
  }

  void playDay() {
    day++;
    final gap = 24 * 3600 / sessions;
    int wallMs(double secs) => ((day * 86400 + secs) * 1000).round();
    for (var k = 0; k < sessions; k++) {
      final sim = Simulator(
        b,
        SimConfig(hours: minutes / 60, sigma: sigma, seed: day * 10 + k),
        state: s,
      );
      final e = sim.e;
      e.windSprings(wallMs(k * gap));
      final gain = e.econ.prestigeGain();
      if (paradoxes && gain >= 5 && gain >= paradoxAt * s.chronons) {
        s.habits
          ..clear()
          ..addAll(['echo', 'combo'].take(e.habitSlots()));
        e.prestige();
        paradoxCount++;
      }
      if (loops) {
        // Strictly in order: nothing dearer is bought past the goal's perks.
        for (final id in [..._rushPerks, ...perkOrder]) {
          if (s.perks.contains(id)) continue;
          if (e.buyPerk(id) != BuyResult.ok) break;
        }
      } else {
        for (final id in perkOrder) {
          if (b.prestige.perks.any((x) => x.id == id)) e.buyPerk(id);
        }
      }
      if (s.perks.length >= b.prestige.perks.length) {
        allPerksDay ??= day - 1 + k / sessions;
      }
      if (k == 0) {
        final d = e.dailyFor(day0.add(Duration(days: day)));
        if (d != null) e.claimDaily(d);
      }
      final startHours = playHours;
      final startDays = day - 1 + k / sessions;
      sim.onStep = (t) => _mark(sim, startHours + t / 3600, startDays);
      sim.run();
      playHours += minutes / 60;
      _loopStep(
        e,
        day - 1 + (k + 0.5) / sessions,
        wallMs(k * gap + minutes * 60),
      );
      final rounds = (minutes * 60 / e.econ.roundSeconds()).floor();
      final exact = (rounds * pWithin(b.jackpot.window, sigma)).round();
      for (var i = 0; i < exact; i++) {
        e.springHit(wallMs(k * gap + minutes * 60 * i / exact));
      }
      e.windSprings(wallMs(k * gap + minutes * 60));
      if (spendSprings) {
        while (true) {
          final id = _bestLevel(e);
          if (id == null || e.levelClock(id) != BuyResult.ok) break;
          levelsBought++;
          if (b.springs.titleLevels.contains(e.econ.clockLevel(id))) titles++;
        }
      }
      onSession?.call(s, day - 1 + (k + 1) / sessions, sim.econ.passive());
      if (unlock) {
        unlockAchievements(
          all,
          s,
          AchievementContext(passive: sim.econ.passive()),
        );
      }
      if (offline) {
        final away = gap - minutes * 60;
        final counted = math.min(away, e.offlineCapSeconds());
        s.earn(
          e.econ.passive() *
              counted *
              e.offlineEfficiency() *
              (offlineAd ? 2 : 1),
        );
        _mark(sim, playHours, day - 1 + (k + 1) / sessions);
      }
      _loopStep(e, day - 1 + (k + 1) / sessions, wallMs((k + 1) * gap - 1));
    }
  }

  int get dials => Economy(b, s).unlockedDials.length;
}

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final sessions = int.parse(opt('sessions', '3'));
  final minutes = double.parse(opt('minutes', '11'));
  final sigma = double.parse(opt('sigma', '0.04'));
  final after = int.parse(opt('after', '24'));
  final parts = opt('part', '1,2,3,4').split(',').toSet();
  final json = File('assets/balance.json').readAsStringSync();
  final b = Balance.fromJsonString(json);

  stdout.writeln(
    '$sessions × ${minutes.toStringAsFixed(0)} min a day, '
    'σ = ${(sigma * 1000).round()} ms, offline ad ×2',
  );

  // ---------------------------------------------------------------- 1 --
  final s = GameState()..tutorialDone = true;
  final p = Player(b, s, sessions: sessions, minutes: minutes, sigma: sigma);
  var doneDay = 0;
  (int, int, int, int, int, int)? atDone;
  (int, int, int, int, int, int) counts() => (
    s.achievements.length,
    p.paradoxCount,
    p.levelsBought,
    p.titles,
    p.dials,
    s.chronons,
  );
  while (doneDay == 0 && p.day < 120) {
    p.playDay();
    if (s.perks.length >= b.prestige.perks.length &&
        p.seenBonuses.length >= p.bonusTotal) {
      doneDay = p.day;
      atDone = counts();
    }
  }
  final hoursAtDone = p.playHours;
  final incomeAtDone = Economy(b, s).passive();
  for (var i = 0; i < after; i++) {
    p.playDay();
  }
  final end = counts();
  if (parts.contains('1')) {
    stdout.writeln('\n== 1. Before and after "everything unlocked"');
    stdout.writeln(
      'every perk and clock bonus seen on day $doneDay '
      '(${hoursAtDone.toStringAsFixed(1)} h played)',
    );
    stdout.writeln(
      'first Chronos on day '
      '${p.firstClockDay['chronos']?.toStringAsFixed(1)} '
      '(${p.firstClock['chronos']?.toStringAsFixed(1)} h played), '
      'every perk on day ${p.allPerksDay?.toStringAsFixed(1)}',
    );
    stdout.writeln(
      '                    first $doneDay days   next $after days',
    );
    void row(String name, Object a, Object z) => stdout.writeln(
      '${name.padRight(20)}${'$a'.padLeft(13)}${'$z'.padLeft(15)}',
    );
    row('clocks unlocked', b.generators.length, 0);
    row('clock bonuses', p.bonusTotal, 0);
    row('perks', b.prestige.perks.length, 0);
    row('achievements', atDone!.$1, end.$1 - atDone.$1);
    row('paradoxes', atDone.$2, end.$2 - atDone.$2);
    row('clock levels', atDone.$3, end.$3 - atDone.$3);
    row('master titles', atDone.$4, end.$4 - atDone.$4);
    row('dial faces', atDone.$5, end.$5 - atDone.$5);
    row('Chronons', atDone.$6, end.$6);
    row('income/s', n(incomeAtDone), n(Economy(b, s).passive()));
  }

  // ---------------------------------------------------------------- 2 --
  final econ = Economy(b, s);
  if (parts.contains('2')) {
    stdout.writeln('\n== 2. What each bonus is worth (day ${p.day})');
    final total = econ.passive();
    stdout.writeln('income ${n(total)}/s, share by clock:');
    for (final g in b.generators) {
      final share = econ.generatorRate(g.id) * econ.permanentMultiplier();
      if (share / total < 0.001) continue;
      stdout.writeln(
        '  ${g.id.padRight(14)} ${pct(share / total).padLeft(5)}'
        '  owned ${econ.owned(g.id)}  level ${econ.clockLevel(g.id)}',
      );
    }
    final chr = 1 + b.prestige.bonusPerChronon * s.chronons;
    final ach = 1 + b.achievements.bonusEach * s.achievements.length;
    stdout.writeln(
      'multipliers: Chronons ×${chr.toStringAsFixed(0)} '
      '(${s.chronons}), achievements ×${ach.toStringAsFixed(2)} '
      '(${s.achievements.length})',
    );
    // Levels: what the bought ones give, the next best, and all of them.
    final saved = Map<String, int>.from(s.clockLevels);
    s.clockLevels.clear();
    final noLevels = econ.passive();
    s.clockLevels.addAll(saved);
    var spent = 0;
    for (final lv in saved.values) {
      spent += lv * (lv + 1) ~/ 2;
    }
    stdout.writeln(
      'clock levels bought (${saved.values.fold(0, (a, x) => a + x)}, '
      '$spent Mainsprings): income ×${(total / noLevels).toStringAsFixed(2)}',
    );
    var bestGain = 0.0;
    var bestId = '';
    var bestCost = 1;
    for (final g in b.generators) {
      final cost = econ.clockLevelCost(g.id);
      if (!econ.clockLevelable(g.id) || cost == null) continue;
      s.clockLevels[g.id] = econ.clockLevel(g.id) + 1;
      final gain = econ.passive() / total - 1;
      s.clockLevels[g.id] = econ.clockLevel(g.id) - 1;
      if (gain / cost > bestGain / bestCost) {
        bestGain = gain;
        bestId = g.id;
        bestCost = cost;
      }
    }
    stdout.writeln(
      'next best level: $bestId, $bestCost Mainsprings, income +'
      '${pct(bestGain)}',
    );
    for (final g in b.generators) {
      s.clockLevels[g.id] = b.springs.maxLevel;
    }
    final full = econ.passive();
    s.clockLevels
      ..clear()
      ..addAll(saved);
    final perClock = b.springs.maxLevel * (b.springs.maxLevel + 1) ~/ 2;
    stdout.writeln(
      'every level of every clock (${perClock * b.generators.length} '
      'Mainsprings): income ×${(full / noLevels).toStringAsFixed(2)}',
    );
    stdout.writeln('one more achievement: income +${pct(0.01 / ach)}');
    final gainNow = econ.prestigeGain();
    stdout.writeln(
      'a paradox now: +$gainNow Chronons, income ×'
      '${((1 + 0.02 * (s.chronons + gainNow)) / chr).toStringAsFixed(2)} '
      '(for free, after rebuying the clocks)',
    );
    stdout.writeln(
      'after it, the next doubling of Chronons needs the lifetime Tiki ×8',
    );
    final perDay =
        (econ.passive() * (24 * 3600 - sessions * minutes * 60) * 2) /
        s.earnedTotal;
    stdout.writeln(
      'a day of offline income now adds ${pct(perDay)} to the lifetime '
      'Tiki (Chronons double when it grows ×8)',
    );
  }

  // ---------------------------------------------------------------- 3 --
  if (parts.contains('3')) {
    stdout.writeln(
      '\n== 3. Mainsprings a day by player: the daily cap of docs/12 '
      '(15 min a hit, 6 h a day) and the reserve (R-SPR-3)',
    );
    final sp = b.springs;
    final round = b.round.target - b.round.latestStart + b.round.resultPause;
    final profiles = [
      ('1 × 2 min, 80 ms', 1, 2.0, 0.08),
      ('3 × 3 min, 50 ms', 3, 3.0, 0.05),
      ('6 × 2 min, 50 ms', 6, 2.0, 0.05),
      ('1 × 30 min, 40 ms', 1, 30.0, 0.04),
      ('3 × 11 min, 40 ms', 3, 11.0, 0.04),
      ('5 × 5 min, 40 ms', 5, 5.0, 0.04),
    ];
    // Hours wound by hits a day under the reserve, the engine's own rules;
    // sessions spread over 16 waking hours, [ads] refills a day.
    double reserveHours(int ses, double mins, double sg, {int ads = 0}) {
      final st = GameState()..prestiges = 1;
      final e = GameEngine(b, st);
      final hits = (mins * 60 / round * pWithin(b.jackpot.window, sg));
      final gap = ses > 1 ? 16 * 3600 / (ses - 1) : 0.0;
      var wound = 0.0;
      const days = 20;
      var carry = 0.0;
      for (var d = 1; d <= days; d++) {
        var adsLeft = ads;
        for (var k = 0; k < ses; k++) {
          carry += hits;
          final n = carry.floor();
          carry -= n;
          for (var i = 0; i < n; i++) {
            final ms =
                ((d * 86400 + 8 * 3600 + k * gap + mins * 60 * i / n) * 1000)
                    .round();
            var got = e.springHit(ms);
            if (got == 0 && adsLeft > 0) {
              adsLeft--;
              e.refillSpringReserve(ms);
              got = e.springHit(ms);
            }
            wound += got;
            st.springs = 0; // never full
          }
        }
      }
      return wound / days / 3600;
    }

    stdout.writeln(
      '${'player'.padRight(20)}${'hits/session'.padLeft(13)}'
      '${'daily cap'.padLeft(11)}${'reserve'.padLeft(9)}'
      '${'reserve, 2 ads'.padLeft(16)}   (Mainsprings a day)',
    );
    for (final (name, ses, mins, sg) in profiles) {
      final hits = mins * 60 / round * pWithin(b.jackpot.window, sg);
      final old = math.min(21600.0, ses * hits * 900) / 3600;
      String perDay(double hours) => (1 + hours / 24).toStringAsFixed(2);
      stdout.writeln(
        '${name.padRight(20)}${hits.toStringAsFixed(1).padLeft(13)}'
        '${perDay(old).padLeft(11)}'
        '${perDay(reserveHours(ses, mins, sg)).padLeft(9)}'
        '${perDay(reserveHours(ses, mins, sg, ads: sp.hitReserve > 0 ? 2 : 0)).padLeft(16)}',
      );
    }
  }

  // ---------------------------------------------------------------- 4 --
  Map<String, Object?> j() => jsonDecode(json) as Map<String, Object?>;
  Map<String, Object?> m(Object? v) => v! as Map<String, Object?>;
  Balance prices(double growth) {
    final v = j();
    v['generatorCostGrowth'] = growth;
    return Balance.fromJsonString(jsonEncode(v));
  }

  Balance noGolden() {
    final v = j();
    m(v['golden'])['intervalMin'] = 1e12;
    m(v['golden'])['intervalMax'] = 1e12;
    return Balance.fromJsonString(jsonEncode(v));
  }

  Balance firstSix() {
    final v = j();
    final gens = (v['generators']! as List).take(6).toList();
    final ids = {for (final g in gens) m(g)['id']};
    v['generators'] = gens;
    v['synergies'] = [
      for (final x in v['synergies']! as List)
        if (ids.contains(m(x)['a']) && ids.contains(m(x)['b'])) x,
    ];
    final ms = m(v['milestones']);
    m(ms['late'])['fromGenerator'] = 6;
    m(ms['last'])['fromGenerator'] = 6;
    final ach = m(v['achievements']);
    m(ach['ownedThresholdsLate'])['fromGenerator'] = 6;
    m(ach['ownedThresholdsLast'])['fromGenerator'] = 6;
    (m(v['prestige'])['perks']! as List).removeWhere(
      (x) => '${m(x)['id']}'.startsWith('unlock'),
    );
    m(v['loops'])['goal'] = m(gens.last)['id'];
    return Balance.fromJsonString(jsonEncode(v));
  }

  String dh(double? days, double? hours) => days == null
      ? '—'.padLeft(13)
      : '${days.toStringAsFixed(1)} (${hours!.toStringAsFixed(1)})'.padLeft(13);

  if (parts.contains('4')) {
    stdout.writeln(
      '\n== 4. A fresh run from this state, Chronons kept '
      '(${s.chronons}, all perks) — days (hours played) until:',
    );
    final variants = <(String, Balance, double, bool)>[
      ('as now', b, 1.0, false),
      ('no Golden Second', noGolden(), 1.0, false),
      ('blind (σ ×1.5)', b, 1.5, false),
      ('prices ×1.25', prices(1.25), 1.0, false),
      ('clocks 1–6 only', firstSix(), 1.0, false),
      ('Chronons asleep', b, 1.0, true),
    ];
    final targets = [1e15, 1e18, 1e21];
    stdout.writeln(
      '${'run'.padRight(18)}${'1aa'.padLeft(13)}${'1ab'.padLeft(13)}'
      '${'1ac'.padLeft(13)}${'Time Machine'.padLeft(13)}'
      '${'all bonuses'.padLeft(13)}',
    );
    for (final (name, vb, sigmaK, asleep) in variants) {
      final c = clone(s);
      final e = GameEngine(vb, c);
      c.perks.removeWhere((id) => !vb.prestige.perks.any((x) => x.id == id));
      if (e.prestige() < 1) {
        c.rewindPending = true;
        e.finishPrestige();
      }
      if (asleep) c.chronons = 0;
      final q = Player(
        vb,
        c,
        sessions: sessions,
        minutes: minutes,
        sigma: sigma * sigmaK,
        paradoxes: false,
        spendSprings: false,
        unlock: false,
      )..runTargets = targets;
      while (q.day < 10 &&
          (q.allBonusesAt == null || q.earnedRunAt.length < 3)) {
        q.playDay();
      }
      stdout.writeln(
        '${name.padRight(18)}'
        '${targets.map((t) => dh(q.earnedRunDay[t], q.earnedRunAt[t])).join()}'
        '${dh(q.firstClockDay['timeMachine'], q.firstClock['timeMachine'])}'
        '${dh(q.allBonusesDay, q.allBonusesAt)}',
      );
    }
  }

  // ---------------------------------------------------------------- 5 --
  if (parts.contains('5')) {
    final days = int.parse(opt('loop-days', '110'));
    stdout.writeln(
      '\n== 5. Time Loops on the game\'s rules: a new game, the player goes '
      'for Chronos, stays for his bonuses (2 days at most), spends '
      'Mainsprings on mastery',
    );
    final st = GameState()..tutorialDone = true;
    final q = Player(
      b,
      st,
      sessions: sessions,
      minutes: minutes,
      sigma: sigma,
      loops: true,
    );
    final want = b.loops.rules.length + 2;
    while (q.day < days && q.loopLog.length < want) {
      q.playDay();
    }
    stdout.writeln(
      'loop  rule       to goal(d)  played  to exit(d)  paradoxes  bonuses'
      '  tiers before',
    );
    q.loopLog.forEach(stdout.writeln);
    stdout.writeln(
      'day ${q.day}: loop ${st.loop}, seals ${st.seals.length}/'
      '${b.loops.rules.length}, Mainsprings wound '
      '${st.lifetime.springsWound}, mastery tiers '
      '${st.clockLevels.values.fold(0, (a, x) => a + x)} of '
      '${b.generators.length * b.springs.maxLevel}',
    );
  }
}
