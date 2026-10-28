import 'dart:math' as math;

import 'grading.dart';

/// Everything that is saved (M2 adds generators, skills and persistence).
class GameState {
  double tiki = 0;

  /// Tiki earned this run and across all runs; never decreases (prestige).
  double earnedThisRun = 0;
  double earnedTotal = 0;

  final RoundStats stats = RoundStats();

  void earn(double amount) {
    if (amount <= 0) return;
    tiki += amount;
    earnedThisRun += amount;
    earnedTotal += amount;
  }
}

/// Per-player round statistics (docs/02 R-STAT-1) and the diagnostic
/// histogram (T-12).
class RoundStats {
  int rounds = 0;
  final Map<Tier, int> byTier = {for (final t in Tier.values) t: 0};

  /// Signed errors (game seconds) of the last [window] graded taps.
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
