/// The only door between the game and an ad network (docs/05-technika.md
/// T-25). Screens and the engine depend on this interface; the real AdMob
/// implementation arrives in M6.
abstract interface class RewardedAds {
  /// Whether an ad can be shown right now without waiting.
  bool get isReady;

  /// Shows an ad and completes with `true` only when the player earned the
  /// reward (watched to the end). Never throws.
  Future<bool> show();
}

/// Stand-in used until M6 and in tests: always ready, "plays" for [delay]
/// and grants the reward.
class FakeRewardedAds implements RewardedAds {
  FakeRewardedAds({this.delay = const Duration(seconds: 1), this.grant = true});

  final Duration delay;

  /// Set to false to simulate an interrupted ad.
  bool grant;

  int shown = 0;

  @override
  bool get isReady => true;

  @override
  Future<bool> show() async {
    shown++;
    await Future<void>.delayed(delay);
    return grant;
  }
}
