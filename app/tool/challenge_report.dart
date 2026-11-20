// How hard the challenges are (docs/14 §5): for players of different
// precision, the targets the planner sets from their own taps and how many
// minutes of play they then take to complete.
//
//   dart run tool/challenge_report.dart [--first]
//
// --first: the easier very first set (balance `firstReachShare`).
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/challenges.dart';
import 'package:hit10/model/grading.dart';

void main(List<String> args) {
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final c = b.challenges;
  final share = args.contains('--first') ? c.firstReachShare : c.reachShare;
  final windows = Windows(
    perfect: b.tier('perfect').window,
    great: b.tier('great').window,
    good: b.tier('good').window,
    close: b.close.window,
  );
  // Base round: 5.00 from 0.00 plus the result pause.
  final roundSeconds = b.round.target + b.round.resultPause;
  const kinds = [
    ChallengeKind.great,
    ChallengeKind.streak,
    ChallengeKind.jackpot,
    ChallengeKind.perfectWindow,
    ChallengeKind.perfect,
    ChallengeKind.hitEarnings,
    ChallengeKind.greatWeek,
    ChallengeKind.jackpotWeek,
    ChallengeKind.streakWeek,
  ];
  stdout.writeln(
    'Targets from 100 own taps; minutes of play to complete '
    '(median / 80th percentile over 200 players), rounds of '
    '${roundSeconds.toStringAsFixed(1)} s.',
  );
  for (final (sigma, bias) in [
    (0.020, 0.0),
    (0.035, 0.0),
    (0.050, 0.010),
    (0.075, 0.015),
    (0.100, 0.020),
    (0.150, 0.030),
  ]) {
    stdout.writeln(
      '\nσ = ${(sigma * 1000).round()} ms, bias +${(bias * 1000).round()} ms',
    );
    for (final kind in kinds) {
      final targets = <double>[];
      final minutes = <double>[];
      for (var player = 0; player < 200; player++) {
        final rng = math.Random(player * 7919 + kind.index);
        final taps = [for (var i = 0; i < 100; i++) bias + _gauss(rng) * sigma];
        final p = ChallengePlayer(
          recentErrors: taps,
          windows: windows,
          jackpotWindow: b.jackpot.window,
          roundSeconds: roundSeconds,
          payout: const {Tier.perfect: 6, Tier.great: 3, Tier.good: 1},
          jackpotPayout: 30,
          comboStep: b.combo.multiplierPerStep,
          comboCap: 5,
          ownedClocks: 50,
          bonusesInReach: 2,
          skillLevelsLeft: 10,
          springsUnlocked: true,
          goldenEnabled: true,
          dailySeconds: c.dailySeconds,
          weeklySeconds: c.weeklySeconds,
          reachShare: share,
        );
        final ch = Challenge(kind, ChallengePlanner.target(kind, p, rng));
        targets.add(ch.target);
        // Then the player plays (fresh taps, same skill) until it is done.
        var rounds = 0;
        var streak = 0;
        while (!ch.done && rounds < 20000) {
          rounds++;
          final e = bias + _gauss(rng) * sigma;
          final g = grade(e, windows);
          final jackpot = e.abs() < b.jackpot.window;
          // The multiplier ladder (docs/15), cap 5.
          streak = g.tier == Tier.miss
              ? 0
              : jackpot
              ? 5
              : math.min(5, streak + (g.tier == Tier.perfect ? 1 : 0));
          final combo = 1 + b.combo.multiplierPerStep * math.min(streak, 5);
          ChallengeProgress.round(
            [ch],
            ChallengeRound(
              tier: g.tier,
              error: e,
              jackpot: jackpot,
              payout:
                  ((const {
                            Tier.perfect: 6.0,
                            Tier.great: 3.0,
                            Tier.good: 1.0,
                          }[g.tier] ??
                          0) +
                      (jackpot ? 30 : 0)) *
                  combo,
            ),
          );
        }
        minutes.add(rounds * roundSeconds / 60);
      }
      targets.sort();
      minutes.sort();
      String q(List<double> v, double at) =>
          v[(at * (v.length - 1)).round()].toStringAsFixed(1);
      stdout.writeln(
        '  ${kind.name.padRight(14)} target ${q(targets, 0.5).padLeft(7)}'
        '   minutes ${q(minutes, 0.5).padLeft(5)} / ${q(minutes, 0.8)}',
      );
    }
  }
}

double _gauss(math.Random rng) {
  final u = 1 - rng.nextDouble();
  final v = rng.nextDouble();
  return math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
}
