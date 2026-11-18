import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// docs/02 R-OCENA-1: the rating window only late, at a high point.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();
  var now = 1800000000000;

  GameController controller(GameState s) => GameController(
    balance: balance,
    state: s,
    store: MemorySaveStore(),
    wallClockMs: () => now,
  );

  GameState fan() => GameState()
    ..tutorialDone = true
    ..lifetime.secondsPlayed = 4 * 3600
    ..lifetime.dailyClaims = 3
    ..loopGoal = true;

  test('a loop completed by a regular player: ask', () {
    final c = controller(fan());
    c.loopEndShown();
    expect(c.reviewPending, isTrue);
    c.reviewShown();
    expect(c.reviewPending, isFalse);
  });

  test('not too early: hours of play on several days first', () {
    final short = controller(fan()..lifetime.secondsPlayed = 3600);
    short.loopEndShown();
    expect(short.reviewPending, isFalse);
    final oneDay = controller(fan()..lifetime.dailyClaims = 1);
    oneDay.loopEndShown();
    expect(oneDay.reviewPending, isFalse);
  });

  test('at most twice, months apart', () {
    final s = fan();
    final c = controller(s)..loopEndShown();
    c.reviewShown();
    s.loopEndSeen = false;
    now += 30 * 24 * 3600 * 1000; // a month later: too soon
    c.loopEndShown();
    expect(c.reviewPending, isFalse);
    s.loopEndSeen = false;
    now += 100 * 24 * 3600 * 1000;
    c.loopEndShown();
    expect(c.reviewPending, isTrue);
    c.reviewShown();
    s.loopEndSeen = false;
    now += 400 * 24 * 3600 * 1000;
    c.loopEndShown();
    expect(c.reviewPending, isFalse); // never a third time
  });
}
