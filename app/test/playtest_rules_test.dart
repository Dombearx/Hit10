import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/time_map.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Rules added after the simulated playtest (docs/08).
void main() {
  final b = loadBalance();
  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState();
    e = GameEngine(b, s);
  });

  group("beginner's luck", () {
    test('pays ×3 for the first rounds, fades to ×1, windows untouched', () {
      final perfect = e.hitPayout(const Grade(Tier.perfect, 0));
      expect(e.econ.playerWindows().good, b.tier('good').window);
      // Halfway through the fade: ×2.
      s.stats.rounds = b.beginner.rounds + b.beginner.fadeRounds ~/ 2;
      expect(
        e.hitPayout(const Grade(Tier.perfect, 0)),
        closeTo(perfect * 2 / 3, 1e-9),
      );
      s.stats.rounds = b.beginner.rounds + b.beginner.fadeRounds;
      expect(
        e.hitPayout(const Grade(Tier.perfect, 0)),
        closeTo(perfect / 3, 1e-9),
      );
    });

    test('never after a paradox', () {
      s.chronons = 1;
      expect(e.econ.beginner, isFalse);
    });
  });

  group('BLISKO (close)', () {
    setUp(() => s.stats.rounds = 30); // past beginner's luck

    test('a miss within the close window pays a little', () {
      final w = e.econ.playerWindows();
      expect(w.close, b.close.window);
      final g = grade(0.1, w);
      expect(g.tier, Tier.miss);
      expect(g.close, isTrue);
      expect(grade(0.2, w).close, isFalse);
      expect(e.hitPayout(g), closeTo(b.close.reward, 1e-9));
      expect(
        e.hitPayout(const Grade(Tier.perfect, 0)) / e.hitPayout(g),
        greaterThanOrEqualTo(20),
      );
    });

    test('breaks the combo like a miss, generators never get it', () {
      s.comboStreak = 6;
      final o = e.resolveRound(grade(-0.1, e.econ.playerWindows()));
      expect(o.comboBroken, isTrue);
      expect(o.payout, greaterThan(0));
      expect(e.econ.windows().close, 0);
    });
  });

  group('a round without a touch is skipped, not missed', () {
    const noTap = Grade(Tier.miss, 0.3, MissKind.noTap);

    test('keeps the combo and the shield, pays nothing, counts no round', () {
      s.comboStreak = 6;
      s.shieldCharges = 1;
      final o = e.resolveRound(noTap);
      expect(o.comboBroken, isFalse);
      expect(s.comboStreak, 6);
      expect(s.shieldCharges, 1);
      expect(o.payout, 0);
      expect(s.stats.rounds, 0);
      expect(s.lifetime.missedInARow, 1);
    });

    test('a real tap resets the untapped count', () {
      e.resolveRound(noTap);
      e.resolveRound(const Grade(Tier.good, 0.04));
      expect(s.lifetime.missedInARow, 0);
    });
  });

  test('without auto-start the stopwatch waits for a touch', () {
    final r = RoundEngine(
      config: b.round,
      timeMapFor: () => TimeMap(zoneStart: 9.8, zoneEnd: 10.2),
      windowsFor: () => e.econ.windows(),
    )..autoStart = false;
    r.tap(0);
    r.update(11); // auto-ends at 10.3 without a tap
    expect(r.phase, RoundPhase.result);
    r.update(20);
    expect(r.phase, RoundPhase.waiting);
  });

  test('turbo ads are 5 minutes apart', () {
    s.tutorialDone = true;
    s.playSeconds = 1000;
    final ads = AdOffers(e);
    ads.grant(AdOffer.turbo, 0);
    expect(ads.available(AdOffer.turbo, 299 * 1000), isFalse);
    expect(ads.available(AdOffer.turbo, 300 * 1000), isTrue);
  });

  group('daily bonus', () {
    final day1 = DateTime(2026, 11, 2, 9);
    DateTime plus(int days) => day1.add(Duration(days: days));

    test('only after the tutorial; once a day', () {
      expect(e.dailyFor(day1), isNull);
      s.tutorialDone = true;
      final d = e.dailyFor(day1)!;
      expect(d.day, 1);
      expect(d.amount, b.daily.floorPerDay); // no income yet: the floor
      e.claimDaily(d);
      expect(s.tiki, d.amount);
      expect(e.dailyFor(day1.add(const Duration(hours: 10))), isNull);
    });

    test('the streak grows day by day, cycles after 7, resets on a gap', () {
      s.tutorialDone = true;
      for (var i = 0; i < 8; i++) {
        final d = e.dailyFor(plus(i))!;
        expect(d.day, i % 7 + 1);
        e.claimDaily(d);
      }
      expect(e.dailyFor(plus(9))!.day, 1); // skipped day 8
    });

    test('pays minutes of passive income once the clocks earn', () {
      s.tutorialDone = true;
      s.owned['grandma'] = 100; // 100/s
      final d = e.dailyFor(day1)!;
      expect(d.amount, closeTo(100 * 60 * b.daily.minutes[0], 1e-6));
    });
  });

  test(
    "the header's price list: the next hit with its combo step and mode",
    () {
      s
        ..stats.rounds = 100
        ..comboStreak =
            2 // cap 5 without the Combo skill
        ..modeBlind = true
        ..lifetime.perfects = 1000; // Blind unlocked
      final step = b.tier('perfect').comboStep;
      final combo = 1 + b.combo.multiplierPerStep * (2 + step);
      final price = e.nextHitPayout(Tier.perfect);
      expect(
        price,
        closeTo(
          (e.hitPayout(const Grade(Tier.perfect, 0)) + e.jackpotAmount()) *
              combo *
              3,
          1e-9,
        ),
      );
      // What the header says is what a 10.00 then pays.
      final o = e.resolveRound(const Grade(Tier.perfect, 0), mode: 3);
      expect(o.payout, closeTo(price, 1e-6));
    },
  );

  group('the 10.00 jackpot', () {
    setUp(() {
      s.stats.rounds = 100; // past beginner's luck
      s.owned['grandma'] = 100; // 100/s
    });

    test('a tap that reads 10.00 pays seconds of the clocks\' income', () {
      final o = e.resolveRound(const Grade(Tier.perfect, 0.003));
      final combo = 1 + b.combo.multiplierPerStep * s.comboStreak;
      expect(
        o.jackpot,
        closeTo(b.jackpot.productionSeconds * 100 * combo, 1e-6),
      );
      expect(o.payout, greaterThan(o.jackpot));
    });

    test('Magnet widens PERFECT, not the jackpot; Luck never wins it', () {
      s.skills['magnet'] = 10;
      final wide = grade(0.008, e.econ.playerWindows());
      expect(wide.tier, Tier.perfect);
      expect(e.resolveRound(wide).jackpot, 0);
      // A GREAT bumped to PERFECT by Luck is not a 10.00.
      expect(e.isJackpot(const Grade(Tier.great, 0.004)), isFalse);
    });

    test('early on it is worth at least a few PERFECTs', () {
      s.owned.clear();
      expect(
        e.jackpotAmount(),
        closeTo(b.jackpot.perfectMultiple * b.tier('perfect').reward, 1e-9),
      );
    });
  });

  test("beginner's luck lifts BLISKO towards a GOOD, then fades", () {
    final w = e.econ.playerWindows();
    final close = grade(0.1, w);
    final start = e.hitPayout(close);
    expect(
      start,
      closeTo(b.beginner.closeReward * b.beginner.rewardMultiplier, 1e-9),
    );
    s.stats.rounds = b.beginner.rounds + b.beginner.fadeRounds;
    expect(e.hitPayout(close), closeTo(b.close.reward, 1e-9));
  });
}
