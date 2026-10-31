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

  test('steps: aim, earned, buy, grandpa info, shop tour, done', () {
    final s = GameState();
    final c = controller(s);
    expect(c.tutorialStep, TutorialStep.aim);
    s.tiki = 4;
    expect(c.tutorialStep, TutorialStep.earned);
    s.tiki = 20;
    expect(c.tutorialStep, TutorialStep.buyGrandpa);
    c.buyGenerators('grandpa', 1);
    expect(c.tutorialStep, TutorialStep.grandpaInfo);
    c.nextTutorialStep();
    expect(c.tutorialStep, TutorialStep.shopTour);
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
    expect(c.pendingTip, 'upgrade');
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
    expect(find.byKey(const Key('tutorial-shopTour')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tutorial-ok')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tutorialDone, isTrue);
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
    expect(find.byKey(const Key('help-replay')), findsNothing); // below
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
