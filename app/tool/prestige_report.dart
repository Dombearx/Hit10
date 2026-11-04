// Several runs in a row: play, paradox, play again (docs/02 §10). Compares
// balance variants for skills that survive the paradox (R-PRES-5a).
// From app/:   dart run tool/prestige_report.dart
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/sim/simulator.dart';

typedef Variant = ({
  String name,
  int keep, // skill levels kept through the paradox (0: none)
  double share, // or this share of each skill's levels, rounded (R-PRES-5a)
  Set<String> whole, // skills kept whole (Habit slots, R-PRES-5b)
  double costScale,
  double growthAdd,
  double future,
});

const hoursPerRun = 6.0;
const runs = 3;

Future<List<String>> play(String json, Variant v, int seed) async {
  final m = jsonDecode(json) as Map<String, dynamic>;
  for (final sk in m['skills'] as List<dynamic>) {
    final s = sk as Map<String, dynamic>;
    s['baseCost'] = (s['baseCost'] as num) * v.costScale;
    if ((s['costGrowth'] as num) > 1) {
      s['costGrowth'] = (s['costGrowth'] as num) + v.growthAdd;
    }
  }
  final b = Balance.fromJsonString(jsonEncode(m));
  final cfg = SimConfig(
    hours: hoursPerRun,
    seed: seed,
    skillFutureWeight: v.future,
  );
  final out = <String>[];
  var sim = Simulator(b, cfg);
  double? firstRunEarned;
  for (var r = 1; r <= runs; r++) {
    final before = sim.s.earnedTotal;
    final res = sim.run();
    final earned = sim.s.earnedTotal - before;
    firstRunEarned ??= earned;
    // When this run caught up with the whole of run 1.
    var catchUp = double.infinity;
    for (final (t, e) in res.earnedLog) {
      if (e - before >= firstRunEarned) {
        catchUp = t;
        break;
      }
    }
    final lv = b.skills
        .where((s) => s.id != 'ticking')
        .map((s) => sim.econ.level(s.id))
        .fold<int>(0, (a, c) => a + c);
    final before2 = Map<String, int>.of(sim.s.skills);
    final gain = sim.e.prestige();
    sim.s.skills
      ..clear()
      ..addAll(
        {
          for (final e in before2.entries)
            if (e.value > 0)
              e.key: v.whole.contains(e.key)
                  ? e.value
                  : v.share > 0
                  ? (e.value * v.share).round()
                  : (e.value < v.keep ? e.value : v.keep),
        }..removeWhere((_, n) => n <= 0),
      );
    out.add(
      'run $r: ${(earned / 1e9).toStringAsFixed(0)}B, '
      'run-1 level after ${(catchUp / 3600).toStringAsFixed(2)} h, '
      'skill levels $lv, +$gain Chronons',
    );
    sim = Simulator(b, cfg, state: sim.s);
  }
  return out;
}

Future<void> main() async {
  final json = File('assets/balance.json').readAsStringSync();
  Variant v(
    String name, {
    int keep = 0,
    double share = 0,
    Set<String>? whole,
  }) => (
    name: name,
    keep: keep,
    share: share,
    whole: whole ?? const {},
    costScale: 1,
    growthAdd: 0,
    future: 0,
  );
  final variants = <Variant>[
    v('no Muscle memory'),
    v('old Muscle memory I: up to 4', keep: 4),
    v('old Muscle memory II: up to 6', keep: 6),
    v('old Muscle memory III: up to 8', keep: 8),
    v('Muscle memory I: 50 %', share: 0.5),
    v('Muscle memory II: 65 %', share: 0.65),
    v('Muscle memory III: 80 %', share: 0.8),
    v('80 % + Habit I (echo)', share: 0.8, whole: {'echo'}),
    v('80 % + Habit II (echo, combo)', share: 0.8, whole: {'echo', 'combo'}),
    v('keep everything', keep: 99),
  ];
  for (final v in variants) {
    final rs = await Future.wait([
      for (final seed in [10, 1, 2]) Isolate.run(() => play(json, v, seed)),
    ]);
    stdout.writeln('\n== ${v.name}');
    for (var r = 0; r < runs; r++) {
      stdout.writeln('  ${rs.map((x) => x[r]).join('   |   ')}');
    }
  }
}
