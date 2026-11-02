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
}
