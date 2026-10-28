import '../ads/rewarded_ads.dart';

/// No ad network on this platform: the stand-in grants rewards.
RewardedAds createRewardedAds() => FakeRewardedAds();
