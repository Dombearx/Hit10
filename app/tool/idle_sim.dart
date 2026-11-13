// An idle player: a few short sessions a day, offline income in between,
// the daily bonus, paradoxes and perks (playtest 27: "it is mainly an
// idle game"). From app/:
//
//   dart run tool/idle_sim.dart [--days 30] [--sessions 3] [--minutes 3]
//       [--sigma 0.05] [--paradox 1.0] [--ads]
//
// --paradox: rewind when it at least multiplies the Chronons by 1 + this.
// --ads: the offline income doubled by an ad every time.
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/achievements.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/sim/simulator.dart';

const perkOrder = [
  'headStart',
  'deepSleep1',
  'longNap1',
  'muscleMemory1',
  'goldRush',
  'daredevil',
  'shieldRecharge',
  'autoBuyer',
  'deepSleep2',
  'longNap2',
  'unlockSchrodinger',
  'comboFloor',
  'muscleMemory2',
  'habit1',
  'secondClock',
  'habit2',
  'muscleMemory3',
  'unlockChronos',
];

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final days = int.parse(opt('days', '30'));
  final sessions = int.parse(opt('sessions', '3'));
  final minutes = double.parse(opt('minutes', '3'));
  final sigma = double.parse(opt('sigma', '0.05'));
  final paradoxAt = double.parse(opt('paradox', '1.0'));
  final ads = args.contains('--ads');
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final all = buildAchievements(b);
  final s = GameState()..tutorialDone = true;
  final day0 = DateTime(2026, 11, 2, 8);
  final gap = 24 * 3600 / sessions; // from one session's start to the next
  String n(double v) => formatNumber(v);

  // Milestone names ever seen (generator, index) and when.
  final seenMilestones = <String>{};
  var paradoxes = 0;
  var offlineTotal = 0.0;
  var playedTotal = 0.0;

  stdout.writeln(
    '$sessions × $minutes min a day, offline between, σ = '
    '${(sigma * 1000).round()} ms${ads ? ', offline ad ×2' : ''}',
  );
  stdout.writeln(
    'day  passive/s  clocks  newest clock     skill lv  Chronons  perks'
    '  bonuses seen  achievements  offline share',
  );
  for (var day = 1; day <= days; day++) {
    var dayOffline = 0.0;
    var dayPlayed = 0.0;
    for (var k = 0; k < sessions; k++) {
      final sim = Simulator(
        b,
        SimConfig(hours: minutes / 60, sigma: sigma, seed: day * 10 + k),
        state: s,
      );
      final e = sim.e;
      // Back from offline: rewind first when it pays, at least
      // ×(1 + paradoxAt) the Chronons.
      final gain = e.econ.prestigeGain();
      if (gain >= 5 && gain >= paradoxAt * s.chronons) {
        // Habits: the two most expensive skills to rebuy.
        s.habits
          ..clear()
          ..addAll(['echo', 'combo'].take(e.habitSlots()));
        e.prestige();
        paradoxes++;
      }
      for (final id in perkOrder) {
        e.buyPerk(id);
      }
      if (k == 0) {
        final d = e.dailyFor(day0.add(Duration(days: day)));
        if (d != null) e.claimDaily(d);
      }
      final before = s.lifetime.earnedEver;
      sim.onStep = (_) {
        for (final g in b.generators) {
          for (var i = 0; i < sim.econ.milestonesReached(g.id); i++) {
            seenMilestones.add('${g.id}#$i');
          }
        }
      };
      sim.run();
      dayPlayed += s.lifetime.earnedEver - before;
      unlockAchievements(
        all,
        s,
        AchievementContext(passive: sim.econ.passive()),
      );
      // Away until the next session.
      final away = gap - minutes * 60;
      final counted = math.min(away, e.offlineCapSeconds());
      final off =
          e.econ.passive() * counted * e.offlineEfficiency() * (ads ? 2 : 1);
      s.earn(off);
      dayOffline += off;
    }
    offlineTotal += dayOffline;
    playedTotal += dayPlayed;
    final sim = Simulator(b, const SimConfig(hours: 0), state: s);
    final clocks = s.owned.values.fold(0, (a, x) => a + x);
    final newest = b.generators.lastWhere(
      (g) => (s.owned[g.id] ?? 0) > 0,
      orElse: () => b.generators.first,
    );
    final lv = s.skills.values.fold(0, (a, x) => a + x);
    final share = dayOffline / math.max(1, dayOffline + dayPlayed);
    stdout.writeln(
      '${'$day'.padLeft(3)}  ${n(sim.econ.passive()).padLeft(9)}'
      '  ${'$clocks'.padLeft(6)}  ${newest.id.padRight(15)}'
      '  ${'$lv'.padLeft(8)}  ${'${s.chronons}'.padLeft(8)}'
      '  ${'${s.perks.length}'.padLeft(5)}'
      '  ${'${seenMilestones.length}/${b.generators.length * 8}'.padLeft(12)}'
      '  ${'${s.achievements.length}/${all.length}'.padLeft(12)}'
      '  ${'${(share * 100).round()}%'.padLeft(13)}',
    );
  }
  stdout.writeln(
    'paradoxes $paradoxes, earned ${n(s.lifetime.earnedEver)} '
    '(offline ${(offlineTotal / (offlineTotal + playedTotal) * 100).round()}%)',
  );
  stdout.writeln('bonuses seen per clock (of 8):');
  for (final g in b.generators) {
    final k = seenMilestones.where((x) => x.startsWith('${g.id}#')).length;
    stdout.writeln('  ${g.id.padRight(14)} $k');
  }
}
