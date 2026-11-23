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

  test('the first paradox is a tip, not a goal (R-TUT-7)', () {
    final s = GameState()
      ..tutorialDone = true
      ..earnedTotal =
          1e8 // exactly 1 Chronon
      ..owned['grandpa'] = 10;
    final c = controller(s);
    expect(c.engine.canPrestige(), isTrue);
    expect(c.nextGoal!.kind, GoalKind.newClock); // not "turn back time"
  });

  test('the goal bar never points at a paradox (R-TUT-7b)', () {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1
      ..chronons = 5
      ..earnedTotal =
          1e8 *
          40 *
          40 *
          40 // a paradox would double them
      ..owned['grandpa'] = 10;
    final c = controller(s);
    expect(c.nextGoal!.kind, GoalKind.newClock);
    for (final gen in balance.generators) {
      if (c.econ.generatorUnlocked(gen.id)) s.owned[gen.id] = 1;
    }
    expect(c.nextGoal!.kind, GoalKind.unlockClock);
  });

  test('the goal bar leads to Chronos, never to another perk (R-TUT-7a)', () {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1
      ..chronons = 20
      ..earnedTotal =
          8e11 // exactly the 20 Chronons owned: a paradox adds none
      ..owned['grandpa'] = 10;
    final c = controller(s);
    // The next clock not bought in this run.
    var g = c.nextGoal!;
    expect(g.kind, GoalKind.newClock);
    expect(g.generator, 'grandma');
    // Every clock within reach bought, up to the Time Machine: the
    // Shards for the cat's key, cheaper perks or not.
    for (final gen in balance.generators) {
      if (c.econ.generatorUnlocked(gen.id)) s.owned[gen.id] = 1;
    }
    expect(c.econ.owned('timeMachine'), 1);
    s.shards = 2;
    g = c.nextGoal!;
    expect(g.kind, GoalKind.unlockClock);
    expect(g.generator, 'schrodinger');
    expect(g.perk, 'unlockSchrodinger');
    expect(g.have, 2);
    expect(g.need, 25);
    // The Shards a paradox would add count too.
    s.earnedTotal = 1e8 * 23 * 23 * 23; // +3
    expect(c.nextGoal!.have, 5);
    // The key bought: the cat is a new clock.
    s.perks.add('unlockSchrodinger');
    g = c.nextGoal!;
    expect(g.kind, GoalKind.newClock);
    expect(g.generator, 'schrodinger');
    // The cat bought: the Shards for the Altar.
    s.owned['schrodinger'] = 1;
    g = c.nextGoal!;
    expect(g.kind, GoalKind.unlockClock);
    expect(g.generator, 'chronos');
    expect(g.perk, 'unlockChronos');
    expect(g.need, 500);
    // The Altar bought: Chronos.
    s.perks.add('unlockChronos');
    g = c.nextGoal!;
    expect(g.kind, GoalKind.newClock);
    expect(g.generator, 'chronos');
    // Chronos bought: only a new loop.
    s.owned['chronos'] = 1;
    s.loopGoal = true;
    expect(c.nextGoal!.kind, GoalKind.newLoop);
  });

  test('the first run also ends at the cat\'s key', () {
    final s = GameState()
      ..tutorialDone = true
      ..owned['grandpa'] = 10;
    final c = controller(s);
    expect(c.lockedClock, isNull); // clocks to buy first
    for (final gen in balance.generators) {
      if (c.econ.generatorUnlocked(gen.id)) s.owned[gen.id] = 1;
    }
    s.owned['grandpa'] = 10; // past the first bonus
    expect(c.lockedClock?.id, 'schrodinger');
    expect(c.nextGoal!.kind, GoalKind.unlockClock);
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
    s.tipsSeen
      ..add('prologue') // it has its own test
      ..addAll(storyScenesSeen);
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

  testWidgets('the first Tik opens the prologue: the goal is Chronos', (
    tester,
  ) async {
    // The first round paid: the prologue follows, not precedes, the first
    // touch of the clock (R-TUT-0).
    final s = GameState()
      ..tiki = 3
      ..earnedTotal = 3;
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
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('prologue')), findsOneWidget);
    // No picture drawn yet: the placeholder scene holds its place.
    expect(find.byKey(const Key('story-placeholder-prologue')), findsOneWidget);
    // The scene plays one line at a time: a caption, then Grandma.
    expect(
      find.text('Kuchnia Babci. Stół nakryty na cztery filiżanki.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('prologue-go')), findsNothing);
    await tester.tap(find.byKey(const Key('story-next')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('story-next')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Babcia'), findsOneWidget);
    expect(find.text('Zmierz mu, dziecko.'), findsOneWidget);
    // Skip: the whole scene to read, the goal and the button.
    await tester.tap(find.byKey(const Key('story-skip')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('story-done')), findsOneWidget);
    expect(find.text('Cel: zdobądź Chronosa'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('prologue-go')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('prologue-go')));
    // The button's press, then the window's exit.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('prologue')), findsNothing);
    expect(s.tipsSeen, contains('prologue'));
    expect(c.prologuePending, isFalse);
  });

  test('no prologue before the first Tik or for a game under way', () {
    expect(controller(GameState()).prologuePending, isFalse);
    expect(
      controller(GameState()..tutorialDone = true).prologuePending,
      isFalse,
    );
    expect(
      controller(
        GameState()
          ..earnedTotal = 50
          ..prestiges = 1,
      ).prologuePending,
      isFalse,
    );
    // Not over a round's result: only once the clock waits again.
    final c = controller(GameState()..earnedTotal = 1);
    expect(c.prologuePending, isTrue);
    c.onPointerDown(Duration.zero);
    expect(c.prologuePending, isFalse);
  });

  testWidgets('help hides what the player has not met yet', (tester) async {
    final s = GameState()..tutorialDone = true;
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('open-help')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('help-chronos')), findsOneWidget);
    // No paradox, Mainsprings or loops yet: "???" instead.
    expect(find.byKey(const Key('help-cyclone')), findsNothing);
    expect(find.byKey(const Key('help-gear')), findsNothing);
    expect(find.byKey(const Key('help-classical_building')), findsNothing);
    expect(
      find.byKey(const Key('help-locked-0'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text(
        'Graj dalej, aby odblokować nowe mechaniki',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
  });

  testWidgets('after a paradox its card and the Mainsprings open', (
    tester,
  ) async {
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1
      ..chronons = 3;
    await pump(tester, s);
    await tester.tap(find.byKey(const Key('open-help')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.dragUntilVisible(
      find.byKey(const Key('help-gear')),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    expect(find.byKey(const Key('help-cyclone')), findsOneWidget);
    expect(find.byKey(const Key('help-gear')), findsOneWidget);
  });
}
