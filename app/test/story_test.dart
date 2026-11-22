import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/l10n/gen/app_localizations.dart';
import 'package:hit10/l10n/gen/app_localizations_en.dart';
import 'package:hit10/l10n/gen/app_localizations_pl.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/catalog.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/providers.dart';
import 'package:hit10/ui/story/story_script.dart';
import 'package:hit10/ui/widgets/story_scene.dart';

import 'helpers.dart';

void main() {
  final balance = loadBalance();
  GameController controller(GameState s) =>
      GameController(balance: balance, state: s, store: MemorySaveStore());

  test('the rare scenes of the first loop come in story order, once', () {
    final s = GameState()..tutorialDone = true;
    final c = controller(s);
    expect(c.storyScenePending, isNull);
    s.prestiges = 1;
    s.owned['atomic'] = 1;
    expect(c.storyScenePending, 'atomic'); // the earlier one first
    c.storySceneShown('atomic');
    expect(c.storyScenePending, 'paradox');
    c.storySceneShown('paradox');
    expect(c.storyScenePending, isNull);
    s.owned['timeMachine'] = 1;
    s.perks.add('unlockChronos');
    expect(c.storyScenePending, 'timeMachine');
    c.storySceneShown('timeMachine');
    expect(c.storyScenePending, 'altar');
    c.storySceneShown('altar');
    expect(c.storyScenePending, isNull);
    // Not during the tutorial, and not after the first loop: later loops
    // tell the story in their chapters.
    expect(
      controller(GameState()..owned['atomic'] = 1).storyScenePending,
      isNull,
    );
    expect(
      controller(
        GameState()
          ..tutorialDone = true
          ..loopsDone = 1
          ..owned['atomic'] = 1,
      ).storyScenePending,
      isNull,
    );
  });

  group('story scripts', () {
    test('rows are speaker, optional stage direction and text', () {
      final lines = parseStory(
        '*: A kitchen.\n'
        'grandma (hands you a stopwatch): Time him, dear.\n'
        '\n'
        'chronos:   …Cheesecake?\n'
        'nobody: stays visible',
      );
      expect(lines, hasLength(4));
      expect(lines[0].caption, isTrue);
      expect(lines[0].text, 'A kitchen.');
      expect(lines[1].who, 'grandma');
      expect(lines[1].direction, 'hands you a stopwatch');
      expect(lines[1].text, 'Time him, dear.');
      expect(lines[2].who, 'chronos');
      expect(lines[2].direction, isNull);
      expect(lines[2].text, '…Cheesecake?');
      // A slip in a translation is shown, not hidden.
      expect(lines[3].caption, isTrue);
      expect(lines[3].text, 'nobody: stays visible');
    });

    for (final l in <AppLocalizations>[
      AppLocalizationsPl(),
      AppLocalizationsEn(),
    ]) {
      test('every scene in ${l.localeName} parses into known speakers', () {
        final scripts = [
          l.prologue,
          for (var n = 1; n <= 7; n++) chapterTexts(l, n)!.$2,
          for (final id in ['atomic', 'paradox', 'timeMachine', 'altar'])
            storySceneTexts(l, id).$2,
          for (var d = 0; d < 7; d++) welcomeLine(l, d),
        ];
        for (final script in scripts) {
          final lines = parseStory(script);
          expect(lines, isNotEmpty);
          // Every row was meant to be a line: none fell back to a caption
          // because its speaker was misspelt.
          for (final (i, row) in script.split('\n').indexed) {
            final line = lines[i];
            if (!row.startsWith('*')) {
              expect(line.who, isNotNull, reason: row);
            }
          }
        }
        // One line a day, never the same two days running.
        expect(welcomeLine(l, 0), isNot(welcomeLine(l, 1)));
        expect(welcomeLine(l, 7), welcomeLine(l, 0));
      });
    }
  });

  testWidgets('a scene plays line by line and ends with its end', (
    tester,
  ) async {
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StoryPlayer(
              script: 'grandpa: Pierwsza.\ngrandma (cicho): Druga.',
              end: const Text('KONIEC'),
              onDone: () => done++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pierwsza.'), findsOneWidget);
    expect(find.text('Dziadek'), findsOneWidget);
    expect(find.text('KONIEC'), findsNothing);
    await tester.tap(find.byKey(const Key('story-next')));
    await tester.pumpAndSettle();
    expect(find.text('Druga.'), findsOneWidget);
    expect(find.text('(cicho)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('story-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('story-done')), findsOneWidget);
    expect(find.text('KONIEC'), findsOneWidget);
    expect(done, 1);
  });

  testWidgets('the first Atomic Clock gets its scene in the next break', (
    tester,
  ) async {
    final s = GameState()
      ..tutorialDone = true
      ..tipsSeen.addAll(['prologue', 'notifyAsked', 'challenges'])
      ..dailyKey = dateKey(DateTime.now())
      ..owned['grandpa'] = 1
      ..owned['atomic'] = 1;
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
    expect(find.byKey(const Key('story-scene-atomic')), findsOneWidget);
    expect(find.text('Zegar atomowy'), findsWidgets);
    expect(s.tipsSeen, contains('story_atomic'));
    await tester.tap(find.byKey(const Key('story-skip')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('story-scene-atomic')), findsNothing);
    expect(c.storyScenePending, isNull);
  });
}
