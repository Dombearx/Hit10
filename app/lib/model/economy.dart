import 'dart:math' as math;

import '../balance/balance.dart';
import 'game_state.dart';
import 'grading.dart';
import 'time_map.dart';

/// All formulas from docs/03-ekonomia.md §2, as pure functions of the balance
/// and the saved state. The game, the tests and `tool/simulate.dart` share
/// this one implementation (T-4).
class Economy {
  Economy(this.b, this.s);

  final Balance b;
  final GameState s;

  // ----------------------------------------- time loops (docs/13 §5.2) --

  /// The changed rule [id] is on in this loop (R-PETLA-4).
  bool ruleOn(String id) => s.loopRules.contains(id);

  /// The seal of rule [id] is won: its bonus holds for good (R-PETLA-5).
  bool sealed(String id) => s.seals.contains(id);

  double _rule(String id, String key) => b.loops.rule(id).params[key]!;
  double _seal(String id, String key) => b.loops.rule(id).seal[key]!;

  /// The rules of the next loop: in the story the first one not beaten
  /// yet, after it whatever the player picked (R-PETLA-4, R-PETLA-8).
  List<String> nextLoopRules() {
    for (final r in b.loops.rules) {
      if (!sealed(r.id)) return [r.id];
    }
    return [
      for (final r in b.loops.rules)
        if (s.nextRules.contains(r.id)) r.id,
    ];
  }

  /// Every rule is beaten: the player picks the rules now (R-PETLA-8).
  bool get storyDone => b.loops.rules.every((r) => sealed(r.id));

  /// Chapters of the Chronicle open (R-PETLA-7).
  int get chaptersOpen => math.min(s.loopsDone, b.loops.storyChapters);

  // ---------------------------------------------------------------- skills --

  int level(String skill) => s.skills[skill] ?? 0;
  double _per(String skill) => b.skill(skill).perLevel;

  bool isMaxed(String skill) => level(skill) >= b.skill(skill).maxLevel;

  /// Price of the next level, or null when maxed.
  double? skillCost(String skill) {
    final c = b.skill(skill);
    final l = level(skill);
    if (l >= c.maxLevel) return null;
    return c.baseCost * math.pow(c.costGrowth, l);
  }

  /// How much beginner's luck is left: 1 for the first rounds of a
  /// brand-new game (never prestiged), fading to 0 (playtest 08).
  double get beginnerShare {
    final n = b.beginner;
    final r = s.stats.rounds;
    if (s.chronons > 0 || r >= n.rounds + n.fadeRounds) return 0;
    if (r < n.rounds) return 1;
    return 1 - (r - n.rounds) / n.fadeRounds;
  }

  bool get beginner => beginnerShare > 0;

  /// Windows from skills; generators always use these. The seal of
  /// "precision" widens PERFECT a little, never past GREAT (R-PROG-2).
  Windows windows() {
    final w = windowsAt(magnet: level('magnet'), wideEye: level('wideEye'));
    if (!sealed('precision')) return w;
    return Windows(
      perfect: math.min(
        w.great,
        w.perfect + _seal('precision', 'perfectWindow'),
      ),
      great: w.great,
      good: w.good,
    );
  }

  /// The windows for the player's own taps: [windows] plus BLISKO, all
  /// widened by Zimna krew.
  Windows playerWindows() {
    final w = windows();
    final f = coldBlood();
    return Windows(
      perfect: w.perfect * f,
      great: w.great * f,
      good: w.good * f,
      close: math.max(b.close.window, w.good) * f,
    );
  }

  /// The payout factor from beginner's luck (×3 → ×1).
  double beginnerPay() => 1 + (b.beginner.rewardMultiplier - 1) * beginnerShare;

  Windows windowsAt({int magnet = 0, int wideEye = 0}) {
    final we = 1 + _per('wideEye') * wideEye;
    return Windows(
      perfect: b.tier('perfect').window + _per('magnet') * magnet,
      great: b.tier('great').window * we,
      good: b.tier('good').window * we,
    );
  }

  /// Chance that a great/good hit is bumped one tier up (Luck).
  double luckChance([int? lvl]) => _per('luck') * (lvl ?? level('luck'));

  /// Start później: where the stopwatch starts — the same step every
  /// level (playtest: the first levels used to give almost everything),
  /// never past `round.latestStart`.
  double laterStart([int? lvl]) {
    final l = lvl ?? level('fastForward');
    return math.min(b.round.latestStart, _per('fastForward') * l);
  }

