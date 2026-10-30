import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/seasons.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Calendar events (docs/02 §14).
void main() {
  final b = loadBalance();
  final cfg = b.seasons;

  group('dates', () {
    test('Easter Sunday', () {
      expect(easterSunday(2025), DateTime(2025, 4, 20));
      expect(easterSunday(2026), DateTime(2026, 4, 5));
      expect(easterSunday(2027), DateTime(2027, 3, 28));
    });

    test('the running season by local date', () {
      expect(seasonAt(cfg, DateTime(2026, 10, 29, 23))!.key, 'halloween-2026');
      expect(seasonAt(cfg, DateTime(2026, 11, 2))!.id, 'halloween');
      expect(seasonAt(cfg, DateTime(2026, 11, 3)), isNull);
      expect(seasonAt(cfg, DateTime(2027, 5, 5))!.id, 'fiveDay');
      expect(seasonAt(cfg, DateTime(2026, 12, 24))!.id, 'christmas');
      expect(seasonAt(cfg, DateTime(2027, 3, 21))!.id, 'easter');
      expect(seasonAt(cfg, DateTime(2027, 3, 20)), isNull);
    });

    test('New Year runs into January and belongs to the year it began', () {
      expect(seasonAt(cfg, DateTime(2026, 12, 31))!.key, 'newYear-2026');
      expect(seasonAt(cfg, DateTime(2027, 1, 2))!.key, 'newYear-2026');
      expect(seasonAt(cfg, DateTime(2027, 1, 3)), isNull);
    });
  });

  group('the goal', () {
    late GameState s;
    late GameEngine e;
    final halloween = seasonAt(cfg, DateTime(2026, 10, 30))!;

    setUp(() {
      s = GameState()..stats.rounds = 100; // past beginner's luck
      e = GameEngine(b, s)..setSeason(halloween);
    });

    void catchOne() {
      e.goldenVisibleLeft = 5;
      e.claimGolden();
      e.onRoundStart(); // the golden round
      e.resolveRound(const Grade(Tier.miss, 0.3, MissKind.noTap));
    }

    test('items and hits count; the reward is paid once', () {
      for (var i = 0; i < cfg.catches; i++) {
        catchOne();
      }
      expect(s.seasonCatches, cfg.catches);
      expect(e.seasonRewardPaid, isNull);
      for (var i = 0; i < cfg.hits - 1; i++) {
        e.resolveRound(const Grade(Tier.good, 0.04));
      }
      e.resolveRound(const Grade(Tier.miss, 0.2)); // misses don't count
      expect(e.seasonRewardPaid, isNull);
      final before = s.tiki;
      e.resolveRound(const Grade(Tier.good, 0.04));
      expect(e.seasonRewardPaid, greaterThanOrEqualTo(cfg.rewardFloor));
      expect(s.tiki, greaterThan(before));
      expect(s.seasonsDone, {'halloween-2026'});
      expect(e.seasonDone, isTrue);
      // Done: nothing more counts and nothing is paid again.
      e.seasonRewardPaid = null;
      e.resolveRound(const Grade(Tier.good, 0.04));
      catchOne();
      expect(e.seasonRewardPaid, isNull);
      expect(s.seasonHits, cfg.hits);
      final unlocked = unlockAchievements(
        buildAchievements(b),
        s,
        const AchievementContext(),
      ).map((a) => a.id);
      expect(unlocked, contains('season_halloween'));
    });

    test('no season, no counting; next year starts from zero', () {
      e.setSeason(null);
      e.resolveRound(const Grade(Tier.good, 0.04));
      expect(s.seasonHits, 0);
      e.setSeason(halloween);
      e.resolveRound(const Grade(Tier.good, 0.04));
      expect(s.seasonHits, 1);
      e.setSeason(seasonAt(cfg, DateTime(2027, 10, 30)));
      expect(s.seasonKey, 'halloween-2027');
      expect(s.seasonHits, 0);
    });

    test('a preview of another season keeps this one\'s progress', () {
      e.resolveRound(const Grade(Tier.good, 0.04));
      e.setSeason(seasonIn(cfg, 'christmas', 2026));
      expect(s.seasonHits, 0);
      e.setSeason(halloween);
      expect(s.seasonHits, 1);
    });

    test('progress and themes survive a save', () {
      s
        ..seasonKey = 'halloween-2026'
        ..seasonCatches = 3
        ..seasonHits = 20
        ..theme = 'christmas';
      s.seasonStash['easter-2026'] = [2, 7];
      s.seasonsDone.add('christmas-2025');
      final back = saveFromJsonString(saveToJsonString(SaveData(s, Settings())))
          .state;
      expect(back.seasonKey, 'halloween-2026');
      expect(back.seasonCatches, 3);
      expect(back.seasonHits, 20);
      expect(back.seasonsDone, {'christmas-2025'});
      expect(back.theme, 'christmas');
      expect(back.seasonStash['easter-2026'], [2, 7]);
    });
  });
}
