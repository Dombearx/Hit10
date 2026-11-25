import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/widgets/res_text.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';
import 'package:hit10/ui/shop/generator_list.dart';

import 'helpers.dart';

void main() {
  final balance = loadBalance();

  Future<GameController> pumpGame(
    WidgetTester tester, {
    GameState? state,
    int Function()? wallMs,
  }) async {
    // The prologue before the first round has its own test.
    state = (state ?? GameState())
      ..tipsSeen.add('prologue')
      ..tipsSeen.addAll(storyScenesSeen);
    final c = GameController(
      balance: balance,
      state: state,
      store: MemorySaveStore(),
      wallClockMs: wallMs,
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
        ],
        child: const Hit5App(locale: Locale('pl')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    return c;
  }

  testWidgets('buying a generator spends Tiki and reveals the next one', (
    tester,
  ) async {
    final s = GameState()..tiki = 20;
    final c = await pumpGame(tester, state: s);
    expect(find.text('Babcia z minutnikiem'), findsNothing);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.state.owned['grandpa'], 1);
    expect(c.state.tiki, closeTo(5, 0.5));
    expect(find.text('Babcia z minutnikiem'), findsOneWidget);
    // Too poor for another: the tap does nothing.
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.state.owned['grandpa'], 1);
  });

  testWidgets('×10 and MAX buy the shown amount', (tester) async {
    final s = GameState()..tiki = 1000;
    final c = await pumpGame(tester, state: s);
    await tester.tap(find.byKey(const Key('amount-ten')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('×10'), findsWidgets);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.owned['grandpa'], 10);
    await tester.tap(find.byKey(const Key('amount-max')));
    await tester.pump(const Duration(milliseconds: 100));
    final expected = 10 + c.econ.maxAffordable('grandpa', c.state.tiki);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.owned['grandpa'], expected);
    expect(c.econ.generatorCost('grandpa'), greaterThan(c.state.tiki));
  });

  testWidgets('BONUS buys up to the next free ×2 (R-ULEP-1)', (tester) async {
    final s = GameState()
      ..tutorialDone =
          true // the tutorial's bubbles are not in the way
      ..dailyKey =
          dateKey(DateTime.now()) // no daily bonus window
      ..dailyStreak = 1
      ..tiki = 1e6
      ..owned['grandpa'] = 3;
    final c = await pumpGame(tester, state: s);
    await tester.tap(find.byKey(const Key('amount-next')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('×7'), findsWidgets);
    await tester.tap(find.byKey(const Key('buy-grandpa')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.state.owned['grandpa'], 10);
    expect(c.econ.milestonesReached('grandpa'), 1);
    await tester.pump(const Duration(seconds: 6)); // the bonus toast leaves
  });

  testWidgets('offline dialog appears and collects (R-OFF-2)', (tester) async {
    const now = 10 * 3600 * 1000;
    final s = GameState()..lastSeenMs = now - 2 * 3600 * 1000;
    s.owned['grandma'] = 1;
    final c = await pumpGame(tester, state: s, wallMs: () => now);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Gdy cię nie było…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('welcome-collect')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tiki, closeTo(3600, 1)); // 2 h × 1/s × 50 %
    expect(c.pendingOffline, isNull);
    // R-OFF-5: the notification question comes after the reward, once.
    expect(find.text('Dać znać, gdy zegary uzbierają limit?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notify-yes')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tipsSeen, contains('notifyAsked'));
    expect(c.settings.notifications, isTrue);
  });

  testWidgets('daily bonus pops up once a day and pays (playtest 08)', (
    tester,
  ) async {
    final s = GameState()..tutorialDone = true;
    final c = await pumpGame(tester, state: s);
    c.checkOffline();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Dzienna premia'), findsOneWidget);
    await tester.tap(find.byKey(const Key('welcome-collect')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tiki, c.balance.daily.floorPerDay);
    expect(c.pendingDaily, isNull);
    c.checkOffline(); // same day: nothing new
    expect(c.pendingDaily, isNull);
  });

  testWidgets('day 7 of the daily bonus shows and pays a Mainspring', (
    tester,
  ) async {
    final now = DateTime.now();
    final s = GameState()
      ..tutorialDone = true
      ..prestiges = 1
      ..dailyKey = dateKey(DateTime(now.year, now.month, now.day - 1))
      ..dailyStreak = 6;
    final c = await pumpGame(tester, state: s);
    await tester.pump(const Duration(seconds: 1));
    expect(c.pendingDaily!.day, 7);
    expect(find.byKey(const Key('daily-day-spring')), findsOneWidget);
    expect(find.byKey(const Key('daily-springs')), findsOneWidget);
    await tester.tap(find.byKey(const Key('welcome-collect')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.springs, c.balance.daily.lastDaySprings);
  });

  testWidgets('offline income and the daily bonus share one window', (
    tester,
  ) async {
    const now = 10 * 3600 * 1000;
    final s = GameState()
      ..tutorialDone = true
      ..lastSeenMs = now - 2 * 3600 * 1000
      ..tipsSeen.add('notifyAsked');
    s.owned['grandma'] = 1;
    final c = await pumpGame(tester, state: s, wallMs: () => now);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.text('Witaj z powrotem!'), findsOneWidget);
    final both = c.pendingOffline!.amount + c.pendingDaily!.amount;
    await tester.tap(find.byKey(const Key('welcome-collect')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.state.tiki, closeTo(both, 1e-6));
    expect(c.pendingOffline, isNull);
    expect(c.pendingDaily, isNull);
    await tester.pump(const Duration(milliseconds: 300)); // closing
    expect(find.byKey(const Key('welcome')), findsNothing);
  });

  testWidgets('shop folds away and back (U-2)', (tester) async {
    await pumpGame(tester, state: GameState()..tiki = 20);
    expect(find.byKey(const Key('buy-grandpa')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shop-toggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('buy-grandpa')), findsNothing);
    await tester.tap(find.byKey(const Key('shop-toggle')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('buy-grandpa')), findsOneWidget);
  });

  testWidgets('a long clock description is shown whole; tap for the card', (
    tester,
  ) async {
    // Everything before the atomic clock owned: it is the next to buy.
    final s = GameState()
      ..tutorialDone = true
      // Today's bonus already collected: no daily dialog in the way.
      ..dailyKey = dateKey(DateTime.now());
    for (final g in balance.generators) {
      if (g.id == 'atomic') break;
      s.owned[g.id] = 1;
    }
    await pumpGame(tester, state: s);
    final list = find
        .descendant(
          of: find.byType(GeneratorList),
          matching: find.byType(Scrollable),
        )
        .first;
    final desc = find.byKey(const Key('gen-desc-atomic'));
    await tester.scrollUntilVisible(desc, 200, scrollable: list);
    final text = tester.widget<ResText>(desc);
    expect(text.maxLines, isNull); // never cut
    const joke =
        'Dziadek: „Myli się o sekundę na sto milionów lat. Teraz zdążę.”\n'
        'Babcia: „Mówiłeś to przy kukułce.”';
    expect(text.text, joke);

    await tester.ensureVisible(find.byKey(const Key('gen-info-atomic')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gen-info-atomic')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gen-info-sheet')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('gen-info-sheet')),
        matching: find.text(joke),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the clock card lists every bonus and its synergy', (
    tester,
  ) async {
    final s = GameState()
      ..tutorialDone = true
      ..dailyKey = dateKey(DateTime.now());
    s.owned.addAll({'grandpa': 25, 'grandma': 3});
    await pumpGame(tester, state: s);
    await tester.tap(find.byKey(const Key('gen-info-grandpa')));
    await tester.pumpAndSettle();
    final sheet = find.byKey(const Key('gen-info-sheet'));
    Finder inSheet(String t) =>
        find.descendant(of: sheet, matching: find.textContaining(t));
    // Reached at 10: name and joke; the 150 one only says what it takes.
    expect(inSheet('Okulary do czytania'), findsOneWidget);
    expect(inSheet('Wreszcie widzi wskazówki.'), findsOneWidget);
    expect(inSheet('150 szt. · ??? · ×2'), findsOneWidget);
    expect(inSheet('Zegarek po pradziadku'), findsNothing);
    expect(inSheet('Tyka w rodzinie od trzech pokoleń.'), findsNothing);
    // Grandpa + Grandma: not on yet, with what it needs.
    expect(find.byKey(const Key('gen-synergy-grandparents')), findsOneWidget);
    expect(inSheet('Dziadkowie na randce'), findsNothing);
    expect(inSheet('Babcia z minutnikiem 3/25'), findsOneWidget);
  });

  testWidgets('Mainsprings: the header badge opens the workshop, a tap '
      'raises a level (docs/12 R-SPR-5)', (tester) async {
    final s = GameState()
      ..tutorialDone = true
      ..dailyKey =
          dateKey(DateTime.now()) // no daily-bonus dialog
      ..prestiges = 1
      ..springs = 3
      ..owned['grandpa'] = 5
      ..everOwned.add('grandpa');
    final c = await pumpGame(tester, state: s);
    expect(find.byKey(const Key('springs-count')), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-springs')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('springs-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('level-up-grandpa')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.state.clockLevels['grandpa'], 1);
    expect(c.state.springs, 2);
    expect(find.text('Stopień 1/5 · ×1,5'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10)); // let the toasts go
  });

  testWidgets('the Mainspring badge shows what the next exact hit winds '
      '(R-SPR-3/4)', (tester) async {
    GameState game(int springs) => GameState()
      ..tutorialDone = true
      ..dailyKey = dateKey(DateTime.now())
      ..prestiges = 1
      ..springs = springs;
    int pips(WidgetTester tester, Color color) => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byKey(const Key('springs-pips')),
            matching: find.byType(Container),
          ),
        )
        .where((w) => (w.decoration as BoxDecoration?)?.color == color)
        .length;
    const gold = Color(0xFFE8A317);

    // A fresh reserve: four hits of 30 min.
    final c = await pumpGame(tester, state: game(2));
    expect(pips(tester, gold), 4);

    // One hit used: three left.
    c.state
      ..springReserve = c.balance.springs.hitReserve - 1800
      ..springReserveMs = c.wallMs();
    c.notifyListeners();
    await tester.pump();
    expect(pips(tester, gold), 3);

    // Full stock: MAX instead of pips.
    c.state.springs = c.balance.springs.maxStock;
    c.notifyListeners();
    await tester.pump();
    expect(find.byKey(const Key('springs-max')), findsOneWidget);
    expect(find.byKey(const Key('springs-pips')), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('no Mainspring badge before the first paradox', (tester) async {
    final s = GameState()..tutorialDone = true;
    await pumpGame(tester, state: s);
    expect(find.byKey(const Key('open-springs')), findsNothing);
  });
}
