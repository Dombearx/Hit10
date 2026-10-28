import 'dart:math' as math;

import '../balance/balance.dart';
import '../engine/game_engine.dart';
import '../model/economy.dart';
import '../model/game_state.dart';
import '../model/grading.dart';

/// Rewarded-ad offers the simulated player always takes (docs/03 §5).
class SimAds {
  const SimAds({
    this.turboMultiplier = 2,
    this.turboDuration = 1800,
    this.turboMaxStock = 14400,
    this.bagSeconds = 300,
    this.bagCooldown = 1800,
    this.goldenCooldown = 1800,
    this.rescueMinStreak = 15,
    this.rescueCooldown = 900,
  });

  factory SimAds.fromBalance(AdsConfig a) => SimAds(
    turboMultiplier: a.turboMultiplier,
    turboDuration: a.turboDuration,
    turboMaxStock: a.turboMaxStock,
    bagSeconds: a.bagProductionSeconds,
    bagCooldown: a.bagCooldown,
    goldenCooldown: a.goldenCooldown,
    rescueMinStreak: a.rescueMinStreak,
    rescueCooldown: a.rescueCooldown,
  );

  final double turboMultiplier;
  final double turboDuration;
  final double turboMaxStock;
  final double bagSeconds;
  final double bagCooldown;
  final double goldenCooldown;
  final int rescueMinStreak;
  final double rescueCooldown;
}

class SimConfig {
  const SimConfig({
    this.hours = 8,
    this.sigma = 0.030,
    this.idleAfterMinutes,
    this.chronons = 0,
    this.seed = 10,
    this.ads,
  });

  final double hours;

  /// Player's timing spread in real seconds.
  final double sigma;

  /// Tap only for the first N minutes, then only buy.
  final double? idleAfterMinutes;
  final int chronons;
  final int seed;
  final SimAds? ads;
}

class HourSample {
  const HourSample(this.hour, this.passive, this.active, this.earned);
  final double hour;
  final double passive;
  final double active;
  final double earned;
}

class SimResult {
  final Map<String, double> firstGenerator = {};
  final List<(double, String, int)> skillLog = [];
  final List<HourSample> hourly = [];
  final List<double> buyTimes = [];
  final List<(double, double)> earnedLog = [];
  final List<(double, String)> adLog = [];
  late GameState state;

  double earnedAt(double t) {
    var best = 0.0;
    for (final (tt, e) in earnedLog) {
      if (tt > t) break;
      best = e;
    }
    return best;
  }

  double timeTo(double target) {
    for (final (tt, e) in earnedLog) {
      if (e >= target) return tt;
    }
    return double.infinity;
  }
}

/// A greedy bot that plays the game with the real economy code (T-4), the
/// Dart port of `design/sim.py`. It taps with a normal timing error, buys
/// whatever pays back fastest, catches every golden second and (optionally)
/// takes every rewarded offer.
class Simulator {
  Simulator(this.b, this.cfg)
    : rnd = math.Random(cfg.seed),
      s = GameState()..chronons = cfg.chronons {
    e = GameEngine(b, s);
  }

  final Balance b;
  final SimConfig cfg;
  final math.Random rnd;
  final GameState s;
  late final GameEngine e;
  Economy get econ => e.econ;

  int _streak = 0;
  int _shield = 0;
  int _shieldProgress = 0;
  double _frenzyUntil = -1;
  double _turboUntil = -1;

  // ------------------------------------------------- analytic estimates --

  double _passive() => econ.passive();

  /// Mean combo streak over renewal cycles (design/sim.py avg_streak).
  static double avgStreak(double inc, double pMiss, int cap) {
    if (inc <= 0) return 0;
    if (pMiss <= 1e-12) return cap.toDouble();
    final q = 1 - pMiss;
    final kCap = math.max(1, (cap / inc).ceil());
    var total = 0.0;
    for (var k = 1; k < kCap; k++) {
      total += math.pow(q, k) * inc * k;
    }
    total += cap * math.pow(q, kCap) / (1 - q);
    return pMiss * total;
  }

  TierOdds _playerOdds() => econ.odds(
    cfg.sigma * econ.bulletTimeSpeed(),
    econ.windows(),
    luck: econ.luckChance(),
  );

