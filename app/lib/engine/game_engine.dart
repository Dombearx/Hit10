import 'dart:math' as math;

import '../balance/balance.dart';
import '../model/economy.dart';
import '../model/game_state.dart';
import '../model/grading.dart';
import '../model/seasons.dart';

enum BuyResult { ok, tooExpensive, unavailable }

enum GoldenEffect { frenzy, lucky, hotHand }

/// What a golden round gave (R-ZLOTA-2/3).
class GoldenOutcome {
  const GoldenOutcome(this.effect, this.strength, this.amount);
  final GoldenEffect? effect; // null = "it escaped!" (miss)
  final double strength;

  /// Seconds of effect for Frenzy/Hot hand, Tiki for Lucky.
  final double amount;
}

/// Everything that happened when a round was graded (docs/02 §3).
class RoundOutcome {
  const RoundOutcome({
    required this.raw,
    required this.tier,
    required this.payout,
    required this.combo,
    required this.streak,
    required this.streakBefore,
    required this.comboBroken,
    required this.shieldUsed,
    required this.bumpedByLuck,
    required this.hotHand,
    this.golden,
    this.jackpot = 0,
  });

  /// The grade before Luck / Hot hand.
  final Grade raw;
  final Tier tier;
  final double payout;
  final double combo;
  final int streak;
  final int streakBefore;
  final bool comboBroken;
  final bool shieldUsed;
  final bool bumpedByLuck;
  final bool hotHand;
  final GoldenOutcome? golden;

