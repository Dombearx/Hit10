import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final b = loadBalance();
  late GameState s;
  late GameEngine g;
  setUp(() {
    s = GameState();
    g = GameEngine(b, s);
  });

  test('buying spends exactly and refuses when short', () {
    s.tiki = 20;
    expect(g.buyGenerators('grandpa', 1), BuyResult.ok);
    expect(s.tiki, 5);
    expect(g.buyGenerators('grandpa', 1), BuyResult.tooExpensive);
    expect(s.owned['grandpa'], 1);
    expect(g.buyGenerators('chronos', 1), BuyResult.unavailable); // perk-gated
  });

  test('the 10th unit doubles the whole kind, for free', () {
    s.tiki = 1e6;
    s.owned['grandpa'] = 9;
    final before = g.passive();
    final tiki = s.tiki;
    final price = g.econ.generatorCost('grandpa');
    expect(g.buyGenerators('grandpa', 1), BuyResult.ok);
    // Only the unit's price is spent; income ×2 × 10/9.
    expect(s.tiki, closeTo(tiki - price, 1e-6));
    expect(g.passive(), closeTo(before * 2 * 10 / 9, 1e-9));
  });

  test('skills level up to max', () {
    s.tiki = 1e30;
    for (var i = 0; i < b.skill('magnet').maxLevel; i++) {
      expect(g.buySkill('magnet'), BuyResult.ok);
    }
    expect(g.buySkill('magnet'), BuyResult.unavailable);
  });

  test('tick earns passive income', () {
    s.owned['grandma'] = 2;
    g.tick(0.5);
    expect(s.tiki, closeTo(1.0, 1e-9));
    expect(s.earnedTotal, closeTo(1.0, 1e-9));
    expect(s.playSeconds, 0.5);
  });

  test('hit payout (R-WYPLATA-1) with echo, combo and mode', () {
    s.stats.rounds = 30; // past beginner's luck
    s.owned['grandma'] = 5; // P = 5/s (under the first ×2 at 10)
    s.skills.addAll({'power': 2, 'echo': 4}); // ×(1 + 1.5·2) = ×4, 2 s
    const perfect = Grade(Tier.perfect, 0);
    // (6·4·1 + 2·0.6·5) · combo 1.5 · mode 3
    expect(
      g.hitPayout(perfect, combo: 1.5, mode: 3),
      closeTo((24 + 6) * 4.5, 1e-9),
    );
    const good = Grade(Tier.good, 0.04);
    expect(g.hitPayout(good), closeTo(1 * 4 + 2 * 0.1 * 5, 1e-9));
    expect(g.hitPayout(const Grade(Tier.miss, 1, MissKind.late)), 0);
  });

  test('frenzy and turbo multiply everything', () {
    s.stats.rounds = 30; // past beginner's luck
    s.owned['grandma'] = 1;
    g.frenzy = 7;
    g.turbo = 2;
    expect(g.passive(), closeTo(14, 1e-9));
    expect(g.hitPayout(const Grade(Tier.perfect, 0)), closeTo(6 * 14, 1e-9));
  });

  group('offline (R-OFF-1…3)', () {
    test('capped and at half efficiency', () {
      s.owned['grandma'] = 1;
      s.lastSeenMs = 1000;
      final r = g.offlineSince(1000 + 10 * 3600 * 1000)!;
      expect(r.countedSeconds, 8 * 3600);
      expect(r.amount, closeTo(8 * 3600 * 0.5, 1e-6));
      g.claimOffline(r, multiplier: 2);
      expect(s.tiki, closeTo(8 * 3600, 1e-6));
    });
    test('short absence, first launch and clock set back give nothing', () {
      s.owned['grandma'] = 1;
      expect(g.offlineSince(5000), isNull); // lastSeen 0 = first launch
      s.lastSeenMs = 100000;
      expect(g.offlineSince(100000 + 30000), isNull);
      expect(g.offlineSince(50000), isNull);
    });
    test('an uncollected summary is carried over, within one cap', () {
      s.owned['grandma'] = 1;
      s.lastSeenMs = 1000;
      final first = g.offlineSince(1000 + 3600 * 1000)!; // 1 h away
      g.holdOffline(first); // shown, then the app was closed
      s.lastSeenMs = 1000 + 3600 * 1000;
      // Reopened 10 s later: the same summary comes back.
      final again = g.offlineSince(s.lastSeenMs + 10000)!;
      expect(again.amount, closeTo(first.amount, 1e-6));
      // Another 10 h away: adds up, but only up to the 8 h cap.
      final later = g.offlineSince(s.lastSeenMs + 10 * 3600 * 1000)!;
      expect(later.countedSeconds, 8 * 3600);
      expect(later.amount, closeTo(8 * 3600 * 0.5, 1e-6));
      g.claimOffline(later);
      expect(s.offlineAmount, 0);
      expect(g.offlineSince(s.lastSeenMs + 10000), isNull);
    });
    test('perks raise cap and efficiency', () {
      s.owned['grandma'] = 1;
      s.perks.addAll({'longNap2', 'deepSleep1'});
      s.lastSeenMs = 1;
      final r = g.offlineSince(1 + 30 * 3600 * 1000)!;
      expect(r.countedSeconds, 24 * 3600);
      expect(r.amount, closeTo(24 * 3600 * 0.75, 1e-6));
    });
  });
}