  double _activeIncome(double passive) {
    final o = _playerOdds();
    var pMiss = 1 - o.hit;
    final inc = 2 * o.perfect + o.great;
    if (econ.shieldCharges() > 0) {
      pMiss = pMiss * math.max(0.0, 1 - (inc / 10) / math.max(1e-9, pMiss));
    }
    final combo =
        1 + b.combo.multiplierPerStep * avgStreak(inc, pMiss, econ.comboCap());
    final flat =
        econ.expectedReward(o) *
        econ.strikePower() *
        econ.permanentMultiplier();
    final echo =
        econ.echoSeconds() *
        (o.perfect +
            o.great * b.tier('great').echoShare +
            o.good * b.tier('good').echoShare) *
        passive;
    return (flat + echo) * combo / econ.roundSeconds();
  }

  double _goldenStrength() {
    final o = _playerOdds();
    final ts = b.golden.tierStrength;
    return (o.perfect * ts['perfect']! +
            o.great * ts['great']! +
            o.good * ts['good']!) *
        econ.goldenStrengthFactor();
  }

  double _goldenInterval() =>
      (b.golden.intervalMin + b.golden.intervalMax) /
      2 *
      econ.goldenIntervalFactor();

  double totalIncome(bool idle) {
    final p = _passive();
    if (idle) return p;
    final total = p + _activeIncome(p);
    final str = _goldenStrength();
    final iv = _goldenInterval();
    final fr = b.golden.effect('frenzy');
    final lucky = b.golden.effect('lucky');
    final frenzyShare = fr.weight * fr.duration * str / iv;
    final luckyIncome = lucky.weight * lucky.productionSeconds * str * p / iv;
    return total * (1 + (fr.multiplier - 1) * frenzyShare) + luckyIncome;
  }

  // ------------------------------------------------------------- buying --

  Iterable<(String, String, double)> _candidates() sync* {
    for (final g in b.generators) {
      if (!econ.generatorUnlocked(g.id)) continue;
      yield ('gen', g.id, econ.generatorCost(g.id));
      final u = econ.nextUpgrade(g.id);
      if (u != null && econ.owned(g.id) >= u.threshold) {
        yield ('upg', g.id, u.cost);
      }
    }
    for (final syn in econ.availableSynergies()) {
      yield ('syn', syn.id, syn.cost);
    }
    for (final sk in b.skills) {
      if (sk.id == 'ticking') continue; // no income effect
      final c = econ.skillCost(sk.id);
      if (c != null) yield ('skill', sk.id, c);
    }
  }

  double _gainOf(String kind, String key, bool idle) {
    final before = totalIncome(idle);
    void apply(int d) {
      switch (kind) {
        case 'gen':
          s.owned[key] = econ.owned(key) + d;
        case 'upg':
          s.upgrades[key] = econ.upgradesBought(key) + d;
        case 'syn':
          d > 0 ? s.synergies.add(key) : s.synergies.remove(key);
        case 'skill':
          s.skills[key] = econ.level(key) + d;
      }
    }

    if (kind == 'skill' &&
        idle &&
        !{'wideEye', 'magnet', 'luck'}.contains(key)) {
      return 0;
    }
    apply(1);
    final after = totalIncome(idle);
    apply(-1);
    return after - before;
  }

  void _buy(String kind, String key) {
    switch (kind) {
      case 'gen':
        e.buyGenerators(key, 1);
      case 'upg':
        e.buyUpgrade(key);
      case 'syn':
        e.buySynergy(key);
      case 'skill':
        e.buySkill(key);
    }
  }

