// Combo redesign (design/combo_sim.py): today's streak against the
// multiplier ladder on the game's own engine. From app/:
//
//   dart run tool/combo_report.dart [--hours 8] [--seeds 3]
//       [--perfect 1 --great 0 --good 0 --jackpot 99]
//
// For each spread, normal play and Blind (spread ×1.5 and ×2): how often
// the multiplier is at its max and its mean in the second half of the run
// (skills bought by then), and Tiki earned against today's rules.
// `--jackpot 99` is "an exact 5.00 fills the multiplier".
import 'dart:convert';
import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/sim/simulator.dart';

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final hours = double.parse(opt('hours', '8'));
  final seeds = int.parse(opt('seeds', '3'));
  final json = File('assets/balance.json').readAsStringSync();
  final ladderJson = jsonDecode(json) as Map<String, dynamic>;
  (ladderJson['combo'] as Map<String, dynamic>)['ladder'] = {
    'steps': {
      'perfect': int.parse(opt('perfect', '1')),
      'great': int.parse(opt('great', '0')),
      'good': int.parse(opt('good', '0')),
    },
    'jackpot': int.parse(opt('jackpot', '99')),
    'rechargeHits': 10,
  };
  final rules = {
    'teraz': Balance.fromJsonString(json),
    'drabinka': Balance.fromJsonString(jsonEncode(ladderJson)),
  };
  const sigmas = [0.02, 0.035, 0.05, 0.1, 0.15];
  const modes = [(false, 1.0), (true, 1.5), (true, 2.0)];
  String p(double x) => '${(x * 100).round()}%';

  for (final (blind, spread) in modes) {
    stdout.writeln(
      blind ? '\n### na ślepo, rozrzut ×$spread' : '\n### zwykła gra',
    );
    stdout.writeln(
      '| σ | teraz: na max · mnożnik | drabinka: na max · mnożnik '
      '| Tiki po ${hours.round()} h vs teraz |',
    );
    stdout.writeln('|---|---|---|---|');
    for (final sigma in sigmas) {
      final row = <String, (double, double, double)>{};
      for (final MapEntry(key: name, value: b) in rules.entries) {
        var earned = 0.0, mean = 0.0, atMax = 0.0;
        for (var seed = 1; seed <= seeds; seed++) {
          final sim = Simulator(
            b,
            SimConfig(
              hours: hours,
              sigma: sigma,
              seed: seed,
              blind: blind,
              blindSpread: spread,
            ),
          );
          var n = 0, m = 0.0, top = 0;
          sim.onStep = (t) {
            if (t < hours * 1800) return;
            final c = sim.e.comboMultiplier();
            n++;
            m += c;
            final max = 1 + b.combo.multiplierPerStep * sim.econ.comboCap();
            if (c >= max - 1e-9) top++;
          };
          final r = sim.run();
          earned += r.state.earnedTotal / seeds;
          mean += m / n / seeds;
          atMax += top / n / seeds;
        }
        row[name] = (earned, mean, atMax);
      }
      final a = row['teraz']!, l = row['drabinka']!;
      final d = (l.$1 / a.$1 - 1) * 100;
      stdout.writeln(
        '| ${(sigma * 1000).round()} ms '
        '| ${p(a.$3)} · ×${a.$2.toStringAsFixed(2)} '
        '| ${p(l.$3)} · ×${l.$2.toStringAsFixed(2)} '
        '| ${d >= 0 ? '+' : ''}${d.toStringAsFixed(1)}% |',
      );
    }
  }
}
