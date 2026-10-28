import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

void main() {
  final balance = loadBalance();

  Future<GameController> pumpGame(
    WidgetTester tester, {
    GameState? state,
    int Function()? wallMs,
  }) async {
    final c = GameController(
      balance: balance,
      state: state,
      store: MemorySaveStore(),
      wallClockMs: wallMs,
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
        child: const Hit10App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    return c;
  }

  testWidgets('buying a generator spends Tiki and reveals the next one', (
    tester,
  ) async {
    final s = GameState()..tiki = 20;
    final c = await pumpGame(tester, state: s);
    expect(find.text('Babcia z minutnikiem'), findsNothing);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.state.owned['grandpa'], 1);
    expect(c.state.tiki, closeTo(5, 0.5));
    expect(find.text('Babcia z minutnikiem'), findsOneWidget);
    // Too poor for another: the tap does nothing.
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.state.owned['grandpa'], 1);
  });

  testWidgets('×10 and MAX buy the shown amount', (tester) async {
    final s = GameState()..tiki = 1000;
    final c = await pumpGame(tester, state: s);
    await tester.tap(find.byKey(const Key('amount-ten')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('×10'), findsWidgets);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.owned['grandpa'], 10);
    await tester.tap(find.byKey(const Key('amount-max')));
    await tester.pump(const Duration(milliseconds: 100));
    final expected = 10 + c.econ.maxAffordable('grandpa', c.state.tiki);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.owned['grandpa'], expected);
    expect(c.econ.generatorCost('grandpa'), greaterThan(c.state.tiki));
  });

  testWidgets('offline dialog appears and collects (R-OFF-2)', (tester) async {
    const now = 10 * 3600 * 1000;
    final s = GameState()..lastSeenMs = now - 2 * 3600 * 1000;
    s.owned['grandma'] = 1;
    final c = await pumpGame(tester, state: s, wallMs: () => now);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Gdy cię nie było…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('offline-collect')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tiki, closeTo(3600, 1)); // 2 h × 1/s × 50 %
    expect(c.pendingOffline, isNull);
  });

  testWidgets('shop folds away and back (U-2)', (tester) async {
    await pumpGame(tester, state: GameState()..tiki = 20);
    expect(find.byKey(const Key('buy-grandpa')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shop-toggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('buy-grandpa')), findsNothing);
    await tester.tap(find.byKey(const Key('shop-toggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('buy-grandpa')), findsOneWidget);
  });
}
