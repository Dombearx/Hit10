import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/ads/rewarded_ads.dart';
import 'package:hit10/analytics/analytics.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// An ad network with a consent form (UMP) that only counts the calls.
class PrivacyAds extends FakeRewardedAds implements AdPrivacy {
  PrivacyAds({this.required = true});
  final bool required;
  int asked = 0;
  @override
  Future<bool> optionsRequired() async => false;
  @override
  Future<void> showOptions() async {}
  @override
  Future<bool?> consentRequired() async => required;
  @override
  Future<void> askConsentIfNeeded() async => asked++;
}

/// docs/05 T-33, docs/02 R-TUT-0: no consent window in the first seconds;
/// the statistics question and the ad consent form after the tutorial.
void main() {
  final balance = loadBalance();
  final day = DateTime(2026, 11, 18, 12);

  Future<(GameController, PrivacyAds, RecordingAnalytics)> pump(
    WidgetTester tester,
    GameState s, {
    bool required = true,
  }) async {
    final ads = PrivacyAds(required: required);
    final a = RecordingAnalytics(initial: StatsConsent.held);
    final c = GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
      analytics: a,
      consentRequired: required,
      localNow: () => day,
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
    return (c, ads, a);
  }

  testWidgets('a new player meets the clock first, no consent window', (
    tester,
  ) async {
    final (c, ads, _) = await pump(tester, GameState());
    expect(find.byKey(const Key('stats-yes')), findsNothing);
    expect(ads.asked, 0);
    expect(c.prologuePending, isFalse); // not before the first Tik
  });

  testWidgets('after the tutorial: the statistics question, then the form', (
    tester,
  ) async {
    final s = GameState()
      ..tipsSeen.add('prologue')
      ..dailyKey = dateKey(day)
      ..dailyStreak = 1;
    final (c, ads, a) = await pump(tester, s);
    expect(find.byKey(const Key('stats-yes')), findsNothing);
    c.finishTutorial();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('stats-yes')), findsOneWidget);
    expect(ads.asked, 0); // our question first
    await tester.tap(find.byKey(const Key('stats-yes')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.statsConsent, StatsConsent.on);
    expect(a.names, contains('tutorial_complete')); // held, now sent
    expect(ads.asked, 1);
    // Once a launch is enough.
    c.notifyListeners();
    await tester.pump(const Duration(milliseconds: 300));
    expect(ads.asked, 1);
  });

  testWidgets('no consent needed here: the end of the tutorial plays on', (
    tester,
  ) async {
    final s = GameState()
      ..tipsSeen.add('prologue')
      ..dailyKey = dateKey(day)
      ..dailyStreak = 1;
    final (c, ads, _) = await pump(tester, s, required: false);
    c.finishTutorial();
    c.onPointerDown(Duration.zero); // a round runs
    await tester.pump(const Duration(milliseconds: 300));
    expect(ads.asked, 1); // checked, nothing to show
    expect(find.byKey(const Key('stats-yes')), findsNothing);
    expect(c.round.phase, RoundPhase.running);
    c.pause();
  });
}
