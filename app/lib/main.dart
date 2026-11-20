import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads/rewarded_ads.dart';
import 'analytics/analytics.dart';
import 'balance/balance.dart';
import 'persistence/cloud_save.dart';
import 'persistence/save_store.dart';
import 'ui/ads.dart';
import 'ui/analytics_platform.dart';
import 'ui/app.dart';
import 'ui/audio.dart';
import 'ui/cloud_save_platform.dart';
import 'ui/game_controller.dart';
import 'ui/notifications.dart';
import 'ui/orientation.dart';
import 'ui/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OrientationPolicy.instance.start();
  final balance = Balance.fromJsonString(
    await rootBundle.loadString('assets/balance.json'),
  );
  LicenseRegistry.addLicense(_assetLicenses);
  _analytics = await createAnalytics();
  _reportErrors(_analytics);
  await _boot(balance);
}

/// Game statistics (docs/05 T-30), one for the app's whole life.
Analytics _analytics = const NoAnalytics();

/// Dart errors to Crashlytics (docs/05 T-30): Play's Android vitals only
/// see the app dying, not an exception Flutter caught. Held on the phone
/// until the player's consent (T-33).
void _reportErrors(Analytics analytics) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    analytics.recordError(details.exception, details.stack);
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    analytics.recordError(error, stack, fatal: true);
    debugPrint('uncaught: $error\n$stack');
    return true;
  };
}

/// Our bundled art and fonts on the licence page (docs/04 §2).
Stream<LicenseEntry> _assetLicenses() async* {
  for (final (name, asset) in [
    ('Paytone One', 'assets/fonts/OFL-PaytoneOne.txt'),
    ('Nunito', 'assets/fonts/OFL-Nunito.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([
      name,
    ], await rootBundle.loadString(asset));
  }
}

/// Loads the save and (re)starts the widget tree. Importing or resetting a
/// save calls this again, so the new state starts exactly like a cold launch.
/// One ad provider for the app's whole life, across restarts.
final RewardedAds _ads = createRewardedAds();

/// Play Games cloud save (docs/05 T-35), one for the app's whole life.
final CloudSave _cloud = createCloudSave();

/// Whether the law asks for consent here (docs/05 T-33): unknown until the
/// ad network's consent check of this launch answers.
bool? _consentRequired;

Future<void> _boot(Balance balance, {GameController? previous}) async {
  final controller = await loadGame(
    balance,
    createSaveStore(),
    notifications: createNotifications(),
    analytics: _analytics,
    cloud: _cloud,
    consentRequired: _consentRequired,
    sfx: previous?.sfx,
    haptics: previous?.haptics,
  );
  // Statistics wait on the phone until we know (T-33). Without a consent
  // check (web, no ad network) none is needed.
  if (_consentRequired == null) {
    final Future<bool?> check = switch (_ads) {
      final AdPrivacy p => p.consentRequired(),
      _ => Future.value(false),
    };
    unawaited(
      check.then((required) {
        _consentRequired = required;
        controller.setConsentRequired(required);
      }),
    );
  }
  // Decode all sounds before play starts so the first hit never stalls; the
  // web must wait for a user gesture instead (GameController.onPointerDown).
  if (previous == null) {
    controller.sfx.musicSuppressed = await otherMusicPlaying();
  }
  if (!kIsWeb) await controller.sfx.init();
  // Is the cloud ahead of this phone (a new phone, a reinstall)? Asked
  // from the game screen once the answer is in (T-35).
  unawaited(controller.checkCloud());
  runApp(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        balanceProvider.overrideWithValue(balance),
        gameControllerProvider.overrideWithValue(controller),
        rewardedAdsProvider.overrideWithValue(_ads),
        restartProvider.overrideWithValue(
          () => _boot(balance, previous: controller),
        ),
      ],
      child: const Hit5App(),
    ),
  );
}
