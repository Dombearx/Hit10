import 'dart:math' as math;

import 'challenges.dart';
import 'grading.dart';

/// Everything that is saved (docs/05 T-17). Mutable on purpose: the engine
/// changes it in place many times a second; the save codec copies it out.
class GameState {
  // -------------------------------------------------------------- money --
  double tiki = 0;

  /// Earned this run (reset by prestige) and across all runs of this Time
  /// Loop (drives Chronons, R-PRES-2; a new loop starts it from 0). The
  /// all-time total is [LifetimeStats.earnedEver].
  double earnedThisRun = 0;
  double earnedTotal = 0;

  // ------------------------------------------------------------ the run --
  final Map<String, int> owned = {};
  final Map<String, int> skills = {};

  /// Tiki seen at least once ≥ this fraction of a skill's price unlocks its
  /// card (R-UMIEJ-3); stored as the max balance ever held this run.
  double peakTiki = 0;

  // ------------------------------------------------------------ forever --
  int chronons = 0;
  int shards = 0;
  final Set<String> perks = {};

  /// Skills put in a Habit slot: they keep every level through the paradox
  /// (R-PRES-5b). At most as many as the Habit perks owned give slots.
  final List<String> habits = [];
  final Set<String> achievements = {};
  int prestiges = 0;

  // ------------------------------------- mainsprings (docs/12 §3.1) --
  /// Ready Mainsprings (R-SPR-4) and the seconds wound towards the next.
  int springs = 0;
  double springProgress = 0;

  /// Wall-clock ms the winding was last brought up to date; 0 = not yet.
  int springClockMs = 0;

  /// The winding reserve (R-SPR-3): seconds exact hits may still wind,
  /// and the wall-clock ms it was last brought up to date (0 = never:
  /// the reserve is full).
  double springReserve = 0;
  int springReserveMs = 0;

  /// Local date (yyyymmdd) and "wind it" ads watched that day (R-SPR-3b).
  int springAdDay = 0;
  int springAdCount = 0;

  /// Clock levels bought with Mainsprings; never reset (R-SPR-5).
  final Map<String, int> clockLevels = {};

  /// Mainsprings given back when the ten levels became five mastery tiers
  /// (docs/13 §5.3); the UI says so once and clears it.
  int springsRefunded = 0;

  /// Clocks bought at least once in any run: only those can be levelled.
  final Set<String> everOwned = {};

  /// Stopwatch face chosen ('' = the classic one) and the faces already
  /// announced (docs/12 §3.3).
  String dial = '';
  final Set<String> dialsSeen = {};

  // -------------------------------------- time loops (docs/13 §5.2) --
  /// The Time Loop being played, from 1, and its changed rules (R-PETLA-4).
  int loop = 1;
  final List<String> loopRules = [];

  /// Rules of loops finished: each seal changes a rule for good (R-PETLA-5).
  final Set<String> seals = {};

  /// Loops finished; as many chapters of the Chronicle are open.
  int loopsDone = 0;

  /// The loop's goal is reached (the first Chronos): a new loop may start.
  bool loopGoal = false;

  /// The ending of this loop was shown.
  bool loopEndSeen = false;

  /// Bonuses of the goal clock already paid in Mainsprings (R-PETLA-2a).
  int loopBonusPaid = 0;

  /// Seconds played and paradoxes made in this loop (the ending's figures).
  double loopPlaySeconds = 0;
  int loopPrestiges = 0;

  /// Wall-clock ms the loop started at; 0 = unknown (the first one).
  int loopStartMs = 0;

  /// Seconds played when the goal was reached: this loop's, and the best
  /// by rule ('' = no rule).
  double loopGoalSeconds = 0;
  final Map<String, double> loopBest = {};

  /// After the story: the rules chosen for the next loop (R-PETLA-8).
  final List<String> nextRules = [];

  /// Paradox paid out, run not reset yet: the player is spending Shards
  /// before the new run starts (R-PRES-6a).
  bool rewindPending = false;

  // -------------------------------------------------------------- misc --
  final RoundStats stats = RoundStats();
  final LifetimeStats lifetime = LifetimeStats();

  /// Wall-clock time of the last save/exit, for offline income (R-OFF-1).
  int lastSeenMs = 0;

  /// Offline summary shown but not collected yet (the app was closed over
  /// it): away and counted seconds, and the amount. 0 = none.
  double offlineAway = 0;
  double offlineCounted = 0;
  double offlineAmount = 0;

  /// Seconds actually played this install (rewarded offers unlock after a
  /// few minutes, R-AD-5).
  double playSeconds = 0;

  bool tutorialDone = false;

  /// Taps graded this run (reset by the paradox): the "no hands"
  /// achievement allows only a few. Saves from before it count as many.
  int runTaps = 0;

  // ---------------------------------------------------------- the combo --
  /// Combo streak (docs/02 §3); survives pauses (R-RUNDA-8), reset by misses.
  int comboStreak = 0;
  int shieldCharges = 0;

  /// Combo steps gained towards the next shield charge.
  int shieldProgress = 0;

  /// Play time (s) at which the next golden second appears (R-ZLOTA-1).
  double goldenNextAt = 0;