  double _gauss() {
    final u1 = 1 - rnd.nextDouble();
    final u2 = rnd.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  double _uniform(double a, double b) => a + rnd.nextDouble() * (b - a);

  // -------------------------------------------------------------- run --

  SimResult run() {
    final res = SimResult()..state = s;
    final gold = b.golden;
    final ads = cfg.ads;
    var t = 0.0;
    var nextGolden = _uniform(gold.intervalMin, gold.intervalMax);
    var nextHour = 3600.0;
    var nextBag = 0.0, nextAdGolden = 0.0, nextRescue = 0.0;
    final end = cfg.hours * 3600;
    while (t < end) {
      final idle =
          cfg.idleAfterMinutes != null && t >= cfg.idleAfterMinutes! * 60;
      e.frenzy = t < _frenzyUntil ? gold.effect('frenzy').multiplier : 1;
      e.turbo = ads != null && t < _turboUntil ? ads.turboMultiplier : 1;
      final dt = idle ? 5.0 : econ.roundSeconds();
      final passive = e.passive();
      var gain = passive * dt;
      if (!idle) {
        final slow = econ.bulletTimeSpeed();
        final err = _gauss() * cfg.sigma * slow;
        var tier = grade(err, econ.windows()).tier;
        if ((tier == Tier.great || tier == Tier.good) &&
            rnd.nextDouble() < econ.luckChance()) {
          tier = tier == Tier.great ? Tier.perfect : Tier.great;
        }
        final cap = econ.comboCap();
        if (tier == Tier.miss) {
          if (_shield > 0) {
            _shield--;
          } else if (ads != null &&
              _streak >= ads.rescueMinStreak &&
              t >= nextRescue) {
            nextRescue = t + ads.rescueCooldown;
            res.adLog.add((t, 'rescue'));
          } else {
            _streak = 0;
          }
        } else {
          final step = b.tier(tier.name).comboStep;
          _streak = math.min(cap, _streak + step);
          _shieldProgress += step;
          while (_shieldProgress >= b.combo.shieldRechargeSteps) {
            _shieldProgress -= b.combo.shieldRechargeSteps;
            _shield = math.min(econ.shieldCharges(), _shield + 1);
          }
          final combo = 1 + b.combo.multiplierPerStep * _streak;
          gain += e.hitPayout(Grade(tier, err), combo: combo);
        }
        if (t >= nextGolden) {
          nextGolden =
              t +
              _uniform(gold.intervalMin, gold.intervalMax) *
                  econ.goldenIntervalFactor();
          if (tier != Tier.miss) {
            final strength =
                gold.tierStrength[tier.name]! * econ.goldenStrengthFactor();
            final r =
                rnd.nextDouble() *
                gold.effects.fold<double>(0, (a, x) => a + x.weight);
            var acc = 0.0;
            for (final eff in gold.effects) {
              acc += eff.weight;
              if (r >= acc) continue;
              if (eff.id == 'frenzy') {
                _frenzyUntil =
                    math.max(_frenzyUntil, t) + eff.duration * strength;
              } else if (eff.id == 'lucky') {
                gain +=
                    strength *
                    math.min(
                      passive * eff.productionSeconds,
                      s.tiki * eff.bankFraction,
                    );
              }
              break;
            }
          }
        }
        if (ads != null) {
          if (_turboUntil - t < 60) {
            _turboUntil = math.min(
              math.max(_turboUntil, t) + ads.turboDuration,
              t + ads.turboMaxStock,
            );
            res.adLog.add((t, 'turbo'));
          }
          if (t >= nextBag) {
            e.frenzy = 1;
            e.turbo = 1;
            gain += e.passive() * ads.bagSeconds;
            nextBag = t + ads.bagCooldown;
            res.adLog.add((t, 'bag'));
          }
          if (t >= nextAdGolden) {
            nextGolden = t;
            nextAdGolden = t + ads.goldenCooldown;
            res.adLog.add((t, 'golden'));
          }
        }
      }
      s.earn(gain);
      t += dt;
      e.frenzy = 1;
      e.turbo = 1;
      // Greedy: best payback first, while affordable.
      while (true) {
        (double, String, String, double)? best;
        final income = math.max(1e-9, totalIncome(idle));
        for (final (kind, key, cost) in _candidates()) {
          final d = _gainOf(kind, key, idle);
          if (d <= 0) continue;
          final score = cost / d + math.max(0.0, cost - s.tiki) / income;
          if (best == null || score < best.$1) best = (score, kind, key, cost);
        }
        if (best == null || best.$4 > s.tiki) break;
        final (_, kind, key, _) = best;
        _buy(kind, key);
        res.buyTimes.add(t);
        if (kind == 'gen') res.firstGenerator.putIfAbsent(key, () => t);
        if (kind == 'skill') res.skillLog.add((t, key, econ.level(key)));
      }
      res.earnedLog.add((t, s.earnedTotal));
      if (t >= nextHour) {
        final base = _passive();
        res.hourly.add(
          HourSample(t / 3600, base, totalIncome(idle) - base, s.earnedTotal),
        );
        nextHour += 3600;
      }
    }
    return res;
  }
}
