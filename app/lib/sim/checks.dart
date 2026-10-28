import 'dart:isolate';

import '../balance/balance.dart';
import 'simulator.dart';

class CheckRow {
  CheckRow(this.id, this.name, this.values, this.median, this.pass);
  final String id;
  final String name;

  /// One value per seed (formatted).
  final List<String> values;
  final String median;
  final bool pass;
}

double _median(List<double> xs) {
  final s = [...xs]..sort();
  return s[s.length ~/ 2];
}

/// Runs every simulation on its own isolate (they are independent).
Future<List<SimResult>> _runAll(Balance b, List<SimConfig> configs) =>
    Future.wait([
      for (final c in configs) Isolate.run(() => Simulator(b, c).run()),
    ]);

/// Pacing targets from docs/03 §3 and §5, each judged on the median over
/// [seeds] (E-5).
Future<List<CheckRow>> runChecks(
  Balance b, {
  List<int> seeds = const [10, 1, 2, 3, 4],
}) async {
  const hr = 3600.0;
  final rows = <CheckRow>[];
  final n = seeds.length;
  final all = await _runAll(b, [
    for (final s in seeds) SimConfig(seed: s),
    for (final s in seeds) SimConfig(seed: s, sigma: 0.06),
    for (final s in seeds) SimConfig(seed: s, idleAfterMinutes: 10),
    for (final s in seeds) SimConfig(seed: s, hours: 6, chronons: 20),
    for (final s in seeds) SimConfig(seed: s, ads: SimAds.fromBalance(b.ads)),
  ]);
  final skilled = all.sublist(0, n);
  final casual = all.sublist(n, 2 * n);
  final idle = all.sublist(2 * n, 3 * n);
  final run2 = all.sublist(3 * n, 4 * n);
  final withAds = all.sublist(4 * n, 5 * n);

  void add(
    String id,
    String name,
    List<double> perSeed,
    bool Function(double) ok, {
    String Function(double)? fmt,
  }) {
    final f =
        fmt ?? (double v) => v.isInfinite ? '∞' : v.toStringAsPrecision(3);
    final m = _median(perSeed);
    rows.add(CheckRow(id, name, perSeed.map(f).toList(), f(m), ok(m)));
  }

  double first(SimResult r, String id) =>
      r.firstGenerator[id] ?? double.infinity;

  add('B-1', 'first grandpa (min)', [
    for (final r in skilled) first(r, 'grandpa') / 60,
  ], (v) => v <= 2);
  add('B-2', 'first watchmaker (min)', [
    for (final r in skilled) first(r, 'watchmaker') / 60,
  ], (v) => v >= 15 && v <= 40);
  add('B-3', 'first atomic clock (h)', [
    for (final r in skilled) first(r, 'atomic') / hr,
  ], (v) => v >= 1.5 && v <= 4);
  add('B-4', 'first time machine (h)', [
    for (final r in skilled) first(r, 'timeMachine') / hr,
  ], (v) => v > 6);
  add('B-5', 'Chronons at 6 h', [
    for (final r in skilled)
      Simulator(
        b,
        const SimConfig(),
      ).econ.chrononsTotalFor(r.earnedAt(6 * hr)).toDouble(),
  ], (v) => v >= 15 && v <= 30);
  double ratioAt(SimResult r, int h) {
    for (final x in r.hourly) {
      if (x.hour.round() == h && x.passive > 0) return x.active / x.passive;
    }
    return 0;
  }

  add('B-6a', 'clicking/passive, hour 1', [
    for (final r in skilled) ratioAt(r, 1),
  ], (v) => v >= 1);
  add('B-6b', 'clicking/passive, min of h2–8', [
    for (final r in skilled)
      [for (var h = 2; h <= 8; h++) ratioAt(r, h)]
          .reduce((a, c) => a < c ? a : c),
  ], (v) => v >= 1.5);
  add('B-6c', 'clicking/passive, max of h2–8', [
    for (final r in skilled)
      [for (var h = 2; h <= 8; h++) ratioAt(r, h)]
          .reduce((a, c) => a > c ? a : c),
  ], (v) => v <= 5);
  add('B-7', 'casual/skilled Tiki at 8 h', [
    for (var i = 0; i < seeds.length; i++)
      casual[i].earnedAt(8 * hr) / skilled[i].earnedAt(8 * hr),
  ], (v) => v >= 0.4);
  add('B-8', 'idle/skilled Tiki at 8 h', [
    for (var i = 0; i < seeds.length; i++)
      idle[i].earnedAt(8 * hr) / skilled[i].earnedAt(8 * hr),
  ], (v) => v >= 0.01);
  add('B-8b', 'idle: fewest buys in an hour', [
    for (final r in idle)
      [
        for (var h = 0; h < 8; h++)
          r.buyTimes
              .where((t) => t >= h * hr && t < (h + 1) * hr)
              .length
              .toDouble(),
      ].reduce((a, c) => a < c ? a : c),
  ], (v) => v >= 1);
  add('B-9', 'run 2 (20 Chronons) reaches run 1 @ 6 h (h)', [
    for (var i = 0; i < seeds.length; i++)
      run2[i].timeTo(skilled[i].earnedAt(6 * hr)) / hr,
  ], (v) => v <= 4.5);
  add('B-10', 'skills never bought', [
    for (final r in skilled)
      b.skills
          .where((s) => s.id != 'ticking' && (r.state.skills[s.id] ?? 0) == 0)
          .length
          .toDouble(),
  ], (v) => v == 0);
  add('A-1', 'with ads: reaches no-ad 8 h after (h)', [
    for (var i = 0; i < seeds.length; i++)
      withAds[i].timeTo(skilled[i].earnedAt(8 * hr)) / hr,
  ], (v) => v >= 3 && v <= 4);
  add('A-2', 'with ads: ads per hour', [
    for (final r in withAds) r.adLog.length / 8,
  ], (v) => v <= 6.5);
  return rows;
}
