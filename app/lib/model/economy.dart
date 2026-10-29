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

  /// Windows from skills; generators always use these.
  Windows windows() =>
      windowsAt(magnet: level('magnet'), wideEye: level('wideEye'));

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

  /// Start później: where the stopwatch starts. Each level closes
  /// `perLevel` of the remaining gap; the last one reaches
  /// `round.latestStart`.
  double laterStart([int? lvl]) {
    final s = b.skill('fastForward');
    final q = 1 - s.perLevel;
    final l = lvl ?? level('fastForward');
    return b.round.latestStart *
        (1 - math.pow(q, l)) /
        (1 - math.pow(q, s.maxLevel));
  }

  /// Zimna krew: how much wider the player's windows are (×1 at level 0).
  double coldBlood([int? lvl]) =>
      1 / (1 - _per('bulletTime') * (lvl ?? level('bulletTime')));

  int comboCap([int? lvl]) =>
      b.combo.baseCap + (_per('combo') * (lvl ?? level('combo'))).round();

  double strikePower() => 1 + _per('power') * level('power');

  double echoSeconds() => _per('echo') * level('echo');

  int shieldCharges() => level('shield');

  /// Golden Touch: interval multiplier (<1 = more often) and strength.
  double goldenIntervalFactor() =>
      1 - _per('goldenTouch') * level('goldenTouch');
  double goldenStrengthFactor() =>
      1 + _per('goldenTouch') * level('goldenTouch');

  TimeMap timeMap({double clock = 1}) {
    final r = b.round;
    return TimeMap(
      start: laterStart(),
      zoneStart: r.target - r.bulletZone,
      zoneEnd: r.target + r.bulletZone,
      clock: clock,
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
  int upgradesBought(String id) => s.upgrades[id] ?? 0;

  bool generatorUnlocked(String id) {
    final perk = b.generator(id).requiresPerk;
    return perk == null || s.perks.contains(perk);
  }

  double generatorCost(String id, [int? ownedNow]) {
    final g = b.generator(id);
    return g.baseCost * math.pow(b.generatorCostGrowth, ownedNow ?? owned(id));
  }

  /// Price of [k] more units (geometric series, docs/03 §2).
  double bulkCost(String id, int k) {
    if (k <= 0) return 0;
    final r = b.generatorCostGrowth;
    return generatorCost(id) * (math.pow(r, k) - 1) / (r - 1);
  }

  /// Largest k affordable with [money] (0 if none).
  int maxAffordable(String id, double money) {
    final first = generatorCost(id);
    if (money < first) return 0;
    final r = b.generatorCostGrowth;
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

  /// Next upgrade for generator [id]: index, unlock threshold, price; null
  /// when all are bought.
  GeneratorUpgrade? nextUpgrade(String id) {
    final gu = b.generatorUpgrades;
    final k = upgradesBought(id);
    if (k >= gu.thresholds.length) return null;
    return GeneratorUpgrade(
      id,
      k,
      gu.thresholds[k],
      b.generator(id).baseCost * gu.costMultipliers[k],
    );
  }

  /// Upgrades that can be bought right now (enough units owned), cheapest
  /// first (R-ULEP-3).
  List<GeneratorUpgrade> availableUpgrades() {
    final list = <GeneratorUpgrade>[
      for (final g in b.generators)
        if (nextUpgrade(g.id) case final u? when owned(g.id) >= u.threshold) u,
    ];
    list.sort((a, b) => a.cost.compareTo(b.cost));
    return list;
  }

  List<SynergyConfig> availableSynergies() => [
    for (final syn in b.synergies)
      if (!s.synergies.contains(syn.id) && owned(syn.a) > 0 && owned(syn.b) > 0)
        syn,
  ];

  double _synergyFactor(String id) {
    var f = 1.0;
    for (final syn in b.synergies) {
      if (!s.synergies.contains(syn.id)) continue;
      if (syn.a == id) f *= 1 + syn.aPerB * owned(syn.b);
      if (syn.b == id) f *= 1 + syn.bPerA * owned(syn.a);
    }
    return f;
  }

  /// Tiki/s of one unit of [id] before the global multiplier.
  double unitRate(String id) =>
      b.generator(id).baseRate *
      math.pow(b.generatorUpgrades.multiplier, upgradesBought(id)) *
      _synergyFactor(id) *
      windowGain(id);

  double generatorRate(String id) => owned(id) * unitRate(id);

  // ---------------------------------------------------------- multipliers --

  /// G without temporary effects: Chronons and achievements (docs/03 §2).
  double permanentMultiplier() =>
      (1 + b.prestige.bonusPerChronon * s.chronons) *
      (1 + b.achievements.bonusEach * s.achievements.length);

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

class GeneratorUpgrade {
  const GeneratorUpgrade(this.generator, this.index, this.threshold, this.cost);
  final String generator;

  /// 0-based; shown as I…VIII.
  final int index;
  final int threshold;
  final double cost;
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
