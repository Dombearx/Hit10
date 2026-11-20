/// Daily and weekly challenges (docs/02 §18, docs/14). Pure Dart: what the
/// challenges are, how hard each one is for this player, and how play
/// moves them forward. The controller feeds it events and pays rewards.
library;

import 'dart:math' as math;

import 'grading.dart';

/// Every kind of challenge. The name is the id in saves and analytics.
enum ChallengeKind {
  // Daily, slot 0: aim.
  great, // N hits GREAT or better
  streak, // N hits in a row since it was handed out
  jackpot, // N exact 5.00s
  // Daily, slot 1: a feat.
  perfectWindow, // N PERFECTs within 10 rounds in a row
  perfect, // N PERFECTs
  hitEarnings, // earn N Tiki from hits
  // Daily, slot 2: building.
  buyClocks, // buy N clocks
  milestones, // earn N clock bonuses
  skillLevels, // buy N skill levels
  // Weekly.
  greatWeek, // N GREAT+ hits this week
  jackpotWeek, // N exact 5.00s this week
  streakWeek, // N hits in a row this week
  goldenWeek, // catch N Golden Seconds this week
  springWeek, // wind N minutes of Mainspring with exact hits this week
}

/// Which slot a kind fills: 0–2 daily, 3 weekly.
int slotOf(ChallengeKind k) => switch (k) {
  ChallengeKind.great || ChallengeKind.streak || ChallengeKind.jackpot => 0,
  ChallengeKind.perfectWindow ||
  ChallengeKind.perfect ||
  ChallengeKind.hitEarnings => 1,
  ChallengeKind.buyClocks ||
  ChallengeKind.milestones ||
  ChallengeKind.skillLevels => 2,
  _ => 3,
};

/// The weekly slot.
const weeklySlot = 3;

/// One challenge on offer and how far the player got.
class Challenge {
  Challenge(this.kind, this.target, {this.progress = 0});

  final ChallengeKind kind;

  /// Fixed when the challenge is handed out (the player's skill then).
  final double target;

  double progress;

  /// The last tiers, for [ChallengeKind.perfectWindow] (1 = PERFECT).
  final List<int> recent = [];

  /// Hits in a row since it was handed out, for the streak kinds: every
  /// miss starts it over, a Shield's too (docs/15).
  int run = 0;

  bool claimed = false;

  int get slot => slotOf(kind);
  bool get weekly => slot == weeklySlot;

  bool get done => progress >= target;

  double get fraction => target <= 0 ? 1 : (progress / target).clamp(0.0, 1.0);

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'target': target,
    'progress': progress,
    'recent': recent,
    'run': run,
    'claimed': claimed,
  };

  static Challenge? fromJson(Object? j) {
    if (j is! Map) return null;
    final name = j['kind'];
    final kind = ChallengeKind.values.where((k) => k.name == name);
    if (kind.isEmpty) return null;
    double d(Object? v) => v is num && v.isFinite ? v.toDouble() : 0;
    final c = Challenge(kind.first, d(j['target']), progress: d(j['progress']))
      ..claimed = j['claimed'] == true
      ..run = d(j['run']).toInt();
    final r = j['recent'];
    if (r is List) c.recent.addAll(r.whereType<num>().map((e) => e.toInt()));
    return c;
  }
}

/// The "streak" challenge whose count the combo row shows: the daily one
/// first, only while it is on (not done, not claimed).
Challenge? streakChallenge(Iterable<Challenge> list) {
  Challenge? weekly;
  for (final c in list) {
    if (c.claimed || c.done) continue;
    if (c.kind == ChallengeKind.streak) return c;
    if (c.kind == ChallengeKind.streakWeek) weekly = c;
  }
  return weekly;
}

/// A graded round of the player, as challenges see it.
class ChallengeRound {
  const ChallengeRound({
    required this.tier,
    required this.error,
    required this.jackpot,
    required this.payout,
  });
  final Tier tier;
  final double error;
  final bool jackpot;
  final double payout;

