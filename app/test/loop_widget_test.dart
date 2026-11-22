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

import 'helpers.dart';

/// Time Loops on screen (docs/13 §5.2): the ending, the Chronicle, a new
/// loop with Chronos' rule.
void main() {
  final balance = loadBalance();
  const now = 1800000000000;

  /// Late in the first loop: every perk, a few clocks, Tiks for a Chronos.
  GameState late() {
    final s = GameState()
      ..tutorialDone = true
      ..playSeconds = 5000
      ..loopPlaySeconds = 5000
      ..dailyKey = dateKey(DateTime.fromMillisecondsSinceEpoch(now))
      ..dailyStreak = 1
      ..prestiges = 4
      ..loopPrestiges = 4
      ..chronons = 600
      ..earnedTotal = 1e8 * 600.0 * 600 * 600
      ..springClockMs = now
      ..tiki = 1e30;
    // Every clock but the last one.
    for (final g in balance.generators) {
      if (g.id != balance.loops.goal) s.owned[g.id] = 10;
    }
    s.perks.addAll(balance.prestige.perks.map((p) => p.id));
    s.tipsSeen.addAll(['golden', 'prestige', 'skills', 'combo', 'modes']);
    s.tipsSeen.addAll(storyScenesSeen);
    return s;
  }

  Future<GameController> pumpGame(WidgetTester tester, GameState s) async {
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
          rewardedAdsProvider.overrideWithValue(
            FakeRewardedAds(delay: Duration.zero),
          ),
        ],
        child: const Hit5App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return c;
  }

  testWidgets('buying Chronos ends the loop: chapter, next rule, staying', (
    tester,
  ) async {
    final c = await pumpGame(tester, late());
    expect(find.byKey(const Key('loop-end')), findsNothing);
    expect(c.buyGenerators('chronos', 1), BuyResult.ok);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loop-end')), findsOneWidget);
    expect(find.text('Czas pokonany!'), findsOneWidget);
    expect(find.text('Rozdział 1: Wezwany'), findsOneWidget);
    // What Chronos brings next, its seal still a mystery.
    expect(find.text('Zepsuty stoper'), findsOneWidget);
    expect(find.text('Pieczęć za jej ukończenie: ???'), findsOneWidget);
    expect(c.state.loopEndSeen, isFalse); // closing the app shows it again
    await tester.tap(find.byKey(const Key('loop-stay')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loop-end')), findsNothing);
    expect(c.state.loopEndSeen, isTrue);
    expect(c.state.loop, 1);
    // Staying pays: the goal bar points at Chronos' next bonus.
    expect(c.nextGoal!.kind, GoalKind.loopBonus);
    expect(find.byKey(const Key('next-goal-loopBonus')), findsOneWidget);
  });

  testWidgets('the Chronicle starts the next loop under Chronos\' rule', (
    tester,
  ) async {
    final s = late()..owned['chronos'] = 1;
    final c = await pumpGame(tester, s);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('loop-stay')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-prestige')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-chronicle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chronicle')), findsOneWidget);
    final list = find.descendant(
      of: find.byKey(const Key('chronicle')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Rozdział 2: ???'),
      200,
      scrollable: list,
    );
    expect(find.text('Rozdział 1: Wezwany'), findsOneWidget);
    expect(find.text('Ukończ pętlę 2'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('chronicle')),
      const Offset(0, 3000),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chronicle-new-loop')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loop-confirm')), findsOneWidget);
    await tester.tap(find.byKey(const Key('loop-confirm-no')));
    await tester.pumpAndSettle();
    expect(c.state.loop, 1);

    await tester.tap(find.byKey(const Key('chronicle-new-loop')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('loop-confirm-yes')));
    await tester.pumpAndSettle();
    expect(c.state.loop, 2);
    expect(c.state.loopRules, ['blindfold']);
    expect(c.state.chronons, 0);
    expect(c.state.perks, isEmpty);
    // Back on the game: the loop's chip, and Blind held on by the rule.
    expect(find.byKey(const Key('chronicle')), findsNothing);
    expect(find.byKey(const Key('loop-chip')), findsOneWidget);
    expect(find.byKey(const Key('mode-blind')), findsOneWidget);
    c.setMode(blind: false);
    expect(c.engine.blindActive, isTrue);
  });

  testWidgets('a new loop straight from the ending; its own ending comes '
      'later', (tester) async {
    final c = await pumpGame(tester, late());
    c.buyGenerators('chronos', 1);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('loop-new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('loop-confirm-yes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loop-end')), findsNothing);
    expect(c.state.loop, 2);
    expect(c.state.loopGoal, isFalse);
    expect(c.state.loopEndSeen, isFalse);
    expect(c.loopEndPending, isFalse);
  });

  testWidgets('a rule loop ends with its seal and dial face', (tester) async {
    final s = late()
      ..loop = 2
      ..loopsDone = 1
      ..loopRules.add('blindfold');
    final c = await pumpGame(tester, s);
    c.buyGenerators('chronos', 1);
    await tester.pumpAndSettle();
    expect(find.text('Rozdział 2: Bez cyferek'), findsOneWidget);
    expect(find.byKey(const Key('loop-end-seal-blindfold')), findsOneWidget);
    expect(find.text('Wyczucie'), findsOneWidget);
    expect(find.textContaining('Tarcza zegara:'), findsOneWidget);
    expect(find.text('Drożyzna'), findsOneWidget); // the next rule
    expect(c.state.seals, {'blindfold'});
    expect(c.econ.unlockedDials.map((d) => d.id), contains('quartz'));
  });

  testWidgets('Mainsprings refunded for the old levels are said once', (
    tester,
  ) async {
    final s = late()
      ..springs = 12
      ..springsRefunded = 9;
    final c = await pumpGame(tester, s);
    await tester.tap(find.byKey(const Key('open-springs')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('springs-refund')), findsOneWidget);
    await tester.tap(find.byKey(const Key('springs-refund-ok')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('springs-refund')), findsNothing);
    expect(c.state.springsRefunded, 0);
    expect(c.state.springs, 12);
  });
}
