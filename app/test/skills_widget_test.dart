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

  Future<GameController> pump(WidgetTester tester, GameState s) async {
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
    );
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
    await tester.tap(find.byKey(const Key('tab-1')));
    await tester.pump(const Duration(milliseconds: 300));
    return c;
  }

  testWidgets('skills reveal at half their price (R-UMIEJ-3)', (tester) async {
    final s = GameState()
      ..tiki = 100
      ..peakTiki = 100;
    await pump(tester, s);
    expect(find.text('Siła trafienia'), findsOneWidget); // 50 → 25 ≤ 100
    expect(find.text('Start później'), findsOneWidget); // 150 → 75 ≤ 100
    expect(find.text('Magnes'), findsNothing); // 2000 → 1000 > 100
  });

  testWidgets('buying a skill levels it and shows the next effect', (
    tester,
  ) async {
    final s = GameState()
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = await pump(tester, s);
    expect(find.textContaining('×1,0 → ×2,5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('skill-power')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.skills['power'], 1);
    expect(c.state.tiki, 950);
    expect(find.textContaining('×2,5 → ×4,0'), findsOneWidget);
  });

  testWidgets('ticking maxes out after one level', (tester) async {
    final s = GameState()
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = await pump(tester, s);
    await tester.scrollUntilVisible(
      find.byKey(const Key('skill-ticking')),
      200,
    );
    // Cards differ in height: bring the whole button into view.
    await tester.ensureVisible(find.byKey(const Key('skill-ticking')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('skill-ticking')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.skills['ticking'], 1);
    expect(find.text('MAX'), findsWidgets);
  });

  testWidgets('Power and Echo say what a PERFECT pays now', (tester) async {
    final s = GameState()
      ..tiki = 10
      ..peakTiki = 10000
      ..stats.rounds = 100; // past beginner's luck
    s.owned['grandma'] = 10; // 10/s
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('skill-info-power')));
    await tester.pumpAndSettle();
    final power = tester.widget<Text>(
      find.byKey(const Key('perfect-now-power')),
    );
    // 10 Tiki for a PERFECT = 1 s of the clocks' 10/s.
    expect(power.data, contains('≈ 1,0 s dochodu zegarów'));
  });

  testWidgets('a skill card opens its full explanation; buy from there', (
    tester,
  ) async {
    final s = GameState()
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = await pump(tester, s);
    await tester.tap(find.byKey(const Key('skill-info-power')));
    await tester.pumpAndSettle();
    final info = tester.widget<Text>(find.byKey(const Key('skill-info-text')));
    expect(info.data, startsWith('Każdy poziom podnosi stałą nagrodę'));
    await tester.tap(find.byKey(const Key('skill-info-buy')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.skills['power'], 1);
  });
}