  bool get hit => tier != Tier.miss;
}

/// Moves challenges forward. Returns the challenges that just got done.
abstract final class ChallengeProgress {
  static const window = 10;

  static List<Challenge> round(Iterable<Challenge> list, ChallengeRound r) {
    final done = <Challenge>[];
    for (final c in list) {
      if (c.claimed || c.done) continue;
      final greatPlus = r.tier == Tier.perfect || r.tier == Tier.great;
      switch (c.kind) {
        case ChallengeKind.great || ChallengeKind.greatWeek:
          if (greatPlus) c.progress++;
        case ChallengeKind.streak || ChallengeKind.streakWeek:
          c.run = r.hit ? c.run + 1 : 0;
          c.progress = math.max(c.progress, c.run.toDouble());
        case ChallengeKind.jackpot || ChallengeKind.jackpotWeek:
          if (r.jackpot) c.progress++;
        case ChallengeKind.perfectWindow:
          c.recent.add(r.tier == Tier.perfect ? 1 : 0);
          if (c.recent.length > window) c.recent.removeAt(0);
          final n = c.recent.fold<int>(0, (a, b) => a + b);
          c.progress = math.max(c.progress, n.toDouble());
        case ChallengeKind.perfect:
          if (r.tier == Tier.perfect) c.progress++;
        case ChallengeKind.hitEarnings:
          c.progress += r.payout;
        default:
          continue;
      }
      if (c.done) done.add(c);
    }
    return done;
  }

  /// Counted events outside rounds: clocks bought, bonuses earned, skill
  /// levels bought, Golden Seconds caught, Mainspring seconds wound.
  static List<Challenge> add(
    Iterable<Challenge> list,
    ChallengeKind kind,
    double amount,
  ) {
    final done = <Challenge>[];
    for (final c in list) {
      if (c.claimed || c.done || c.kind != kind) continue;
      c.progress += amount;
      if (c.done) done.add(c);
    }
    return done;
  }
}

/// What the planner knows about the player when handing out challenges.
class ChallengePlayer {
  const ChallengePlayer({
    required this.recentErrors,
    required this.windows,
    required this.jackpotWindow,
    required this.roundSeconds,
    required this.payout,
    required this.jackpotPayout,
    required this.comboStep,
    required this.comboCap,
    required this.ownedClocks,
    required this.bonusesInReach,
    required this.skillLevelsLeft,
    required this.springsUnlocked,
    required this.goldenEnabled,
    this.springsWindable = true,
    this.dailySeconds = 240,
    this.weeklySeconds = 2100,
    this.reachShare = 0.6,
  });

  /// The player's last tapped errors (seconds); few or none for a new
  /// player.
  final List<double> recentErrors;
  final Windows windows;
  final double jackpotWindow;

  /// Real seconds per round, the result pause included.
  final double roundSeconds;

  /// What one hit of each tier pays at combo ×1, jackpot excluded.
  final Map<Tier, double> payout;

  /// What an exact 5.00 adds on top of its PERFECT, at combo ×1.
  final double jackpotPayout;
  final double comboStep;
  final int comboCap;
  final int ownedClocks;

  /// Bonuses (R-ULEP-1) within ten clocks of the counts owned now.
  final int bonusesInReach;
  final int skillLevelsLeft;
  final bool springsUnlocked;

  /// Exact hits can wind the Mainspring: the stock is not full, or a
  /// clock level it could buy would make room (R-SPR-4).
  final bool springsWindable;

  /// Golden Seconds fly (not in the "Cloudy Day" loop, R-PETLA-4).
  final bool goldenEnabled;

  /// A daily challenge is sized for about this much play, the weekly one
  /// for [weeklySeconds]; a target is what the player reaches in
  /// [reachShare] of simulated sessions (balance `challenges`).
  final double dailySeconds;
  final double weeklySeconds;
  final double reachShare;
}

