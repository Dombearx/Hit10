import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/analytics/analytics.dart';
import 'package:hit10/engine/ad_offers.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';
import 'package:hit10/ui/widgets/buy_button.dart';

import 'helpers.dart';

/// Rewarded ads are offered first, then confirmed (docs/02 §13).
void main() {
  final balance = loadBalance();
  const now = 1800000000000;

  GameState played() => GameState()
    ..tutorialDone = true
    ..tipsSeen.addAll(storyScenesSeen)
    ..playSeconds = 1000
    // Today's bonus already collected: no daily dialog in the way.
    ..dailyKey = dateKey(DateTime.fromMillisecondsSinceEpoch(now))
    ..dailyStreak = 1
    ..owned['grandma'] = 10;

  Future<GameController> pumpGame(
    WidgetTester tester,
    GameState s,
    FakeRewardedAds ads, {
    Analytics analytics = const NoAnalytics(),
  }) async {
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
      analytics: analytics,
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
        child: const Hit5App(locale: Locale('pl')),
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

  testWidgets('an empty winding reserve: the workshop offers an ad that '
      'fills it (R-SPR-3b)', (tester) async {
    final s = played()
      ..prestiges = 1
      ..springClockMs = now
      ..springReserve = 0
      ..springReserveMs = now;
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, s, ads);
    expect(find.byKey(const Key('springs-ad-hint')), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-springs')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Zapas pusty'), findsOneWidget);
    expect(find.text('0 min z 2 h'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ad-spring')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(ads.shown, 1);
    expect(c.engine.springReserveAt(now), balance.springs.hitReserve);
    expect(c.state.springAdCount, 1);
    expect(find.text('2 h z 2 h'), findsOneWidget);
    expect(find.byKey(const Key('ad-spring')), findsNothing);
    expect(find.textContaining('Zapas pełny'), findsOneWidget);
  });

  testWidgets('offers on screen are counted once (ad_offer_shown)', (
    tester,
  ) async {
    final a = RecordingAnalytics();
    final s = played()
      ..prestiges = 1
      ..springClockMs = now
      ..springReserve = 0
      ..springReserveMs = now;
    await pumpGame(
      tester,
      s,
      FakeRewardedAds(delay: Duration.zero),
      analytics: a,
    );
    List<Object?> shown() => [
      for (final e in a.events)
        if (e.$1 == 'ad_offer_shown') e.$2['offer'],
    ];
    expect(shown(), containsAll(['turbo', 'golden']));
    expect(shown(), isNot(contains('spring')));
    await tester.tap(find.byKey(const Key('open-springs')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(shown().where((o) => o == 'spring').length, 1);
    expect(shown().where((o) => o == 'turbo').length, 1);
  });

  testWidgets('a full reserve: no ad, what a hit winds is said', (
    tester,
  ) async {
    final s = played()
      ..prestiges = 1
      ..springClockMs = now;
    final c = await pumpGame(tester, s, FakeRewardedAds(delay: Duration.zero));
    expect(find.byKey(const Key('springs-ad-hint')), findsNothing);
    await tester.tap(find.byKey(const Key('open-springs')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ad-spring')), findsNothing);
    expect(find.textContaining('dokręca 30 min z zapasu'), findsOneWidget);
    expect(c.engine.springReserveAt(now), c.balance.springs.hitReserve);
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

  testWidgets('the offline ×2 spins while the ad loads, then lights up', (
    tester,
  ) async {
    final s = played()..lastSeenMs = now - 3 * 3600 * 1000;
    final ads = FakeRewardedAds(delay: Duration.zero, ready: false)
      ..loading = true;
    await pumpGame(tester, s, ads);
    await tester.pump(const Duration(seconds: 1));
    BuyButton button() => tester.widget<BuyButton>(
      find.descendant(
        of: find.byKey(const Key('offline-double')),
        matching: find.byType(BuyButton),
      ),
    );
    expect(button().loading, isTrue); // cold start: still loading
    ads.ready = true;
    await tester.pump();
    expect(button().loading, isFalse);
    expect(button().enabled, isTrue);
  });

  testWidgets('no ad coming: the offline ×2 says so instead of spinning', (
    tester,
  ) async {
    final s = played()..lastSeenMs = now - 3 * 3600 * 1000;
    final ads = FakeRewardedAds(delay: Duration.zero, ready: false);
    await pumpGame(tester, s, ads);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('buy-loading')), findsNothing);
    expect(find.text('Reklama niedostępna'), findsOneWidget);
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

  testWidgets('shopping does not stop the stopwatch (only ⏸ does)', (
    tester,
  ) async {
    final ads = FakeRewardedAds(delay: Duration.zero);
    final c = await pumpGame(tester, played()..comboStreak = 5, ads);
    await tester.tap(find.byKey(const Key('arena')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.round.phase, RoundPhase.running);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.round.phase, RoundPhase.running);
    expect(c.paused, isFalse);
    expect(c.state.comboStreak, 5);
  });

  testWidgets(
    'rescue: tapping the popup plays the ad and restores the streak',
    (tester) async {
      final ads = FakeRewardedAds(delay: const Duration(milliseconds: 50));
      final c = await pumpGame(tester, played()..skills['combo'] = 15, ads);
      c.ads.rescue = RescueOffer(20, c.state.playSeconds + 5);
      c.state.comboStreak = 0;
      c.notifyListeners();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('ad-rescue')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(ads.shown, 1);
      expect(c.state.comboStreak, 20);
    },
  );
}
