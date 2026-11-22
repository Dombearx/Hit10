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

/// The auto buyer's chip and its clock picker (docs/02 §9.3).
void main() {
  final balance = loadBalance();

  Future<GameController> pumpGame(WidgetTester tester, GameState s) async {
    s
      ..tutorialDone = true
      ..perks.add('autoBuyer')
      ..dailyKey =
          dateKey(DateTime.now()) // no daily bonus window
      ..tipsSeen.addAll(['prologue', 'modes', ...storyScenesSeen]);
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
    );
    c.checkOffline();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
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
    return c;
  }

  String label(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('mode-auto-label'))).data!;

  testWidgets('off → pick a clock in the sheet → buying, then waiting', (
    tester,
  ) async {
    final c = await pumpGame(
      tester,
      GameState()
        ..tiki = 1e6
        ..owned['grandpa'] = 9,
    );
    expect(label(tester), 'Auto-kupiec');
    await tester.tap(find.byKey(const Key('mode-auto')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('auto-sheet')), findsOneWidget);
    expect(find.byKey(const Key('auto-continue')), findsNothing);
    await tester.tap(find.byKey(const Key('auto-pick-grandpa')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(c.state.autoBuyerOn, isTrue);
    expect(c.state.autoTarget, 'grandpa');
    expect(label(tester), '9/10');
    expect(find.byKey(const Key('mode-auto-clock-grandpa')), findsOneWidget);
    expect(find.byKey(const Key('mode-auto-alert-false')), findsOneWidget);

    c.engine.autoBuy(5);
    c.autoWatch(5);
    c.notifyListeners();
    await tester.pump();
    expect(label(tester), '✓ 10 · wybierz');
    expect(find.byKey(const Key('mode-auto-alert-true')), findsOneWidget);

    // Waiting: the sheet offers "next" first, to the following bonus.
    await tester.tap(find.byKey(const Key('mode-auto-waiting')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Dalej: Dziadek z zegarkiem → 20'), findsOneWidget);
    await tester.tap(find.byKey(const Key('auto-continue')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(label(tester), '10/20');
  });

  testWidgets('switch off from the sheet', (tester) async {
    final c = await pumpGame(
      tester,
      GameState()
        ..autoBuyerOn = true
        ..autoTarget = 'grandpa'
        ..autoUntil = 10,
    );
    await tester.tap(find.byKey(const Key('mode-auto')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('auto-off')));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(c.state.autoBuyerOn, isFalse);
    expect(label(tester), 'Auto-kupiec');
  });

  test('a waiting buyer nudges once after a while, never again', () {
    final c = GameController(
      balance: balance,
      state: GameState()
        ..perks.add('autoBuyer')
        ..autoBuyerOn = true,
    );
    final after = balance.perk('autoBuyer').params['remindAfterSeconds']!;
    c.autoWatch(after - 1);
    expect(c.autoNudge, 0);
    c.autoWatch(1);
    expect(c.autoNudge, 1);
    c.autoWatch(after * 3);
    expect(c.autoNudge, 1);
    // A new pick and a new stop: one more nudge.
    c.state.owned['grandpa'] = 1;
    c.engine.setAutoTarget('grandpa');
    c.autoWatch(1);
    c.state.owned['grandpa'] = 10;
    c.autoWatch(after);
    expect(c.autoNudge, 2);
  });
}
