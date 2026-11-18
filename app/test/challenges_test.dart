import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/analytics/analytics.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/challenges.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// docs/02 §18: daily and weekly challenges.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final b = loadBalance();
  final windows = Windows(
    perfect: b.tier('perfect').window,
    great: b.tier('great').window,
    good: b.tier('good').window,
  );

  ChallengePlayer player({double sigma = 0.05, int taps = 100}) {
    final rng = math.Random(1);
    double gauss() =>
        math.sqrt(-2 * math.log(1 - rng.nextDouble())) *
        math.cos(2 * math.pi * rng.nextDouble());
    return ChallengePlayer(
      recentErrors: [for (var i = 0; i < taps; i++) gauss() * sigma],
      windows: windows,
      jackpotWindow: b.jackpot.window,
      roundSeconds: 5.7,
      payout: const {Tier.perfect: 6, Tier.great: 3, Tier.good: 1},
      jackpotPayout: 30,
      comboStep: 0.05,
      comboCap: 5,
      ownedClocks: 40,
      bonusesInReach: 2,
      skillLevelsLeft: 20,
      springsUnlocked: false,
      goldenEnabled: true,
    );
  }

  group('targets follow the player\'s own aim (docs/14)', () {
    test('a precise player gets bigger numbers than a loose one', () {
      final sharp = player(sigma: 0.025);
      final loose = player(sigma: 0.12);
      for (final k in [
        ChallengeKind.great,
        ChallengeKind.streak,
        ChallengeKind.jackpot,
        ChallengeKind.greatWeek,
      ]) {
        final a = ChallengePlanner.target(k, sharp, math.Random(2));
        final z = ChallengePlanner.target(k, loose, math.Random(2));
        expect(a, greaterThan(z), reason: k.name);
        expect(z, greaterThanOrEqualTo(1), reason: k.name);
      }
    });

    test('a newcomer without taps still gets sensible targets', () {
      final p = player(taps: 3);
      final great = ChallengePlanner.target(
        ChallengeKind.great,
        p,
        math.Random(3),
      );
      expect(great, inInclusiveRange(3, 30));
    });

    test('only what the player can do is offered', () {
      final p = player();
      expect(
        ChallengePlanner.available(weeklySlot, p),
        isNot(contains(ChallengeKind.springWeek)),
      );
      final none = ChallengePlayer(
        recentErrors: const [],
        windows: windows,
        jackpotWindow: 0.01,
        roundSeconds: 5.7,
        payout: const {},
        jackpotPayout: 0,
        comboStep: 0.05,
        comboCap: 5,
        ownedClocks: 0,
        bonusesInReach: 0,
        skillLevelsLeft: 0,
        springsUnlocked: false,
        goldenEnabled: false,
      );
      expect(ChallengePlanner.available(2, none), [ChallengeKind.buyClocks]);
      expect(
        ChallengePlanner.available(weeklySlot, none),
        isNot(contains(ChallengeKind.goldenWeek)),
      );
    });
  });

  group('progress', () {
    ChallengeRound r(Tier t, {double e = 0, int streak = 0}) => ChallengeRound(
      tier: t,
      error: e,
      jackpot: t == Tier.perfect && e.abs() < 0.01,
      payout: 10,
      streak: streak,
    );

    test('each kind counts what it says', () {
      final great = Challenge(ChallengeKind.great, 2);
      final streak = Challenge(ChallengeKind.streak, 5);
      final perfect = Challenge(ChallengeKind.perfect, 1);
      final window = Challenge(ChallengeKind.perfectWindow, 2);
      final money = Challenge(ChallengeKind.hitEarnings, 25);
      final all = [great, streak, perfect, window, money];
      ChallengeProgress.round(all, r(Tier.great, e: -0.02, streak: 2));
      ChallengeProgress.round(all, r(Tier.good, e: 0.04, streak: 3));
      expect(great.progress, 1);
      expect(perfect.done, isFalse);
      final done = ChallengeProgress.round(
        all,
        r(Tier.perfect, e: 0.012, streak: 6),
      );
      expect(done, containsAll([great, streak, perfect, money]));
      expect(window.progress, 1);
      for (var i = 0; i < 9; i++) {
        ChallengeProgress.round([window], r(Tier.good));
      }
      // The PERFECT left the window of ten.
      ChallengeProgress.round([window], r(Tier.perfect));
      expect(window.progress, 1);
      ChallengeProgress.round([window], r(Tier.perfect));
      expect(window.done, isTrue);
    });

    test('counted events and a claimed one that stays put', () {
      final buy = Challenge(ChallengeKind.buyClocks, 5);
      expect(ChallengeProgress.add([buy], ChallengeKind.buyClocks, 3), isEmpty);
      expect(ChallengeProgress.add([buy], ChallengeKind.buyClocks, 3), [buy]);
      buy.claimed = true;
      ChallengeProgress.add([buy], ChallengeKind.buyClocks, 3);
      expect(buy.progress, 6);
    });
  });

  group('the board', () {
    late GameState s;
    late GameEngine e;
    final rng = math.Random(4);
    final monday = DateTime(2026, 11, 16, 10);

    setUp(() {
      s = GameState()
        ..tutorialDone = true
        ..lifetime.secondsPlayed = 3600
        ..owned['grandma'] = 10;
      e = GameEngine(b, s);
    });

    test('locked during the first minutes', () {
      s.lifetime.secondsPlayed = 60;
      e.refreshChallenges(monday, player, rng);
      expect(s.challenges, isEmpty);
    });

    test('three daily ones in their slots and a weekly one', () {
      e.refreshChallenges(monday, player, rng);
      expect(e.dailyChallenges.map((c) => c.slot), [0, 1, 2]);
      expect(e.weeklyChallenge, isNotNull);
      // Later the same day: nothing changes.
      final before = [...s.challenges];
      e.refreshChallenges(monday.add(const Duration(hours: 5)), player, rng);
      expect(s.challenges, before);
    });

    test('claiming pays, the third one adds the day\'s bonus', () {
      e.refreshChallenges(monday, player, rng);
      final daily = e.dailyChallenges;
      for (final c in daily) {
        c.progress = c.target;
      }
      final first = e.claimChallenge(daily[0]);
      expect(first.tiki, greaterThanOrEqualTo(b.challenges.dailyFloor));
      expect(first.bonus, 0);
      expect(e.claimChallenge(daily[0]).tiki, 0); // only once
      e.claimChallenge(daily[1]);
      final last = e.claimChallenge(daily[2]);
      expect(last.bonus, greaterThanOrEqualTo(b.challenges.bonusFloor));
      expect(e.challengeBonusOpen, isFalse);
      expect(s.lifetime.challengesDone, 3);
    });

    test('a new day pays what was done but not claimed', () {
      e.refreshChallenges(monday, player, rng);
      final c = e.dailyChallenges.first..progress = 1e9;
      final tiki = s.tiki;
      final paid = e.refreshChallenges(
        monday.add(const Duration(days: 1)),
        player,
        rng,
      );
      expect(paid.tiki, greaterThan(0));
      expect(s.tiki, greaterThan(tiki));
      expect(e.dailyChallenges, isNot(contains(c)));
      // Same week: the weekly one stays.
      expect(e.weeklyChallenge, isNotNull);
    });

    test('a new week; the weekly one pays a Mainspring after a paradox', () {
      e.refreshChallenges(monday, player, rng);
      final week = e.weeklyChallenge!;
      e.refreshChallenges(monday.add(const Duration(days: 6)), player, rng);
      expect(e.weeklyChallenge, same(week));
      e.refreshChallenges(monday.add(const Duration(days: 7)), player, rng);
      expect(e.weeklyChallenge, isNot(same(week)));
      s.prestiges = 1; // Mainsprings unlocked
      final w = e.weeklyChallenge!..progress = 1e9;
      final springs = s.springs;
      expect(e.claimChallenge(w).springs, b.challenges.weeklySprings);
      expect(s.springs, springs + b.challenges.weeklySprings);
    });

    test('one free re-roll a day, not for a finished one', () {
      e.refreshChallenges(monday, player, rng);
      final old = e.dailyChallenges[1];
      final fresh = e.rerollChallenge(1, player(), rng);
      expect(fresh, isNotNull);
      expect(fresh!.kind, isNot(old.kind));
      expect(e.rerollChallenge(0, player(), rng), isNull);
      e.refreshChallenges(monday.add(const Duration(days: 1)), player, rng);
      e.dailyChallenges[0].progress = 1e9;
      expect(e.rerollChallenge(0, player(), rng), isNull);
      expect(e.rerollChallenge(weeklySlot, player(), rng), isNull);
    });
  });

  test('saved and loaded with their progress', () {
    final s = GameState()
      ..challengeDay = 20261116
      ..challengeWeek = 20261116
      ..challengeRerollDay = 20261116;
    s.challenges.add(
      Challenge(ChallengeKind.perfectWindow, 3, progress: 2)
        ..recent.addAll([1, 0, 1]),
    );
    s.challenges.add(Challenge(ChallengeKind.perfect, 4, progress: 3));
    s.challenges.add(Challenge(ChallengeKind.greatWeek, 90)..claimed = true);
    final back = importSave(exportSave(SaveData(s, Settings()))).state;
    expect(back.challengeDay, 20261116);
    expect(back.challenges.map((c) => c.kind), [
      ChallengeKind.perfectWindow,
      ChallengeKind.perfect,
      ChallengeKind.greatWeek,
    ]);
    expect(back.challenges[0].recent, [1, 0, 1]);
    expect(back.challenges[1].progress, 3);
    expect(back.challenges[2].claimed, isTrue);
  });

  test('a retired kind in an old save: its slot is filled', () {
    final s = GameState()
      ..tutorialDone = true
      ..lifetime.secondsPlayed = 3600;
    final e = GameEngine(b, s);
    final day = DateTime(2026, 11, 18, 9);
    e.refreshChallenges(day, player, math.Random(5));
    final back = importSave(exportSave(SaveData(s, Settings()))).state;
    // Pretend slot 1 held a kind this version no longer knows.
    back.challenges.removeWhere((c) => c.slot == 1);
    final e2 = GameEngine(b, back)
      ..refreshChallenges(day, player, math.Random(6));
    expect(e2.dailyChallenges.map((c) => c.slot), [0, 1, 2]);
  });

  test('they arrive at a round start after 3 min; the first set easier', () {
    final s = GameState()
      ..tutorialDone = true
      ..lifetime.secondsPlayed = 100;
    final a = RecordingAnalytics();
    final c = GameController(
      balance: b,
      state: s,
      store: MemorySaveStore(),
      analytics: a,
      localNow: () => DateTime(2026, 11, 18, 12),
    );
    c.syncChallenges();
    expect(s.challenges, isEmpty); // under 3 min of play
    // Before the ad offers: never both at once.
    expect(b.challenges.unlockPlaySeconds, lessThan(b.ads.unlockAfterSeconds));
    expect(c.challengePlayer().reachShare, b.challenges.firstReachShare);
    s.lifetime.secondsPlayed = b.challenges.unlockPlaySeconds;
    c.syncChallenges(); // mid-session, at a round start
    expect(s.challenges, hasLength(4));
    expect(a.names, contains('challenges_unlocked'));
    expect(c.challengePlayer().reachShare, b.challenges.reachShare);
  });

  test('the controller hands them out and counts purchases', () async {
    final s = GameState()
      ..tutorialDone = true
      ..lifetime.secondsPlayed = 3600
      ..tiki = 1e9;
    final c = GameController(
      balance: b,
      state: s,
      store: MemorySaveStore(),
      localNow: () => DateTime(2026, 11, 18, 12),
    );
    c.syncChallenges();
    expect(s.challenges, hasLength(4));
    // Make the building slot "buy 5 clocks" and play it.
    s.challenges.removeWhere((x) => x.slot == 2);
    s.challenges.add(Challenge(ChallengeKind.buyClocks, 5));
    final done = <Challenge>[];
    final sub = c.challengeDone.listen(done.add);
    c.buyGenerators('grandpa', 5);
    await Future<void>.delayed(Duration.zero);
    expect(done.single.kind, ChallengeKind.buyClocks);
    expect(c.challengesToClaim, 1);
    expect(c.claimChallenge(done.single).tiki, greaterThan(0));
    expect(c.challengesToClaim, 0);
    await sub.cancel();
  });
}
