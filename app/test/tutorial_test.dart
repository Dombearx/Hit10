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

  test('steps: aim, earned, buy, grandpa info, auto start, done', () {
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
    expect(c.tutorialStep, TutorialStep.autoStart);
    expect(s.tutorialDone, isFalse);
    // Read off the save: closing the app here does not go back a step.
    expect(controller(s).tutorialStep, TutorialStep.autoStart);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.done);
    expect(s.tutorialDone, isTrue);
    expect(c.engine.goldenEnabled, isTrue);
  });

  test('a replay walks every step, whatever the player owns', () {
    final s = GameState()
      ..tutorialDone = true
      ..tiki = 1e6
      ..owned['grandpa'] = 3;
    final c = controller(s);
    c.replayTutorial();
    expect(c.tutorialStep, TutorialStep.aim);
    expect(c.coachTiming, isTrue);
    expect(c.engine.goldenEnabled, isFalse);
    // The game goes on as it was: nothing is hidden or saved as undone.
    expect(s.tutorialDone, isTrue);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.earned);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.buyGrandpa);
    c.buyGenerators('grandpa', 1);
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
    c.checkTips();
    expect(c.pendingTip, isNull);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.autoStart);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.done);
    expect(c.replaying, isFalse);
    expect(c.engine.goldenEnabled, isTrue);
  });

  test('a replay before the first clock is the real first run', () {
    final s = GameState()
      ..tutorialDone = true
      ..tipsSeen.add('tutorial:grandpaInfo');
    final c = controller(s);
    c.replayTutorial();
    expect(c.replaying, isFalse);
    expect(s.tutorialDone, isFalse);
    expect(c.tutorialStep, TutorialStep.aim);
    // Grandpa's step comes again, not straight the last one.
    s.tiki = 1000;
    c.buyGenerators('grandpa', 1);
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
  });

  test("Grandpa's bubble waits for OK or the next purchase", () {
    final s = GameState()..tiki = 1000;
    final c = controller(s);
    c.buyGenerators('grandpa', 1);
    for (var i = 0; i < 60; i++) {
      s.playSeconds += 1;
      c.debugAutoAdvance();
    }
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
    c.buyGenerators('grandpa', 1);
    expect(c.tutorialStep, TutorialStep.autoStart);
    // The last step waits for OK too.
    for (var i = 0; i < 60; i++) {
      s.playSeconds += 1;
      c.debugAutoAdvance();
    }
    expect(c.tutorialStep, TutorialStep.autoStart);
    c.nextTutorialStep();
    expect(s.tutorialDone, isTrue);
  });

  test('during the tutorial each round waits for a tap', () {
    final s = GameState();
    final c = controller(s);
    c.tick();
    expect(c.round.autoStart, isFalse);
    c.finishTutorial();
    c.tick();
    expect(c.round.autoStart, isTrue);
    // A replay waits again.
    s.owned['grandpa'] = 1;
    c.replayTutorial();
    c.tick();
    expect(c.round.autoStart, isFalse);
  });

  test('Mainsprings and a new loop get one tip each', () {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1;
    final c = controller(s);
    c.checkTips();
    expect(c.pendingTip, 'springs');
    c.tipActed('springs');
    expect(c.pendingTip, isNull);
    s.playSeconds += GameController.tipGap + 1;
    c.checkTips();
    expect(c.pendingTip, isNull); // still the first loop
    s.loop = 2;
    c.checkTips();
    expect(c.pendingTip, 'loop');
    c.dismissTip();
    s.playSeconds += GameController.tipGap + 1;
    s.loop = 3;
    c.checkTips();
    expect(c.pendingTip, isNull); // once, not every loop
  });

  test('the next goal: first bonus, then each new clock', () {
    final s = GameState()..owned['grandpa'] = 3;
    final c = controller(s);
    expect(c.nextGoal, isNull); // not during the tutorial
    s.tutorialDone = true;
    var g = c.nextGoal!;
    expect(g.kind, GoalKind.bonus);
    expect(g.generator, 'grandpa');
    expect(g.have, 3);
    expect(g.need, c.econ.nextMilestone('grandpa'));
    s.owned['grandpa'] = g.need.toInt();
    g = c.nextGoal!;
    expect(g.kind, GoalKind.newClock);
    expect(g.generator, balance.generators[1].id);
  });

  test('after the first paradox the goal bar stays (R-TUT-7)', () {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1
      ..chronons = 20
      ..earnedTotal =
          8e11 // exactly the 20 Chronons owned
      ..owned['grandpa'] = 10;
    final c = controller(s);
    // The next clock not bought in this run.
    var g = c.nextGoal!;
    expect(g.kind, GoalKind.newClock);
    expect(g.generator, 'grandma');
    // Every clock within reach bought: the cheapest perk, by Shards.
    for (final gen in balance.generators) {
      if (c.econ.generatorUnlocked(gen.id)) s.owned[gen.id] = 1;
    }
    s.shards = 2;
    g = c.nextGoal!;
    expect(g.kind, GoalKind.perk);
    expect(g.perk, 'headStart');
    expect(g.have, 2);
    expect(g.need, 5);
    // A paradox would pay for it: that is the goal.
    s.earnedTotal = 1e8 * 23 * 23 * 23; // +3 Chronons and Shards
    g = c.nextGoal!;
    expect(g.kind, GoalKind.prestige);
    expect(g.perk, 'headStart');
    // Enough Shards already: buy it.
    s.shards = 5;
    g = c.nextGoal!;
    expect(g.kind, GoalKind.perk);
    expect(g.have, greaterThanOrEqualTo(g.need));
    // A paradox that doubles the Chronons comes first.
    s.earnedTotal = 1e8 * 40 * 40 * 40;
    g = c.nextGoal!;
    expect(g.kind, GoalKind.prestige);
    expect(g.perk, isNull);
  });

  test('everything unlocked: the clock bonus closest to done', () {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 3
      ..chronons = 5000
      ..earnedTotal = 1e8 * 5000.0 * 5000 * 5000;
    for (final p in balance.prestige.perks) {
      s.perks.add(p.id);
    }
    for (final gen in balance.generators) {
      s.owned[gen.id] = 1;
    }
    s.owned['cuckoo'] = 9; // 9/10
    final c = controller(s);
    final g = c.nextGoal!;
    expect(g.kind, GoalKind.bonus);
    expect(g.generator, 'cuckoo');
    expect(g.need, 10);
    // Every bonus reached: nothing to show.
    for (final gen in balance.generators) {
      s.owned[gen.id] = 200;
    }
    expect(c.nextGoal, isNull);
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
    expect(find.textContaining('Tiki'), findsWidgets);
    await tester.tap(find.byKey(const Key('tutorial-ok')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('tutorial-autoStart')), findsOneWidget);
    expect(find.textContaining('startuje sam'), findsOneWidget);
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

  testWidgets('the goal bar shows over the shop after the tutorial', (
    tester,
  ) async {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 3;
    await pump(tester, s);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('next-goal-bonus')), findsOneWidget);
    expect(find.textContaining('3/10'), findsWidgets);
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
