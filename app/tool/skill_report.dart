// When does each skill pay off? Runs the greedy simulated player (the same
// as `make sim`) and, at fixed play times, reports for every skill:
//   share: how much of the income would be lost without the skill's levels
//   next:  cost, gain and payback of the next level, against the best clock
// From app/:   dart run tool/skill_report.dart [--sigma 0.06] [--hours 8]
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

  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final sim = Simulator(
    b,
    SimConfig(
      hours: double.parse(opt('hours') ?? '8'),
      sigma: double.parse(opt('sigma') ?? '0.03'),
    ),
  );
  final marks = [5, 15, 30, 60, 120, 240, 480].map((m) => m * 60.0).toList();
  String dur(double s) => s.isInfinite || s > 3.15e7
      ? '>1 rok'
      : s < 120
      ? '${s.round()} s'
      : s < 7200
      ? '${(s / 60).round()} min'
      : s < 172800
      ? '${(s / 3600).toStringAsFixed(1)} h'
      : '${(s / 86400).round()} d';
  sim.onStep = (t) {
    if (marks.isEmpty || t < marks.first) return;
    marks.removeAt(0);
    final income = sim.totalIncome(false);
    final s = sim.s;
    // The best clock to buy right now (what a skill competes with).
    var bestGen = double.infinity;
    for (final (kind, key, cost) in sim.candidates()) {
      if (kind != 'gen') continue;
      final d = sim.gainOf(kind, key);
      if (d > 0) bestGen = math.min(bestGen, cost / d);
    }
    stdout.writeln(
      '\n=== ${(t / 60).round()} min  · dochód ${formatNumber(income)}/s '
      '(zegary ${formatNumber(sim.econ.passive())}/s) · najlepszy zegar '
      'zwraca się w ${dur(bestGen)}',
    );
    stdout.writeln(
      '  umiejętność   poz.  udział  | następny: cena    +dochód/s   zwrot     vs zegar',
    );
    for (final sk in b.skills) {
      final lv = sim.econ.level(sk.id);
      // Share of income that depends on this skill's levels.
      s.skills[sk.id] = 0;
      final without = sim.totalIncome(false);
      s.skills[sk.id] = lv;
      final share = income <= 0 ? 0 : (income - without) / income;
      final cost = sim.econ.skillCost(sk.id);
      var next = '  (max)';
      if (cost != null) {
        final d = sim.gainOf('skill', sk.id);
        final pay = d > 0 ? cost / d : double.infinity;
        final ratio = pay / bestGen;
        next =
            '  ${formatNumber(cost).padLeft(7)}  '
            '${formatNumber(d).padLeft(9)}  ${dur(pay).padLeft(8)}  '
            '${ratio.isFinite ? '×${ratio.toStringAsFixed(ratio < 10 ? 1 : 0)}' : '–'}';
      }
      stdout.writeln(
        '  ${sk.id.padRight(12)} ${'$lv'.padLeft(4)}  '
        '${(share * 100).toStringAsFixed(share < 0.1 ? 1 : 0).padLeft(5)}% |$next',
      );
    }
  };
  sim.run();
}
