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

  test('upgrade and synergy purchases', () {
    s.tiki = 1e6;
    expect(g.buyUpgrade('grandpa'), BuyResult.unavailable);
    s.owned.addAll({'grandpa': 1, 'grandma': 1});
    expect(g.buyUpgrade('grandpa'), BuyResult.ok);
    expect(s.upgrades['grandpa'], 1);
    expect(g.buyUpgrade('grandpa'), BuyResult.unavailable); // needs 5
    expect(g.buySynergy('grandparents'), BuyResult.ok);
    expect(g.buySynergy('grandparents'), BuyResult.unavailable);
  });

  test('skills level up to max', () {
    s.tiki = 1e30;
    for (var i = 0; i < 10; i++) {
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
    s.owned['grandma'] = 10; // P = 10/s
    s.skills.addAll({'power': 2, 'echo': 4}); // ×(1 + 1.5·2) = ×4, 2 s
    const perfect = Grade(Tier.perfect, 0);
    // (10·4·1 + 2·1.0·10) · combo 1.5 · mode 3
    expect(
      g.hitPayout(perfect, combo: 1.5, mode: 3),
      closeTo((40 + 20) * 4.5, 1e-9),
    );
    const good = Grade(Tier.good, 0.04);
    expect(g.hitPayout(good), closeTo(1 * 4 + 2 * 0.1 * 10, 1e-9));
    expect(g.hitPayout(const Grade(Tier.miss, 1, MissKind.late)), 0);
  });

  test('frenzy and turbo multiply everything', () {
    s.owned['grandma'] = 1;
    g.frenzy = 7;
    g.turbo = 2;
    expect(g.passive(), closeTo(14, 1e-9));
    expect(g.hitPayout(const Grade(Tier.perfect, 0)), closeTo(140, 1e-9));
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
