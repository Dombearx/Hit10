import 'package:hit10/engine/tap_clock.dart';
import 'package:hit10/model/calibration.dart';
import 'package:test/test.dart';

/// Fair timing (docs/05 T-9, T-10, T-13).
void main() {
  group('TapClock', () {
    // The platform clock runs 1000 s ahead of the game clock.
    const offset = 1000.0;

    test('without a stamp the handler reading counts', () {
      final c = TapClock();
      expect(c.tapTime(12.5, null), 12.5);
      expect(c.tapTime(12.5, 0), 12.5);
    });

    test('a touch that waited for a busy frame counts when it happened', () {
      final c = TapClock();
      // Quick handlers teach the offset (plus a 1 ms minimum wait).
      for (var i = 0; i < 5; i++) {
        final touch = 10.0 + i;
        expect(c.tapTime(touch + 0.001, touch + offset), closeTo(touch, 0.002));
      }
      // This one waited 14 ms for a frame: it still counts at the touch.
      expect(c.tapTime(20.014 + 0.001, 20.0 + offset), closeTo(20.001, 1e-9));
      expect(c.lastWait, closeTo(0.014, 1e-9));
    });

    test('an implausible wait means the clocks moved: start over', () {
      final c = TapClock();
      c.tapTime(10.001, 10.0 + offset);
      // The phone slept and the platform clock fell 5 s behind ours.
      expect(c.tapTime(30.0, 25.0 + offset), 30.0);
      expect(c.lastWait, 0);
      // From now on the new offset is the reference.
      expect(c.tapTime(40.010, 35.0 + offset), closeTo(40.0, 1e-9));
    });

    test('the minimum follows a window of recent touches', () {
      final c = TapClock(window: 3);
      c.tapTime(10.0, 10.0 + offset); // a lucky 0 ms wait
      for (var i = 0; i < 3; i++) {
        c.tapTime(11.0 + i + 0.004, 11.0 + i + offset);
      }
      // The 0 ms sample left the window: 4 ms is now the minimum.
      expect(c.tapTime(20.006, 20.0 + offset), closeTo(20.004, 1e-9));
    });
  });

  group('Calibration', () {
    test('the median error is the offset; slips are dropped', () {
      final r = Calibration.analyse([
        0.040, 0.050, 0.030, 0.045, 0.035, 0.060, 0.042, 0.038,
        0.9, // a slip
        -0.5, // another
      ]);
      expect(r.used, 8);
      expect(r.offsetMs, 41);
      expect(r.unreliable, isFalse);
    });

    test('scattered or too few taps are flagged, the offset is clamped', () {
      expect(Calibration.analyse([0.01, 0.02]).unreliable, isTrue);
      final wild = Calibration.analyse([
        for (var i = 0; i < 10; i++) (i.isEven ? 0.15 : -0.15),
      ]);
      expect(wild.unreliable, isTrue);
      final late = Calibration.analyse([for (var i = 0; i < 10; i++) 0.199]);
      expect(late.offsetMs, Calibration.maxOffsetMs.clamp(0, 199));
      expect(Calibration.analyse([]).offsetMs, 0);
    });
  });
}
