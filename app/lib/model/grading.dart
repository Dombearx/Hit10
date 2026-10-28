/// Hit grading (docs/02 §2). Pure functions over the current windows.
library;

enum Tier { perfect, great, good, miss }

/// Why a round ended as a miss; `null` for hits. [noTap] is the auto-end at
/// `target + autoEndAfter` (R-RUNDA-5), which the "nap" achievement counts.
enum MissKind { early, late, noTap }

class Windows {
  const Windows({
    required this.perfect,
    required this.great,
    required this.good,
  });

  final double perfect;
  final double great;
  final double good;

  @override
  bool operator ==(Object other) =>
      other is Windows &&
      other.perfect == perfect &&
      other.great == great &&
      other.good == good;

  @override
  int get hashCode => Object.hash(perfect, great, good);
}

class Grade {
  const Grade(this.tier, this.error, [this.missKind]);

  final Tier tier;

  /// Game-time error `t − target`, negative = early. For [MissKind.noTap] it
  /// is the auto-end offset.
  final double error;
  final MissKind? missKind;

  bool get isHit => tier != Tier.miss;
}

/// Narrowest window wins (R-PROG-1). The perfect window is clamped to the
/// great one so upgrades can never invert the order (R-PROG-2).
Grade grade(double error, Windows w) {
  final a = error.abs();
  final perfect = w.perfect < w.great ? w.perfect : w.great;
  if (a < perfect) return Grade(Tier.perfect, error);
  if (a < w.great) return Grade(Tier.great, error);
  if (a < w.good) return Grade(Tier.good, error);
  return Grade(Tier.miss, error, error < 0 ? MissKind.early : MissKind.late);
}
