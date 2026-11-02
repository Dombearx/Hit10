import 'dart:async';

/// The only door between the game and an ad network (docs/05-technika.md
/// T-25). Screens and the engine depend on this interface; the real AdMob
/// implementation arrives in M6.
abstract interface class RewardedAds {
  /// Whether an ad can be shown right now without waiting.
  bool get isReady;

  /// Emits [isReady] whenever it changes (an ad finished loading, or was
  /// used): screens that show an ad button without rebuilding otherwise,
  /// like the offline summary, listen to it.
  Stream<bool> get readiness;

  /// Shows an ad and completes with `true` only when the player earned the
  /// reward (watched to the end). Never throws.
  Future<bool> show();
}

/// Stand-in used until M6 and in tests: ready unless told otherwise,
/// "plays" for [delay] and grants the reward.
class FakeRewardedAds implements RewardedAds {
  FakeRewardedAds({
    this.delay = const Duration(seconds: 1),
    this.grant = true,
    this._ready = true,
  });

  final Duration delay;

  /// Set to false to simulate an interrupted ad.
  bool grant;

  int shown = 0;

  bool _ready;
  final _changes = StreamController<bool>.broadcast(sync: true);

  @override
  bool get isReady => _ready;

  /// Tests: an ad finishes loading (or goes away).
  set ready(bool v) {
    if (v == _ready) return;
    _ready = v;
    _changes.add(v);
  }

  @override
  Stream<bool> get readiness => _changes.stream;

  @override
  Future<bool> show() async {
    shown++;
    await Future<void>.delayed(delay);
    return grant;
  }
}

/// Implemented by ad networks that need a consent form (UMP, EU): the
/// settings show a "privacy options" entry while [optionsRequired] is true.
abstract interface class AdPrivacy {
  Future<bool> optionsRequired();

  Future<void> showOptions();
}
