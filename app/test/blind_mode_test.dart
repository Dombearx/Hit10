import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// Blind mode (docs/02 §7): everything that shows the time goes at 4.00.
void main() {
  test('the clock is hidden from 4.00 of game time, only when blind', () {
    final c = GameController(
      balance: loadBalance(),
      state: GameState()..tutorialDone = true,
    );
    final slot = c.clocks.first;
    slot.round.tap(0); // starts the round
    expect(c.blindHidden(slot, 4.5), isFalse); // not blind
    slot.blind = true;
    expect(c.blindHidden(slot, 3.99), isFalse);
    expect(c.blindHidden(slot, 4.0), isTrue);
    expect(c.blindHidden(slot, 4.9), isTrue);
    slot.round.cancel();
    expect(c.blindHidden(slot, 4.9), isFalse); // stopped: nothing to hide
  });

  test('switching blind off mid-round shows the clock, without the bonus', () {
    final c = GameController(
      balance: loadBalance(),
      state: GameState()
        ..tutorialDone = true
        ..modeBlind = true
        ..lifetime.perfects = 100,
    );
    final slot = c.clocks.first;
    slot.round.tap(0);
    slot
      ..blind = true
      ..mode = 3;
    expect(c.blindHidden(slot, 4.5), isTrue);
    c.setMode(blind: false);
    expect(c.blindHidden(slot, 4.5), isFalse);
    expect(slot.mode, 1);
  });

  GameController blindReady() => GameController(
    balance: loadBalance(),
    state: GameState()
      ..tutorialDone = true
      ..lifetime.perfects = 100,
  );

  test('switched on before 4.00 the round goes blind and pays at once', () {
    final c = blindReady();
    final slot = c.clocks.first;
    slot.round.tap(c.now() - 2); // 2 s into the round
    expect(c.blindPending, isFalse);
    c.setMode(blind: true);
    expect(slot.blind, isTrue);
    expect(slot.mode, 3);
    expect(c.blindHidden(slot, 4.5), isTrue);
    expect(c.blindPending, isFalse);
  });

  test('switched on after 4.00 it waits for the next round, and says so', () {
    final c = blindReady();
    final slot = c.clocks.first;
    slot.round.tap(c.now() - 4.5); // the digits would already be gone
    c.setMode(blind: true);
    expect(slot.blind, isFalse);
    expect(slot.mode, 1);
    expect(c.blindHidden(slot, 4.8), isFalse);
    expect(c.blindPending, isTrue);
  });
}
