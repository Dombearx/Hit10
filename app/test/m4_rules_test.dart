import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final b = loadBalance();
  late GameState s;
  late GameEngine e;
  setUp(() {
    s = GameState();
    e = GameEngine(b, s);
  });

  group('risk modes (R-TRYB-1)', () {
    test('locked until enough perfects or the perk', () {
      s.modeBlind = true;
      expect(e.modeMultiplier(), 1);
      s.lifetime.perfects = 100;
      expect(e.modeMultiplier(), 3);
      s.lifetime.perfects = 0;
      s.perks.add('earlyModes');
      expect(e.modeMultiplier(), 3);
    });
  });

  group('prestige (R-PRES-1…5)', () {
    setUp(() {
      s
        ..earnedTotal =
            1e8 *
            27 // 3 Chronons
        ..tiki = 5000
        ..comboStreak = 9;
      s.owned['grandpa'] = 40;
      s.upgrades['grandpa'] = 3;
      s.synergies.add('grandparents');
      s.skills.addAll({'fastForward': 6, 'wideEye': 4, 'magnet': 5, 'echo': 7});
      s.achievements.add('earned_1e+3');
    });

    test('gain, reset and what survives', () {
      expect(e.canPrestige(), isTrue);
      expect(e.prestige(), 3);
      expect(s.chronons, 3);
      expect(s.shards, 3);
      expect(s.prestiges, 1);
      expect(s.tiki, 0);
      expect(s.owned, isEmpty);
      expect(s.upgrades, isEmpty);
      expect(s.synergies, isEmpty);
      expect(s.skills, isEmpty);
      expect(s.comboStreak, 0);
      expect(s.achievements, contains('earned_1e+3'));
      expect(s.earnedTotal, 1e8 * 27); // lifetime stays
      expect(e.canPrestige(), isFalse); // needs ≥ 1 new Chronon
    });

    test('muscle memory and head start', () {
      s.perks.addAll({
        'muscleMemory1',
        'muscleMemory2',
        'muscleMemory3',
        'headStart',
      });
      e.prestige();
      expect(s.skills['fastForward'], 6);
      expect(s.skills['wideEye'], 4);
      expect(s.skills['magnet'], 5);
      expect(s.skills['echo'], 3); // halved, rounded down
      expect(s.owned['grandpa'], 10);
      expect(s.tiki, 1000);
    });

    test('perk tree: cost, prerequisites, no double buy', () {
      s.shards = 60;
      expect(e.buyPerk('muscleMemory2'), BuyResult.unavailable); // needs I
      expect(e.buyPerk('muscleMemory1'), BuyResult.ok);
      expect(e.buyPerk('muscleMemory2'), BuyResult.ok);
      expect(s.shards, 0);
      expect(e.buyPerk('muscleMemory1'), BuyResult.unavailable);
      expect(e.buyPerk('headStart'), BuyResult.tooExpensive);
    });
  });

  test('auto buyer buys the cheapest visible generator when on', () {
    s.perks.add('autoBuyer');
    s.tiki = 1000;
    expect(e.autoBuy(10), isNull); // switched off
    s.autoBuyerOn = true;
    expect(e.autoBuy(5), 'grandpa');
    expect(e.autoBuy(1), isNull); // waits 5 s between buys
  });

  group('rewarded offers (docs/02 §13)', () {
    late AdOffers ads;
    setUp(() {
      ads = AdOffers(e);
      s
        ..tutorialDone = true
        ..playSeconds = 400;
      s.owned['grandma'] = 1; // 1/s
    });

    test('locked during the tutorial and the first 5 minutes (R-AD-5)', () {
      s.playSeconds = 100;
      expect(ads.available(AdOffer.turbo, 0), isFalse);
      s
        ..playSeconds = 400
        ..tutorialDone = false;
      expect(ads.available(AdOffer.turbo, 0), isFalse);
    });

    test('turbo stacks to 4 h, 5 min apart, drains only in play, feeds G', () {
      const gap = 300 * 1000;
      for (var i = 0; i < 8; i++) {
        expect(ads.available(AdOffer.turbo, i * gap), isTrue);
        ads.grant(AdOffer.turbo, i * gap);
        // Playtest 08: no chaining ads back to back.
        expect(ads.available(AdOffer.turbo, i * gap + gap - 1), isFalse);
      }
      expect(s.turboLeft, 14400);
      expect(ads.available(AdOffer.turbo, 9 * gap), isFalse); // full
      ads.tick(1);
      expect(e.passive(), closeTo(2, 1e-9));
      ads.tick(14400);
      expect(e.turbo, 1);
    });

    test('bag pays 5 min of income; 30 min cooldown in real time', () {
      final got = ads.grant(AdOffer.bag, 1000);
      expect(got, closeTo(300, 1e-9));
      expect(ads.available(AdOffer.bag, 1000 + 29 * 60 * 1000), isFalse);
      expect(ads.available(AdOffer.bag, 1000 + 30 * 60 * 1000), isTrue);
    });

    test('rescue: offered after a big break, restores, expires', () {
      const lost = RoundOutcome(
        raw: Grade(Tier.miss, -1, MissKind.early),
        tier: Tier.miss,
        payout: 0,
        combo: 1,
        streak: 0,
        streakBefore: 18,
        comboBroken: true,
        shieldUsed: false,
        bumpedByLuck: false,
        hotHand: false,
      );
      ads.onRound(lost, 0);
      expect(ads.available(AdOffer.rescue, 0), isTrue);
      ads.grant(AdOffer.rescue, 0);
      expect(s.comboStreak, 18);
      expect(ads.available(AdOffer.rescue, 1000), isFalse); // used + cooldown
      ads.onRound(lost, 16 * 60 * 1000);
      s.playSeconds += 6;
      ads.tick(0);
      expect(ads.rescue, isNull); // 5 s window passed
    });

    test('offline doubles the pending amount', () {
      expect(ads.grant(AdOffer.offline, 0, offlineAmount: 500), 500);
      expect(s.tiki, 500);
    });

    test('golden offer summons a clock', () {
      ads.grant(AdOffer.golden, 0);
      expect(e.goldenVisibleLeft, b.golden.visibleFor);
      expect(ads.available(AdOffer.golden, 0), isFalse);
    });
  });

  group('achievements (R-OSIAG-1…3)', () {
    final all = buildAchievements(b);

    test('about a hundred, unique ids', () {
      expect(all.length, inInclusiveRange(95, 105));
      expect(all.map((a) => a.id).toSet(), hasLength(all.length));
    });

    test('unlock once, each +1 %', () {
      s.lifetime.earnedEver = 2e6;
      s.owned['grandpa'] = 50;
      final first = unlockAchievements(all, s, const AchievementContext());
      expect(
        first.map((a) => a.id),
        containsAll([
          'earned_1e+3',
          'earned_1e+6',
          'owned_grandpa_1',
          'owned_grandpa_50',
        ]),
      );
      expect(unlockAchievements(all, s, const AchievementContext()), isEmpty);
      expect(
        e.econ.permanentMultiplier(),
        closeTo(1 + 0.01 * s.achievements.length, 1e-12),
      );
    });

    test('hidden: almost, punctual, tenth day', () {
      s.stats.recentErrors.addAll([-0.0101, 0.0098]); // 4.99 then 5.01
      expect(
        unlockAchievements(all, s, const AchievementContext()).map((a) => a.id),
        contains('hidden_almost'),
      );
      // 17:00 on the 5th: punctual (5:00 or 17:00) and "Piątka".
      final at5 = DateTime(2026, 3, 5, 17, 0);
      expect(
        unlockAchievements(
          all,
          s,
          AchievementContext(now: at5, lastHitPerfect: true),
        ).map((a) => a.id),
        contains('hidden_punctual'),
      );
      for (var i = 0; i < 10; i++) {
        e.recordPerfectDate(at5);
      }
      expect(
        unlockAchievements(
          all,
          s,
          AchievementContext(now: at5),
        ).map((a) => a.id),
        contains('hidden_tenth'),
      );
    });

    test('blind perfects, then on a 10+ and a 25+ streak', () {
      Iterable<String> at(int streak) => unlockAchievements(
        all,
        s,
        AchievementContext(
          lastHitPerfect: true,
          lastHitBlind: true,
          streak: streak,
        ),
      ).map((a) => a.id);
      expect(at(3), ['mode_blind']);
      expect(at(12), ['mode_fast']); // mode_blind is already unlocked
      expect(at(25), ['mode_both']);
    });
  });
}
