import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.appTitle,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 72,
                    color: Palette.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l.tagline, style: const TextStyle(fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
