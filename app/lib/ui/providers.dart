import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads/rewarded_ads.dart';
import '../balance/balance.dart';

/// Loaded once in `main` and injected with an override, so everything below
/// can read it synchronously.
final balanceProvider = Provider<Balance>(
  (ref) => throw UnimplementedError('balanceProvider must be overridden'),
);

final rewardedAdsProvider = Provider<RewardedAds>((ref) => FakeRewardedAds());
