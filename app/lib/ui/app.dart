import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import 'game_screen.dart';
import 'providers.dart';
import 'theme.dart';

class Hit5App extends ConsumerWidget {
  const Hit5App({super.key, this.locale});

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
      // Tablets (M-9): the phone layout, scaled up to fill the screen.
      builder: (context, child) => TabletScale(child: child!),
      home: const GameScreen(),
    );
  }
}

/// Scales the whole app up on screens much bigger than a phone, so a
/// tablet shows the phone layout at a comfortable size instead of a small
/// column in a sea of background. Phones (and widget tests) are untouched.
class TabletScale extends StatelessWidget {
  const TabletScale({super.key, required this.child});
  final Widget child;

  /// The logical size the layout is designed around: a large phone.
  static const designWidth = 420.0;
  static const designHeight = 760.0;

  static double scaleFor(Size size) {
    final s = math.min(size.width / designWidth, size.height / designHeight);
    return s.clamp(1.0, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = scaleFor(mq.size);
    if (s == 1.0) return child;
    final size = mq.size / s;
    return FittedBox(
      fit: BoxFit.fill,
      alignment: Alignment.topLeft,
      child: SizedBox.fromSize(
        size: size,
        child: MediaQuery(
          data: mq.copyWith(
            size: size,
            padding: mq.padding / s,
            viewPadding: mq.viewPadding / s,
            viewInsets: mq.viewInsets / s,
            systemGestureInsets: mq.systemGestureInsets / s,
          ),
          child: child,
        ),
      ),
    );
  }
}
