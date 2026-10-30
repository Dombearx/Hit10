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

  test('upgrades double, synergies add per partner unit', () {
    s.owned['grandpa'] = 10;
    s.owned['grandma'] = 4;
    s.upgrades['grandpa'] = 2;
    expect(e.unitRate('grandpa'), closeTo(0.1 * 4, 1e-12));
    s.synergies.add('grandparents');
    expect(e.unitRate('grandpa'), closeTo(0.4 * 1.04, 1e-12));
    expect(e.unitRate('grandma'), closeTo(1 * 1.01, 1e-12));
  });

  test('wider windows help sloppy generators, not perfect ones (R-GEN-6)', () {
    s.skills['wideEye'] = 10;
    expect(e.windowGain('grandpa'), closeTo(1.575, 0.01));
    expect(e.windowGain('chronos'), 1);
    s.skills['magnet'] = 10;
    expect(e.windowGain('atomic'), greaterThan(1));
  });

  test('upgrades unlock at thresholds and sort by price', () {
    expect(e.availableUpgrades(), isEmpty);
    s.owned['grandpa'] = 1;
    s.owned['grandma'] = 5;
    s.upgrades['grandma'] = 1;
    final list = e.availableUpgrades();
    expect(list.map((u) => '${u.generator}#${u.index}'), [
      'grandpa#0',
      'grandma#1',
    ]);
    expect(list.first.cost, 150);
    expect(list.last.cost, 100 * 50);
  });

  test('skills: windows, speeds, caps', () {
    s.skills.addAll({
      'magnet': 3,
      'wideEye': 5,
      'fastForward': 4,
      'bulletTime': 10,
      'combo': 2,
    });
    final w = e.windows();
    expect(w.perfect, closeTo(0.008, 1e-12));
    expect(w.great, closeTo(0.028, 1e-12));
    expect(e.laterStart(), closeTo(4 * 0.08, 1e-12)); // the same step each
    expect(e.laterStart(10), closeTo(b.round.latestStart, 1e-12));
    expect(e.laterStart(0), 0);
    expect(e.coldBlood(), closeTo(2.5, 1e-12));
    // Zimna krew widens the player's windows, never the generators'.
    expect(e.playerWindows().perfect, closeTo(0.008 * 2.5, 1e-12));
    expect(e.windows().perfect, closeTo(0.008, 1e-12));
    expect(e.comboCap(), 9);
    expect(e.skillCost('magnet'), 2000 * math.pow(7, 3));
    s.skills['ticking'] = 1;
    expect(e.skillCost('ticking'), isNull);
  });

  test('round length matches docs/03 (5.7 s → 4.9 s)', () {
    expect(e.roundSeconds(), closeTo(5.7, 1e-9));
    s.skills.addAll({'fastForward': 10, 'bulletTime': 10});
    expect(e.roundSeconds(), closeTo(4.2 + 0.7, 1e-9));
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
