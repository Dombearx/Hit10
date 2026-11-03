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
/// Asks for consent first (UMP), keeps one ad loaded, and reports not
/// ready instead of making anyone wait (T-27).
class AdMobRewardedAds implements RewardedAds, AdPrivacy {
  AdMobRewardedAds({required this.unitId});

  final String unitId;
  RewardedAd? _adValue;
  RewardedAd? get _ad => _adValue;
  set _ad(RewardedAd? v) {
    _adValue = v;
    _notify();
  }

  final _changes = StreamController<bool>.broadcast();

  /// Consent and SDK start, before the first load.
  bool _starting = true;

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
  int _failures = 0;

  /// Consent, SDK start, first load. Never throws; without consent or
  /// network the offers simply stay greyed out.
  Future<void> start() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (_) => updated.complete(),
      );
      await updated.future;
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      _canRequest = await ConsentInformation.instance.canRequestAds();
      if (!_canRequest) return;
      await MobileAds.instance.initialize();
      _load();
    } on Object catch (e) {
      debugPrint('ads unavailable: $e');
    } finally {
      _starting = false;
      _notify();
    }
  }

  void _load() {
    if (_loading || _ad != null || !_canRequest) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          _failures = 0;
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
  Future<bool> show() async {
    final ad = _ad;
    if (ad == null) {
      _load();
      return false;
    }
    _ad = null;
    var earned = false;
    var closed = false;
    final done = Completer<bool>();
    void finish(Ad a, {bool failed = false}) {
      closed = true;
      a.dispose();
      _load();
      if (done.isCompleted) return;
      if (earned || failed) {
        done.complete(earned);
        return;
      }
      // On some devices the reward callback lands just after the ad is
      // closed: wait a moment for it before calling the ad unwatched
      // (playtest 25: a watched rescue gave nothing).
      Timer(const Duration(milliseconds: 1500), () {
        if (!done.isCompleted) done.complete(earned);
      });
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: finish,
      onAdFailedToShowFullScreenContent: (a, _) {
        earned = false;
        finish(a, failed: true);
      },
    );
    try {
      // R-AD-3: the reward counts only once the network says it was earned.
      await ad.show(
        onUserEarnedReward: (_, _) {
          earned = true;
          // Late reward: the ad is already closed and waiting for it.
          if (closed && !done.isCompleted) done.complete(true);
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
      _canRequest = await ConsentInformation.instance.canRequestAds();
      _load();
    } on Object catch (e) {
      debugPrint('privacy options failed: $e');
    }
  }
}
