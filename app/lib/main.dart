import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'balance/balance.dart';
import 'ui/app.dart';
import 'ui/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final balance = Balance.fromJsonString(
    await rootBundle.loadString('assets/balance.json'),
  );
  runApp(
    ProviderScope(
      overrides: [balanceProvider.overrideWithValue(balance)],
      child: const Hit10App(),
    ),
  );
}
