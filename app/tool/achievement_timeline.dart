// When does a real player reach each counted achievement (docs/02 §8)?
// `late_game_report.dart`'s player: a few sessions a day, offline income
// in between (doubled by an ad), paradoxes, perks, Mainsprings and the
// Time Loops. Logs the day each value of each category is first reached,
// so any threshold can be read off. From app/:
//
//   dart run tool/achievement_timeline.dart [--days 180] [--sessions 3]
//       [--minutes 11] [--sigma 0.04] [--stay 2] [--no-loops]
//
// --stay: days the player stays in a loop after its goal (the loops'
// default 2); --no-loops: never starts a new loop, only paradoxes.
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/number_format.dart';

import 'late_game_report.dart' show Player;

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final days = int.parse(opt('days', '180'));
  final sessions = int.parse(opt('sessions', '3'));
  final minutes = double.parse(opt('minutes', '11'));
  final sigma = double.parse(opt('sigma', '0.04'));
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final s = GameState()..tutorialDone = true;
  final p = Player(
    b,
    s,
    sessions: sessions,
    minutes: minutes,
    sigma: sigma,
    loops: !args.contains('--no-loops'),
    stayDays: double.parse(opt('stay', '2')),
  );

  // Category → the best value so far and the day each new best came.
  final best = <String, double>{};
  final log = <String, List<(double, double)>>{};
  void see(String key, num v, double day) {
    final x = v.toDouble();
    if (x > (best[key] ?? double.negativeInfinity)) {
      best[key] = x;
      (log[key] ??= []).add((day, x));
    }
  }

  final perLoop = <int, Map<String, int>>{};
  p.onSession = (s, day, passive) {
    final m = perLoop[s.loop] ??= {};
    for (final g in b.generators) {
      final n = s.owned[g.id] ?? 0;
      see('owned ${g.id}', n, day);
      m[g.id] = math.max(m[g.id] ?? 0, n);
    }
    see('clocks', s.owned.values.fold(0, (a, n) => a + n), day);
    see('earned', s.lifetime.earnedEver, day);
    see('income', passive, day);
    see('prestiges', s.prestiges, day);
    see('perfects', s.lifetime.perfects, day);
    see('exact', s.lifetime.exactHits, day);
    see('rounds', s.stats.rounds, day);
    see('golden', s.lifetime.goldenCaught, day);
    see('skillLevels', s.skills.values.fold(0, (a, n) => a + n), day);
    see('playHours', s.lifetime.secondsPlayed / 3600, day);
    see('achievements', s.achievements.length, day);
    see('mastery', s.clockLevels.values.fold(0, (a, n) => a + n), day);
    see('loop', s.loop, day);
  };
  while (p.day < days) {
    p.playDay();
  }

  /// The first day [key] reached [v], or null.
  double? dayOf(String key, double v) {
    for (final (d, x) in log[key] ?? const <(double, double)>[]) {
      if (x >= v) return d;
    }
    return null;
  }

  stdout.writeln(
    '$sessions × ${minutes.toStringAsFixed(0)} min a day, '
    'σ = ${(sigma * 1000).round()} ms, $days days',
  );
  final loops = log['loop']!;
  stdout.writeln(
    'loops start on days: ${loops.map((e) => e.$1.toStringAsFixed(0)).join(', ')}',
  );
  String row(String key, List<num> values) {
    final cells = [
      for (final v in values)
        '${v is double ? formatNumber(v) : v}: '
            '${dayOf(key, v.toDouble())?.toStringAsFixed(0) ?? '—'}',
    ];
    return '${key.padRight(20)} best ${formatNumber(best[key] ?? 0).padLeft(8)}'
        ' | ${cells.join('  ')}';
  }

  final ach = b.achievements;
  stdout.writeln('\nvalue: day first reached (— = never)');
  for (final (i, g) in b.generators.indexed) {
    final now = ach.ownedThresholdsFor(i);
    final top = now.last;
    final probe = {
      ...now,
      for (final f in [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2.0])
        (top * f).round(),
    }.toList()..sort();
    stdout.writeln(row('owned ${g.id}', probe));
  }
  stdout.writeln(row('clocks', [...ach.clocksThresholds, 2000, 2500, 3000]));
  stdout.writeln(row('earned', ach.earnedThresholds));
  stdout.writeln(row('income', ach.incomeThresholds));
  stdout.writeln(row('prestiges', [...ach.prestigeThresholds, 75, 100]));
  stdout.writeln(row('perfects', ach.perfectThresholds));
  stdout.writeln(row('exact', ach.exactThresholds));
  stdout.writeln(row('rounds', ach.roundThresholds));
  stdout.writeln(row('golden', [...ach.goldenThresholds, 1000]));
  stdout.writeln(row('skillLevels', [...ach.skillLevelThresholds, 120, 134]));
  stdout.writeln(row('playHours', ach.playHoursThresholds));
  stdout.writeln(
    row('achievements', [...ach.achievementCountThresholds, 125, 150]),
  );
  stdout.writeln(row('mastery', [14, 28, 42, 56, 70]));
  stdout.writeln('\nper loop, the most of each clock owned at once:');
  stdout.writeln(
    'clock'.padRight(14) +
        [for (final l in perLoop.keys) 'L$l'.padLeft(5)].join(),
  );
  final ids = perLoop.keys.toList()..sort();
  for (final g in b.generators) {
    final cells = [
      for (final l in ids) (perLoop[l]![g.id] ?? 0).toString().padLeft(5),
    ];
    stdout.writeln(g.id.padRight(14) + cells.join());
  }
}