/// Picks the challenges and sets their targets for this player.
///
/// Targets come from the player's own taps: their last errors are
/// resampled into many simulated sessions, and the target is what the
/// player reaches in [ChallengePlayer.reachShare] of them — a real
/// challenge, but one an ordinary session of their own play usually
/// completes.
abstract final class ChallengePlanner {
  static const trials = 160;

  /// A player with fewer taps than this is planned with [newcomerSigma].
  static const minTaps = 20;
  static const newcomerSigma = 0.075;

  static const _daily = [
    [ChallengeKind.great, ChallengeKind.streak, ChallengeKind.jackpot],
    [
      ChallengeKind.perfectWindow,
      ChallengeKind.perfect,
      ChallengeKind.hitEarnings,
    ],
    [
      ChallengeKind.buyClocks,
      ChallengeKind.milestones,
      ChallengeKind.skillLevels,
    ],
  ];

  static const _weekly = [
    ChallengeKind.greatWeek,
    ChallengeKind.jackpotWeek,
    ChallengeKind.goldenWeek,
    ChallengeKind.streakWeek,
    ChallengeKind.springWeek,
  ];

  /// Kinds this player can do now in [slot].
  static List<ChallengeKind> available(int slot, ChallengePlayer p) {
    final pool = slot == weeklySlot ? _weekly : _daily[slot];
    return [
      for (final k in pool)
        if (switch (k) {
          ChallengeKind.milestones => p.bonusesInReach >= 1,
          ChallengeKind.skillLevels => p.skillLevelsLeft >= 2,
          ChallengeKind.goldenWeek => p.goldenEnabled,
          ChallengeKind.springWeek => p.springsUnlocked && p.springsWindable,
          _ => true,
        })
          k,
    ];
  }

  /// A challenge for [slot]: a kind other than [avoid] when there is one,
  /// with its target for this player.
  static Challenge pick(
    int slot,
    ChallengePlayer p,
    math.Random rng, {
    ChallengeKind? avoid,
  }) {
    var kinds = available(slot, p);
    if (kinds.length > 1) kinds = [...kinds.where((k) => k != avoid)];
    final kind = kinds[rng.nextInt(kinds.length)];
    return Challenge(kind, target(kind, p, rng));
  }

  /// The target of [kind] for this player.
  static double target(ChallengeKind kind, ChallengePlayer p, math.Random rng) {
    final weekly = slotOf(kind) == weeklySlot;
    final seconds = switch (kind) {
      // One bad tap ends a streak: its best over a long week varies a lot
      // from player to player, so it is sized for half the week's play.
      ChallengeKind.streakWeek => p.weeklySeconds / 2,
      _ => weekly ? p.weeklySeconds : p.dailySeconds,
    };
    final rounds = math.max(10, (seconds / p.roundSeconds).round());
    double sim(double Function(_Session) metric, {double min = 1}) =>
        math.max(min, _reach(p, rounds, rng, metric));
    return switch (kind) {
      ChallengeKind.great => _nice(sim((s) => s.great, min: 3), max: 50),
      ChallengeKind.greatWeek => _nice(sim((s) => s.great, min: 20), max: 400),
      ChallengeKind.streak => _nice(sim((s) => s.bestStreak, min: 3), max: 100),
      ChallengeKind.streakWeek => _nice(
        sim((s) => s.bestStreak, min: 6),
        max: 300,
      ),
      ChallengeKind.jackpot => _nice(sim((s) => s.jackpots), max: 20),
      ChallengeKind.jackpotWeek => _nice(
        sim((s) => s.jackpots, min: 5),
        max: 150,
      ),
      ChallengeKind.perfectWindow => sim(
        (s) => s.bestWindow,
      ).clamp(1, 8).floorToDouble(),
      ChallengeKind.perfect => _nice(sim((s) => s.perfects, min: 2), max: 30),
      ChallengeKind.hitEarnings => _round3(sim((s) => s.earned, min: 10)),
      ChallengeKind.buyClocks =>
        p.ownedClocks < 30
            ? 5
            : p.ownedClocks < 150
            ? 15
            : 30,
      ChallengeKind.milestones => math.min(2, p.bonusesInReach).toDouble(),
      ChallengeKind.skillLevels => math.min(3, p.skillLevelsLeft).toDouble(),
      // About one Golden Second per 10 minutes of play.
      ChallengeKind.goldenWeek =>
        (p.weeklySeconds / 600 * 0.6).roundToDouble().clamp(2, 6),
      // 15 min per exact hit (the first after a break winds more), within
      // what the winding reserve refills in a week (R-SPR-3).
      ChallengeKind.springWeek =>
        (sim((s) => s.jackpots, min: 4) * 15 * 60).clamp(3600, 4 * 3600),
    };
  }

