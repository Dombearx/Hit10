import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads/rewarded_ads.dart';
import '../balance/balance.dart';
import 'game_controller.dart';

/// Loaded once in `main` and injected with an override, so everything below
/// can read it synchronously.
final balanceProvider = Provider<Balance>(
  (ref) => throw UnimplementedError('balanceProvider must be overridden'),
);

final gameControllerProvider = Provider<GameController>(
  (ref) =>
      throw UnimplementedError('gameControllerProvider must be overridden'),
);

final rewardedAdsProvider = Provider<RewardedAds>((ref) => FakeRewardedAds());

/// Restarts the app from the saved state (after an import or a reset).
final restartProvider = Provider<Future<void> Function()>((ref) => () async {});
