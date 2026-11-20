import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/app.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/orientation.dart';
import 'package:hit10/ui/providers.dart';

import 'helpers.dart';

/// Large screens (docs/06 M-9): tablets and unfolded foldables may turn,
/// so the game, the shop and every sheet must fit either way.
void main() {
  final balance = loadBalance();

  test('phones are held upright, large screens turn freely', () {
    expect(OrientationPolicy.orientationsFor(const Size(360, 740)), [
      DeviceOrientation.portraitUp,
    ]);
    // A big phone held sideways is still a phone.
    expect(OrientationPolicy.orientationsFor(const Size(915, 412)), [
      DeviceOrientation.portraitUp,
    ]);
    expect(OrientationPolicy.orientationsFor(const Size(800, 1280)), isEmpty);
    expect(OrientationPolicy.orientationsFor(const Size(1280, 800)), isEmpty);
    expect(OrientationPolicy.orientationsFor(const Size(884, 841)), isEmpty);
  });

  // Physical size and pixel ratio of each screen.
  const screens = {
    'phone': (Size(1080, 2220), 3.0),
    'phone, small': (Size(720, 1280), 2.0),
    'tablet, landscape': (Size(2560, 1600), 2.0),
    'tablet, portrait': (Size(1600, 2560), 2.0),
    'small tablet, landscape': (Size(1920, 1200), 2.0),
    'foldable, open': (Size(2208, 1840), 2.5),
    'foldable, open, turned': (Size(1840, 2208), 2.5),
  };

  for (final MapEntry(key: name, value: (size, ratio)) in screens.entries) {
    testWidgets('$name: game, shop and sheets fit', (tester) async {
      final s = GameState()
        ..tutorialDone = true
        ..lifetime.secondsPlayed =
            3600 // challenges on
        ..tipsSeen.addAll(['prologue', 'notifyAsked', 'challenges'])
        ..dailyKey = dateKey(DateTime.now())
        ..dailyStreak = 1
        ..tiki = 5e6
        ..owned['grandpa'] = 25
        ..owned['grandma'] = 12
        ..owned['cuckoo'] = 3;
      final c = GameController(
        balance: balance,
        state: s,
        store: MemorySaveStore(),
      )..checkOffline();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = ratio;
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
      // The dial keeps about the room it has on the smallest phone
      // (360 × 640: 194 px; a 7" tablet turned sideways: 167 px).
      final arena = tester.getRect(find.byKey(const Key('arena')));
      expect(arena.height, greaterThan(160));
      await tester.tap(find.byKey(const Key('tab-1')));
      await tester.pump(const Duration(milliseconds: 300));
      for (final sheet in [
        'open-settings',
        'open-help',
        'open-stats',
        'open-achievements',
        'open-prestige',
        'open-challenges',
      ]) {
        await tester.tap(find.byKey(Key(sheet)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const Key('sheet-close')), findsOneWidget);
        await tester.tap(find.byKey(const Key('sheet-close')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }
    });
  }
}