  /// Tiki of the 10.00 jackpot in [payout] (0 = none).
  final double jackpot;
}

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
  GameEngine(this.b, this.s, {math.Random? random})
    : econ = Economy(b, s),
      rng = random ?? math.Random() {
    if (s.goldenNextAt <= s.playSeconds) _scheduleGolden();
  }

  final Balance b;
  final GameState s;
  final Economy econ;
  final math.Random rng;

  /// Temporary global multipliers. [frenzy] follows the golden-second effect;
  /// [turbo] is set by the ad offers (M4).
  double frenzy = 1;
  double turbo = 1;

  // --------------------------------------------------------- golden second --

  /// Golden seconds are off during the tutorial (R-ZLOTA-5).
  bool goldenEnabled = true;

  /// Seconds left of the visible golden clock; 0 = none on screen.
  double goldenVisibleLeft = 0;

  /// The player caught the clock: the next round is golden.
  bool goldenArmed = false;

  /// The round in progress is golden.
  bool goldenRound = false;

  double frenzyLeft = 0;
  double hotHandLeft = 0;

  void _scheduleGolden() {
    final g = b.golden;
    var interval =
        g.intervalMin + rng.nextDouble() * (g.intervalMax - g.intervalMin);
    interval *= econ.goldenIntervalFactor();
    if (s.perks.contains('goldRush')) {
      interval *= b.perk('goldRush').params['intervalMultiplier']!;
    }
    s.goldenNextAt = s.playSeconds + interval;
  }

  /// Advances golden-second and effect timers by [dt] seconds of play.
  /// Returns true when a golden clock just appeared.
  bool updateEffects(double dt) {
    frenzyLeft = math.max(0, frenzyLeft - dt);
    hotHandLeft = math.max(0, hotHandLeft - dt);
    frenzy = frenzyLeft > 0 ? b.golden.effect('frenzy').multiplier : 1;
    if (goldenVisibleLeft > 0) {
      goldenVisibleLeft = math.max(0, goldenVisibleLeft - dt);
      if (goldenVisibleLeft == 0) _scheduleGolden(); // it flew away
      return false;
    }
    if (!goldenEnabled || goldenArmed || goldenRound) return false;
    if (s.playSeconds >= s.goldenNextAt) {
      goldenVisibleLeft = b.golden.visibleFor;
      return true;
    }
    return false;
  }

  /// The player tapped the flying golden clock.
  bool claimGolden() {
    if (goldenVisibleLeft <= 0) return false;
    goldenVisibleLeft = 0;
    goldenArmed = true;
    if (_seasonRunning) {
      s.seasonCatches++;
      _checkSeasonGoal();
    }
    return true;
  }

  // ------------------------------------------------------------- seasons --

  /// The calendar event running now (docs/02 §14), set by the controller
  /// from the local date.
  Season? season;

  /// Tiki paid when the season's goal was reached; the UI shows it once
  /// and clears it.
  double? seasonRewardPaid;

  /// Switches to [se]; a new run of a season counts from zero, one seen
  /// before picks up where it was.
  void setSeason(Season? se) {
    season = se;
    if (se != null && s.seasonKey != se.key) {
      if (s.seasonKey.isNotEmpty && !s.seasonsDone.contains(s.seasonKey)) {
        s.seasonStash[s.seasonKey] = [s.seasonCatches, s.seasonHits];
      }
      final back = s.seasonStash.remove(se.key);
      s
        ..seasonKey = se.key
        ..seasonCatches = back?[0] ?? 0
        ..seasonHits = back?[1] ?? 0;
    }
  }

  bool get seasonDone => season != null && s.seasonsDone.contains(season!.key);

  bool get _seasonRunning => season != null && !seasonDone;

  /// What finishing the season pays: minutes of passive income.
  double seasonReward() {
    final c = b.seasons;
    return math.max(c.rewardFloor, passive() * 60 * c.rewardMinutes);
  }

  void _checkSeasonGoal() {
    final c = b.seasons;
    if (s.seasonCatches < c.catches || s.seasonHits < c.hits) return;
    final amount = seasonReward();
    s.seasonsDone.add(season!.key);
    s.earn(amount);
    seasonRewardPaid = amount;
  }

  /// Ad offer "Golden second now" (R-AD): show the clock immediately.
  void summonGolden() {
    if (goldenVisibleLeft > 0 || goldenArmed || goldenRound) return;
    goldenVisibleLeft = b.golden.visibleFor;
  }

  void onRoundStart() {
    if (goldenArmed) {
      goldenArmed = false;
      goldenRound = true;
    }
  }

  /// A round was abandoned (pause): an armed golden round stays armed.
  void onRoundCancelled() {
    if (goldenRound) {
      goldenRound = false;
      goldenArmed = true;
    }
  }

  GoldenOutcome _resolveGolden(Tier tier) {
    _scheduleGolden();
    if (tier == Tier.miss) return const GoldenOutcome(null, 0, 0);
    s.lifetime.goldenCaught++;
    final strength =
        b.golden.tierStrength[tier.name]! * econ.goldenStrengthFactor();
    final total = b.golden.effects.fold<double>(0, (a, e) => a + e.weight);
    var r = rng.nextDouble() * total;
    var pick = b.golden.effects.last;
    for (final e in b.golden.effects) {
      r -= e.weight;
      if (r < 0) {
        pick = e;
        break;
      }
    }
    switch (pick.id) {
      case 'frenzy':
        final secs = pick.duration * strength;
        frenzyLeft += secs; // the same effect again extends it (R-ZLOTA-4)
        frenzy = pick.multiplier;
        return GoldenOutcome(GoldenEffect.frenzy, strength, secs);
      case 'lucky':
        final amount =
            strength *
            math.min(
              passive() * pick.productionSeconds,
              s.tiki * pick.bankFraction,
            );
        s.earn(amount);
        return GoldenOutcome(GoldenEffect.lucky, strength, amount);
      default:
        final secs = pick.duration * strength;
        hotHandLeft += secs;
        return GoldenOutcome(GoldenEffect.hotHand, strength, secs);
    }
  }

  // ------------------------------------------------------------ the round --

  /// Applies Luck, Hot hand, the combo and the Shield, pays out and records
  /// statistics (docs/02 §2–§3, §6). [mode] is the risk-mode multiplier.
  RoundOutcome resolveRound(Grade g, {double mode = 1}) {
    // No touch at all is a skipped round, not a miss (playtest 08): looking
    // at the shop or putting the phone down costs nothing but the round.
    if (g.missKind == MissKind.noTap) {
      s.lifetime.missedInARow++;
      GoldenOutcome? golden;
      if (goldenRound) {
        goldenRound = false;
        golden = _resolveGolden(Tier.miss);
      }
      final combo = 1 + b.combo.multiplierPerStep * s.comboStreak;
      return RoundOutcome(
        raw: g,
        tier: Tier.miss,
        payout: 0,
        combo: combo,
        streak: s.comboStreak,
        streakBefore: s.comboStreak,
        comboBroken: false,
        shieldUsed: false,
        bumpedByLuck: false,
        hotHand: false,
        golden: golden,
      );
    }
    var tier = g.tier;
    var bumped = false;
    final hot = hotHandLeft > 0 && tier != Tier.miss;
    if (hot) {
      tier = Tier.perfect;
    } else if ((tier == Tier.great || tier == Tier.good) &&
        rng.nextDouble() < econ.luckChance()) {
      tier = tier == Tier.great ? Tier.perfect : Tier.great;
      bumped = true;
    }
    if (tier != Tier.miss && _seasonRunning) {
      s.seasonHits++;
      _checkSeasonGoal();
    }
    final before = s.comboStreak;
    var broken = false;
    var shieldUsed = false;
    if (tier == Tier.miss) {
      if (s.shieldCharges > 0 && before > 0) {
        s.shieldCharges--;
        shieldUsed = true;
      } else {
        final floor = s.perks.contains('comboFloor')
            ? b.perk('comboFloor').params['floor']!.round()
            : 0;
        s.comboStreak = math.min(before, floor);
        broken = before > s.comboStreak;
      }
    } else {
      final step = b.tier(tier.name).comboStep;
      s.comboStreak = math.min(econ.comboCap(), before + step);
      s.shieldProgress += step;
      while (s.shieldProgress >= b.combo.shieldRechargeSteps) {
        s.shieldProgress -= b.combo.shieldRechargeSteps;
        s.shieldCharges = math.min(maxShieldCharges(), s.shieldCharges + 1);
      }
    }
    final combo = 1 + b.combo.multiplierPerStep * s.comboStreak;
    // The 10.00 jackpot goes by the raw tap: Luck and Hot hand don't win it.
    final jackpot = isJackpot(g) ? jackpotAmount() * combo * mode : 0.0;
    final payout =
        hitPayout(
          Grade(tier, g.error, g.missKind, g.close),
          combo: combo,
          mode: mode,
        ) +
        jackpot;
    s.earn(payout);
    _recordStats(g, tier);
    GoldenOutcome? golden;
    if (goldenRound) {
      goldenRound = false;
      golden = _resolveGolden(tier);
    }
    return RoundOutcome(
      raw: g,
      tier: tier,
      payout: payout,
      combo: combo,
      streak: s.comboStreak,
      streakBefore: before,
      comboBroken: broken,
      shieldUsed: shieldUsed,
      bumpedByLuck: bumped,
      hotHand: hot,
      golden: golden,
      jackpot: jackpot,
    );
  }

  /// A tap that shows 10.00 on the dial (docs/02 §2): within the jackpot
  /// window whatever skills widen the PERFECT window.
  bool isJackpot(Grade g) =>
      g.tier == Tier.perfect && g.error.abs() < b.jackpot.window;

  /// The jackpot before combo and mode: seconds of the clocks' income, at
  /// least a few base PERFECTs (so it counts from the first minute).
  double jackpotAmount() {
    final j = b.jackpot;
    final perfect =
        b.tier('perfect').reward *
        econ.strikePower() *
        globalMultiplier() *
        econ.beginnerPay();
    return math.max(
      j.productionSeconds * passive(),
      j.perfectMultiple * perfect,
    );
  }

  /// Shield level plus the "shield at start" perk (docs/02 §9.1).
  int maxShieldCharges() {
    var n = econ.shieldCharges();
    if (s.perks.contains('startShield')) {
      n = math.max(n, b.perk('startShield').params['charges']!.round());
    }
    return n;
  }

  void _recordStats(Grade raw, Tier tier) {
    s.stats.record(Grade(tier, raw.error, raw.missKind), tapped: true);
    final l = s.lifetime;
    if (tier == Tier.perfect) {
      l.perfects++;
      l.perfectStreak++;
      l.bestPerfectStreak = math.max(l.bestPerfectStreak, l.perfectStreak);
    } else {
      l.perfectStreak = 0;
    }
    l.bestCombo = math.max(l.bestCombo, s.comboStreak);
    if (raw.missKind == MissKind.early) l.earlyTaps++;
    l.missedInARow = 0;
  }

  double passive() => econ.passive(frenzy: frenzy, turbo: turbo);

  /// Global multiplier G for hit rewards (docs/03 §2).
  double globalMultiplier() => econ.permanentMultiplier() * frenzy * turbo;

  /// Earns passive income for [dt] seconds of play (T-14).
  void tick(double dt) {
    if (dt <= 0) return;
    updateEffects(dt);
    s.earn(passive() * dt);
    s.playSeconds += dt;
    s.lifetime.secondsPlayed += dt;
  }

  /// R-WYPLATA-1: what a graded tap pays.
  double hitPayout(Grade g, {double combo = 1, double mode = 1}) {
    if (!g.isHit) {
      // BLISKO: a small consolation, no echo (docs/02 §2).
      if (!g.close) return 0;
      // Beginner's luck lifts BLISKO towards a GOOD (playtest: imprecise
      // players waited minutes for the first grandpa).
      final reward =
          b.close.reward +
          (b.beginner.closeReward - b.close.reward) * econ.beginnerShare;
      return reward *
          econ.strikePower() *
          globalMultiplier() *
          econ.beginnerPay() *
          combo *
          mode;
    }
    final t = b.tier(g.tier.name);
    final flat =
        t.reward * econ.strikePower() * globalMultiplier() * econ.beginnerPay();
    final echo = econ.echoSeconds() * t.echoShare * passive();
    return (flat + echo) * combo * mode;
  }

  /// What a [tier] hit would pay on the next tap: the combo after that
  /// hit's step and the risk mode on now. A PERFECT is priced as a 10.00,
  /// jackpot included (the header's "10.00 = +X").
  double nextHitPayout(Tier tier) {
    final step = b.tier(tier.name).comboStep;
    final streak = math.min(econ.comboCap(), s.comboStreak + step);
    final combo = 1 + b.combo.multiplierPerStep * streak;
    final mode = modeMultiplier();
    final jackpot = tier == Tier.perfect ? jackpotAmount() * combo * mode : 0;
    return hitPayout(Grade(tier, 0), combo: combo, mode: mode) + jackpot;
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
    // A new Shield level arrives charged.
    if (id == 'shield') s.shieldCharges = maxShieldCharges();
    // Golden Touch shortens the wait right away.
    if (id == 'goldenTouch' && goldenVisibleLeft == 0 && !goldenArmed) {
      final before = s.goldenNextAt;
      _scheduleGolden();
      s.goldenNextAt = math.min(before, s.goldenNextAt);
    }
    return BuyResult.ok;
  }

  // ----------------------------------------------------------- risk modes --

  bool blindUnlocked() =>
      s.perks.contains('earlyModes') ||
      s.lifetime.perfects >= b.blind.unlockPerfects;

  bool get blindActive => s.modeBlind && blindUnlocked();

  /// Reward multiplier of the mode switched on (R-TRYB-1).
  double modeMultiplier() => blindActive ? b.blind.rewardMultiplier : 1;

  /// "Dziesiątka": counts perfects made on a 10th of the month.
  void recordPerfectDate(DateTime local) {
    final key = local.year * 10000 + local.month * 100 + local.day;
    final l = s.lifetime;
    if (l.tenthDayKey != key) {
      l.tenthDayKey = key;
      l.tenthDayPerfects = 0;
    }
    if (local.day == 10) l.tenthDayPerfects++;
  }

  // ------------------------------------------------------------- prestige --

  bool canPrestige() => econ.prestigeGain() >= 1;

  /// Time paradox (R-PRES-1…5): converts lifetime Tiki into Chronons and
  /// Shards, resets the run, keeps what the perks keep. Returns the gain.
  int prestige() {
    final gain = econ.prestigeGain();
    if (gain < 1) return 0;
    s.chronons += gain;
    s.shards += gain;
    s.prestiges++;
    final kept = <String, int>{};
    final skills = Map<String, int>.of(s.skills);
    if (s.perks.contains('muscleMemory1')) {
      kept['fastForward'] = skills['fastForward'] ?? 0;
    }
    if (s.perks.contains('muscleMemory2')) {
      kept['wideEye'] = skills['wideEye'] ?? 0;
      kept['magnet'] = skills['magnet'] ?? 0;
    }
    if (s.perks.contains('muscleMemory3')) {
      for (final e in skills.entries) {
        kept.putIfAbsent(e.key, () => e.value ~/ 2);
      }
    }
    s
      ..tiki = 0
      ..earnedThisRun = 0
      ..peakTiki = 0
      ..comboStreak = 0
      ..shieldProgress = 0;
    s.owned.clear();
    s.upgrades.clear();
    s.synergies.clear();
    s.skills
      ..clear()
      ..addAll(kept..removeWhere((_, v) => v <= 0));
    if (s.perks.contains('headStart')) {
      final p = b.perk('headStart').params;
      s.owned['grandpa'] = p['grandpas']!.round();
      s.tiki = p['tiki']!;
      s.peakTiki = s.tiki;
    }
    s.shieldCharges = maxShieldCharges();
    goldenVisibleLeft = 0;
    goldenArmed = false;
    goldenRound = false;
    frenzyLeft = 0;
    hotHandLeft = 0;
    frenzy = 1;
    _scheduleGolden();
    return gain;
  }

  /// Perk can be bought now: not owned, prerequisite owned, enough Shards.
  bool perkAvailable(String id) {
    final p = b.perk(id);
    if (s.perks.contains(id)) return false;
    if (p.requires != null && !s.perks.contains(p.requires)) return false;
    return true;
  }

  BuyResult buyPerk(String id) {
    if (!perkAvailable(id)) return BuyResult.unavailable;
    final cost = b.perk(id).cost;
    if (s.shards < cost) return BuyResult.tooExpensive;
    s.shards -= cost;
    s.perks.add(id);
    if (id == 'startShield') s.shieldCharges = maxShieldCharges();
    return BuyResult.ok;
  }

  // ----------------------------------------------------------- auto buyer --

  double _autoBuyAcc = 0;

  /// The "automatic buyer" perk buys the cheapest affordable generator
  /// every few seconds when switched on. Returns the id bought, if any.
  String? autoBuy(double dt) {
    if (!s.perks.contains('autoBuyer') || !s.autoBuyerOn) return null;
    _autoBuyAcc += dt;
    final every = b.perk('autoBuyer').params['intervalSeconds']!;
    if (_autoBuyAcc < every) return null;
    _autoBuyAcc = 0;
    String? best;
    var bestCost = double.infinity;
    for (var i = 0; i < b.generators.length; i++) {
      final g = b.generators[i];
      if (!econ.generatorUnlocked(g.id)) continue;
      // Only what the shop shows: owned, or the next one in line.
      if (i > 0 && econ.owned(b.generators[i - 1].id) == 0) break;
      final c = econ.generatorCost(g.id);
      if (c < bestCost) {
        bestCost = c;
        best = g.id;
      }
    }
    if (best == null || bestCost > s.tiki) return null;
    return buyGenerators(best, 1) == BuyResult.ok ? best : null;
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

  /// Today's daily bonus, or null when already claimed today or the
  /// tutorial isn't done (playtest 08). [now] is local time.
  DailyBonus? dailyFor(DateTime now) {
    if (!s.tutorialDone) return null;
    final key = dateKey(now);
    if (key == s.dailyKey) return null;
    final yesterday = dateKey(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
    );
    final days = b.daily.minutes.length;
    final day = s.dailyKey == yesterday ? s.dailyStreak % days + 1 : 1;
    final amount = math.max(
      b.daily.floorPerDay * day,
      passive() * 60 * b.daily.minutes[day - 1],
    );
    return DailyBonus(key, day, amount);
  }

  void claimDaily(DailyBonus d) {
    s.earn(d.amount);
    s.dailyKey = d.key;
    s.dailyStreak = d.day;
  }

  void claimOffline(OfflineReport r, {double multiplier = 1}) =>
      s.earn(r.amount * multiplier);
}

/// yyyymmdd of a local date.
int dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// The daily bonus on offer: streak [day] (1–7) pays [amount].
class DailyBonus {
  const DailyBonus(this.key, this.day, this.amount);
  final int key;
  final int day;
  final double amount;
}
