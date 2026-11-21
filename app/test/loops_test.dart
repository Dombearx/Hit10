import 'dart:convert';
import 'dart:math' as math;

import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/seasons.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Time Loops (docs/13 §5.2, docs/02 §16): the goal, the reset, the rules
/// and the seals.
void main() {
  final b = loadBalance();
  final rules = b.loops.storyRules.map((r) => r.id).toList();
  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState()..tutorialDone = true;
    e = GameEngine(b, s, random: math.Random(1));
  });

  /// A game with every perk and the goal clock bought.
  void reachGoal() {
    s
      ..prestiges = 3
      ..loopPrestiges = 3
      ..chronons = 600
      ..shards = 7
      ..earnedTotal = 1e8 * 600.0 * 600 * 600
      ..tiki = 1e30
      ..loopPlaySeconds = 3600;
    s.perks.addAll(b.prestige.perks.map((p) => p.id));
    expect(e.buyGenerators('chronos', 1), BuyResult.ok);
  }

  group('the goal (R-PETLA-1, 2a)', () {
    test('the first Chronos ends the loop, once', () {
      expect(e.checkLoop().goalReached, isFalse);
      reachGoal();
      final r = e.checkLoop();
      expect(r.goalReached, isTrue);
      expect(s.loopGoal, isTrue);
      expect(s.loopsDone, 1);
      expect(s.loopGoalSeconds, 3600);
      expect(s.loopBest[''], 3600);
      expect(s.seals, isEmpty); // the first loop had no rule
      expect(e.checkLoop().goalReached, isFalse);
      expect(e.econ.chaptersOpen, 1);
    });

    test('a Chronos bought before the loops existed counts in loop 1', () {
      s.everOwned.add('chronos');
      expect(e.checkLoop().goalReached, isTrue);
    });

    test('each bonus of Chronos pays a Mainspring, once a loop', () {
      reachGoal();
      expect(e.checkLoop().springs, 0);
      final t = e.econ.milestoneThresholds('chronos');
      s.owned['chronos'] = t[1]; // two bonuses
      expect(e.checkLoop().springs, 2 * b.loops.goalBonusSprings);
      expect(s.springs, 2);
      expect(e.checkLoop().springs, 0);
      // After a paradox the same bonuses pay nothing again.
      s.owned['chronos'] = 0;
      expect(e.checkLoop().springs, 0);
      s.owned['chronos'] = t[2];
      expect(e.checkLoop().springs, 1);
      s.owned['chronos'] = t.last;
      e.checkLoop();
      expect(s.loopBonusPaid, t.length);
      expect(s.springs, t.length); // over the stock's cap is fine
    });
  });

  group('a new loop (R-PETLA-3, 4)', () {
    test('not before the goal', () {
      expect(e.startLoop(1000), isFalse);
      expect(s.loop, 1);
    });

    test('resets the run, Chronons, Shards and perks; the rest stays', () {
      reachGoal();
      e.checkLoop();
      s
        ..springs = 4
        ..clockLevels['grandpa'] = 2
        ..skills['power'] = 5
        ..habits.add('power')
        ..secondClockOn = true
        ..autoBuyerOn = true;
      s.achievements.add('x');
      final ever = s.lifetime.earnedEver;
      expect(e.startLoop(5000), isTrue);
      expect(s.loop, 2);
      expect(s.loopRules, [rules.first]);
      expect(s.loopGoal, isFalse);
      expect(s.loopPlaySeconds, 0);
      expect(s.loopPrestiges, 0);
      expect(s.loopStartMs, 5000);
      expect(s.tiki, 0);
      expect(s.earnedTotal, 0);
      expect(s.chronons, 0);
      expect(s.shards, 0);
      expect(s.owned, isEmpty);
      expect(s.skills, isEmpty);
      expect(s.perks, isEmpty);
      expect(s.habits, isEmpty);
      expect(s.secondClockOn, isFalse);
      expect(s.autoBuyerOn, isFalse);
      // What stays.
      expect(s.springs, 4);
      expect(s.clockLevels['grandpa'], 2);
      expect(s.achievements, {'x'});
      expect(s.prestiges, 3);
      expect(s.lifetime.earnedEver, ever);
      expect(s.everOwned, contains('chronos'));
      // Lifetime Tiki go on from where they were.
      s.earn(10);
      expect(s.earnedTotal, 10);
      expect(s.lifetime.earnedEver, ever + 10);
    });

    test('the story brings the rules in order, then the player picks', () {
      for (var i = 0; i < rules.length; i++) {
        reachGoal();
        e.checkLoop();
        expect(e.econ.storyDone, isFalse);
        expect(e.econ.nextLoopRules(), [rules[i]]);
        e.startLoop(0);
        expect(s.loopRules, [rules[i]]);
      }
      reachGoal();
      e.checkLoop();
      expect(s.seals, rules.toSet());
      expect(s.loopsDone, rules.length + 1);
      expect(e.econ.chaptersOpen, b.loops.storyChapters);
      expect(e.econ.storyDone, isTrue);
      // Free play: any rules, several or none.
      expect(e.econ.nextLoopRules(), isEmpty);
      s.nextRules.addAll([rules[3], rules[0]]);
      expect(e.econ.nextLoopRules(), [rules[0], rules[3]]);
      e.startLoop(0);
      expect(s.loopRules, [rules[0], rules[3]]);
      expect(s.nextRules, isEmpty);
      // A rule outside the story only comes picked (docs/15).
      expect(rules, isNot(contains('fragileCombo')));
      s.nextRules.add('fragileCombo');
      expect(e.econ.nextLoopRules(), ['fragileCombo']);
    });

    test('the best time of a rule is kept', () {
      reachGoal();
      e.checkLoop();
      e.startLoop(0);
      s.loopPlaySeconds = 5000;
      reachGoal();
      s.loopPlaySeconds = 5000;
      e.checkLoop();
      expect(s.loopBest[rules.first], 5000);
    });
  });

  group('the rules (R-PETLA-4)', () {
    test('broken stopwatch: Blind is on, and pays as Blind', () {
      expect(e.blindActive, isFalse);
      s.loopRules.add('blindfold');
      expect(e.blindForced, isTrue);
      expect(e.blindActive, isTrue);
      expect(e.modeMultiplier(), b.blind.rewardMultiplier);
    });

    test('price hike: each unit raises the price by 20 %', () {
      final before = e.econ.generatorCost('grandma', 10);
      s.loopRules.add('inflation');
      expect(e.econ.costGrowth, 1.2);
      expect(
        e.econ.generatorCost('grandma', 10),
        closeTo(before * math.pow(1.2 / 1.15, 10), before * 1e-9),
      );
      // Bulk price and MAX agree with buying one by one.
      var sum = 0.0;
      for (var n = 0; n < 7; n++) {
        sum += e.econ.generatorCost('grandma', n);
      }
      expect(e.econ.bulkCost('grandma', 7), closeTo(sum, sum * 1e-9));
      expect(e.econ.maxAffordable('grandma', sum * 1.0001), 7);
    });

    test('cloudy day: no golden second, no golden ad; a season still', () {
      s
        ..loopRules.add('noGold')
        ..playSeconds = 1e6
        ..goldenNextAt = 0;
      expect(e.goldenBlocked, isTrue);
      expect(e.updateEffects(1), isFalse);
      e.summonGolden();
      expect(e.goldenVisibleLeft, 0);
      expect(AdOffers(e).available(AdOffer.golden, 0), isFalse);
      final cfg = b.seasons.list.firstWhere((x) => x.id == 'christmas');
      e.setSeason(
        Season(cfg, 2026, DateTime(2026, 12, 18), DateTime(2026, 12, 27)),
      );
      expect(e.goldenBlocked, isFalse);
      expect(e.updateEffects(1), isTrue);
    });

    test('short fuse: the combo stops at 5, no Shield', () {
      s
        ..skills['combo'] = 10
        ..skills['shield'] = 3;
      expect(e.econ.comboCap(), greaterThan(5));
      s.loopRules.add('shortFuse');
      expect(e.econ.comboCap(), 5);
      expect(e.econ.shieldCharges(), 0);
      expect(e.maxShieldCharges(), 0);
    });

    test('Swiss precision: a GOOD pays nothing, a GREAT does', () {
      s.owned['grandpa'] = 10;
      expect(e.hitPayout(const Grade(Tier.good, 0.04)), greaterThan(0));
      s.loopRules.add('precision');
      expect(e.hitPayout(const Grade(Tier.good, 0.04)), 0);
      expect(e.hitPayout(const Grade(Tier.great, 0.02)), greaterThan(0));
    });

    test('insomnia: 25 % offline whatever the perks', () {
      s.perks.addAll(['deepSleep1', 'deepSleep2']);
      expect(e.offlineEfficiency(), 1);
      s.loopRules.add('insomnia');
      expect(e.offlineEfficiency(), 0.25);
    });
  });

  group('the seals (R-PETLA-5)', () {
    test('broken stopwatch: Blind pays one more', () {
      final before = e.blindMultiplier();
      s.seals.add('blindfold');
      expect(e.blindMultiplier(), before + 1);
    });

    test('price hike: the first 10 of each clock cost half', () {
      final tenth = e.econ.generatorCost('cuckoo', 9);
      final eleventh = e.econ.generatorCost('cuckoo', 10);
      s.seals.add('inflation');
      expect(e.econ.generatorCost('cuckoo', 9), tenth / 2);
      expect(e.econ.generatorCost('cuckoo', 10), eleventh);
      var sum = 0.0;
      for (var n = 0; n < 14; n++) {
        sum += e.econ.generatorCost('cuckoo', n);
      }
      expect(e.econ.bulkCost('cuckoo', 14), closeTo(sum, sum * 1e-9));
      expect(e.econ.maxAffordable('cuckoo', sum * 1.0001), 14);
      expect(e.econ.maxAffordable('cuckoo', sum * 0.9999), 13);
      s.owned['cuckoo'] = 8;
      expect(
        e.econ.bulkCost('cuckoo', 3),
        closeTo(
          e.econ.generatorCost('cuckoo', 8) +
              e.econ.generatorCost('cuckoo', 9) +
              e.econ.generatorCost('cuckoo', 10),
          1e-6,
        ),
      );
    });

    test('cloudy day: back after an hour, gold within 30 s', () {
      s
        ..playSeconds = 100
        ..goldenNextAt = 900;
      e.onReturn(7200);
      expect(s.goldenNextAt, 900); // no seal yet
      s.seals.add('noGold');
      e.onReturn(600);
      expect(s.goldenNextAt, 900); // too short an absence
      e.onReturn(7200);
      expect(s.goldenNextAt, inInclusiveRange(100, 130));
    });

    test('short fuse: one more Shield charge, from the start', () {
      s.seals.add('shortFuse');
      expect(e.econ.shieldCharges(), 1);
      s.earnedTotal = 1e12;
      e.prestige();
      expect(s.shieldCharges, 1);
    });

    test('Swiss precision: PERFECT 1 ms wider, never past GREAT', () {
      final before = e.econ.windows().perfect;
      s.seals.add('precision');
      expect(e.econ.windows().perfect, closeTo(before + 0.001, 1e-12));
      s.skills['magnet'] = b.skill('magnet').maxLevel;
      final w = e.econ.windows();
      expect(w.perfect, lessThanOrEqualTo(w.great));
    });

    test('insomnia: 12 more hours of offline income', () {
      final before = e.offlineCapSeconds();
      s.seals.add('insomnia');
      expect(e.offlineCapSeconds(), before + 12 * 3600);
    });
  });

  group('save (T-17)', () {
    test('loop fields round-trip', () {
      s
        ..loop = 3
        ..loopRules.add('inflation')
        ..seals.add('blindfold')
        ..loopsDone = 2
        ..loopGoal = true
        ..loopEndSeen = true
        ..loopBonusPaid = 4
        ..loopPlaySeconds = 99.5
        ..loopPrestiges = 6
        ..loopStartMs = 77
        ..loopGoalSeconds = 88
        ..loopBest['blindfold'] = 1234
        ..nextRules.add('noGold');
      final back = saveFromJsonString(saveToJsonString(SaveData(s, Settings())))
          .state;
      expect(back.loop, 3);
      expect(back.loopRules, ['inflation']);
      expect(back.seals, {'blindfold'});
      expect(back.loopsDone, 2);
      expect(back.loopGoal, isTrue);
      expect(back.loopEndSeen, isTrue);
      expect(back.loopBonusPaid, 4);
      expect(back.loopPlaySeconds, 99.5);
      expect(back.loopPrestiges, 6);
      expect(back.loopStartMs, 77);
      expect(back.loopGoalSeconds, 88);
      expect(back.loopBest, {'blindfold': 1234});
      expect(back.nextRules, ['noGold']);
    });

    test('a v1 save: Mainsprings spent on levels come back, old faces '
        'stay, the first loop takes the figures so far', () {
      final v1 = {
        'saveVersion': 1,
        'tiki': 5,
        'prestiges': 4,
        'springs': 2,
        'clockLevels': {'grandpa': 2, 'chronos': 8}, // 3 + 36 spent
        'achievements': ['mastery_chronos_5'],
        'dialsSeen': ['classic', 'wood'],
        'lifetime': {'earnedEver': 2e20, 'secondsPlayed': 4000},
      };
      final st = saveFromJsonString(jsonEncode(v1)).state;
      expect(st.clockLevels, isEmpty);
      expect(st.springs, 2 + 39);
      expect(st.springsRefunded, 39);
      expect(st.achievements, contains('mastery_chronos_5'));
      expect(
        st.dialsSeen,
        containsAll(['classic', 'wood', 'quartz', 'atomic']),
      );
      expect(st.dialsSeen, isNot(contains('neon')));
      expect(st.loop, 1);
      expect(st.loopPlaySeconds, 4000);
      expect(st.loopPrestiges, 4);
      // Saved again it is a v2 save: nothing is refunded twice.
      final again = saveFromJsonString(
        saveToJsonString(SaveData(st, Settings())),
      ).state;
      expect(again.springs, 41);
    });
  });
}
