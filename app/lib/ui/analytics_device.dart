import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../analytics/analytics.dart';

// The Firebase project (docs/05 T-30). Release builds pass it with
// `--dart-define=FIREBASE_…`; without it nothing is sent, so the APKs we
// test on our own phones never mix into the players' statistics.
const _appId = String.fromEnvironment('FIREBASE_APP_ID');
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');

Future<Analytics> createAnalytics() async {
  if (defaultTargetPlatform != TargetPlatform.android || _appId.isEmpty) {
    return const NoAnalytics();
  }
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        appId: _appId,
        apiKey: _apiKey,
        projectId: _projectId,
        messagingSenderId: _senderId,
      ),
    );
    return FirebaseGameAnalytics(
      FirebaseAnalytics.instance,
      FirebaseCrashlytics.instance,
    );
  } on Object catch (e) {
    // Statistics must never stop the game from starting.
    debugPrint('analytics off: $e');
    return const NoAnalytics();
  }
}

/// Firebase Analytics and Crashlytics behind the game's [Analytics] door.
/// Both are off in the manifest until the player's consent turns them on
/// (docs/05 T-33); the statistics are never used for ads (no ad id, no ad
/// consent). While consent is held, Crashlytics keeps its reports on the
/// phone and sends them once it is given.
class FirebaseGameAnalytics extends ConsentAwareAnalytics {
  FirebaseGameAnalytics(this._fa, this._crash);
  final FirebaseAnalytics _fa;
  final FirebaseCrashlytics _crash;

  @override
  void sendEvent(String name, Map<String, Object> params) =>
      _quietly(_fa.logEvent(name: name, parameters: params));

  @override
  void sendUserProperty(String name, String? value) =>
      _quietly(_fa.setUserProperty(name: name, value: value));

  @override
  void applyConsent(StatsConsent consent) {
    final on = consent == StatsConsent.on;
    _quietly(
      _fa.setConsent(
        analyticsStorageConsentGranted: on,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
      ),
    );
    _quietly(_fa.setAnalyticsCollectionEnabled(on));
    _quietly(_crash.setCrashlyticsCollectionEnabled(on));
    switch (consent) {
      case StatsConsent.on:
        _quietly(_crash.sendUnsentReports());
      case StatsConsent.off:
        _quietly(_crash.deleteUnsentReports());
      case StatsConsent.held:
        break;
    }
  }

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    if (consent == StatsConsent.off) return;
    _quietly(_crash.recordError(error, stack, fatal: fatal));
  }

  void _quietly(Future<void> f) =>
      unawaited(f.catchError((Object e) => debugPrint('analytics: $e')));
}
