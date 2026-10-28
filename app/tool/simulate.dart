// Balance simulator (docs/05 T-4, docs/06 §1.2). Uses the game's own
// economy code. From app/:
//
//   dart run tool/simulate.dart            # report for one 8 h run
//   dart run tool/simulate.dart --check    # all pacing targets, exit 1 on fail
//   dart run tool/simulate.dart --sigma 0.06 --hours 12 --chronons 20 --ads
//   dart run tool/simulate.dart --check --balance /tmp/variant.json
import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/sim/checks.dart';
import 'package:hit10/sim/simulator.dart';

Future<void> main(List<String> args) async {
  String? opt(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  // --balance tries a variant file without touching assets/balance.json.
  final b = Balance.fromJsonString(
    File(opt('balance') ?? 'assets/balance.json').readAsStringSync(),
  );

  if (args.contains('--check')) {
    final sw = Stopwatch()..start();
    final rows = await runChecks(b);
    var ok = true;
    for (final r in rows) {
      ok &= r.pass;
      stdout.writeln(
        '${r.pass ? 'PASS' : 'FAIL'}  ${r.id.padRight(5)} ${r.name.padRight(44)} '
        'median ${r.median.padLeft(7)}   [${r.values.join(', ')}]',
      );
    }
    stdout.writeln('(${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)} s)');
    exit(ok ? 0 : 1);
  }

  final idleAfter = opt('idle-after');
  final cfg = SimConfig(
    hours: double.parse(opt('hours') ?? '8'),
    sigma: double.parse(opt('sigma') ?? '0.03'),
    idleAfterMinutes: idleAfter == null ? null : double.parse(idleAfter),
    chronons: int.parse(opt('chronons') ?? '0'),
    seed: int.parse(opt('seed') ?? '10'),
    ads: args.contains('--ads') ? SimAds.fromBalance(b.ads) : null,
  );
  final r = Simulator(b, cfg).run();
  stdout.writeln('First of each generator:');
  r.firstGenerator.forEach(
    (id, t) => stdout.writeln(
      '  ${id.padRight(14)} ${(t / 60).toStringAsFixed(1).padLeft(7)} min',
    ),
  );
  stdout.writeln('\nSkill levels:');
  final bySkill = <String, List<String>>{};
  for (final (t, id, lv) in r.skillLog) {
    bySkill.putIfAbsent(id, () => []).add('$lv@${(t / 60).round()}m');
  }
  bySkill.forEach(
    (id, l) => stdout.writeln('  ${id.padRight(12)} ${l.join(' ')}'),
  );
  stdout.writeln('\nHour  passive/s   clicking/s  earned');
  for (final h in r.hourly) {
    stdout.writeln(
      '${h.hour.round().toString().padLeft(4)}  '
      '${formatNumber(h.passive).padLeft(9)}  '
      '${formatNumber(h.active).padLeft(10)}  '
      '${formatNumber(h.earned).padLeft(8)}',
    );
  }
  if (r.adLog.isNotEmpty) stdout.writeln('\nads watched: ${r.adLog.length}');
}
