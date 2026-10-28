import 'package:flutter/services.dart';

import '../model/grading.dart';

/// Vibration per hit tier (docs/04 §3). Off when the player disables it.
class Haptics {
  bool enabled = true;

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
