import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/app_updates.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/game_screen.dart';
import 'package:hit10/ui/providers.dart';
import 'package:hit10/ui/widgets/alert_dot.dart';
import 'package:hit10/ui/widgets/game_snack.dart';

import 'helpers.dart';

/// A downloaded Google Play update stays offered until it is installed
/// (playtest: the reward message after an ad took the offer away until
/// the next launch).
void main() {
  final balance = loadBalance();

  Future<void> pumpGame(WidgetTester tester) async {
    final c = GameController(
      balance: balance,
      state: GameState()
        ..tiki = 1234
        ..tutorialDone = true,
      store: MemorySaveStore(),
    );
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(() => appUpdateReady.value = false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceProvider.overrideWithValue(balance),
          gameControllerProvider.overrideWithValue(c),
        ],
        child: const Hit5App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }

  bool settingsDot(WidgetTester tester) => tester
      .widget<AlertDot>(
        find.ancestor(
          of: find.byKey(const Key('open-settings')),
          matching: find.byType(AlertDot),
        ),
      )
      .show;

  testWidgets('no update: no message, no dot, no settings row', (tester) async {
    await pumpGame(tester);
    expect(find.byKey(const Key('update-ready')), findsNothing);
    expect(settingsDot(tester), isFalse);
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('set-update')), findsNothing);
  });

  testWidgets('another message does not take the offer away', (tester) async {
    await pumpGame(tester);
    appUpdateReady.value = true;
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('update-ready')), findsOneWidget);
    expect(settingsDot(tester), isTrue);

    // The reward message after an ad.
    showGameSnack(
      ScaffoldMessenger.of(tester.element(find.byType(GameScreen))),
      key: const Key('other'),
      text: 'Turbo!',
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('other')), findsOneWidget);
    expect(find.byKey(const Key('update-ready')), findsNothing);

    // Back once the other message is gone, and only once.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('other')), findsNothing);
    expect(find.byKey(const Key('update-ready')), findsOneWidget);
  });

  testWidgets('swiped away: the dot and the settings row stay', (tester) async {
    await pumpGame(tester);
    appUpdateReady.value = true;
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.drag(
      find.byKey(const Key('update-ready')),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('update-ready')), findsNothing);
    expect(settingsDot(tester), isTrue);

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('set-update')), findsOneWidget);
    expect(find.text('Zainstaluj nową wersję'), findsOneWidget);
  });
}
