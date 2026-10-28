import 'dart:math' as math;

import '../balance/balance.dart';
import '../model/economy.dart';
import '../model/game_state.dart';
import '../model/grading.dart';

enum BuyResult { ok, tooExpensive, unavailable }

/// Offline income waiting for the player to collect it (R-OFF-1…2).
class OfflineReport {
  const OfflineReport(this.awaySeconds, this.countedSeconds, this.amount);
  final double awaySeconds;

  /// Away time after the cap.
  final double countedSeconds;
  final double amount;
}

/// The game rules that change state: economy ticks, payouts, purchases and
/// offline income. Pure Dart (T-3); the Flutter controller drives it.
class GameEngine {
  GameEngine(this.b, this.s) : econ = Economy(b, s);

  final Balance b;
  final GameState s;
  final Economy econ;

  /// Temporary global multipliers (Frenzy, Turbo) — set by M3/M4 systems.
  double frenzy = 1;
  double turbo = 1;

  double passive() => econ.passive(frenzy: frenzy, turbo: turbo);

  /// Global multiplier G for hit rewards (docs/03 §2).
  double globalMultiplier() => econ.permanentMultiplier() * frenzy * turbo;

  /// Earns passive income for [dt] seconds of play (T-14).
  void tick(double dt) {
    if (dt <= 0) return;
    s.earn(passive() * dt);
    s.playSeconds += dt;
    s.lifetime.secondsPlayed += dt;
  }

  /// R-WYPLATA-1: what a graded tap pays.
  double hitPayout(Grade g, {double combo = 1, double mode = 1}) {
    if (!g.isHit) return 0;
    final t = b.tier(g.tier.name);
    final flat = t.reward * econ.strikePower() * globalMultiplier();
    final echo = econ.echoSeconds() * t.echoShare * passive();
    return (flat + echo) * combo * mode;
  }

  // ------------------------------------------------------------- shopping --

  BuyResult buyGenerators(String id, int count) {
    if (count <= 0 || !econ.generatorUnlocked(id)) return BuyResult.unavailable;
    if (!s.spend(econ.bulkCost(id, count))) return BuyResult.tooExpensive;
    s.owned[id] = econ.owned(id) + count;
    return BuyResult.ok;
  }

  BuyResult buyUpgrade(String id) {
    final u = econ.nextUpgrade(id);
    if (u == null || econ.owned(id) < u.threshold) return BuyResult.unavailable;
    if (!s.spend(u.cost)) return BuyResult.tooExpensive;
    s.upgrades[id] = u.index + 1;
    return BuyResult.ok;
  }

  BuyResult buySynergy(String id) {
    final syn = econ.availableSynergies().where((x) => x.id == id).firstOrNull;
    if (syn == null) return BuyResult.unavailable;
    if (!s.spend(syn.cost)) return BuyResult.tooExpensive;
    s.synergies.add(id);
    return BuyResult.ok;
  }

  BuyResult buySkill(String id) {
    final cost = econ.skillCost(id);
    if (cost == null) return BuyResult.unavailable;
    if (!s.spend(cost)) return BuyResult.tooExpensive;
    s.skills[id] = econ.level(id) + 1;
    return BuyResult.ok;
  }

  // --------------------------------------------------------------- offline --

  double offlineCapSeconds() {
    var hours = b.offline.capHours;
    for (final id in ['longNap1', 'longNap2']) {
      if (s.perks.contains(id)) {
        hours = math.max(hours, b.perk(id).params['capHours']!);
      }
    }
    return hours * 3600;
  }

  double offlineEfficiency() {
    var e = b.offline.efficiency;
    for (final id in ['deepSleep1', 'deepSleep2']) {
      if (s.perks.contains(id)) {
        e = math.max(e, b.perk(id).params['efficiency']!);
      }
    }
    return e;
  }

  /// Income for the time since [GameState.lastSeenMs] (R-OFF-1, R-OFF-3).
  /// Null when there is nothing to report. Does not credit it.
  OfflineReport? offlineSince(int nowMs) {
    if (s.lastSeenMs <= 0) return null;
    final away = (nowMs - s.lastSeenMs) / 1000;
    if (away < b.offline.minAwaySeconds) return null; // also clock set back
    final counted = math.min(away, offlineCapSeconds());
    final amount = econ.passive() * counted * offlineEfficiency();
    if (amount <= 0) return null;
    return OfflineReport(away, counted, amount);
  }

  void claimOffline(OfflineReport r, {double multiplier = 1}) =>
      s.earn(r.amount * multiplier);
}
