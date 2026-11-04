import '../balance/balance.dart';
import 'game_state.dart';
import 'grading.dart';

enum AchievementCategory {
  earned,
  owned,
  perfects,
  perfectStreak,
  combo,
  golden,
  prestige,
  mode,
  season,
  hidden,
  // Added after playtest 25, after Cookie Clicker's kinds (docs/02 §8).
  exact,
  rounds,
  income,
  clocks,
  skillLevels,
  blindPerfects,
  playTime,
  meta,
  daily,
  shield,

  /// One-off feats with a fixed name, like [mode].
  feat,
}

/// What the latest event knows that the saved state does not (docs/02 §8).
class AchievementContext {
  const AchievementContext({
    this.now,
    this.lastHitBlind = false,
    this.streak = 0,
    this.lastHitPerfect = false,
    this.passive,
  });

  /// Local wall-clock time of the event (punctual / tenth-day badges).
  final DateTime? now;
  final bool lastHitBlind;

  /// The combo streak right after the hit.
  final int streak;
  final bool lastHitPerfect;

  /// Passive income per second without temporary boosts, when known
  /// (the once-a-second check).
  final double? passive;
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

  /// Name and description are fixed texts, not a template with a number.
  bool get fixedText =>
      category == AchievementCategory.mode ||
      category == AchievementCategory.hidden ||
      category == AchievementCategory.feat;
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
  counts(
    'exact',
    AchievementCategory.exact,
    a.exactThresholds,
    (s) => s.lifetime.exactHits,
  );
  counts(
    'rounds',
    AchievementCategory.rounds,
    a.roundThresholds,
    (s) => s.stats.rounds,
  );
  for (final t in a.incomeThresholds) {
    list.add(
      AchievementDef(
        'income_${t.toStringAsExponential(0)}',
        AchievementCategory.income,
        (s, c) => (c.passive ?? 0) >= t,
        threshold: t,
      ),
    );
  }
  counts(
    'clocks',
    AchievementCategory.clocks,
    a.clocksThresholds,
    (s) => s.owned.values.fold(0, (x, n) => x + n),
  );
  counts(
    'skillLevels',
    AchievementCategory.skillLevels,
    a.skillLevelThresholds,
    (s) => s.skills.values.fold(0, (x, n) => x + n),
  );
  counts(
    'blindPerfects',
    AchievementCategory.blindPerfects,
    a.blindPerfectThresholds,
    (s) => s.lifetime.blindPerfects,
  );
  counts(
    'playHours',
    AchievementCategory.playTime,
    a.playHoursThresholds,
    (s) => (s.lifetime.secondsPlayed / 3600).floor(),
  );
  counts(
    'achievements',
    AchievementCategory.meta,
    a.achievementCountThresholds,
    (s) => s.achievements.length,
  );
  counts(
    'daily',
    AchievementCategory.daily,
    a.dailyClaimThresholds,
    (s) => s.lifetime.dailyClaims,
  );
  counts(
    'shield',
    AchievementCategory.shield,
    a.shieldSaveThresholds,
    (s) => s.lifetime.shieldSaves,
  );
  AchievementDef feat(String id, bool Function(GameState s) check) =>
      AchievementDef(id, AchievementCategory.feat, (s, _) => check(s));
  list.addAll([
    feat('feat_goldenFast', (s) => s.lifetime.goldenFast > 0),
    feat('feat_goldenFrenzy', (s) => s.lifetime.goldenInFrenzy > 0),
    feat('feat_dailyWeek', (s) => s.dailyStreak >= 7),
    feat('feat_offlineFull', (s) => s.lifetime.offlineFull > 0),
    feat('feat_bothClocks', (s) => s.lifetime.bothClocksPerfects > 0),
    feat(
      'feat_allPerks',
      (s) => b.prestige.perks.every((p) => s.perks.contains(p.id)),
    ),
    feat(
      'feat_noHands',
      (s) => s.earnedThisRun >= a.noHandsEarned && s.runTaps <= a.noHandsTaps,
    ),
    AchievementDef(
      'mode_blind',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitBlind,
    ),
    AchievementDef(
      'mode_fast',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitBlind && c.streak >= 10,
    ),
    AchievementDef(
      'mode_both',
      AchievementCategory.mode,
      (s, c) => c.lastHitPerfect && c.lastHitBlind && c.streak >= 25,
    ),
    // One per calendar event, for reaching its goal in any year (§14).
    for (final se in b.seasons.list)
      AchievementDef(
        'season_${se.id}',
        AchievementCategory.season,
        (s, _) => s.seasonsDone.any((k) => k.startsWith('${se.id}-')),
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
      // Just under, then just over the target (4.99, 5.01 on the dial).
      final e = s.stats.recentErrors;
      if (e.length < 2) return false;
      final t = (b.round.target * 100).round();
      final prev = ((b.round.target + e[e.length - 2]) * 100).round();
      final last = ((b.round.target + e.last) * 100).round();
      return prev == t - 1 && last == t + 1;
    }),
    AchievementDef(
      'hidden_punctual',
      AchievementCategory.hidden,
      (s, c) =>
          c.lastHitPerfect &&
          c.now != null &&
          (c.now!.hour == 5 || c.now!.hour == 17) &&
          c.now!.minute == 0,
    ),
    AchievementDef(
      'hidden_tenth',
      AchievementCategory.hidden,
      (s, c) =>
          c.now != null &&
          c.now!.day == 5 &&
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
    AchievementDef(
      'hidden_midnight',
      AchievementCategory.hidden,
      (s, c) =>
          c.lastHitPerfect &&
          c.now != null &&
          c.now!.hour == 0 &&
          c.now!.minute == 0,
    ),
    AchievementDef(
      'hidden_stubborn',
      AchievementCategory.hidden,
      (s, _) => s.stats.byTier[Tier.miss]! >= a.stubbornMisses,
    ),
    AchievementDef(
      'hidden_atomic',
      AchievementCategory.hidden,
      (s, _) =>
          s.stats.nearErrors.length >= a.atomicSamples &&
          s.stats.typicalError <= a.atomicTypicalError,
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
