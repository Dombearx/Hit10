import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Mainsprings, clock levels and dial faces (docs/12 §3.1, §3.3).
void main() {
  final b = loadBalance();
  final sp = b.springs;
  const day = 86400 * 1000;
  late GameState s;
  late GameEngine e;

  setUp(() {
    s = GameState();
    e = GameEngine(b, s);
  });

  /// A game after its first paradox, the winding started at [t0].
  void afterParadox({int t0 = 1000}) {
    s.prestiges = 1;
    e.windSprings(t0);
  }

  group('winding (R-SPR-1…4)', () {
    test('nothing before the first paradox', () {
      expect(e.windSprings(1000), 0);
      expect(e.windSprings(1000 + 3 * day), 0);
      expect(s.springs, 0);
      expect(e.springHit(1000), 0);
    });

    test('the first paradox gives one to try and starts the winding', () {
      s.earnedTotal = 1e12;
      expect(e.beginPrestige(), greaterThan(0));
      expect(s.springs, sp.firstGift);
      e.windSprings(5000); // starts the clock
      expect(e.windSprings(5000 + day), 1);
      expect(s.springs, sp.firstGift + 1);
      // A second paradox gives no gift.
      s.earnedTotal = 1e15;
      e.finishPrestige();
      e.beginPrestige();
      expect(s.springs, sp.firstGift + 1);
    });

    test('one a day of real time, offline included, with the remainder', () {
      afterParadox();
      expect(e.windSprings(1000 + day ~/ 2), 0);
      expect(e.springFraction(), closeTo(0.5, 1e-9));
      expect(e.windSprings(1000 + 2 * day + day ~/ 4), 2);
      expect(s.springs, 2);
      expect(e.springFraction(), closeTo(0.25, 1e-9));
    });

    test('a clock set back winds nothing', () {
      afterParadox(t0: 10 * day);
      expect(e.windSprings(5 * day), 0);
      expect(s.springProgress, 0);
      // …and counts from the new time on.
      expect(e.windSprings(6 * day), 1);
    });

    test('the stock stops at the cap; the overflow is lost', () {
      afterParadox();
      expect(e.windSprings(1000 + 30 * day), sp.maxStock);
      expect(s.springs, sp.maxStock);
      expect(s.springProgress, 0);
      expect(e.springFraction(), 1);
      expect(s.lifetime.springSecondsLost, greaterThan(0));
      // Spending one starts the winding again.
      s.everOwned.add('grandpa');
      expect(e.levelClock('grandpa'), BuyResult.ok);
      expect(e.windSprings(1000 + 30 * day + day), 1);
    });

    test('exact hits wind 30 min out of a 2 h reserve (R-SPR-3)', () {
      afterParadox();
      const t = 2000;
      expect(sp.hitSeconds, 1800);
      expect(e.springReserveAt(t), sp.hitReserve);
      var total = 0.0;
      for (var i = 0; i < 40; i++) {
        total += e.springHit(t + i);
      }
      expect(total, sp.hitReserve);
      expect(e.springReserveAt(t + 40), closeTo(0, 0.1));
      expect(s.springProgress, sp.hitReserve);
      expect(e.springHit(t + 50), 0);
    });

    test('the reserve comes back 30 min an hour, full after 4 h', () {
      afterParadox();
      for (var i = 0; i < 4; i++) {
        e.springHit(2000);
      }
      expect(e.springReserveAt(2000), 0);
      const hour = 3600 * 1000;
      expect(e.springReserveAt(2000 + hour), closeTo(1800, 1e-6));
      expect(e.springReserveFullIn(2000 + hour), closeTo(3 * 3600, 1e-6));
      expect(e.springReserveAt(2000 + 4 * hour), sp.hitReserve);
      expect(e.springReserveAt(2000 + 40 * hour), sp.hitReserve);
      expect(e.springReserveFullIn(2000 + 4 * hour), 0);
      // A clock set back gives nothing.
      expect(e.springReserveAt(500), 0);
    });

    test('hits finishing a spring make it ready', () {
      afterParadox();
      s.springProgress = sp.secondsPerSpring - 60;
      e.springHit(2000);
      expect(s.springs, 1);
      expect(s.springProgress, closeTo(sp.hitSeconds - 60, 1e-9));
    });
  });

  group('a full stock (R-SPR-4)', () {
    test('a hit takes nothing from the reserve', () {
      afterParadox();
      s.springs = sp.maxStock;
      expect(e.springsFull, isTrue);
      expect(e.springHit(2000), 0);
      expect(e.springReserveAt(2000), sp.hitReserve);
      expect(s.lifetime.springSecondsLost, 0);
      // Spent one: the same hit winds again.
      s.springs--;
      expect(e.springHit(3000), sp.hitSeconds);
    });

    test('the last spring takes only what it still needs', () {
      afterParadox();
      s
        ..springs = sp.maxStock - 1
        ..springProgress = sp.secondsPerSpring - 300;
      expect(e.springHit(2000), closeTo(300, 1e-9));
      expect(s.springs, sp.maxStock);
      expect(e.springReserveAt(2000), closeTo(sp.hitReserve - 300, 1e-9));
      expect(s.lifetime.springSecondsLost, 0);
    });
  });

  group('the "wind it" ad (R-SPR-3b)', () {
    final noon = DateTime(2026, 11, 15, 12).millisecondsSinceEpoch;

    test('offered when the reserve is empty, refills it, twice a day', () {
      afterParadox(t0: noon);
      s
        ..tutorialDone = true
        ..playSeconds = b.ads.unlockAfterSeconds + 1;
      final ads = AdOffers(e);
      expect(ads.available(AdOffer.spring, noon), isFalse); // full
      while (e.springHit(noon) > 0) {}
      expect(ads.available(AdOffer.spring, noon), isTrue);
      expect(ads.springAdsLeft(noon), b.ads.springPerDay);
      for (var i = 0; i < b.ads.springPerDay; i++) {
        ads.grant(AdOffer.spring, noon);
        expect(e.springReserveAt(noon), sp.hitReserve);
        expect(ads.available(AdOffer.spring, noon), isFalse);
        while (e.springHit(noon) > 0) {}
      }
      // The day's ads are used up; tomorrow there are two again.
      expect(ads.available(AdOffer.spring, noon), isFalse);
      expect(ads.springAdsLeft(noon), 0);
      final tomorrow = noon + day;
      expect(ads.springAdsLeft(tomorrow), b.ads.springPerDay);
    });

    test('not before the first paradox', () {
      s
        ..tutorialDone = true
        ..playSeconds = b.ads.unlockAfterSeconds + 1;
      expect(AdOffers(e).available(AdOffer.spring, noon), isFalse);
    });
  });

  group('clock levels (R-SPR-5/6)', () {
    test('level N costs N, max level, only clocks bought once', () {
      afterParadox();
      s.springs = 100;
      expect(e.levelClock('grandma'), BuyResult.unavailable);
      expect(e.buyGenerators('grandpa', 1), BuyResult.tooExpensive);
      s.tiki = 100;
      expect(e.buyGenerators('grandpa', 1), BuyResult.ok);
      for (var lv = 1; lv <= sp.maxLevel; lv++) {
        expect(e.econ.clockLevelCost('grandpa'), lv);
        expect(e.levelClock('grandpa'), BuyResult.ok);
      }
      expect(e.econ.clockLevelCost('grandpa'), isNull);
      expect(e.levelClock('grandpa'), BuyResult.unavailable);
      expect(s.springs, 100 - 15); // 1 + 2 + 3 + 4 + 5
    });

    test('too few Mainsprings: refused, nothing spent', () {
      afterParadox();
      s.everOwned.add('grandpa');
      s.clockLevels['grandpa'] = 3; // next costs 4
      s.springs = 3;
      expect(e.levelClock('grandpa'), BuyResult.tooExpensive);
      expect(s.springs, 3);
    });

    test('each tier multiplies that clock only by 1.5', () {
      s.owned['grandpa'] = 10;
      s.owned['grandma'] = 10;
      final pa = e.econ.generatorRate('grandpa');
      final ma = e.econ.generatorRate('grandma');
      s.clockLevels['grandpa'] = 4;
      expect(
        e.econ.generatorRate('grandpa'),
        closeTo(pa * sp.levelFactor * sp.levelFactor * 1.5 * 1.5, pa * 1e-9),
      );
      expect(e.econ.generatorRate('grandma'), ma);
    });

    test('levels and Mainsprings survive the paradox', () {
      afterParadox();
      s
        ..clockLevels['cuckoo'] = 3
        ..springs = 2
        ..everOwned.add('cuckoo')
        ..earnedTotal = 1e15;
      e.prestige();
      expect(s.clockLevels['cuckoo'], 3);
      expect(s.springs, 2);
      expect(s.everOwned, contains('cuckoo'));
    });

    test('tiers 3 and 5 are master titles (+1 % each), ids as before', () {
      final all = buildAchievements(b);
      final ids = all
          .where((a) => a.category == AchievementCategory.mastery)
          .map((a) => a.id)
          .toSet();
      expect(ids, hasLength(b.generators.length * sp.titleLevels.length));
      s.clockLevels['quartz'] = 3;
      var got = unlockAchievements(all, s, const AchievementContext());
      expect(got.map((a) => a.id), contains('mastery_quartz_5'));
      expect(got.map((a) => a.id), isNot(contains('mastery_quartz_10')));
      s.clockLevels['quartz'] = 5;
      got = unlockAchievements(all, s, const AchievementContext());
      expect(got.map((a) => a.id), ['mastery_quartz_10']);
    });
  });

  group('dial faces (docs/17 §5)', () {
    DialConfig dial(String id) => b.dials.firstWhere((d) => d.id == id);
    List<String> ids(Iterable<DialConfig> ds) => [for (final d in ds) d.id];

    test('17 faces on five tracks, the classic from the start', () {
      expect(b.dials, hasLength(17));
      expect(e.econ.dialTracks, DialTrack.values);
      expect(ids(e.econ.unlockedDials), ['classic']);
      // The last mastery face is every tier of every clock (R-SPR-5).
      expect(dial('grandmaster').tiers, b.generators.length * sp.maxLevel);
    });

    test('Tiki earned open the first four only', () {
      s.lifetime.earnedEver = 1e300;
      expect(ids(e.econ.unlockedDials), [
        'classic',
        'wood',
        'porcelain',
        'brass',
      ]);
      expect(e.econ.nextDialOn(DialTrack.earned), isNull);
    });

    test('mastery tiers in total', () {
      s.clockLevels.addAll({'grandpa': 3, 'cuckoo': 1});
      expect(e.econ.masteryTiers, 4);
      expect(e.econ.nextDialOn(DialTrack.mastery)!.id, 'spring');
      expect(e.econ.dialProgress(dial('spring')), closeTo(0.8, 1e-9));
      s.clockLevels['metronome'] = 1;
      expect(e.econ.dialUnlocked(dial('spring')), isTrue);
      // The next one fills from the last below it: 5 of 5..30.
      expect(e.econ.nextDialOn(DialTrack.mastery)!.id, 'swiss');
      expect(e.econ.dialProgress(dial('swiss')), 0);
    });

    test('the first loop, then the seals (R-PETLA-5)', () {
      expect(e.econ.nextDialOn(DialTrack.loops)!.id, 'station');
      s.loopsDone = 1;
      expect(e.econ.dialUnlocked(dial('station')), isTrue);
      expect(e.econ.nextDialOn(DialTrack.loops)!.seal, 'blindfold');
      expect(e.econ.dialProgress(dial('quartz')), 0);
      s.seals.addAll(b.loops.rules.map((r) => r.id));
      expect(e.econ.nextDialOn(DialTrack.loops), isNull);
    });

    test('100 Chronos in one loop stay after the loop resets them', () {
      s.owned['chronos'] = 50;
      expect(e.econ.dialProgress(dial('hourglass')), closeTo(0.5, 1e-9));
      s.owned['chronos'] = 100;
      expect(e.econ.dialUnlocked(dial('hourglass')), isTrue);
      s.dialsSeen.add('hourglass'); // the controller marks it each second
      s.owned['chronos'] = 0;
      expect(e.econ.dialUnlocked(dial('hourglass')), isTrue);
    });

    test('days with the daily bonus, no streak needed', () {
      s.lifetime.dailyClaims = 99;
      expect(e.econ.dialUnlocked(dial('calendar')), isFalse);
      s.lifetime.dailyClaims = 100;
      expect(e.econ.dialUnlocked(dial('calendar')), isTrue);
    });

    test('the next face fills linearly between the two thresholds', () {
      final wood = dial('wood').earned;
      final porcelain = dial('porcelain').earned;
      s.lifetime.earnedEver = wood / 1000;
      expect(e.econ.dialProgress(dial('wood')), closeTo(0.001, 1e-9));
      s.lifetime.earnedEver = wood + (porcelain - wood) / 4;
      expect(e.econ.dialProgress(dial('porcelain')), closeTo(0.25, 1e-9));
    });

    test('a face unlocked under an old rule stays (R-TARCZA-1)', () {
      s.dialsSeen.addAll(['station', 'swiss']);
      expect(e.econ.dialUnlocked(dial('station')), isTrue);
      expect(e.econ.dialUnlocked(dial('swiss')), isTrue);
      expect(e.econ.nextDialOn(DialTrack.mastery)!.id, 'spring');
      expect(e.econ.nextDialOn(DialTrack.loops)!.seal, 'blindfold');
    });

    test('a locked or unknown choice draws the classic face', () {
      s.dial = 'rift';
      expect(e.econ.dialId, 'classic');
      s.seals.add('insomnia');
      expect(e.econ.dialId, 'rift');
      s.dial = 'nope';
      expect(e.econ.dialId, 'classic');
    });
  });

  group('save (T-17)', () {
    test('new fields round-trip', () {
      s
        ..springs = 4
        ..springProgress = 123.5
        ..springClockMs = 42
        ..springReserve = 900
        ..springReserveMs = 43
        ..springAdDay = 20261115
        ..springAdCount = 1
        ..clockLevels['gps'] = 2
        ..everOwned.addAll(['grandpa', 'gps'])
        ..dial = 'wood'
        ..dialsSeen.addAll(['classic', 'wood']);
      s.lifetime
        ..springsWound = 9
        ..springSecondsLost = 77;
      final back = saveFromJsonString(saveToJsonString(SaveData(s, Settings())))
          .state;
      expect(back.springs, 4);
      expect(back.springProgress, 123.5);
      expect(back.springClockMs, 42);
      expect(back.springReserve, 900);
      expect(back.springReserveMs, 43);
      expect(back.springAdDay, 20261115);
      expect(back.springAdCount, 1);
      expect(back.clockLevels, {'gps': 2});
      expect(back.everOwned, {'grandpa', 'gps'});
      expect(back.dial, 'wood');
      expect(back.dialsSeen, {'classic', 'wood'});
      expect(back.lifetime.springsWound, 9);
      expect(back.lifetime.springSecondsLost, 77);
    });

    test('an older save learns which clocks were ever bought', () {
      final j = encodeSave(SaveData(s, Settings()))
        ..remove('everOwned')
        ..remove('dialsSeen')
        ..['owned'] = {'grandpa': 3, 'cuckoo': 0}
        ..['achievements'] = ['owned_gps_1', 'owned_gps_10', 'earned_1'];
      final back = decodeSave(j).state;
      expect(back.everOwned, {'grandpa', 'gps'});
      expect(back.dialsSeen, {'*'}); // replaced by the controller
    });
  });
}
