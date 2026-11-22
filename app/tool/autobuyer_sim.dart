// The "automatic buyer" perk: what each way of choosing the clock adds
// for a player who taps the rounds and only looks into the shop now and
// then. From app/:
//
//   dart run tool/autobuyer_sim.dart [--minutes 60] [--sigma 0.05]
//       [--interval 5] [--cue 30] [--warmup 15]
//       [--chronons 100,3000,100000]
//
// Every run first plays `warmup` minutes shopping every round, then the
// measured `minutes`. Player: shops greedily (best payback first, skills included) every
// `shopEvery` seconds, otherwise only taps. Between visits the auto buyer
// buys one clock every `interval` seconds when it can afford it:
//
//   none        no auto buyer (the baseline)
//   cheapest    today's perk: the cheapest clock in the shop
//   target      the clock the player picked at the last visit (the best
//               payback then), without end
//   target-stop the same, but it stops at that clock's next milestone and
//               waits; the player picks again at the next visit
//   stop+pick   target-stop, but the stop is noticed within `cue` seconds
//               and the player only picks the next clock (one tap, no
//               shopping): what the signal itself is worth
//   stop+shop   the same, but noticing it the player shops as at a visit
//   newest      always the newest clock in the shop
//   best        always the best payback clock (the "too easy" one)
//
// "ideal" is the simulator's bot shopping every round. It scores one unit
// at a time, so it undervalues milestones: a buyer that pushes to the next
// milestone can beat it (> 100 %). Numbers are
// the tiki earned in the session as % of ideal; for the stop variants,
// how many stops and how long the buyer stood still on average.
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/sim/simulator.dart';

const variants = [
  'none',
  'cheapest',
  'target',
  'target-stop',
  'stop+pick',
  'stop+shop',
  'newest',
  'best',
];

