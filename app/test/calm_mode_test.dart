import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/arena/arena_game.dart';
import 'package:hit10/arena/pop_text.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// Calm mode (docs/04 U-6): the "Reduce motion" setting, extended after a
/// tester felt sick during Frenzy. A perfect jackpot is the loudest hit.
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

  Future<ArenaGame> pumpArena(WidgetTester tester, GameController c) async {
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
    for (var i = 0; i < 100 && !arena.isLoaded; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(arena.isLoaded, isTrue);
    return arena;
  }

  HitFeedback jackpot() => HitFeedback(
    const RoundOutcome(
      raw: Grade(Tier.perfect, 0),
      tier: Tier.perfect,
      payout: 100,
      combo: 1,
      streak: 1,
      streakBefore: 0,
      comboBroken: false,
      shieldUsed: false,
      bumpedByLuck: false,
      hotHand: false,
      jackpot: 50,
    ),
    10,
  );

  for (final calm in [false, true]) {
    testWidgets('jackpot effects with calm mode ${calm ? 'on' : 'off'}', (
      tester,
    ) async {
      final c = GameController(
        balance: balance,
        state: GameState()..tutorialDone = true,
        store: MemorySaveStore(),
      )..settings.reduceMotion = calm;
      final arena = await pumpArena(tester, c);
      final stage = arena.stage;
      stage.onFeedback(jackpot());
      await tester.pump(const Duration(milliseconds: 16));
      final waves = stage.children.whereType<Shockwave>();
      final pops = stage.children.whereType<PopText>().toList();
      expect(pops, isNotEmpty);
      if (calm) {
        expect(waves, isEmpty);
        expect(pops.every((p) => p.still), isTrue);
        expect(stage.particles.density, closeTo(1 / 3, 1e-9));
        expect(stage.particles.speed, lessThan(1));
      } else {
        expect(waves, isNotEmpty);
        expect(pops.any((p) => p.still), isFalse);
        expect(stage.particles.density, 1);
        expect(stage.particles.speed, 1);
      }
      arena.suspend();
    });
  }
}

String _id(String s) => s;
