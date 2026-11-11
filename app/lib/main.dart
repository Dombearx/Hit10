import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads/rewarded_ads.dart';
import 'analytics/analytics.dart';
import 'balance/balance.dart';
import 'persistence/save_store.dart';
import 'ui/ads.dart';
import 'ui/analytics_platform.dart';
import 'ui/app.dart';
import 'ui/audio.dart';
import 'ui/game_controller.dart';
import 'ui/notifications.dart';
import 'ui/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

/// Dart errors as `app_error` events (docs/05 T-30): Play's Android vitals
/// only see the app dying, not an exception Flutter caught. A few per
/// launch are enough to spot a broken spot.
void _reportErrors(Analytics analytics) {
  var left = 5;
  void report(String where, Object error, StackTrace? stack) {
    if (left <= 0) return;
    left--;
    final frame = stack
        ?.toString()
        .split('\n')
        .firstWhere((l) => l.contains('package:hit10/'), orElse: () => '');
    analytics.log('app_error', {
      'where': where,
      'type': clip(error.runtimeType.toString()),
      'message': clip(error.toString()),
      'frame': clip((frame ?? '').trim()),
    });
  }

  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    report('flutter', details.exception, details.stack);
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    report('async', error, stack);
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

Future<void> _boot(Balance balance, {GameController? previous}) async {
  final controller = await loadGame(
    balance,
    createSaveStore(),
    notifications: createNotifications(),
    analytics: _analytics,
    sfx: previous?.sfx,
    haptics: previous?.haptics,
  );
  // Decode all sounds before play starts so the first hit never stalls; the
  // web must wait for a user gesture instead (GameController.onPointerDown).
  if (previous == null) {
    controller.sfx.musicSuppressed = await otherMusicPlaying();
  }
  if (!kIsWeb) await controller.sfx.init();
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
