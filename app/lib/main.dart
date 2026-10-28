import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'balance/balance.dart';
import 'persistence/save_store.dart';
import 'ui/app.dart';
import 'ui/game_controller.dart';
import 'ui/notifications.dart';
import 'ui/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final balance = Balance.fromJsonString(
    await rootBundle.loadString('assets/balance.json'),
  );
  final controller = await loadGame(
    balance,
    createSaveStore(),
    notifications: createNotifications(),
  );
  // Decode all sounds before play starts so the first hit never stalls; the
  // web must wait for a user gesture instead (GameController.onPointerDown).
  if (!kIsWeb) await controller.sfx.init();
  runApp(
    ProviderScope(
      overrides: [
        balanceProvider.overrideWithValue(balance),
        gameControllerProvider.overrideWithValue(controller),
      ],
      child: const Hit10App(),
    ),
  );
}
