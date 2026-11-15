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
      expect(e.springHit(DateTime(2026, 11, 15)), 0);
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

    test('exact hits wind 15 min, at most 6 h a local day (R-SPR-3)', () {
      afterParadox();
      final today = DateTime(2026, 11, 15, 10);
      var total = 0.0;
      for (var i = 0; i < 40; i++) {
        total += e.springHit(today);
      }
      expect(total, sp.hitSecondsPerDay);
      expect(e.springHitLeft(today), 0);
      expect(s.springProgress, sp.hitSecondsPerDay);
      // A new day, a new share.
      final tomorrow = DateTime(2026, 11, 16, 9);
      expect(e.springHitLeft(tomorrow), sp.hitSecondsPerDay);
      expect(e.springHit(tomorrow), sp.hitSeconds);
    });

    test('hits finishing a spring make it ready', () {
      afterParadox();
      s.springProgress = sp.secondsPerSpring - 60;
      e.springHit(DateTime(2026, 11, 15));
      expect(s.springs, 1);
      expect(s.springProgress, closeTo(sp.hitSeconds - 60, 1e-9));
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
      expect(s.springs, 100 - 55);
    });

    test('too few Mainsprings: refused, nothing spent', () {
      afterParadox();
      s.everOwned.add('grandpa');
      s.clockLevels['grandpa'] = 3; // next costs 4
      s.springs = 3;
      expect(e.levelClock('grandpa'), BuyResult.tooExpensive);
      expect(s.springs, 3);
    });

    test('each level adds +10 % to that clock only', () {
      s.owned['grandpa'] = 10;
      s.owned['grandma'] = 10;
      final pa = e.econ.generatorRate('grandpa');
      final ma = e.econ.generatorRate('grandma');
      s.clockLevels['grandpa'] = 4;
      expect(
        e.econ.generatorRate('grandpa'),
        closeTo(pa * (1 + 4 * sp.levelBonus), pa * 1e-9),
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

    test('levels 5 and 10 are master titles (+1 % each)', () {
      final all = buildAchievements(b);
      final ids = all
          .where((a) => a.category == AchievementCategory.mastery)
          .map((a) => a.id)
          .toSet();
      expect(ids, hasLength(b.generators.length * sp.titleLevels.length));
      s.clockLevels['quartz'] = 5;
      final got = unlockAchievements(all, s, const AchievementContext());
      expect(got.map((a) => a.id), contains('mastery_quartz_5'));
      expect(got.map((a) => a.id), isNot(contains('mastery_quartz_10')));
    });
  });

  group('dial faces (docs/12 §3.3)', () {
    test('unlocked by Tiki earned in all runs, in order', () {
      expect(e.econ.unlockedDials.map((d) => d.id), ['classic']);
      s.lifetime.earnedEver = b.dials[3].earned;
      expect(e.econ.unlockedDials, hasLength(4));
      expect(e.econ.nextDial, b.dials[4]);
      s.lifetime.earnedEver = 1e300;
      expect(e.econ.nextDial, isNull);
    });

    test('a locked or unknown choice draws the classic face', () {
      s.dial = 'rift';
      expect(e.econ.dialId, 'classic');
      s.lifetime.earnedEver = b.dials.last.earned;
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
        ..springHitDay = 20261115
        ..springHitSeconds = 900
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
      expect(back.springHitDay, 20261115);
      expect(back.springHitSeconds, 900);
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
