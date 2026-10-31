import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// R-TUT-1/2 after the playtest: every step says what to do and why.
void main() {
  final balance = loadBalance();

  GameController controller(GameState s) =>
      GameController(balance: balance, state: s, store: MemorySaveStore());

  test('steps: aim, earned, buy, grandpa info, done', () {
    final s = GameState();
    final c = controller(s);
    expect(c.tutorialStep, TutorialStep.aim);
    s.tiki = 4;
    expect(c.tutorialStep, TutorialStep.earned);
    s.tiki = 20;
    expect(c.tutorialStep, TutorialStep.buyGrandpa);
    c.buyGenerators('grandpa', 1);
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
    expect(s.tutorialDone, isFalse);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.done);
    expect(s.tutorialDone, isTrue);
    expect(c.engine.goldenEnabled, isTrue);
  });

  test('the tutorial can be replayed from the help screen', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 3;
    final c = controller(s);
    c.replayTutorial();
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
    expect(c.engine.goldenEnabled, isFalse);
  });

  test('skills and upgrades get a tip wherever the player looks', () {
    final s = GameState()
      ..tutorialDone = true
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = controller(s);
    c.checkTips(); // runs once a second in play
    expect(c.pendingTip, 'skills');
    expect(c.skillAffordable, isTrue);
    c.dismissTip();
    s.owned['grandpa'] = 10;
    c.checkTips();
    // Tips are spaced out: nothing right after the last one…
    expect(c.pendingTip, isNull);
    s.playSeconds += GameController.tipGap + 1;
    c.checkTips();
    expect(c.pendingTip, 'upgrade');
  });

  test('a tip closes for good once the player does what it says', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 10
      ..tiki = 1e6;
    final c = controller(s);
    c.checkTips();
    expect(c.pendingTip, 'upgrade');
    c.buyUpgrade('grandpa');
    expect(c.pendingTip, isNull);
    expect(s.tipsSeen, contains('upgrade'));
    // Found on one's own: never explained afterwards.
    c.tipActed('skills');
    expect(s.tipsSeen, contains('skills'));
  });

  test('the first tip waits a moment after the tutorial', () {
    final s = GameState()
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = controller(s);
    c.finishTutorial();
    c.checkTips();
    expect(c.pendingTip, isNull);
    s.playSeconds += GameController.tipGapAfterTutorial + 1;
    c.checkTips();
    expect(c.pendingTip, isNotNull);
  });

  test('the stopwatch shows the timing to new players only', () {
    final s = GameState();
    final c = controller(s);
    expect(c.coachTiming, isTrue);
    s
      ..tutorialDone = true
      ..stats.rounds = GameController.coachRounds - 1;
    expect(c.coachTiming, isTrue);
    s.stats.rounds = GameController.coachRounds;
    expect(c.coachTiming, isFalse);
  });

  Future<GameController> pump(WidgetTester tester, GameState s) async {
    final c = controller(s);
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

  testWidgets('the bubble walks through Grandpa', (tester) async {
    final s = GameState()..tiki = 20;
    final c = await pump(tester, s);
    expect(find.byKey(const Key('tutorial-buyGrandpa')), findsOneWidget);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('tutorial-grandpaInfo')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tutorial-ok')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tutorialDone, isTrue);
  });

  testWidgets('the coach points at its target', (tester) async {
    final s = GameState()..tiki = 20;
    await pump(tester, s);
    await tester.pump(const Duration(milliseconds: 100));
    final bubble = tester.getRect(find.byKey(const Key('tutorial-buyGrandpa')));
    final button = tester.getRect(find.byKey(const Key('buy-grandpa')));
    // Right above Grandpa's button, not somewhere in the middle.
    expect(bubble.bottom, lessThanOrEqualTo(button.top));
    expect(button.top - bubble.bottom, lessThan(40));
  });

  testWidgets('a red dot marks an affordable skill on the other tab', (
    tester,
  ) async {
    final s = GameState()
      ..tutorialDone = true
      ..tiki = 1000
      ..peakTiki = 1000;
    await pump(tester, s);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('tab-1-alert-true')), findsOneWidget);
  });

  testWidgets('the ? button opens the help', (tester) async {
    final s = GameState()..tutorialDone = true;
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('open-help')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Jak grać'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('help-replay')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('help-replay')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(s.tutorialDone, isFalse);
  });
}
