import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/rewarded_ads.dart';

/// Google's public test unit (docs/05 T-28). Release builds pass the real
/// one with `--dart-define=ADMOB_REWARDED_ID=…`; without it nobody can click
/// a real ad by accident.
const _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
const _rewardedId = String.fromEnvironment(
  'ADMOB_REWARDED_ID',
  defaultValue: _testRewardedId,
);

RewardedAds createRewardedAds() =>
    defaultTargetPlatform == TargetPlatform.android
    ? (AdMobRewardedAds(unitId: _rewardedId)..start())
    : FakeRewardedAds();

/// Rewarded ads from AdMob behind the game's [RewardedAds] door (T-26).
/// At launch it only checks whether consent is needed (UMP asks for that
/// on every launch); the consent form waits for [askConsentIfNeeded],
/// after the tutorial. Keeps one ad loaded, replaces it before AdMob's
/// one-hour limit, and reports not ready instead of making anyone wait
/// (T-27).
class AdMobRewardedAds implements RewardedAds, AdPrivacy {
  AdMobRewardedAds({required this.unitId});

  final String unitId;

  /// A loaded ad is good for about an hour; one shown later may fail or not
  /// count. Replaced a little before.
  static const adLifetime = Duration(minutes: 55);

  RewardedAd? _adValue;
  RewardedAd? get _ad => _adValue;
  set _ad(RewardedAd? v) {
    _adValue = v;
    _notify();
  }

  Timer? _expiry;

  final _changes = StreamController<bool>.broadcast();

  /// This launch's consent check, before anything else.
  bool _starting = true;
  final _checked = Completer<void>();

  @override
  bool get isLoading => _ad == null && (_starting || _loading);

  (bool, bool) _last = (false, true);
  void _notify() {
    final now = (isReady, isLoading);
    if (now == _last) return;
    _last = now;
    _changes.add(isReady);
  }

  @override
  Stream<bool> get readiness => _changes.stream;
  bool _loadingValue = false;
  bool get _loading => _loadingValue;
  set _loading(bool v) {
    _loadingValue = v;
    _notify();
  }

  bool _canRequest = false;
  bool _initialized = false;
  int _failures = 0;

  /// The consent check (no form), then the SDK when consent is already
  /// there or not needed. Never throws; without consent or network the
  /// offers simply stay greyed out.
  Future<void> start() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (_) => updated.complete(),
      );
      await updated.future;
      await _startIfAllowed();
    } on Object catch (e) {
      debugPrint('ads unavailable: $e');
    } finally {
      _starting = false;
      if (!_checked.isCompleted) _checked.complete();
      _notify();
    }
  }

  Future<void> _startIfAllowed() async {
    _canRequest = await ConsentInformation.instance.canRequestAds();
    if (!_canRequest) return;
    if (!_initialized) {
      await MobileAds.instance.initialize();
      _initialized = true;
    }
    _load();
  }

  @override
  Future<bool?> consentRequired() async {
    await _checked.future;
    try {
      return switch (await ConsentInformation.instance.getConsentStatus()) {
        ConsentStatus.notRequired => false,
        ConsentStatus.required || ConsentStatus.obtained => true,
        _ => null,
      };
    } on Object {
      return null;
    }
  }

  @override
  Future<void> askConsentIfNeeded() async {
    await _checked.future;
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      await _startIfAllowed();
    } on Object catch (e) {
      debugPrint('consent form failed: $e');
    }
  }

  void _load() {
    if (_loading || _ad != null || !_canRequest || !_initialized) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          _failures = 0;
          _expiry?.cancel();
          _expiry = Timer(adLifetime, () {
            if (_ad != ad) return;
            _ad = null;
            ad.dispose();
            _load();
          });
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _failures++;
          // Back off: 15 s, 60 s, 135 s … up to 5 min.
          final wait = math.min(300, 15 * _failures * _failures);
          Timer(Duration(seconds: wait), _load);
        },
      ),
    );
  }

  @override
  bool get isReady => _ad != null;

  @override
  Future<AdResult> show() async {
    final ad = _ad;
    if (ad == null) {
      _load();
      return AdResult.failed;
    }
    _ad = null;
    _expiry?.cancel();
    var earned = false;
    var closed = false;
    final done = Completer<AdResult>();
    void finish(Ad a, {bool failed = false}) {
      closed = true;
      a.dispose();
      _load();
      if (done.isCompleted) return;
      if (earned) {
        done.complete(AdResult.earned);
        return;
      }
      if (failed) {
        done.complete(AdResult.failed);
        return;
      }
      // On some devices the reward callback lands just after the ad is
      // closed: wait a moment for it before calling the ad unwatched
      // (playtest 25: a watched rescue gave nothing).
      Timer(const Duration(milliseconds: 1500), () {
        if (!done.isCompleted) {
          done.complete(earned ? AdResult.earned : AdResult.closedEarly);
        }
      });
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: finish,
      onAdFailedToShowFullScreenContent: (a, _) => finish(a, failed: true),
    );
    try {
      // R-AD-3: the reward counts only once the network says it was earned.
      await ad.show(
        onUserEarnedReward: (_, _) {
          earned = true;
          // Late reward: the ad is already closed and waiting for it.
          if (closed && !done.isCompleted) done.complete(AdResult.earned);
        },
      );
    } on Object catch (e) {
      debugPrint('ad show failed: $e');
      finish(ad, failed: true);
    }
    return done.future;
  }

  @override
  Future<bool> optionsRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> showOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
      await _startIfAllowed();
    } on Object catch (e) {
      debugPrint('privacy options failed: $e');
    }
  }
}