  /// The player's timing spread from their recent taps (outliers such as
  /// a tap at 9.20 left out); 60 ms until there are enough taps.
  double playerSpread() {
    final e = s.stats.recentErrors.where((x) => x.abs() < 0.3).toList();
    if (e.length < 10) return 0.06;
    final m = e.reduce((a, c) => a + c) / e.length;
    final v =
        e.map((x) => (x - m) * (x - m)).reduce((a, c) => a + c) /
        (e.length - 1);
    return math.sqrt(v).clamp(0.005, 0.2);
  }

  /// The player's windows with skill [id] at level [lv] (the rest as owned).
  Windows playerWindowsWith(String id, int lv) {
    final w = windowsAt(
      magnet: id == 'magnet' ? lv : level('magnet'),
      wideEye: id == 'wideEye' ? lv : level('wideEye'),
    );
    final f = coldBlood(id == 'bulletTime' ? lv : null);
    return Windows(
      perfect: w.perfect * f,
      great: w.great * f,
      good: w.good * f,
    );
  }

  /// Zimna krew: how much wider the player's windows are (×1 at level 0).
  double coldBlood([int? lvl]) =>
      1 / (1 - _per('bulletTime') * (lvl ?? level('bulletTime')));

  /// The most the streak counts. "Short fuse" keeps it at its own cap.
  int comboCap([int? lvl]) => ruleOn('shortFuse')
      ? _rule('shortFuse', 'comboCap').round()
      : b.combo.baseCap + (_per('combo') * (lvl ?? level('combo'))).round();

  double strikePower() => 1 + _per('power') * level('power');

  double echoSeconds() => _per('echo') * level('echo');

  /// Shield charges held at most: none under "short fuse", one more with
  /// its seal.
  int shieldCharges() => ruleOn('shortFuse')
      ? 0
      : level('shield') +
            (sealed('shortFuse')
                ? _seal('shortFuse', 'shieldCharges').round()
                : 0);

  /// Golden Touch: interval multiplier (<1 = more often) and strength.
  double goldenIntervalFactor() =>
      1 - _per('goldenTouch') * level('goldenTouch');
  double goldenStrengthFactor() =>
      1 + _per('goldenTouch') * level('goldenTouch');

  TimeMap timeMap() {
    final r = b.round;
    return TimeMap(
      start: laterStart(),
      zoneStart: r.target - r.bulletZone,
      zoneEnd: r.target + r.bulletZone,
    );
  }

  /// Real seconds of a round tapped at the target, plus the result pause
  /// (docs/03 §2).
  double roundSeconds() =>
      timeMap().realAt(b.round.target) + b.round.resultPause;

  // ------------------------------------------------------- hit statistics --

  /// Probability of each tier for a normal error with spread [sigma], with
  /// Luck applied (docs/03 §2).
  TierOdds odds(double sigma, Windows w, {double luck = 0}) {
    final p = pWithin(w.perfect, sigma);
    final g = pWithin(w.great, sigma) - p;
    final d = pWithin(w.good, sigma) - p - g;
    return TierOdds(p + luck * g, (1 - luck) * g + luck * d, (1 - luck) * d);
  }

  double expectedReward(TierOdds o) =>
      o.perfect * b.tier('perfect').reward +
      o.great * b.tier('great').reward +
      o.good * b.tier('good').reward;

  late final Map<String, double> _baseEv = {
    for (final g in b.generators)
      g.id: expectedReward(odds(g.sigma, windowsAt())),
  };

  /// How much the current windows and Luck raise generator [id]'s income
  /// (R-GEN-6); 1 for a generator that never misses.
  double windowGain(String id) {
    final g = b.generator(id);
    if (g.sigma <= 0) return 1;
    final base = _baseEv[id]!;
    if (base <= 0) return 1;
    return expectedReward(odds(g.sigma, windows(), luck: luckChance())) / base;
  }

  // ------------------------------------------------------------ generators --

  int owned(String id) => s.owned[id] ?? 0;

  bool generatorUnlocked(String id) {
    final perk = b.generator(id).requiresPerk;
    return perk == null || s.perks.contains(perk);
  }

  /// What each unit raises the price of the next by: more under
  /// "inflation" (R-PETLA-4).
  double get costGrowth => ruleOn('inflation')
      ? _rule('inflation', 'costGrowth')
      : b.generatorCostGrowth;

  /// The first units go at a discount with the seal of "inflation".
  int get _cheapUnits =>
      sealed('inflation') ? _seal('inflation', 'halfPriceUnits').round() : 0;

