import 'dart:math' as math;

import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/challenges.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Clock traits of the master titles (docs/18 §4, docs/02 R-CECHA).
void main() {
  final b = loadBalance();
  final t3 = b.springs.titleLevels[0];
  final t5 = b.springs.titleLevels[1];
  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState()..tutorialDone = true;
    e = GameEngine(b, s, random: math.Random(1));
  });

  void level(String id, int lv) => s.clockLevels[id] = lv;

  group('tiers (R-CECHA-1)', () {
    test('no trait below the first title, the first at 3, both at 5', () {
      expect(e.econ.traitTier('watchmaker'), 0);
      expect(e.econ.trait('watchmaker', 'perkCost'), isNull);
      level('watchmaker', t3);
      expect(e.econ.traitTier('watchmaker'), 1);
      expect(e.econ.trait('watchmaker', 'perkCost'), 0.9);
      level('watchmaker', t5);
      expect(e.econ.traitTier('watchmaker'), 2);
      // Tier 5's value is the total.
      expect(e.econ.trait('watchmaker', 'perkCost'), 0.8);
    });

    test('tier 5 adds to tier 3: the first trait stays', () {
      level('sprintJudge', t5);
      // From tier 3: the break it takes and the cap; from tier 5: the hits.
      expect(e.econ.trait('sprintJudge', 'warmUpAwaySeconds'), 3600);
      expect(e.econ.warmUpHits, 25);
    });

    test('every clock has two traits in the balance file', () {
      for (final g in b.generators) {
        expect(b.traits.of(g.id, 0), isNotEmpty, reason: g.id);
        expect(b.traits.of(g.id, 1), isNotEmpty, reason: g.id);
      }
    });
  });

  test('Grandpa: offline limit +4 h, then income +10%', () {
    final cap = e.offlineCapSeconds();
    final eff = e.offlineEfficiency();
    level('grandpa', t3);
    expect(e.offlineCapSeconds(), cap + 4 * 3600);
    expect(e.offlineEfficiency(), eff);
    level('grandpa', t5);
    expect(e.offlineEfficiency(), closeTo(eff * 1.1, 1e-9));
  });

  group('Grandma', () {
    DateTime d(int day) => DateTime(2026, 11, day, 9);
    void claim(int day) => e.claimDaily(e.dailyFor(d(day))!);

    test('a missed day keeps the streak every time, not once a week', () {
      level('grandma', t3);
      claim(2);
      claim(4); // 3rd missed: the weekly grace
      expect(s.dailyStreak, 2);
      final again = e.dailyFor(d(6))!; // 5th missed too
      expect(again.grace, isTrue);
      expect(again.day, 3);
    });

    test('without it the second missed day in a week restarts it', () {
      claim(2);
      claim(4);
      expect(e.dailyFor(d(6))!.day, 1);
    });

    test('day 7 gives 3 Mainsprings at tier 5', () {
      s.prestiges = 1;
      level('grandma', t5);
      s
        ..dailyKey = dateKey(d(1))
        ..dailyStreak = 6;
      expect(e.dailyFor(d(2))!.springs, 3);
    });
  });

  group('Cuckoo', () {
    test('a Golden Second on top: the regular wait goes on after it', () {
      s.goldenNextAt = s.playSeconds + 200;
      expect(e.cuckooGolden(), isTrue);
      expect(e.goldenVisibleLeft, b.golden.visibleFor);
      // It flies away: the regular one still comes in 200 s.
      e.updateEffects(b.golden.visibleFor);
      expect(s.goldenNextAt - s.playSeconds, closeTo(200, 1e-6));
    });

    test('not while another is on screen, nor on a cloudy day', () {
      e.summonGolden();
      expect(e.cuckooGolden(), isFalse);
      e.goldenVisibleLeft = 0;
      s.loopRules.add('noGold');
      expect(e.cuckooGolden(), isFalse);
    });

    test('the full hour at tier 3, the half hour at tier 5', () {
      expect(e.econ.cuckooOnHour, isFalse);
      level('cuckoo', t3);
      expect(e.econ.cuckooOnHour, isTrue);
      expect(e.econ.cuckooOnHalfHour, isFalse);
      level('cuckoo', t5);
      expect(e.econ.cuckooOnHalfHour, isTrue);
    });
  });

  test('Metronome: the reserve refills ×1.5, then holds ×2', () {
    s.prestiges = 1;
    final sp = b.springs;
    level('metronome', t3);
    expect(e.econ.hitReserveRefill(), sp.hitReserveRefill * 1.5);
    expect(e.econ.hitReserve(), sp.hitReserve);
    level('metronome', t5);
    expect(e.econ.hitReserve(), sp.hitReserve * 2);
    expect(e.springReserveAt(1000), sp.hitReserve * 2);
  });

  test('Watchmaker: perks −10%, then −20% in all', () {
    s.shards = 1000;
    final cost = b.perk('deepSleep2').cost;
    level('watchmaker', t3);
    expect(e.econ.perkCost('deepSleep2'), (cost * 0.9).ceil());
    level('watchmaker', t5);
    expect(e.econ.perkCost('deepSleep2'), (cost * 0.8).ceil());
    s.perks.add('deepSleep1');
    final before = s.shards;
    expect(e.buyPerk('deepSleep2'), BuyResult.ok);
    expect(before - s.shards, (cost * 0.8).ceil());
  });

  group('Sprint judge: "Na start!"', () {
    Grade perfect() => const Grade(Tier.perfect, 0.002);

    test('after a 3 h break the first 10 hits pay ×4', () {
      level('sprintJudge', t3);
      expect(e.onReturn(3 * 3600), isTrue);
      expect(s.warmUpHits, 10);
      expect(s.warmUpMultiplier, closeTo(4, 1e-9));
      s.owned['grandpa'] = 10;
      final plain = e.hitPayout(perfect());
      final o = e.resolveRound(perfect());
      expect(o.warmUp, closeTo(4, 1e-9));
      expect(s.warmUpHits, 9);
      expect(o.payout, greaterThan(plain * 3.5));
    });

    test('at most ×9, not after a short break, not on a miss', () {
      level('sprintJudge', t3);
      expect(e.onReturn(1800), isFalse);
      expect(s.warmUpHits, 0);
      e.onReturn(24 * 3600);
      expect(s.warmUpMultiplier, 9);
      e.resolveRound(const Grade(Tier.miss, 0.4, MissKind.late));
      expect(s.warmUpHits, 10);
    });

    test('25 hits at tier 5', () {
      level('sprintJudge', t5);
      e.onReturn(2 * 3600);
      expect(s.warmUpHits, 25);
    });

    test('nothing without the trait', () {
      expect(e.onReturn(10 * 3600), isFalse);
      expect(e.resolveRound(perfect()).warmUp, 1);
    });
  });

  group('Station clock', () {
    test('Golden Seconds 10% more often', () {
      final f = e.econ.goldenIntervalFactor();
      level('stationClock', t3);
      expect(e.econ.goldenIntervalFactor(), closeTo(f / 1.1, 1e-9));
    });

    test('Express: every 5th caught one is twice as strong', () {
      level('stationClock', t5);
      s.owned['grandpa'] = 10;
      final strengths = <double>[];
      for (var i = 0; i < 10; i++) {
        e.nextGoldenExpress; // the tag reads this
        s.goldenArmed = true;
        e.onRoundStart();
        final o = e.resolveRound(const Grade(Tier.perfect, 0.002));
        strengths.add(o.golden!.strength);
        expect(o.golden!.express, (i + 1) % 5 == 0, reason: 'catch ${i + 1}');
      }
      expect(strengths[4], closeTo(strengths[0] * 2, 1e-9));
      expect(s.expressCount, 0);
    });

    test('the tag says which one it is', () {
      level('stationClock', t5);
      s.expressCount = 3;
      expect(e.nextGoldenExpress, isFalse);
      s.expressCount = 4;
      expect(e.nextGoldenExpress, isTrue);
    });
  });

  test('Quartz: clocks +10%, Synchronisation +1% a clock at tier 5', () {
    s.owned['grandpa'] = 10;
    final p = e.econ.passive();
    level('quartz', t3);
    expect(e.econ.passive(), closeTo(p * 1.1, p * 1e-9));
    level('quartz', t5);
    level('grandma', t5);
    // Quartz and Grandma are at tier 5: +2%; Grandpa's own ×1.5 levels
    // are not in it (none bought).
    expect(e.econ.clocksAtTopTier, 2);
    expect(e.econ.passive(), closeTo(p * 1.12, p * 1e-9));
  });

  test('Atomic clock: a Mainspring in 22 h, then 20 h', () {
    s.prestiges = 1;
    level('atomic', t3);
    e.windSprings(1000);
    expect(e.windSprings(1000 + 22 * 3600 * 1000), 1);
    level('atomic', t5);
    expect(e.windSprings(1000 + 42 * 3600 * 1000), 1);
  });

  group('GPS', () {
    test('weekly challenge +1 Mainspring at tier 5', () {
      s.prestiges = 1;
      level('gps', t5);
      final weekly = Challenge(ChallengeKind.goldenWeek, 1);
      expect(e.challengeSprings(weekly), b.challenges.weeklySprings + 1);
    });

    test('all three daily ones wind half a Mainspring', () {
      s.prestiges = 1;
      level('gps', t3);
      e.windSprings(1000);
      s.challengeDay = 20261126; // today's bonus still open
      s.challenges.addAll([
        for (final k in [
          ChallengeKind.great,
          ChallengeKind.perfect,
          ChallengeKind.buyClocks,
        ])
          Challenge(k, 1, progress: 1),
      ]);
      var wound = 0.0;
      for (final c in e.dailyChallenges) {
        wound += e.claimChallenge(c).springSeconds;
      }
      expect(wound, b.springs.secondsPerSpring / 2);
      expect(s.springProgress, b.springs.secondsPerSpring / 2);
    });
  });

  test('Pulsar: effects +15%, Frenzy 50% longer', () {
    final f = e.econ.goldenStrengthFactor();
    level('pulsar', t3);
    expect(e.econ.goldenStrengthFactor(), closeTo(f * 1.15, 1e-9));
    expect(e.econ.frenzyDurationFactor(), 1);
    level('pulsar', t5);
    expect(e.econ.frenzyDurationFactor(), 1.5);
  });

  group('Time machine', () {
    void loopDone() {
      s
        ..loopGoal = true
        ..chronons = 5000
        ..shards = 30;
    }

    test('a new loop starts with 10 Chronons and Shards, 25 at tier 5', () {
      level('timeMachine', t3);
      loopDone();
      expect(e.startLoop(1000), isTrue);
      expect(s.chronons, 10);
      expect(s.shards, 10);
      level('timeMachine', t5);
      loopDone();
      e.startLoop(2000);
      expect(s.chronons, 25);
    });

    test('the next paradox does not take them back', () {
      level('timeMachine', t3);
      loopDone();
      e.startLoop(1000);
      s.earnedTotal = b.prestige.divisor * 1000; // 10 Chronons earned
      expect(e.econ.prestigeGain(), 10);
    });
  });

  group("Schrödinger's cat", () {
    test('the coin: won or lost, about half and half', () {
      level('schrodinger', t3);
      var won = 0, lost = 0;
      for (var i = 0; i < 400; i++) {
        s
          ..chronons = 0
          ..chrononGift = 0
          ..rewindPending = false
          ..earnedTotal = b.prestige.divisor * 1e6; // 100 Chronons
        final gain = e.beginPrestige();
        if (e.lastCoin! > 0) {
          won++;
          expect(e.lastCoin, 10);
          expect(gain, 110);
        } else {
          lost++;
          expect(gain, 100);
        }
      }
      expect(won, inInclusiveRange(160, 240));
      expect(lost, inInclusiveRange(160, 240));
    });

    test('a won coin is not taken back by the next paradox', () {
      level('schrodinger', t5);
      s.earnedTotal = b.prestige.divisor * 1e6;
      while (true) {
        s
          ..chronons = 0
          ..chrononGift = 0
          ..rewindPending = false;
        e.beginPrestige();
        if (e.lastCoin! > 0) break;
      }
      expect(e.lastCoin, 20);
      expect(s.chronons, 120);
      expect(e.econ.prestigeGain(), 0);
      s.earnedTotal = b.prestige.divisor * 8e6; // 200 earned
      expect(e.econ.prestigeGain(), 100);
    });

    test('no coin without the trait', () {
      s.earnedTotal = b.prestige.divisor * 1e6;
      e.beginPrestige();
      expect(e.lastCoin, isNull);
    });
  });

  test('Chronos: its perk for 400, then 2 Mainsprings a bonus', () {
    level('chronos', t3);
    expect(e.econ.perkCost('unlockChronos'), 400);
    expect(e.econ.goalBonusSprings(), b.loops.goalBonusSprings);
    level('chronos', t5);
    expect(e.econ.goalBonusSprings(), 2);
    // With the Watchmaker too: 400 × 0.8.
    level('watchmaker', t5);
    expect(e.econ.perkCost('unlockChronos'), 320);
  });

  test('the new state survives a save', () {
    s
      ..chrononGift = 12
      ..expressCount = 3
      ..warmUpHits = 7
      ..warmUpMultiplier = 4.5;
    final back = decodeSave(encodeSave(SaveData(s, Settings()))).state;
    expect(back.chrononGift, 12);
    expect(back.expressCount, 3);
    expect(back.warmUpHits, 7);
    expect(back.warmUpMultiplier, 4.5);
  });
}
