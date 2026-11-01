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
  bool keep,
  double costScale,
  double growthAdd,
  double future,
});

const hoursPerRun = 6.0;
const runs = 3;

Future<List<String>> play(String json, Variant v, int seed) async {
  final m = jsonDecode(json) as Map<String, dynamic>;
  (m['prestige'] as Map<String, dynamic>)['keepSkills'] = v.keep;
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
    final gain = sim.e.prestige();
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
  const variants = <Variant>[
    (
      name: 'today: skills reset',
      keep: false,
      costScale: 1,
      growthAdd: 0,
      future: 0,
    ),
    (
      name: 'kept, same prices',
      keep: true,
      costScale: 1,
      growthAdd: 0,
      future: 0,
    ),
    (
      name: 'kept, ×10 prices',
      keep: true,
      costScale: 10,
      growthAdd: 0,
      future: 0,
    ),
    (
      name: 'kept, ×10, player values future ×2',
      keep: true,
      costScale: 10,
      growthAdd: 0,
      future: 1,
    ),
    (
      name: 'kept, growth +2',
      keep: true,
      costScale: 1,
      growthAdd: 2,
      future: 0,
    ),
    (
      name: 'kept, growth +2, future ×2',
      keep: true,
      costScale: 1,
      growthAdd: 2,
      future: 1,
    ),
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
