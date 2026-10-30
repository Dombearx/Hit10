import 'dart:math' as math;

import 'economy.dart';
import 'grading.dart';

/// One generator "hit" shown on screen (docs/04 §3, T-15).
class ShowcaseHit {
  const ShowcaseHit(this.generator, this.gameTime, this.tier, this.reward);
  final String generator;
  final double gameTime;
  final Tier tier;

  /// What this single attempt is "worth": the unit's per-attempt income
  /// scaled by how good the hit was. Display only.
  final double reward;
}

/// Samples visible generator hits from each unit's spread. Purely
/// cosmetic: income always comes from expected values, so thousands of
/// units cost nothing (T-15).
class GeneratorShowcase {
  GeneratorShowcase({math.Random? random, this.maxPerSecond = 3})
    : _rng = random ?? math.Random();

  final math.Random _rng;
  double maxPerSecond;
  double _budget = 0;

  /// Each unit attempts once per [attemptEvery] seconds.
  static const attemptEvery = 5.0;

  List<ShowcaseHit> update(double dt, Economy econ) {
    final ids = [
      for (final g in econ.b.generators)
        if (econ.owned(g.id) > 0) g.id,
    ];
    if (ids.isEmpty) return const [];
    final units = ids.fold<int>(0, (a, id) => a + econ.owned(id));
    final rate = math.min(maxPerSecond, units / attemptEvery);
    _budget += dt * rate;
    final out = <ShowcaseHit>[];
    final w = econ.windows();
    final luck = econ.luckChance();
    final target = econ.b.round.target;
    while (_budget >= 1) {
      _budget -= 1;
      // Pick a generator weighted by how many units it has.
      var pick = _rng.nextDouble() * units;
      var id = ids.last;
      for (final x in ids) {
        pick -= econ.owned(x);
        if (pick < 0) {
          id = x;
          break;
        }
      }
      final sigma = econ.b.generator(id).sigma;
      final err = sigma <= 0 ? 0.0 : _gauss() * sigma;
      var tier = grade(err, w).tier;
      if ((tier == Tier.great || tier == Tier.good) &&
          _rng.nextDouble() < luck) {
        tier = tier == Tier.great ? Tier.perfect : Tier.great;
      }
      if (tier == Tier.miss) {
        // Misses are shown too (grey, no reward): a grandpa at 07.81 is
        // half the fun. Time stays within what a stopwatch would show.
        out.add(ShowcaseHit(id, (target + err).clamp(0, 99.99), tier, 0));
        continue;
      }
      final ev = econ.expectedReward(econ.odds(sigma, w, luck: luck));
      final perAttempt =
          econ.unitRate(id) * attemptEvery * econ.permanentMultiplier();
      final tierReward = econ.b.tier(tier.name).reward;
      out.add(
        ShowcaseHit(
          id,
          tier == Tier.perfect ? target : target + err,
          tier,
          ev > 0 ? perAttempt * tierReward / ev : perAttempt,
        ),
      );
    }
    return out;
  }

  double _gauss() {
    final u1 = 1 - _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }
}