  // -------------------------------------------------------- toggles (M4) --
  bool modeBlind = false;
  bool secondClockOn = false;
  bool autoBuyerOn = false;

  /// The clock the auto buyer buys, chosen by the player; null until one
  /// is (docs/02 §9.3).
  String? autoTarget;

  /// It buys [autoTarget] up to this many owned, then waits.
  int autoUntil = 0;

  /// One-time tips already shown (R-TUT-2).
  final Set<String> tipsSeen = {};

  // ------------------------------------------------------- ad offers (M4) --
  /// Wall-clock ms until which each rewarded offer is on cooldown (R-AD-1).
  final Map<String, int> adCooldownUntil = {};

  /// Turbo seconds left; only drains while playing (R-AD-1).
  double turboLeft = 0;

  // ------------------------------------------------------- daily bonus --
  /// Local date (yyyymmdd) of the last daily bonus claimed; 0 = never.
  int dailyKey = 0;

  /// Day of the 7-day streak that [dailyKey] paid (1–7).
  int dailyStreak = 0;

  /// This week's grace day is used up (R-DZIEN-3): one missed day keeps
  /// the streak once per seven claims.
  bool dailyGraceUsed = false;

  /// Challenges (docs/02 §18): the day (yyyymmdd) the daily ones belong to,
  /// the Monday of the weekly one, the day the free re-roll was used and
  /// the day the all-three bonus was paid.
  int challengeDay = 0;
  int challengeWeek = 0;
  int challengeRerollDay = 0;
  int challengeBonusDay = 0;

  /// The three daily challenges (slots 0–2) and the weekly one (slot 3).
  final List<Challenge> challenges = [];

  /// Play time ([LifetimeStats.secondsPlayed]) when the tutorial ended:
  /// challenges count their minutes from here (R-WYZ-1). 0 for saves from
  /// before it, whose tutorial is long over.
  double tutorialEndPlay = 0;

  // ---------------------------------------------------------- seasons --
  /// The season run being counted ("halloween-2026", docs/02 §14); the
  /// counters below reset when it changes.
  String seasonKey = '';
  int seasonCatches = 0;
  int seasonHits = 0;

  /// Counters of other season runs [catches, hits], kept when the running
  /// season changes (e.g. a QA preview) and restored when it comes back.
  final Map<String, List<int>> seasonStash = {};

  /// Season runs whose goal was reached; their themes stay unlocked.
  final Set<String> seasonsDone = {};

  /// Chosen look: '' follows the running season, 'classic' or a season id.
  String theme = '';

  void earn(double amount) {
    if (amount <= 0 || amount.isNaN) return;
    tiki += amount;
    earnedThisRun += amount;
    earnedTotal += amount;
    peakTiki = math.max(peakTiki, tiki);
    // Not a running maximum: a new Time Loop starts [earnedTotal] from 0.
    lifetime.earnedEver += amount;
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

  /// Taps ignored as accidental (R-RUNDA-5a), all time.
  int accidental = 0;

  /// Recent taps near the target: a tap seconds off is a slip, not aim
  /// (playtest: three stray taps turned a ~40 ms player's spread into
  /// 440 ms). The figures below use these only.
  static const near = 0.3;
  List<double> get nearErrors =>
      recentErrors.where((e) => e.abs() < near).toList();

  /// Average signed error of near taps (negative: early).
  double get meanError {
    final e = nearErrors;
    return e.isEmpty ? 0 : e.reduce((a, b) => a + b) / e.length;
  }

  /// Median distance from the target: half the near taps are closer.
  double get typicalError {
    final e = nearErrors.map((x) => x.abs()).toList()..sort();
    if (e.isEmpty) return 0;
    final m = e.length ~/ 2;
    return e.length.isOdd ? e[m] : (e[m - 1] + e[m]) / 2;
  }

  /// Standard deviation of near taps (diagnostics).
  double get spread {
    final e = nearErrors;
    if (e.length < 2) return 0;
    final m = meanError;
    final v =
        e.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b) /
        (e.length - 1);
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

  /// Perfects on the current 10th-of-month day ("Dziesiątka").
  int tenthDayPerfects = 0;

  /// yyyymmdd the counter above belongs to.
  int tenthDayKey = 0;

  // Counters for the achievements added after playtest 25 (docs/02 §8).
  /// Hits the dial showed as exactly 5.00.
  int exactHits = 0;
  int blindPerfects = 0;

  /// PERFEKT on one clock right after a PERFEKT on the other one.
  int bothClocksPerfects = 0;
  int dailyClaims = 0;

  /// Challenges claimed, all time (docs/02 §18).
  int challengesDone = 0;

  /// Misses a Shield charge took instead of the combo.
  int shieldSaves = 0;

  /// Golden clocks caught within a second of appearing / during Frenzy.
  int goldenFast = 0;
  int goldenInFrenzy = 0;

  /// Offline income collected after an absence longer than the limit.
  int offlineFull = 0;

  /// Mainsprings wound in total, and the seconds lost while the stock was
  /// full (analytics: is the cap too low?).
  int springsWound = 0;
  double springSecondsLost = 0;
}