  double generatorCost(String id, [int? ownedNow]) {
    final g = b.generator(id);
    final n = ownedNow ?? owned(id);
    final discount = n < _cheapUnits ? _seal('inflation', 'halfPrice') : 1.0;
    return g.baseCost * math.pow(costGrowth, n) * discount;
  }

  /// Price of [k] more units (geometric series, docs/03 §2): the
  /// discounted first units, then the rest.
  double bulkCost(String id, int k) {
    if (k <= 0) return 0;
    final r = costGrowth;
    final n = owned(id);
    final base = b.generator(id).baseCost;
    double series(int from, int count) => count <= 0
        ? 0
        : base * math.pow(r, from) * (math.pow(r, count) - 1) / (r - 1);
    final cheap = (_cheapUnits - n).clamp(0, k);
    return (cheap > 0 ? _seal('inflation', 'halfPrice') : 1.0) *
            series(n, cheap) +
        series(n + cheap, k - cheap);
  }

  /// Largest k affordable with [money] (0 if none).
  int maxAffordable(String id, double money) {
    final first = generatorCost(id);
    if (money < first) return 0;
    final r = costGrowth;
    var k = (math.log(money * (r - 1) / first + 1) / math.log(r)).floor();
    // Guard against floating error at the boundary.
    while (k > 0 && bulkCost(id, k) > money) {
      k--;
    }
    while (bulkCost(id, k + 1) <= money) {
      k++;
    }
    return k;
  }

  /// Milestones reached (R-ULEP-1): each threshold owned doubles the
  /// generator, for free.
  int milestonesReached(String id) {
    final n = owned(id);
    var k = 0;
    for (final t in milestoneThresholds(id)) {
      if (n >= t) k++;
    }
    return k;
  }

  /// The next milestone's owned count, or null when all are reached.
  int? nextMilestone(String id) {
    final k = milestonesReached(id);
    final t = milestoneThresholds(id);
    return k < t.length ? t[k] : null;
  }

  /// The previous milestone's count (0 before the first): where the
  /// progress bar starts.
  int lastMilestone(String id) {
    final k = milestonesReached(id);
    return k == 0 ? 0 : milestoneThresholds(id)[k - 1];
  }

  /// R-ULEP-1: the owned counts that double [id]; lower for later clocks.
  List<int> milestoneThresholds(String id) =>
      b.milestones.thresholdsFor(_genIndex(id));

  /// What each milestone of [id] multiplies it by (×2 for the first clocks).
  double milestoneMultiplier(String id) =>
      b.milestones.multiplierFor(_genIndex(id));

  int _genIndex(String id) => b.generators.indexWhere((g) => g.id == id);

  /// R-SYN-1: on, for free, once both partners reach [SynergyConfig.requires].
  bool synergyActive(SynergyConfig syn) =>
      owned(syn.a) >= syn.requires && owned(syn.b) >= syn.requires;

  double _synergyFactor(String id) {
    var f = 1.0;
    for (final syn in b.synergies) {
      if (!synergyActive(syn)) continue;
      if (syn.a == id) f *= 1 + syn.aPerB * owned(syn.b);
      if (syn.b == id) f *= 1 + syn.bPerA * owned(syn.a);
    }
    return f;
  }

  /// Tiki/s of one unit of [id] before the global multiplier.
  double unitRate(String id) =>
      b.generator(id).baseRate *
      math.pow(milestoneMultiplier(id), milestonesReached(id)) *
      _synergyFactor(id) *
      windowGain(id) *
      clockLevelFactor(id);

  // ------------------------------------------- clock levels (R-SPR-5) --

  int clockLevel(String id) => s.clockLevels[id] ?? 0;

  /// What the mastery tiers multiply clock [id] by (R-SPR-5).
  double clockLevelFactor(String id, [int? level]) =>
      math.pow(b.springs.levelFactor, level ?? clockLevel(id)).toDouble();

  /// What all the clock levels together multiply the income by now
  /// (1 without clocks or levels).
  double clockLevelsGain() {
    var withLevels = 0.0, without = 0.0;
    for (final g in b.generators) {
      if (owned(g.id) == 0) continue;
      final rate = generatorRate(g.id);
      withLevels += rate;
      without += rate / clockLevelFactor(g.id);
    }
    return without > 0 ? withLevels / without : 1;
  }

  /// The Chronons' share of the global multiplier (R-PRES-3).
  double chrononMultiplier([int? chronons]) =>
      1 + b.prestige.bonusPerChronon * (chronons ?? s.chronons);

  /// The achievements' share of the global multiplier (R-OSIAG-1).
  double achievementMultiplier() =>
      1 + b.achievements.bonusEach * s.achievements.length;

