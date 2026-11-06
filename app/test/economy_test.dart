import 'dart:math' as math;

import 'package:hit10/model/economy.dart';
import 'package:hit10/model/game_state.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final b = loadBalance();
  late GameState s;
  late Economy e;
  setUp(() {
    s = GameState();
    e = Economy(b, s);
  });

  test('erf matches known values', () {
    expect(erf(0), closeTo(0, 1e-7));
    expect(erf(0.5), closeTo(0.5204999, 2e-7));
    expect(erf(1), closeTo(0.8427008, 2e-7));
    expect(erf(-1), closeTo(-0.8427008, 2e-7));
    expect(pWithin(0.05, 0.03), closeTo(0.9044, 1e-3)); // docs/03 table
  });

  test('generator prices (R-GEN-1/2)', () {
    expect(e.generatorCost('grandpa'), 15);
    s.owned['grandpa'] = 2;
    expect(e.generatorCost('grandpa'), closeTo(15 * 1.15 * 1.15, 1e-9));
    final ten = e.bulkCost('grandpa', 10);
    var sum = 0.0;
    for (var i = 0; i < 10; i++) {
      sum += 15 * math.pow(1.15, 2 + i);
    }
    expect(ten, closeTo(sum, 1e-6));
  });

  test('MAX buys the largest affordable count', () {
    for (final money in <double>[0, 14.9, 15, 100, 12345.6, 1e9]) {
      final k = e.maxAffordable('grandpa', money);
      expect(e.bulkCost('grandpa', k), lessThanOrEqualTo(money));
      expect(e.bulkCost('grandpa', k + 1), greaterThan(money));
    }
  });

  test('base income equals the table at base windows', () {
    s.owned['grandma'] = 3;
    expect(e.windowGain('grandma'), closeTo(1, 1e-12));
    expect(e.passive(), closeTo(3.0, 1e-9));
  });

  test('milestones double for free, synergies add per partner unit', () {
    s.owned['grandpa'] = 9;
    expect(e.milestonesReached('grandpa'), 0);
    expect(e.unitRate('grandpa'), closeTo(0.1, 1e-12));
    s.owned['grandpa'] = 20; // 10 and 20 reached
    expect(e.milestonesReached('grandpa'), 2);
    expect(e.unitRate('grandpa'), closeTo(0.1 * 4, 1e-12));
    // Synergy (R-SYN-1): on once both own 25.
    s.owned['grandma'] = 24;
    expect(e.unitRate('grandma'), closeTo(1 * 4, 1e-12)); // 10, 20
    s
      ..owned['grandpa'] = 25
      ..owned['grandma'] = 25;
    expect(e.unitRate('grandpa'), closeTo(0.4 * 1.25, 1e-12));
    expect(e.unitRate('grandma'), closeTo(4 * 1.025, 1e-12));
  });

  test('wider windows help sloppy generators, not perfect ones (R-GEN-6)', () {
    s.skills['wideEye'] = 15;
    expect(e.windowGain('grandpa'), greaterThan(1.3));
    expect(e.windowGain('chronos'), 1);
    s.skills['magnet'] = 10;
    expect(e.windowGain('atomic'), greaterThan(1));
  });

  test('milestone progress: last and next threshold', () {
    expect(e.lastMilestone('grandpa'), 0);
    expect(e.nextMilestone('grandpa'), 10);
    s.owned['grandpa'] = 13;
    expect(e.lastMilestone('grandpa'), 10);
    expect(e.nextMilestone('grandpa'), 20);
    s.owned['grandpa'] = 999;
    expect(e.nextMilestone('grandpa'), isNull);
    expect(e.milestonesReached('grandpa'), 8);
  });

  test('later clocks: lower counts, smaller multiplier (playtest 27)', () {
    expect(e.milestoneThresholds('grandpa').last, 150);
    expect(e.milestoneMultiplier('grandpa'), 2);
    expect(e.milestoneThresholds('quartz').last, 80);
    expect(e.milestoneMultiplier('quartz'), 1.7);
    expect(e.milestoneThresholds('chronos').first, 5);
    expect(e.milestoneThresholds('chronos').last, 50);
    expect(e.milestoneMultiplier('chronos'), 1.4);
    s.owned['chronos'] = 50;
    expect(e.milestonesReached('chronos'), 8);
    final r = b.generator('chronos').baseRate * math.pow(1.4, 8);
    expect(
      e.unitRate('chronos'),
      closeTo(r * e.windowGain('chronos'), r * 1e-9),
    );
  });

  test('skills: windows, speeds, caps', () {
    // Window and tempo skills reach the same top effect in 15 finer steps.
    s.skills.addAll({
      'magnet': 15,
      'wideEye': 15,
      'fastForward': 4,
      'bulletTime': 15,
      'combo': 2,
    });
    final w = e.windows();
    expect(w.perfect, closeTo(0.025, 1e-4)); // ±15 → ±25 ms
    expect(w.great, closeTo(0.030 * 1.8, 1e-4)); // ×1.8
    expect(w.perfect, lessThan(b.tier('great').window)); // R-PROG-2
    final step = b.skill('fastForward').perLevel;
    expect(e.laterStart(), closeTo(4 * step, 1e-12)); // the same step each
    expect(e.laterStart(15), closeTo(b.round.latestStart, 1e-4));
    expect(e.laterStart(0), 0);
    expect(e.coldBlood(), closeTo(2.5, 1e-12));
    // Zimna krew widens the player's windows, never the generators'.
    expect(e.playerWindows().perfect, closeTo(w.perfect * 2.5, 1e-12));
    expect(e.comboCap(), 9);
    s.skills['magnet'] = 3;
    final m = b.skill('magnet');
    expect(e.skillCost('magnet'), m.baseCost * math.pow(m.costGrowth, 3));
    s.skills['ticking'] = 1;
    expect(e.skillCost('ticking'), isNull);
  });

  test('round length matches docs/03 (5.7 s → 3.7 s)', () {
    expect(e.roundSeconds(), closeTo(5.7, 1e-9));
    s.skills.addAll({'fastForward': 15, 'bulletTime': 15});
    expect(e.roundSeconds(), closeTo(3.0 + 0.7, 1e-3));
  });

  test('permanent multiplier from Chronons and achievements', () {
    s.chronons = 20;
    s.achievements.addAll(['a', 'b', 'c']);
    expect(e.permanentMultiplier(), closeTo(1.4 * 1.03, 1e-12));
  });

  test('prestige gain (R-PRES-2)', () {
    s.earnedTotal = 1e8 * 8000; // cube root 20
    expect(e.prestigeGain(), 20);
    s.chronons = 15;
    expect(e.prestigeGain(), 5);
  });
}
