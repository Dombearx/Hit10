import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// docs/04 U-35: the screens survive the system's large text sizes.
void main() {
  final balance = loadBalance();

  for (final scale in [1.3, 1.6, 2.0]) {
    for (final lang in ['pl', 'en']) {
      testWidgets('text ×$scale, $lang: game, shop and settings fit', (
        tester,
      ) async {
        final s = GameState()
          ..tutorialDone = true
          ..tipsSeen.addAll(['prologue', 'notifyAsked'])
          ..dailyKey = dateKey(DateTime.now())
          ..dailyStreak = 1
          ..tiki = 5e6
          ..owned['grandpa'] = 25
          ..owned['grandma'] = 12
          ..owned['cuckoo'] = 3;
        final c = GameController(
          balance: balance,
          state: s,
          store: MemorySaveStore(),
        );
        // A small phone: 360 × 740 logical pixels.
        tester.view.physicalSize = const Size(1080, 2220);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              balanceProvider.overrideWithValue(balance),
              gameControllerProvider.overrideWithValue(c),
            ],
            child: Hit5App(locale: Locale(lang)),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.byKey(const Key('tab-1')));
        await tester.pump(const Duration(milliseconds: 300));
        for (final sheet in [
          'open-settings',
          'open-help',
          'open-stats',
          'open-achievements',
          'open-prestige',
        ]) {
          await tester.tap(find.byKey(Key(sheet)));
          await tester.pump(const Duration(milliseconds: 600));
          expect(find.byKey(const Key('sheet-close')), findsOneWidget);
          await tester.tap(find.byKey(const Key('sheet-close')));
          await tester.pump(const Duration(milliseconds: 600));
        }
      });

      testWidgets('text ×$scale, $lang: the welcome window fits', (
        tester,
      ) async {
        const now = 10 * 24 * 3600 * 1000;
        final s = GameState()
          ..tutorialDone = true
          ..tipsSeen.addAll(['prologue', 'notifyAsked'])
          ..lastSeenMs = now - 9 * 3600 * 1000
          ..dailyStreak = 3
          ..owned['grandma'] = 40;
        final c = GameController(
          balance: balance,
          state: s,
          store: MemorySaveStore(),
          wallClockMs: () => now,
        )..checkOffline();
        tester.view.physicalSize = const Size(1080, 2220);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              balanceProvider.overrideWithValue(balance),
              gameControllerProvider.overrideWithValue(c),
            ],
            child: Hit5App(locale: Locale(lang)),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(const Key('welcome')), findsOneWidget);
        await tester.tap(find.byKey(const Key('welcome-collect')));
        await tester.pump(const Duration(milliseconds: 600));
      });
    }
  }
}