  /// Mainsprings the next level of [id] costs, or null when maxed.
  int? clockLevelCost(String id) {
    final l = clockLevel(id);
    return l >= b.springs.maxLevel ? null : b.springs.costOf(l + 1);
  }

  /// Mainsprings appear with the first paradox (R-SPR-1).
  bool get springsUnlocked => s.prestiges > 0;

  /// Clock [id] can take a level at all (bought once, not maxed).
  bool clockLevelable(String id) =>
      springsUnlocked && s.everOwned.contains(id) && clockLevelCost(id) != null;

  // ------------------------------------------------- dials (docs/12 §3.3) --

  /// A face is unlocked by the Tiki earned in all runs, or by the seal of
  /// its Time Loop (R-PETLA-5); one unlocked under the old thresholds
  /// stays.
  bool dialUnlocked(DialConfig d) => d.seal == null
      ? s.lifetime.earnedEver >= d.earned
      : sealed(d.seal!) || s.dialsSeen.contains(d.id);

  List<DialConfig> get unlockedDials => [
    for (final d in b.dials)
      if (dialUnlocked(d)) d,
  ];

  /// The next face to unlock, or null when all are.
  DialConfig? get nextDial {
    for (final d in b.dials) {
      if (!dialUnlocked(d)) return d;
    }
    return null;
  }

  /// How far the way to [nextDial] is done, 0..1, from the last unlocked
  /// face. The thresholds are ×100 apart and lifetime Tiki grow
  /// exponentially, so the scale is logarithmic: a straight share would sit
  /// near 0 for most of the way and jump at the end.
  double get nextDialProgress {
    final next = nextDial;
    if (next == null) return 1;
    if (next.seal != null) return 0;
    final have = s.lifetime.earnedEver;
    final earnedFaces = unlockedDials.where((d) => d.seal == null);
    final prev = earnedFaces.isEmpty ? 0.0 : earnedFaces.last.earned;
    if (have <= 0) return 0;
    if (prev <= 0) {
      return (math.log(1 + have) / math.log(1 + next.earned)).clamp(0.0, 1.0);
    }
    return (math.log(have / prev) / math.log(next.earned / prev)).clamp(
      0.0,
      1.0,
    );
  }

  /// The face to draw: the chosen one if unlocked, else the classic.
  String get dialId {
    final id = s.dial;
    if (id.isEmpty) return b.dials.first.id;
    return unlockedDials.any((d) => d.id == id) ? id : b.dials.first.id;
  }

  double generatorRate(String id) => owned(id) * unitRate(id);

  // ---------------------------------------------------------- multipliers --

  /// G without temporary effects: Chronons and achievements (docs/03 §2).
  double permanentMultiplier() => chrononMultiplier() * achievementMultiplier();

  /// Passive Tiki/s. [frenzy] and [turbo] are the temporary multipliers.
  double passive({double frenzy = 1, double turbo = 1}) {
    var sum = 0.0;
    for (final g in b.generators) {
      if (owned(g.id) > 0) sum += generatorRate(g.id);
    }
    return sum * permanentMultiplier() * frenzy * turbo;
  }

  // ------------------------------------------------------------ prestige --

  int chrononsTotalFor(double earnedTotal) {
    final x = earnedTotal / b.prestige.divisor;
    if (x <= 0) return 0;
    var n = math.pow(x, 1 / b.prestige.root).floor();
    // Correct floating error at exact powers (8000 → 20, not 19.999…).
    while (math.pow(n + 1, b.prestige.root) <= x) {
      n++;
    }
    while (n > 0 && math.pow(n, b.prestige.root) > x) {
      n--;
    }
    return n;
  }

  /// Chronons a prestige right now would add.
  int prestigeGain() =>
      math.max(0, chrononsTotalFor(s.earnedTotal) - s.chronons);
}

class TierOdds {
  const TierOdds(this.perfect, this.great, this.good);
  final double perfect;
  final double great;
  final double good;
  double get hit => perfect + great + good;
}

/// P(|x| < w) for x ~ N(0, sigma); 1 when sigma is 0.
double pWithin(double w, double sigma) =>
    sigma <= 0 ? 1 : erf(w / (sigma * math.sqrt2));

/// Error function, Abramowitz–Stegun 7.1.26 (|error| < 1.5e-7).
double erf(double x) {
  final sign = x < 0 ? -1.0 : 1.0;
  final a = x.abs();
  final t = 1 / (1 + 0.3275911 * a);
  final y =
      1 -
      (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t -
                      0.284496736) *
                  t +
              0.254829592) *
          t *
          math.exp(-a * a);
  return sign * y;
}
