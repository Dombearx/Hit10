import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/round_engine.dart';
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

  test('skills and the bonus bar get a tip wherever the player looks', () {
    final s = GameState()
      ..tutorialDone = true
      ..tiki = 1000
      ..peakTiki = 1000;
    final c = controller(s);
    c.checkTips(); // runs once a second in play
    expect(c.pendingTip, 'skills');
    expect(c.skillAffordable, isTrue);
    c.dismissTip();
    s.owned['grandpa'] = GameController.milestoneTipAt;
    c.checkTips();
    // Tips are spaced out: nothing right after the last one…
    expect(c.pendingTip, isNull);
    s.playSeconds += GameController.tipGap + 1;
    c.checkTips();
    expect(c.pendingTip, 'milestone');
  });

  test('a tip closes for good once the player does what it says', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 9
      ..tiki = 1e6;
    final c = controller(s);
    c.checkTips();
    expect(c.pendingTip, 'milestone');
    // The 10th Grandpa reaches the bonus the tip was about.
    c.buyGenerators('grandpa', 1);
    expect(c.pendingTip, isNull);
    expect(s.tipsSeen, contains('milestone'));
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

  test('the bonus bar tip comes with a few Grandpas, not after the bonus', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 1;
    final c = controller(s);
    c.checkTips();
    expect(c.pendingTip, isNull);
    s.owned['grandpa'] = 10; // already reached
    c.checkTips();
    expect(c.pendingTip, isNull);
    s.owned['grandpa'] = GameController.milestoneTipAt;
    c.checkTips();
    expect(c.pendingTip, 'milestone');
  });

  test('a bonus reached is announced once', () async {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 9
      ..tiki = 1e6;
    final c = controller(s);
    final events = <MilestoneEvent>[];
    c.milestoneReached.listen(events.add);
    c.buyGenerators('grandpa', 1);
    c.buyGenerators('grandpa', 1);
    await Future<void>.delayed(Duration.zero);
    expect(events.map((e) => '${e.generator}#${e.index}'), ['grandpa#0']);
  });

  test('an ignored tip goes away, comes back once, then never', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 5;
    final c = controller(s);
    void play(double secs) {
      // The controller's own check, one tick a second.
      for (var i = 0; i < secs; i++) {
        s.playSeconds += 1;
        c.debugAutoAdvance();
        c.checkTips();
      }
    }

    c.checkTips();
    expect(c.pendingTip, 'milestone');
    play(GameController.tipLife + 1);
    expect(c.pendingTip, isNull);
    expect(s.tipsSeen, isNot(contains('milestone')));
    play(GameController.tipGap + 1);
    expect(c.pendingTip, 'milestone');
    play(GameController.tipLife + 1);
    expect(s.tipsSeen, contains('milestone'));
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

  testWidgets('the pause button stops the round and starts the next', (
    tester,
  ) async {
    final s = GameState()..tutorialDone = true;
    final c = await pump(tester, s);
    c.onPointerDown(Duration.zero); // start a round
    expect(c.round.phase, RoundPhase.running);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('pause-button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.round.phase, RoundPhase.waiting);
    expect(c.paused, isTrue);
    await tester.tap(find.byKey(const Key('pause-button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.round.phase, RoundPhase.running);
    expect(c.paused, isFalse);
  });

  testWidgets('achievements keep undiscovered clocks a secret', (tester) async {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 1;
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('open-achievements')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Dziadek z zegarkiem'), findsWidgets);
    expect(find.textContaining('Babcia'), findsWidgets); // next in line
    expect(find.textContaining('Kukułka'), findsNothing); // not yet
  });

  testWidgets('the ? button opens the help', (tester) async {
    final s = GameState()..tutorialDone = true;
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('open-help')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Jak grać'), findsOneWidget);
    // The list is longer than the sheet: drag the button well into view.
    await tester.dragUntilVisible(
      find.byKey(const Key('help-replay')),
      find.byType(Scrollable).last,
      const Offset(0, -300),
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('help-replay')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(s.tutorialDone, isFalse);
  });
}
