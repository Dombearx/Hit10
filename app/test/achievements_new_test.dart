import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/model/settings.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Achievements added after playtest 25 (docs/02 §8, Cookie Clicker kinds).
void main() {
  final b = loadBalance();
  final all = buildAchievements(b);
  late GameState s;
  late GameEngine e;
  setUp(() {
    s = GameState();
    e = GameEngine(b, s);
  });

  Iterable<String> unlock([
    AchievementContext c = const AchievementContext(),
  ]) => unlockAchievements(all, s, c).map((a) => a.id);

  test('about 150, unique ids, every new kind present', () {
    expect(all.length, inInclusiveRange(145, 160));
    expect(all.map((a) => a.id).toSet(), hasLength(all.length));
    for (final c in AchievementCategory.values) {
      expect(all.where((a) => a.category == c), isNotEmpty, reason: '$c');
    }
  });

  test('5.00 on the dial counts as exact; a PERFEKT 5.01 does not', () {
    final w = e.econ.playerWindows();
    e.resolveRound(grade(0.012, w)); // 5.01: PERFEKT, not exact
    expect(s.lifetime.perfects, 1);
    expect(s.lifetime.exactHits, 0);
    e.resolveRound(grade(-0.003, w)); // 5.00
    expect(s.lifetime.exactHits, 1);
    // The dial snaps to 5.00 inside the jackpot window, so this counts too.
    e.resolveRound(grade(0.008, w));
    expect(s.lifetime.exactHits, 2);
    expect(e.isJackpot(grade(0.008, w)), isTrue);
    expect(unlock(), contains('exact_1'));
  });

  test('income per second comes from the once-a-second check', () {
    expect(unlock(), isNot(contains('income_1e+3')));
    expect(
      unlock(const AchievementContext(passive: 2e6)),
      containsAll(['income_1e+3', 'income_1e+6']),
    );
  });

  test('no hands: 1M in a run with at most 15 taps', () {
    s
      ..earnedThisRun = 1e6
      ..runTaps = 16;
    expect(unlock(), isNot(contains('feat_noHands')));
    s.runTaps = 15;
    expect(unlock(), contains('feat_noHands'));
  });

  test('the paradox resets the run taps', () {
    s
      ..earnedTotal = 1e8 * 27
      ..runTaps = 500;
    e.prestige();
    expect(s.runTaps, 0);
  });

  test('a save from before the counter does not give no hands away', () {
    final json = saveToJsonString(SaveData(GameState(), Settings()));
    final old = json.replaceFirst('"runTaps":0,', '');
    expect(old, isNot(contains('runTaps')));
    expect(saveFromJsonString(old).state.runTaps, greaterThan(15));
  });

  test('golden clock: fast catch and catch during Frenzy', () {
    e.goldenVisibleLeft = b.golden.visibleFor - 0.5;
    e.frenzyLeft = 10;
    expect(e.claimGolden(), isTrue);
    expect(s.lifetime.goldenFast, 1);
    expect(s.lifetime.goldenInFrenzy, 1);
    expect(unlock(), containsAll(['feat_goldenFast', 'feat_goldenFrenzy']));
  });

  test('counted totals: clocks, skill levels, achievements', () {
    s.owned.addAll({'grandpa': 60, 'grandma': 40});
    s.skills.addAll({'echo': 15, 'combo': 10});
    final got = unlock().toList();
    expect(got, containsAll(['clocks_100', 'skillLevels_25']));
    // The meta badge counts the others, so it can follow in the same check.
    s.achievements.addAll(List.generate(30, (i) => 'x$i'));
    expect(unlock(), contains('achievements_25'));
  });

  test('atomic clock needs a full window of 100 taps', () {
    s.stats.recentErrors.add(0.001); // one great tap is not enough
    expect(unlock(), isNot(contains('hidden_atomic')));
    s.stats.recentErrors
      ..clear()
      ..addAll(List.generate(100, (i) => i.isEven ? 0.01 : -0.012));
    expect(unlock(), contains('hidden_atomic'));
  });

  test('later clocks count fewer pieces (playtest 25 report)', () {
    final ids = all.map((a) => a.id).toSet();
    expect(ids, containsAll(['owned_grandpa_200', 'owned_chronos_50']));
    expect(ids, isNot(contains('owned_chronos_200')));
    expect(ids, contains('owned_quartz_100'));
  });
}
