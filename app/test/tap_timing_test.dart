import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/round_engine.dart';
import 'package:hit10/model/features.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/grading.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';

import 'helpers.dart';

/// T-10: the grade follows the touch's platform timestamp, not the moment
/// the (busy) UI thread handled it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();

  test('a tap handled 40 ms late still grades at its timestamp', () async {
    final c = GameController(
      balance: balance,
      state: GameState()
        ..tutorialDone = true
        ..stats.rounds = 100
        ..skills['fastForward'] = 15, // starts at 2.00: a short test
      store: MemorySaveStore(),
    );
    // The platform clock runs 1000 s ahead of ours.
    Duration stamp(double gameClock) =>
        Duration(microseconds: ((gameClock + 1000) * 1e6).round());
    final grades = <Grade>[];
    final sub = c.feedback.listen((f) => grades.add(f.grade));
    final startReal = c.now();
    c.onPointerDown(stamp(startReal));
    expect(c.round.phase, RoundPhase.running);
    final start = c.round.timeMap.start;
    final target = balance.round.target;
    final atTarget = startReal + (target - start);
    // The UI thread is busy until 40 ms after 5.00.
    while (c.now() < atTarget + 0.040) {}
    c.onPointerDown(stamp(atTarget));
    await Future<void>.delayed(Duration.zero);
    expect(grades, hasLength(1));
    expect(grades.single.error.abs(), lessThan(0.003));
    expect(grades.single.tier, Tier.perfect);
    await sub.cancel();
  });

  test('the calibration offset stays off in player builds', () {
    final c = GameController(balance: balance);
    c.settings.inputOffsetMs = 80;
    expect(Features.calibration, isFalse);
    expect(c.inputOffsetSeconds, 0);
  });
}
