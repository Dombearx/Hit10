import 'dart:async';

/// How an ad ended (R-AD-3, R-AD-8).
enum AdResult {
  /// Watched to the end: the reward is earned.
  earned,

  /// The player closed it early: no reward.
  closedEarly,

  /// It could not be shown (expired, network, no fill): no reward, and the
  /// player did nothing wrong.
  failed,
}

/// The only door between the game and an ad network (docs/05-technika.md
/// T-25). Screens and the engine depend on this interface; the real AdMob
/// implementation arrives in M6.
abstract interface class RewardedAds {
  /// Whether an ad can be shown right now without waiting.
  bool get isReady;

  /// No ad yet, but one is on its way (consent, SDK start, a load in
  /// progress): buttons show a spinner instead of looking broken.
  bool get isLoading;

  /// Emits whenever [isReady] or [isLoading] changes (an ad finished
  /// loading, or was used): screens that show an ad button without
  /// rebuilding otherwise, like the offline summary, listen to it.
  Stream<bool> get readiness;

  /// Shows an ad; [AdResult.earned] only when the player watched it to the
  /// end. Never throws.
  Future<AdResult> show();
}

/// Stand-in used until M6 and in tests: ready unless told otherwise,
/// "plays" for [delay] and grants the reward.
class FakeRewardedAds implements RewardedAds {
  FakeRewardedAds({
    this.delay = const Duration(seconds: 1),
    this.grant = true,
    this._ready = true,
    this._loading = false,
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

  bool _loading;

  @override
  bool get isLoading => !_ready && _loading;

  /// Tests: a load starts or gives up.
  set loading(bool v) {
    if (v == _loading) return;
    _loading = v;
    _changes.add(_ready);
  }

  @override
  Stream<bool> get readiness => _changes.stream;

  /// Set to make the next ads fail to show (tests).
  bool failToShow = false;

  @override
  Future<AdResult> show() async {
    shown++;
    await Future<void>.delayed(delay);
    if (failToShow) return AdResult.failed;
    return grant ? AdResult.earned : AdResult.closedEarly;
  }
}

/// Implemented by ad networks that need a consent form (UMP, EU): the
/// settings show a "privacy options" entry while [optionsRequired] is true.
abstract interface class AdPrivacy {
  Future<bool> optionsRequired();

  Future<void> showOptions();

  /// Whether the law asks for consent where the player is (EEA, UK): true,
  /// false, or null when it could not be checked (no network). Waits for
  /// this launch's consent check (docs/05 T-33).
  Future<bool?> consentRequired();

  /// Shows the consent form if it is needed and not answered yet, then
  /// starts the ads. Called after the tutorial, not at launch (docs/02
  /// R-AD-6, R-TUT-0): the first seconds belong to the game.
  Future<void> askConsentIfNeeded();
}
