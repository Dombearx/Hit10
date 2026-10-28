import 'dart:math' as math;

import '../balance/balance.dart';
import '../model/game_state.dart';
import 'game_engine.dart';

enum AdOffer { offline, turbo, bag, rescue, golden }

/// A combo-rescue offer waiting for the player (R-AD, `adRescue`).
class RescueOffer {
  const RescueOffer(this.streak, this.expiresAtPlay);
  final int streak;
  final double expiresAtPlay;
}

/// Rules of the five rewarded offers (docs/02 §13). Showing the ad is the
/// UI's job (RewardedAds); this decides when an offer exists and grants it.
class AdOffers {
  AdOffers(this.e);

  final GameEngine e;
  GameState get s => e.s;
  AdsConfig get cfg => e.b.ads;

  RescueOffer? rescue;

  /// R-AD-5: nothing before the tutorial is done and a few minutes played.
  bool get unlocked =>
      s.tutorialDone && s.playSeconds >= cfg.unlockAfterSeconds;

  int cooldownLeftMs(AdOffer o, int nowMs) =>
      math.max(0, (s.adCooldownUntil[o.name] ?? 0) - nowMs);

  double _cooldownSeconds(AdOffer o) => switch (o) {
    AdOffer.bag => cfg.bagCooldown,
    AdOffer.rescue => cfg.rescueCooldown,
    AdOffer.golden => cfg.goldenCooldown,
    AdOffer.turbo => cfg.turboCooldown,
    _ => 0,
  };

  /// Whether the offer can be taken right now (ignoring ad availability).
  bool available(AdOffer o, int nowMs) {
    if (!unlocked) return false;
    if (cooldownLeftMs(o, nowMs) > 0) return false;
    return switch (o) {
      AdOffer.offline => true,
      AdOffer.turbo => s.turboLeft + cfg.turboDuration <= cfg.turboMaxStock,
      AdOffer.bag => e.passive() > 0,
      AdOffer.golden =>
        e.goldenVisibleLeft == 0 && !e.goldenArmed && !e.goldenRound,
      AdOffer.rescue => rescue != null && s.playSeconds < rescue!.expiresAtPlay,
    };
  }

  /// After a graded round: offer a rescue for a big lost streak.
  void onRound(RoundOutcome o, int nowMs) {
    rescue = null; // any next tap dismisses a pending offer
    if (o.comboBroken &&
        o.streakBefore >= cfg.rescueMinStreak &&
        unlocked &&
        cooldownLeftMs(AdOffer.rescue, nowMs) == 0) {
      rescue = RescueOffer(
        o.streakBefore,
        s.playSeconds + cfg.rescueOfferSeconds,
      );
    }
  }

  /// Turbo drains only while playing (R-AD-1) and feeds G (R-AD-2).
  void tick(double dt) {
    if (s.turboLeft > 0) s.turboLeft = math.max(0, s.turboLeft - dt);
    e.turbo = s.turboLeft > 0 ? cfg.turboMultiplier : 1;
    final r = rescue;
    if (r != null && s.playSeconds >= r.expiresAtPlay) rescue = null;
  }

  /// Grants the reward after a fully watched ad (R-AD-3). [offlineAmount]
  /// is the pending offline income for [AdOffer.offline]. Returns Tiki
  /// granted (bag, offline) or 0.
  double grant(AdOffer o, int nowMs, {double offlineAmount = 0}) {
    final cd = _cooldownSeconds(o);
    if (cd > 0) s.adCooldownUntil[o.name] = nowMs + (cd * 1000).round();
    switch (o) {
      case AdOffer.offline:
        final extra = offlineAmount * (cfg.offlineMultiplier - 1);
        s.earn(extra);
        return extra;
      case AdOffer.turbo:
        s.turboLeft = math.min(
          cfg.turboMaxStock,
          s.turboLeft + cfg.turboDuration,
        );
        e.turbo = cfg.turboMultiplier;
        return 0;
      case AdOffer.bag:
        final f = e.frenzy, t = e.turbo;
        e
          ..frenzy = 1
          ..turbo = 1;
        final amount = e.passive() * cfg.bagProductionSeconds;
        e
          ..frenzy = f
          ..turbo = t;
        s.earn(amount);
        return amount;
      case AdOffer.rescue:
        final r = rescue;
        if (r != null) s.comboStreak = math.max(s.comboStreak, r.streak);
        rescue = null;
        return 0;
      case AdOffer.golden:
        e.summonGolden();
        return 0;
    }
  }
}