class Run {
  double earned = 0;
  int stops = 0;
  double stoppedSecs = 0;
  int autoBought = 0;
}

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final minutes = double.parse(opt('minutes', '60'));
  final sigma = double.parse(opt('sigma', '0.05'));
  final interval = double.parse(opt('interval', '5'));
  final cue = double.parse(opt('cue', '30'));
  final warm = double.parse(opt('warmup', '15'));
  final chronons = opt(
    'chronons',
    '100,3000,100000',
  ).split(',').map(int.parse).toList();
  final shopEvery = [30.0, 120.0, 600.0, double.infinity];
  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );

  Run play(int ch, double every, String v, int seed, {bool ideal = false}) {
    final s = GameState()
      ..tutorialDone = true
      ..chronons = ch
      ..perks.add('autoBuyer');
    // Warm-up: the run's first minutes played and shopped normally, so
    // every variant starts from the same, already working economy.
    if (warm > 0) {
      Simulator(
        b,
        SimConfig(hours: warm / 60, sigma: sigma, seed: seed + 100),
        state: s,
      ).run();
    }
    final sim = Simulator(
      b,
      SimConfig(hours: minutes / 60, sigma: sigma, buys: ideal, seed: seed),
      state: s,
    );
    final e = sim.e;
    final econ = sim.econ;
    final run = Run();
    String? target;
    var stoppedAt = -1.0; // when target-stop stood still, -1 while buying
    var nextVisit = 0.0;
    var repickAt = double.infinity;
    var acc = 0.0;
    var lastT = 0.0;

    // Only what the shop shows: owned, or the next one in line.
    Iterable<String> shop() sync* {
      for (var i = 0; i < b.generators.length; i++) {
        final g = b.generators[i];
        if (!econ.generatorUnlocked(g.id)) continue;
        if (i > 0 && econ.owned(b.generators[i - 1].id) == 0) break;
        yield g.id;
      }
    }

    // The best payback, as the simulator's greedy bot scores it.
    String? bestOf({required bool gensOnly}) {
      String? best;
      var bestScore = double.infinity;
      final income = math.max(1e-9, sim.totalIncome(false));
      for (final (kind, key, cost) in sim.candidates()) {
        if (gensOnly && kind != 'gen') continue;
        if (kind == 'gen' && !shop().contains(key)) continue;
        final d = sim.gainOf(kind, key);
        if (d <= 0) continue;
        final score = cost / d + math.max(0.0, cost - s.tiki) / income;
        if (score < bestScore) {
          bestScore = score;
          best = '$kind:$key';
        }
      }
      return best;
    }

    // The clock with the best payback counting its next milestone: the
    // units up to it bought together (what a thinking player sees, and
    // what a "most profitable" buyer would compute).
    String? bestClock() {
      String? best;
      var bestScore = double.infinity;
      final before = sim.totalIncome(false);
      final income = math.max(1e-9, before);
      for (final id in shop()) {
        final have = econ.owned(id);
        final k = math.max(1, (econ.nextMilestone(id) ?? have + 1) - have);
        var cost = 0.0;
        for (var i = 0; i < k; i++) {
          cost += econ.generatorCost(id, have + i);
        }
        s.owned[id] = have + k;
        final gain = sim.totalIncome(false) - before;
        s.owned[id] = have;
        if (gain <= 0) continue;
        final one = econ.generatorCost(id);
        final score = cost / gain + math.max(0.0, one - s.tiki) / income;
        if (score < bestScore) {
          bestScore = score;
          best = id;
        }
      }
      return best;
    }

    void visit(double t) {
      // Greedy, while the best thing is affordable.
      while (true) {
        final best = bestOf(gensOnly: false);
        if (best == null) break;
        final [kind, key] = best.split(':');
        final ok = kind == 'gen'
            ? e.buyGenerators(key, 1) == BuyResult.ok
            : e.buySkill(key) == BuyResult.ok;
        if (!ok) break;
      }
      target = bestClock();
      if (stoppedAt >= 0) {
        run.stoppedSecs += t - stoppedAt;
        stoppedAt = -1;
      }
    }

    String? pick() {
      switch (v) {
        case 'cheapest':
          String? c;
          for (final id in shop()) {
            if (c == null || econ.generatorCost(id) < econ.generatorCost(c)) {
              c = id;
            }
          }
          return c;
        case 'newest':
          return shop().isEmpty ? null : shop().last;
        case 'best':
          return bestClock();
        case 'target':
        case 'target-stop':
        case 'stop+pick':
        case 'stop+shop':
          return stoppedAt >= 0 ? null : target;
      }
      return null;
    }

    sim.onStep = (t) {
      if (ideal) return;
      if (t >= nextVisit) {
        visit(t);
        nextVisit = t + every;
        repickAt = double.infinity;
      }
      if (t >= repickAt) {
        target = bestClock();
        run.stoppedSecs += t - stoppedAt;
        stoppedAt = -1;
        repickAt = double.infinity;
      }
      if (v != 'none') {
        acc += t - lastT;
        while (acc >= interval) {
          acc -= interval;
          final id = pick();
          if (id == null || econ.generatorCost(id) > s.tiki) continue;
          final before = econ.milestonesReached(id);
          if (e.buyGenerators(id, 1) != BuyResult.ok) continue;
          run.autoBought++;
          final stops = v.startsWith('stop') || v == 'target-stop';
          if (stops && econ.milestonesReached(id) > before) {
            run.stops++;
            stoppedAt = t;
            if (v == 'stop+shop') nextVisit = math.min(nextVisit, t + cue);
            if (v == 'stop+pick') repickAt = t + cue;
          }
        }
      }
      lastT = t;
    };
    final before = s.earnedTotal;
    sim.run();
    if (stoppedAt >= 0) run.stoppedSecs += minutes * 60 - stoppedAt;
    run.earned = s.earnedTotal - before;
    return run;
  }

  String pct(double x) => '${(x * 100).toStringAsFixed(0)}%'.padLeft(5);
  String shopName(double e) =>
      e.isInfinite ? 'never' : '${(e / 60).toStringAsFixed(e < 60 ? 1 : 0)}m';

  stdout.writeln(
    'Auto buyer: $minutes min of tapping after a $warm min warm-up, σ ${(sigma * 1000).round()} ms, '
    'one clock per ${interval}s, cue $cue s',
  );
  const seeds = [1, 2, 3, 4, 5, 6];
  for (final ch in chronons) {
    final ideal = [
      for (final sd in seeds) play(ch, 0, 'none', sd, ideal: true).earned,
    ];
    stdout.writeln('\nChronons $ch — % of ideal (bot shopping every round)');
    stdout.writeln(
      'shop every ${variants.map((v) => v.padLeft(12)).join()}'
      '   stops/run   mean stop   (target-stop / stop+pick)',
    );
    for (final every in shopEvery) {
      final cells = <String>[];
      final ts = Run(), sc = Run();
      for (final v in variants) {
        // Geometric mean over the seeds: the income compounds.
        var logSum = 0.0;
        for (var i = 0; i < seeds.length; i++) {
          final r = play(ch, every, v, seeds[i]);
          logSum += math.log(math.max(1e-12, r.earned / ideal[i]));
          final sum = v == 'target-stop'
              ? ts
              : v == 'stop+pick'
              ? sc
              : null;
          if (sum != null) {
            sum.stops += r.stops;
            sum.stoppedSecs += r.stoppedSecs;
          }
        }
        cells.add(pct(math.exp(logSum / seeds.length)).padLeft(12));
      }
      String mean(Run r) =>
          r.stops == 0 ? '-' : '${(r.stoppedSecs / r.stops).round()}s';
      stdout.writeln(
        '${shopName(every).padRight(11)}${cells.join()}'
        '   ${(ts.stops / seeds.length).toStringAsFixed(0).padLeft(4)}'
        ' / ${(sc.stops / seeds.length).toStringAsFixed(0).padRight(4)}'
        '  ${mean(ts)} / ${mean(sc)}',
      );
    }
  }
}