  /// The value of [metric] reached in [reachShare] of simulated sessions.
  static double _reach(
    ChallengePlayer p,
    int rounds,
    math.Random rng,
    double Function(_Session) metric,
  ) {
    final results = [
      for (var t = 0; t < trials; t++) metric(_Session.play(p, rounds, rng)),
    ]..sort();
    return results[((1 - p.reachShare) * (trials - 1)).floor()];
  }

  /// Round, friendly numbers: 7, 12, 15, 20, 25, 30, 40, 50…
  static double _nice(double v, {required double max}) {
    final x = v.clamp(1.0, max);
    if (x <= 12) return x.floorToDouble();
    if (x <= 50) return (x / 5).floorToDouble() * 5;
    return (x / 10).floorToDouble() * 10;
  }

  /// Three significant digits, rounded down: 1234567 → 1230000.
  static double _round3(double v) {
    if (v < 100) return v.floorToDouble();
    final p = math.pow(10, (math.log(v) / math.ln10).floor() - 2);
    return (v / p).floorToDouble() * p;
  }
}

/// One simulated session of the player's own taps.
class _Session {
  double great = 0;
  double perfects = 0;
  double jackpots = 0;
  double bestStreak = 0;
  double bestWindow = 0;
  double earned = 0;

  static _Session play(ChallengePlayer p, int rounds, math.Random rng) {
    final s = _Session();
    final errors = p.recentErrors.length >= ChallengePlanner.minTaps
        ? p.recentErrors
        : null;
    var streak = 0;
    var ladder = 0;
    final window = <int>[];
    for (var i = 0; i < rounds; i++) {
      final e = errors != null
          ? errors[rng.nextInt(errors.length)]
          : _gauss(rng) * ChallengePlanner.newcomerSigma;
      final g = grade(e, p.windows);
      final jackpot = e.abs() < p.jackpotWindow;
      final greatPlus = g.tier == Tier.perfect || g.tier == Tier.great;
      if (greatPlus) s.great++;
      if (g.tier == Tier.perfect) s.perfects++;
      if (jackpot) s.jackpots++;
      streak = g.tier == Tier.miss ? 0 : streak + 1;
      s.bestStreak = math.max(s.bestStreak, streak.toDouble());
      window.add(g.tier == Tier.perfect ? 1 : 0);
      if (window.length > ChallengeProgress.window) window.removeAt(0);
      s.bestWindow = math.max(
        s.bestWindow,
        window.fold<int>(0, (a, b) => a + b).toDouble(),
      );
      // The multiplier ladder (docs/15): PERFECT +1, 5.00 fills it, a
      // miss empties it (Shields left out: the target comes out lower).
      ladder = g.tier == Tier.miss
          ? 0
          : jackpot
          ? p.comboCap
          : math.min(p.comboCap, ladder + (g.tier == Tier.perfect ? 1 : 0));
      final combo = 1 + p.comboStep * ladder;
      s.earned +=
          ((p.payout[g.tier] ?? 0) + (jackpot ? p.jackpotPayout : 0)) * combo;
    }
    return s;
  }

  static double _gauss(math.Random rng) {
    // Box–Muller.
    final u = 1 - rng.nextDouble();
    final v = rng.nextDouble();
    return math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
  }
}
