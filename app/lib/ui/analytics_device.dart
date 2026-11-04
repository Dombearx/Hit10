import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
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
    return FirebaseGameAnalytics(FirebaseAnalytics.instance);
  } on Object catch (e) {
    // Statistics must never stop the game from starting.
    debugPrint('analytics off: $e');
    return const NoAnalytics();
  }
}

/// Firebase Analytics behind the game's [Analytics] door. Collection is
/// off in the manifest until the player's setting turns it on, and the
/// statistics are never used for ads (no ad id, no ad consent).
class FirebaseGameAnalytics implements Analytics {
  FirebaseGameAnalytics(this._fa);
  final FirebaseAnalytics _fa;

  @override
  void log(String name, [Map<String, Object> params = const {}]) =>
      _quietly(_fa.logEvent(name: name, parameters: params));

  @override
  void setUserProperty(String name, String? value) =>
      _quietly(_fa.setUserProperty(name: name, value: value));

  @override
  void setEnabled(bool on) {
    _quietly(
      _fa.setConsent(
        analyticsStorageConsentGranted: on,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
      ),
    );
    _quietly(_fa.setAnalyticsCollectionEnabled(on));
  }

  void _quietly(Future<void> f) =>
      unawaited(f.catchError((Object e) => debugPrint('analytics: $e')));
}
