import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/challenges.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// docs/02 §18, docs/04 U-36: the badge, the sheet, claiming, re-rolling.
void main() {
  final balance = loadBalance();
  final today = DateTime.now();

  Future<GameController> pump(WidgetTester tester) async {
    final s = GameState()
      ..tutorialDone = true
      ..lifetime.secondsPlayed = 3600
      ..tipsSeen.addAll(['prologue', 'notifyAsked', 'challenges'])
      ..dailyKey = dateKey(today)
      ..dailyStreak = 1
      ..owned['grandma'] = 5;
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
    )..checkOffline();
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
    await tester.pump(const Duration(milliseconds: 300));
    return c;
  }

  testWidgets('the badge opens today\'s three and the week\'s one', (
    tester,
  ) async {
    final c = await pump(tester);
    expect(c.state.challenges, hasLength(4));
    expect(find.text('0/3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-challenges')));
    await tester.pump(); // the sheet's route starts
    await tester.pump(const Duration(milliseconds: 600));
    for (var slot = 0; slot < 4; slot++) {
      expect(find.byKey(Key('challenge-$slot')), findsOneWidget);
    }
    expect(find.byKey(const Key('challenge-bonus')), findsOneWidget);
    // A free swap, once.
    final before = c.engine.dailyChallenges[0].kind;
    await tester.tap(find.byKey(const Key('challenge-reroll-0')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.engine.dailyChallenges[0].kind, isNot(before));
    expect(find.byKey(const Key('challenge-reroll-1')), findsNothing);
    await tester.tap(find.byKey(const Key('sheet-close')));
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('a finished challenge: toast, golden badge, claim', (
    tester,
  ) async {
    final c = await pump(tester);
    c.state.challenges.removeWhere((x) => x.slot == 2);
    c.state.challenges.add(Challenge(ChallengeKind.buyClocks, 1));
    c.state.tiki = 1e6;
    c.buyGenerators('grandpa', 1);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('challenge-done')), findsOneWidget);
    expect(find.text('!'), findsOneWidget); // the badge says: claim me
    await tester.tap(find.byKey(const Key('open-challenges')));
    await tester.pump(); // the sheet's route starts
    await tester.pump(const Duration(milliseconds: 600));
    final tiki = c.state.tiki;
    await tester.tap(find.byKey(const Key('challenge-claim-2')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tiki, greaterThan(tiki));
    expect(c.challengesToClaim, 0);
    await tester.tap(find.byKey(const Key('sheet-close')));
    await tester.pump(const Duration(seconds: 5));
  });
}
