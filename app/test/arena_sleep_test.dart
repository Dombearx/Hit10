import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/arena/arena_game.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// docs/05 T-21a: a still arena stops drawing; the economy goes on.
void main() {
  final balance = loadBalance();
  const labels = ArenaLabels(
    perfect: 'P',
    great: 'G',
    good: 'D',
    early: 'E',
    late: 'L',
    close: 'C',
    tapToStart: 'tap',
    paused: 'paused',
    decimalSeparator: '.',
    goldenRound: 'gold',
    goldenEscaped: 'esc',
    frenzy: _id,
    lucky: _id,
    hotHand: 'hot',
    luckyBump: 'bump',
    shieldSaved: 'shield',
  );

  testWidgets('asleep when still, awake for a round, money keeps coming', (
    tester,
  ) async {
    final c = GameController(
      balance: balance,
      state: GameState()
        ..tutorialDone = true
        ..owned['grandma'] = 10,
      store: MemorySaveStore(),
    );
    final arena = ArenaGame(c, labels);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 400,
          height: 400,
          child: GameWidget(game: arena),
        ),
      ),
    );
    // The emoji art loads from real files: let real time pass.
    for (var i = 0; i < 100 && !arena.isLoaded; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(arena.isLoaded, isTrue);
    expect(arena.asleep, isFalse);
    // Nobody taps: the clock waits, and after a few seconds it sleeps.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(arena.asleep, isTrue);
    expect(arena.paused, isTrue);
    // The economy still ticks without frames (real time passes: the
    // controller reads a real stopwatch).
    final before = c.state.tiki;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.state.tiki, greaterThan(before));
    // A round starts (the pause button): drawing again.
    c.onPointerDown(Duration.zero);
    await tester.pump(const Duration(milliseconds: 50));
    expect(arena.asleep, isFalse);
    expect(arena.paused, isFalse);
    arena.suspend();
  });
}

String _id(String s) => s;
