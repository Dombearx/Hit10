import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// Rewarded ads are offered first, then confirmed (docs/02 §13).
void main() {
  final balance = loadBalance();
  const now = 1800000000000;

  GameState played() => GameState()
    ..tutorialDone = true
    ..playSeconds = 1000
    // Today's bonus already collected: no daily dialog in the way.
    ..dailyKey = dateKey(DateTime.fromMillisecondsSinceEpoch(now))
    ..dailyStreak = 1
    ..owned['grandma'] = 10;

  Future<GameController> pumpGame(
    WidgetTester tester,
    GameState s,
    FakeRewardedAds ads,
  ) async {
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
      wallClockMs: () => now,
      localNow: () => DateTime.fromMillisecondsSinceEpoch(now),
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
          rewardedAdsProvider.overrideWithValue(ads),
        ],
        child: const Hit10App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return c;
  }

  testWidgets('Turbo: the offer says what it gives; "Not now" plays nothing', (
    tester,
  ) async {
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, played(), ads);
    await tester.tap(find.byKey(const Key('ad-turbo')));
    await tester.pumpAndSettle();
    expect(find.text('×2 Tików przez 30 min'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ad-not-now')));
    await tester.pumpAndSettle();
    expect(ads.shown, 0);
    expect(c.state.turboLeft, 0);

    await tester.tap(find.byKey(const Key('ad-turbo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ad-watch')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(ads.shown, 1);
    expect(c.state.turboLeft, balance.ads.turboDuration);
    expect(find.textContaining('Turbo włączone'), findsOneWidget);
  });

  testWidgets('an interrupted ad gives nothing and says so', (tester) async {
    final ads = FakeRewardedAds(delay: Duration.zero, grant: false);
    final c = await pumpGame(tester, played(), ads);
    await tester.tap(find.byKey(const Key('ad-turbo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ad-watch')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.turboLeft, 0);
    expect(find.textContaining('bez nagrody'), findsOneWidget);
  });

  testWidgets('doubling offline income pays twice the amount', (tester) async {
    final s = played()..lastSeenMs = now - 3 * 3600 * 1000;
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, s, ads);
    final amount = c.pendingOffline!.amount;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('offline-double')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.tiki, closeTo(2 * amount, amount * 1e-6));
    expect(c.pendingOffline, isNull);
  });

  testWidgets('touching an offer tile is not a round tap; the combo stays', (
    tester,
  ) async {
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, played()..comboStreak = 5, ads);
    await tester.tap(find.byKey(const Key('arena')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.round.phase, RoundPhase.running);
    await tester.tap(find.byKey(const Key('ad-turbo')));
    await tester.pumpAndSettle();
    expect(c.state.comboStreak, 5);
    expect(c.round.phase, RoundPhase.waiting); // paused, not graded
    expect(c.state.stats.rounds, 0);
  });

  testWidgets('touching the shop pauses the stopwatch', (tester) async {
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, played()..comboStreak = 5, ads);
    await tester.tap(find.byKey(const Key('arena')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.round.phase, RoundPhase.running);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.round.phase, RoundPhase.waiting);
    expect(c.state.comboStreak, 5);
  });
}
