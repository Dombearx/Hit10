import 'dart:math' as math;

import 'grading.dart';

/// Everything that is saved (docs/05 T-17). Mutable on purpose: the engine
/// changes it in place many times a second; the save codec copies it out.
class GameState {
  // -------------------------------------------------------------- money --
  double tiki = 0;

  /// Earned this run (reset by prestige) and across all runs (never reset;
  /// drives Chronons, R-PRES-2).
  double earnedThisRun = 0;
  double earnedTotal = 0;

  // ------------------------------------------------------------ the run --
  final Map<String, int> owned = {};
  final Map<String, int> upgrades = {};
  final Set<String> synergies = {};
  final Map<String, int> skills = {};

  /// Tiki seen at least once ≥ this fraction of a skill's price unlocks its
  /// card (R-UMIEJ-3); stored as the max balance ever held this run.
  double peakTiki = 0;

  // ------------------------------------------------------------ forever --
  int chronons = 0;
  int shards = 0;
  final Set<String> perks = {};
  final Set<String> achievements = {};
  int prestiges = 0;

  // -------------------------------------------------------------- misc --
  final RoundStats stats = RoundStats();
  final LifetimeStats lifetime = LifetimeStats();

  /// Wall-clock time of the last save/exit, for offline income (R-OFF-1).
  int lastSeenMs = 0;

  /// Seconds actually played this install (rewarded offers unlock after a
  /// few minutes, R-AD-5).
  double playSeconds = 0;

  bool tutorialDone = false;

  // ---------------------------------------------------------- the combo --
  /// Combo streak (docs/02 §3); survives pauses (R-RUNDA-8), reset by misses.
  int comboStreak = 0;
  int shieldCharges = 0;

  /// Combo steps gained towards the next shield charge.
  int shieldProgress = 0;

  /// Play time (s) at which the next golden second appears (R-ZLOTA-1).
  double goldenNextAt = 0;

  void earn(double amount) {
    if (amount <= 0 || amount.isNaN) return;
    tiki += amount;
    earnedThisRun += amount;
    earnedTotal += amount;
    peakTiki = math.max(peakTiki, tiki);
    lifetime.earnedEver = math.max(lifetime.earnedEver, earnedTotal);
  }

  /// Spends [amount] if affordable; returns whether it did.
  bool spend(double amount) {
    if (amount > tiki || amount.isNaN) return false;
    tiki -= amount;
    return true;
  }
}

/// Per-player round statistics (docs/02 R-STAT-1) and the diagnostic
/// histogram (T-12).
class RoundStats {
  int rounds = 0;
  final Map<Tier, int> byTier = {for (final t in Tier.values) t: 0};

  /// Signed errors (game seconds) of the last [window] tapped rounds.
  final List<double> recentErrors = [];
  static const window = 100;

  void record(Grade g, {required bool tapped}) {
    rounds++;
    byTier[g.tier] = byTier[g.tier]! + 1;
    if (tapped) {
      recentErrors.add(g.error);
      if (recentErrors.length > window) recentErrors.removeAt(0);
    }
  }

  double get meanError => recentErrors.isEmpty
      ? 0
      : recentErrors.reduce((a, b) => a + b) / recentErrors.length;

  double get spread {
    if (recentErrors.length < 2) return 0;
    final m = meanError;
    final v =
        recentErrors.map((e) => (e - m) * (e - m)).reduce((a, b) => a + b) /
        (recentErrors.length - 1);
    return v <= 0 ? 0 : math.sqrt(v);
  }
}

/// Counters that survive prestige; achievements read them (docs/02 §8).
class LifetimeStats {
  double earnedEver = 0;
  int perfects = 0;
  int perfectStreak = 0;
  int bestPerfectStreak = 0;
  int bestCombo = 0;
  int earlyTaps = 0;
  int missedInARow = 0;
  int goldenCaught = 0;
  double secondsPlayed = 0;
}
