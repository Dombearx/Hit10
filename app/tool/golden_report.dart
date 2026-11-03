// What is a golden second worth? At fixed play times of the greedy
// simulated player (the same as `make sim`), the game state is copied and
// played on for 3 minutes without buying, once plain and once with each
// effect at full strength (a PERFECT on the golden round). The gain is in
// seconds of the player's normal total income at that moment.
// From app/:   dart run tool/golden_report.dart [--sigma 0.03] [--seeds 5]
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/sim/simulator.dart';

const window = 180.0; // seconds played on after the catch

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final sigma = double.parse(opt('sigma') ?? '0.03');
  final seeds = int.parse(opt('seeds') ?? '5');
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final marks = [15, 60, 180, 360, 480];
  // mark → effect → gains (s of income), one per seed
  final gains = <int, Map<String, List<double>>>{};
  final luckyCap = <int, List<double>>{};
  final hitShare = <int, List<double>>{};

  for (var seed = 1; seed <= seeds; seed++) {
    final sim = Simulator(b, SimConfig(hours: 8, sigma: sigma, seed: seed));
    final left = marks.map((m) => m * 60.0).toList();
    sim.onStep = (t) {
      if (left.isEmpty || t < left.first) return;
      final mark = (left.removeAt(0) / 60).round();
      final snap = saveToJsonString(SaveData(sim.s, Settings()));
      double play(String effect, {bool lucky = false}) {
        final s = saveFromJsonString(snap).state;
        final e = GameEngine(b, s, random: math.Random(seed))
          ..goldenEnabled = false;
        final rnd = math.Random(seed * 31 + mark);
        double gauss() {
          final u = math.max(1e-12, rnd.nextDouble());
          return math.sqrt(-2 * math.log(u)) *
              math.cos(2 * math.pi * rnd.nextDouble());
        }

        final start = s.earnedTotal;
        if (effect == 'frenzy') {
          e.frenzyLeft = b.golden.effect('frenzy').duration;
          e.frenzy = b.golden.effect('frenzy').multiplier;
        } else if (effect == 'hotHand') {
          e.hotHandLeft = b.golden.effect('hotHand').duration;
        }
        var t = 0.0;
        var hits = 0.0;
        while (t < window) {
          final dt = e.econ.roundSeconds();
          final before = s.earnedTotal;
          e.tick(dt);
          final passive = s.earnedTotal - before;
          final o = e.resolveRound(
            grade(gauss() * sigma, e.econ.playerWindows()),
          );
          hits += o.payout;
          t += dt;
          if (passive < 0) break;
        }
        if (effect == 'none') {
          hitShare
              .putIfAbsent(mark, () => [])
              .add(hits / math.max(1e-9, s.earnedTotal - start));
        }
        return s.earnedTotal - start;
      }

      final base = play('none');
      final perSecond = base / window;
      final m = gains.putIfAbsent(mark, () => {});
      for (final fx in ['frenzy', 'hotHand']) {
        m.putIfAbsent(fx, () => []).add((play(fx) - base) / perSecond);
      }
      // Lucky is a lump: 10 min of clocks, at most 10 % of the bank.
      final lucky = b.golden.effect('lucky');
      final passive = sim.e.passive();
      final full = passive * lucky.productionSeconds;
      final capped = math.min(full, sim.s.tiki * lucky.bankFraction);
      m.putIfAbsent('lucky', () => []).add(capped / perSecond);
      m.putIfAbsent('lucky (no cap)', () => []).add(full / perSecond);
      luckyCap.putIfAbsent(mark, () => []).add(capped < full ? 1 : 0);
    };
    sim.run();
  }

  double median(List<double> v) {
    final c = [...v]..sort();
    return c[c.length ~/ 2];
  }

  stdout.writeln(
    'Złota Sekunda przy PERFEKCIE (σ = ${(sigma * 1000).round()} ms, '
    '$seeds ziaren, mediana). Zysk w sekundach normalnego dochodu.\n',
  );
  stdout.writeln(
    '  czas    Szał   Gorąca ręka   Fart   Fart bez limitu  limit 10%   udział trafień',
  );
  for (final mark in marks) {
    final m = gains[mark];
    if (m == null) continue;
    final capHit = luckyCap[mark]!.fold<double>(0, (a, v) => a + v);
    String f(String k) => median(m[k]!).round().toString();
    stdout.writeln(
      '  ${mark.toString().padLeft(3)} min'
      '${f('frenzy').padLeft(7)}'
      '${f('hotHand').padLeft(14)}'
      '${f('lucky').padLeft(7)}'
      '${f('lucky (no cap)').padLeft(17)}'
      '${'${capHit.round()}/$seeds'.padLeft(11)}'
      '${'${(median(hitShare[mark]!) * 100).round()}%'.padLeft(17)}',
    );
  }
  // Expected value per catch with the weights (45/45/10).
  stdout.writeln('\nŚrednio na złapaną (wagi z balance.json):');
  for (final mark in marks) {
    final m = gains[mark];
    if (m == null) continue;
    var ev = 0.0;
    for (final fx in b.golden.effects) {
      ev += fx.weight * median(m[fx.id]!);
    }
    stdout.writeln(
      '  ${mark.toString().padLeft(3)} min  ${formatNumber(ev)} s',
    );
  }
}
