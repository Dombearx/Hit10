// Multi-day balance run: N minutes a day, offline income for the rest of
// the day, the daily bonus, paradoxes and perks. From app/:
//
//   dart run tool/daily_sim.dart [minutes=8] [sigma=0.05] [paradoxAt=1.0] [ads]
import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/sim/simulator.dart';

const perkOrder = [
  'headStart',
  'deepSleep1',
  'longNap1',
  'muscleMemory1',
  'goldRush',
  'earlyModes',
  'startShield',
  'autoBuyer',
  'deepSleep2',
  'longNap2',
  'unlockSchrodinger',
  'comboFloor',
  'muscleMemory2',
  'secondClock',
  'muscleMemory3',
  'unlockChronos',
];

void main(List<String> args) {
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final minutes = double.parse(args.isNotEmpty ? args[0] : '8');
  final sigma = double.parse(args.length > 1 ? args[1] : '0.05');
  final prestigeAt = double.parse(args.length > 2 ? args[2] : '1.0');
  final offlineAd = args.contains('ads');
  final s = GameState()..tutorialDone = true;
  final day0 = DateTime(2026, 11, 2, 19);
  final seen = <String>{};
  void mark(String what, int day) {
    if (seen.add(what)) {
      stdout.writeln('dzień ${day.toString().padLeft(4)}: $what');
    }
  }

  for (var day = 1; day <= 2000; day++) {
    final sim = Simulator(
      b,
      SimConfig(hours: minutes / 60, sigma: sigma, seed: day),
      state: s,
    );
    final e = sim.e;
    final d = e.dailyFor(day0.add(Duration(days: day)));
    if (d != null) e.claimDaily(d);
    sim.run();
    for (final g in b.generators) {
      if ((s.owned[g.id] ?? 0) > 0) mark('pierwszy ${g.id}', day);
    }
    for (final k in b.skills) {
      if (k.id != 'ticking' && (s.skills[k.id] ?? 0) >= k.maxLevel) {
        mark('max ${k.id}', day);
      }
    }
    if (b.skills.every(
      (k) => k.id == 'ticking' || (s.skills[k.id] ?? 0) >= k.maxLevel,
    )) {
      mark('WSZYSTKIE umiejętności na max (w jednym biegu)', day);
    }
    // Paradox when it at least multiplies the Chronons by (1+prestigeAt).
    final gain = e.econ.prestigeGain();
    if (gain >= 5 && gain >= prestigeAt * s.chronons) {
      e.prestige();
      stdout.writeln(
        'dzień ${day.toString().padLeft(4)}:   paradoks +$gain → ${s.chronons} Chrononów',
      );
      for (final id in perkOrder) {
        e.buyPerk(id);
      }
    }
    for (final id in perkOrder) {
      e.buyPerk(id);
    }
    if (s.perks.length == b.prestige.perks.length) mark('WSZYSTKIE perki', day);
    if (seen.contains('WSZYSTKIE perki') && (s.owned['chronos'] ?? 0) > 0) {
      mark('KONIEC: Chronos kupiony', day);
      break;
    }
    // Offline for the rest of the day.
    final away = 24 * 3600 - minutes * 60;
    final counted = away < e.offlineCapSeconds() ? away : e.offlineCapSeconds();
    s.earn(
      e.econ.passive() * counted * e.offlineEfficiency() * (offlineAd ? 2 : 1),
    );
  }
}
