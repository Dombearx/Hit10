import 'package:flutter/services.dart';

import '../model/grading.dart';

/// Vibrations from the effects table (docs/04 §3). Off when the player
/// disables them.
class Haptics {
  bool enabled = true;

  /// Purchases.
  Future<void> light() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  /// A new generator, an achievement.
  Future<void> medium() async {
    if (enabled) await HapticFeedback.mediumImpact();
  }

  /// The time paradox: a long rumble.
  Future<void> long() async {
    if (!enabled) return;
    for (var i = 0; i < 5; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<void> forTier(Tier tier) async {
    if (!enabled) return;
    switch (tier) {
      case Tier.perfect:
        await HapticFeedback.heavyImpact();
      case Tier.great:
        await HapticFeedback.mediumImpact();
      case Tier.good:
        await HapticFeedback.lightImpact();
      case Tier.miss:
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 90));
        await HapticFeedback.lightImpact();
    }
  }
}
