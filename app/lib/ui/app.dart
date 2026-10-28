import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import 'game_screen.dart';
import 'providers.dart';
import 'theme.dart';

class Hit10App extends ConsumerWidget {
  const Hit10App({super.key, this.locale});

  /// Forced locale (tests); otherwise the language from the settings, and
  /// null there follows the system (01-wizja).
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(gameControllerProvider);
    return ValueListenableBuilder(
      valueListenable: c.settingsVersion,
      builder: (context, _, _) {
        final lang = c.settings.language;
        return _app(locale ?? (lang == null ? null : Locale(lang)));
      },
    );
  }

  Widget _app(Locale? locale) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const GameScreen(),
    );
  }
}
