import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/number_format.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/persistence/save_codec.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

void main() {
  final balance = loadBalance();

  Future<(GameController, MemorySaveStore, List<int>)> pumpGame(
    WidgetTester tester, {
    Locale? locale = const Locale('pl'),
    bool tall = false,
  }) async {
    final store = MemorySaveStore();
    final c = GameController(
      balance: balance,
      state: GameState()
        ..tiki = 1234
        ..tutorialDone = true,
      store: store,
    );
    final restarts = <int>[];
    // Tall enough for the whole settings list when a test needs its end.
    tester.view.physicalSize = Size(1170, tall ? 4200 : 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceProvider.overrideWithValue(balance),
          gameControllerProvider.overrideWithValue(c),
          restartProvider.overrideWithValue(() async => restarts.add(1)),
        ],
        child: Hit10App(locale: locale),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    return (c, store, restarts);
  }

  testWidgets('switches change the settings and are saved', (tester) async {
    final (c, store, _) = await pumpGame(tester);
    await tester.tap(find.byKey(const Key('set-reduce-motion')));
    await tester.tap(find.byKey(const Key('set-notation-Notation.scientific')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.settings.reduceMotion, isTrue);
    expect(c.settings.notation, Notation.scientific);
    final saved = saveFromJsonString(store.main!);
    expect(saved.settings.reduceMotion, isTrue);
  });

  testWidgets('language follows the setting', (tester) async {
    final (c, _, _) = await pumpGame(tester, locale: null);
    await tester.tap(find.byKey(const Key('set-language-en')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(c.settings.language, 'en');
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-language-pl')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Ustawienia'), findsOneWidget);
  });

  testWidgets('reset needs the typed word', (tester) async {
    final (c, store, restarts) = await pumpGame(tester, tall: true);
    Future<void> attempt(String word) async {
      await tester.tap(find.byKey(const Key('set-reset')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dialog-ok')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('dialog-field')), word);
      await tester.tap(find.byKey(const Key('dialog-ok')));
      await tester.pumpAndSettle();
    }

    await attempt('nope');
    expect(restarts, isEmpty);
    await attempt('reset');
    expect(restarts, hasLength(1));
    final saved = saveFromJsonString(store.main!);
    expect(saved.state.tiki, 0);
    // The old controller never writes over the fresh save again.
    c.state.tiki = 999;
    await c.save();
    expect(saveFromJsonString(store.main!).state.tiki, 0);
  });

  test('export and import round-trip; garbage is refused', () async {
    final store = MemorySaveStore();
    final a = GameController(
      balance: balance,
      state: GameState()..tiki = 4242,
      store: MemorySaveStore(),
    );
    final b = GameController(balance: balance, store: store);
    await b.importText(a.exportText());
    expect(saveFromJsonString(store.main!).state.tiki, 4242);
    expect(
      () => b.importText('definitely not a save'),
      throwsA(isA<SaveFormatException>()),
    );
  });
}
