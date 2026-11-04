import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';
import 'package:hit10/ui/screens/prestige_screen.dart';

import 'helpers.dart';

/// R-PRES-6a: the Shards a paradox pays can buy perks before the new run.
void main() {
  final balance = loadBalance();
  const now = 1800000000000;

  GameState ready() => GameState()
    ..tutorialDone = true
    ..playSeconds = 1000
    ..dailyKey = dateKey(DateTime.fromMillisecondsSinceEpoch(now))
    ..dailyStreak = 1
    ..earnedTotal =
        1e8 *
        1000 // 10 Chronons
    ..owned['grandma'] = 10
    ..skills['echo'] = 9;

  GameController controller(GameState s) => GameController(
    balance: balance,
    state: s,
    store: MemorySaveStore(),
    wallClockMs: () => now,
    localNow: () => DateTime.fromMillisecondsSinceEpoch(now),
  );

  testWidgets('rewind, buy Muscle memory, then the run resets', (tester) async {
    final c = controller(ready());
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceProvider.overrideWithValue(balance),
          gameControllerProvider.overrideWithValue(c),
          rewardedAdsProvider.overrideWithValue(
            FakeRewardedAds(delay: Duration.zero),
          ),
        ],
        child: const Hit5App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    unawaited(showPrestige(tester.element(find.byKey(const Key('arena'))), c));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('prestige-go')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-yes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-yes')));
    await tester.pumpAndSettle();

    expect(c.rewindPending, isTrue);
    expect(c.state.shards, 10);
    expect(c.state.skills['echo'], 9);
    expect(find.text('Okruchy czasu: 10 ✦'), findsOneWidget);

    final sheetList = find.byType(Scrollable).last;
    final perk = find.byKey(const Key('perk-muscleMemory1'));
    await tester.scrollUntilVisible(perk, 200, scrollable: sheetList);
    await tester.tap(perk);
    await tester.pump();
    expect(c.state.perks, contains('muscleMemory1'));

    final start = find.byKey(const Key('prestige-start'));
    await tester.scrollUntilVisible(start, -200, scrollable: sheetList);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(c.rewindPending, isFalse);
    expect(c.state.skills['echo'], 5); // 50 % of 9, rounded up
    expect(c.state.owned, isEmpty);
  });

  testWidgets('a Habit bought at the paradox is filled before the reset', (
    tester,
  ) async {
    final c = controller(
      ready()
        ..shards = 40
        ..skills['magnet'] = 3,
    );
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceProvider.overrideWithValue(balance),
          gameControllerProvider.overrideWithValue(c),
          rewardedAdsProvider.overrideWithValue(
            FakeRewardedAds(delay: Duration.zero),
          ),
        ],
        child: const Hit5App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    unawaited(showPrestige(tester.element(find.byKey(const Key('arena'))), c));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('prestige-go')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-yes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-yes')));
    await tester.pumpAndSettle();

    final sheetList = find.byType(Scrollable).last;
    final perk = find.byKey(const Key('perk-habit1'));
    await tester.scrollUntilVisible(perk, 200, scrollable: sheetList);
    await tester.ensureVisible(perk);
    await tester.pumpAndSettle();
    await tester.tap(perk);
    await tester.pump();
    expect(c.state.perks, contains('habit1'));

    final pick = find.byKey(const Key('habit-echo'));
    await tester.scrollUntilVisible(pick, -200, scrollable: sheetList);
    await tester.ensureVisible(pick);
    await tester.pumpAndSettle();
    await tester.tap(pick);
    await tester.pump();
    expect(c.engine.activeHabits, ['echo']);

    final start = find.byKey(const Key('prestige-start'));
    await tester.scrollUntilVisible(start, -200, scrollable: sheetList);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(c.state.skills['echo'], 9); // kept whole
    expect(c.state.skills.containsKey('magnet'), isFalse); // no Muscle memory
  });

  test('an app closed while choosing perks starts the new run on load', () {
    final s = ready()
      ..chronons = 10
      ..shards = 10
      ..rewindPending = true;
    final c = controller(s);
    expect(c.rewindPending, isFalse);
    expect(s.owned, isEmpty);
    expect(s.skills, isEmpty);
  });
}
