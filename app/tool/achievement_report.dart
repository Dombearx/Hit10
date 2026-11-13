// Which counted achievements a player reaches, and when (docs/02 §8).
// Plays many runs in a row with the greedy bot (paradox at the end of
// each run, Muscle memory III, no offline income, no achievement bonus:
// the bot is slower than a real player) and logs the records.
// From app/:   dart run tool/achievement_report.dart [--runs 12] [--hours 8]
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/sim/simulator.dart';

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final runs = int.parse(opt('runs') ?? '12');
  final hours = double.parse(opt('hours') ?? '8');
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final cfg = SimConfig(
    hours: hours,
    sigma: double.parse(opt('sigma') ?? '0.03'),
  );
  var sim = Simulator(b, cfg);
  // Perks bought with the Shards as they come, cheapest useful first.
  const perkOrder = [
    'muscleMemory1',
    'headStart',
    'goldRush',
    'unlockSchrodinger',
    'muscleMemory2',
    'habit1',
    'shieldRecharge',
    'comboFloor',
    'habit2',
    'muscleMemory3',
    'unlockChronos',
  ];
  void buyPerks() {
    for (final id in perkOrder) {
      if (sim.s.perks.contains(id)) continue;
      if (sim.e.buyPerk(id).name != 'ok') break; // save up for it
    }
  }

  var bestPassive = 0.0;
  var bestClocks = 0;
  // The most of each clock owned at once, and the play time it took.
  final bestOwned = <String, int>{};
  final bestOwnedAt = <String, double>{};
  String n(double v) => formatNumber(v);
  stdout.writeln(
    'run  played  passive/s best  clocks best  skill lv  rounds  Chronons',
  );
  for (var r = 1; r <= runs; r++) {
    var runPassive = 0.0;
    var runClocks = 0;
    sim.onStep = (t) {
      runPassive = math.max(runPassive, sim.econ.passive());
      runClocks = math.max(
        runClocks,
        sim.s.owned.values.fold(0, (a, x) => a + x),
      );
      sim.s.owned.forEach((id, x) {
        if (x > (bestOwned[id] ?? 0)) {
          bestOwned[id] = x;
          bestOwnedAt[id] = (r - 1) * hours + t / 3600;
        }
      });
    };
    sim.run();
    bestPassive = math.max(bestPassive, runPassive);
    bestClocks = math.max(bestClocks, runClocks);
    final lv = sim.s.skills.values.fold(0, (a, x) => a + x);
    stdout.writeln(
      '${'$r'.padLeft(3)}  ${(r * hours).toStringAsFixed(0).padLeft(4)} h'
      '  ${n(runPassive).padLeft(14)}  ${'$runClocks'.padLeft(11)}'
      '  ${'$lv'.padLeft(8)}  ${'${sim.s.stats.rounds}'.padLeft(6)}'
      '  ${sim.s.chronons + sim.econ.prestigeGain()}'
      '  perks ${sim.s.perks.length}'
      '  earned ${n(sim.s.lifetime.earnedEver)}'
      '  golden ${sim.s.lifetime.goldenCaught}'
      '  perfects ${sim.s.lifetime.perfects}'
      '  exact ${sim.s.lifetime.exactHits}'
      '  ≥200 of ${sim.s.owned.values.where((x) => x >= 200).length} clocks'
      '  best ${sim.s.owned.values.fold(0, math.max)}'
      '  typical ${(sim.s.stats.typicalError * 1000).toStringAsFixed(1)} ms'
      '  prestiges ${sim.s.prestiges}',
    );
    sim.e.beginPrestige();
    buyPerks();
    // Habits: the two most expensive skills to rebuy.
    sim.s.habits
      ..clear()
      ..addAll(['echo', 'combo']);
    sim.e.finishPrestige();
    sim = Simulator(b, cfg, state: sim.s);
  }
  stdout.writeln('best passive ${n(bestPassive)}/s, best clocks $bestClocks');
  // Milestones (docs/02 R-ULEP-1) and owned achievements must be reachable.
  // The bot only buys what pays back fastest, so it leaves cheap old
  // clocks alone; a player chasing a milestone would top them up. Hence
  // also: how many one could own from scratch with 15 min of the best
  // income.
  final growth = b.generatorCostGrowth;
  stdout.writeln(
    'clock           most owned (play h)  with 15 min income  top milestone',
  );
  for (final (i, g) in b.generators.indexed) {
    final x = bestOwned[g.id] ?? 0;
    final at = bestOwnedAt[g.id];
    final budget = bestPassive * 15 * 60;
    final afford =
        (math.log(1 + budget * (growth - 1) / g.baseCost) / math.log(growth))
            .floor();
    final top = b.milestones.thresholdsFor(i).last;
    stdout.writeln(
      '  ${g.id.padRight(14)} ${'$x'.padLeft(4)}'
      '${(at == null ? '' : ' (${at.toStringAsFixed(0)} h)').padRight(9)}'
      '  ${'$afford'.padLeft(16)}  ${'$top'.padLeft(13)}'
      '${math.max(x, afford) < top ? '  OUT OF REACH' : ''}',
    );
  }
}
