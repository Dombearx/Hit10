import '../balance/balance.dart';
import 'game_state.dart';

enum AchievementCategory {
  earned,
  owned,
  perfects,
  perfectStreak,
  combo,
  golden,
  prestige,
  mode,
  hidden,
}

/// What the latest event knows that the saved state does not (docs/02 §8).
class AchievementContext {
  const AchievementContext({
    this.now,
    this.lastHitBlind = false,
    this.lastHitFast = false,
    this.lastHitPerfect = false,
  });

  /// Local wall-clock time of the event (punctual / tenth-day badges).
  final DateTime? now;
  final bool lastHitBlind;
  final bool lastHitFast;
  final bool lastHitPerfect;
}

class AchievementDef {
  const AchievementDef(
    this.id,
    this.category,
    this.check, {
    this.threshold = 0,
    this.generator,
  });

  final String id;
  final AchievementCategory category;
  final bool Function(GameState s, AchievementContext ctx) check;

  /// Display number (amount, count…) for the localized name.
  final double threshold;
  final String? generator;

  bool get hidden => category == AchievementCategory.hidden;
}

/// The full list (≈100), built from the thresholds in the balance file
/// (R-OSIAG-2). Each gives +1 % to the global multiplier (R-OSIAG-1).
List<AchievementDef> buildAchievements(Balance b) {
  final a = b.achievements;
  final list = <AchievementDef>[];
  for (final t in a.earnedThresholds) {
    list.add(
      AchievementDef(
        'earned_${t.toStringAsExponential(0)}',
        AchievementCategory.earned,
        (s, _) => s.lifetime.earnedEver >= t,
        threshold: t,
      ),
    );
  }
  for (final g in b.generators) {
    for (final n in a.ownedThresholds) {
      list.add(
        AchievementDef(
          'owned_${g.id}_$n',
          AchievementCategory.owned,
          (s, _) => (s.owned[g.id] ?? 0) >= n,
          threshold: n.toDouble(),
          generator: g.id,
        ),
      );
    }
  }
  void counts(
    String prefix,
    AchievementCategory cat,
    List<int> thresholds,
    int Function(GameState s) value,
  ) {
    for (final n in thresholds) {
      list.add(
        AchievementDef(
          '${prefix}_$n',
          cat,
          (s, _) => value(s) >= n,
          threshold: n.toDouble(),
        ),
      );
    }
  }

  counts(
    'perfects',
    AchievementCategory.perfects,
    a.perfectThresholds,
    (s) => s.lifetime.perfects,
  );
  counts(
    'perfectStreak',
    AchievementCategory.perfectStreak,
    a.perfectStreakThresholds,
    (s) => s.lifetime.bestPerfectStreak,
  );
  counts(
    'combo',
    AchievementCategory.combo,
    a.comboThresholds,
    (s) => s.lifetime.bestCombo,
  );
  counts(
    'golden',
    AchievementCategory.golden,
    a.goldenThresholds,
    (s) => s.lifetime.goldenCaught,
  );
  counts(
    'prestige',
    AchievementCategory.prestige,
    a.prestigeThresholds,
    (s) => s.prestiges,
  );
  list.addAll([
    AchievementDef(
      'mode_blind',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitBlind,
    ),
    AchievementDef(
      'mode_fast',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitFast,
    ),
    AchievementDef(
      'mode_both',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitBlind && c.lastHitFast,
    ),
    AchievementDef(
      'hidden_impatient',
      AchievementCategory.hidden,
      (s, _) => s.lifetime.earlyTaps >= a.impatientEarlyTaps,
    ),
    AchievementDef(
      'hidden_nap',
      AchievementCategory.hidden,
      (s, _) => s.lifetime.missedInARow >= a.napMissedRounds,
    ),
    AchievementDef('hidden_almost', AchievementCategory.hidden, (s, _) {
      // 9.99 and then 10.01 (as shown on the stopwatch).
      final e = s.stats.recentErrors;
      if (e.length < 2) return false;
      final prev = ((10 + e[e.length - 2]) * 100).round();
      final last = ((10 + e.last) * 100).round();
      return prev == 999 && last == 1001;
    }),
    AchievementDef(
      'hidden_punctual',
      AchievementCategory.hidden,
      (s, c) =>
          c.lastHitPerfect &&
          c.now != null &&
          c.now!.hour == 10 &&
          c.now!.minute == 0,
    ),
    AchievementDef(
      'hidden_tenth',
      AchievementCategory.hidden,
      (s, c) =>
          c.now != null &&
          c.now!.day == 10 &&
          s.lifetime.tenthDayPerfects >= a.tenthDayPerfects,
    ),
    AchievementDef(
      'hidden_fullCollection',
      AchievementCategory.hidden,
      (s, _) => b.skills.every((k) => (s.skills[k.id] ?? 0) >= k.maxLevel),
    ),
    AchievementDef(
      'hidden_museum',
      AchievementCategory.hidden,
      (s, _) => b.generators.every((g) => (s.owned[g.id] ?? 0) > 0),
    ),
    AchievementDef(
      'hidden_boiledEgg',
      AchievementCategory.hidden,
      (s, _) => (s.owned['grandma'] ?? 0) >= a.boiledEggGrandmas,
    ),
  ]);
  return list;
}

/// Unlocks every achievement whose condition now holds; returns the new
/// ones (for toasts).
List<AchievementDef> unlockAchievements(
  List<AchievementDef> all,
  GameState s,
  AchievementContext ctx,
) {
  final out = <AchievementDef>[];
  for (final a in all) {
    if (s.achievements.contains(a.id)) continue;
    if (a.check(s, ctx)) {
      s.achievements.add(a.id);
      out.add(a);
    }
  }
  return out;
}
