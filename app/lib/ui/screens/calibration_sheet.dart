import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/calibration.dart';
import '../../model/number_format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'sheet.dart';

/// Input-lag calibration (docs/05 T-13), behind `Features.calibration`:
/// ten taps on a stopwatch that runs like the real one, from 3.00 to 5.00.
/// The median error becomes the offset taken off every graded tap.
Future<void> showCalibration(BuildContext context, GameController c) =>
    showGameSheet(
      context,
      c,
      title: (l) => l.calibTitle,
      builder: (context) => CalibrationPanel(controller: c),
    );

/// "+42 ms", "−12 ms", "0 ms".
String formatOffsetMs(num ms) {
  final r = ms.round();
  return r == 0 ? '0 ms' : '${r > 0 ? '+' : '−'}${r.abs()} ms';
}

class CalibrationPanel extends StatefulWidget {
  const CalibrationPanel({super.key, required this.controller});
  final GameController controller;

  @override
  State<CalibrationPanel> createState() => _CalibrationPanelState();
}

class _CalibrationPanelState extends State<CalibrationPanel>
    with SingleTickerProviderStateMixin {
  static const _from = 3.0;
  static const _target = 5.0;
  static const _autoEnd = 5.4;

  /// Pause between attempts, showing the last error.
  static const _gap = 0.9;

  late final Ticker _ticker = createTicker((_) => _frame());
  final _errors = <double>[];

  /// Game clock when the stopwatch leaves 3.00, or null before the test.
  double? _start;
  double? _lastError;
  bool _noTap = false;
  bool _running = false;
  CalibrationResult? _result;

  GameController get c => widget.controller;

  double get _shown {
    final start = _start;
    if (!_running || start == null) return _from;
    return (_from + c.now() - start).clamp(_from, _autoEnd);
  }

  void _begin() {
    setState(() {
      _errors.clear();
      _result = null;
      _lastError = null;
      _noTap = false;
      _running = true;
      _start = c.now() + _gap;
    });
    if (!_ticker.isActive) _ticker.start();
  }

  void _frame() {
    final start = _start;
    if (_running && start != null && c.now() - start >= _autoEnd - _from) {
      // No tap: this attempt does not count, the next one starts.
      _noTap = true;
      _lastError = null;
      _start = c.now() + _gap;
    }
    setState(() {});
  }

  void _tap(PointerDownEvent e) {
    final start = _start;
    if (!_running || start == null) return;
    final t = c.tapClock.tapTime(
      c.now(),
      e.timeStamp == Duration.zero ? null : e.timeStamp.inMicroseconds / 1e6,
    );
    final since = t - start;
    // Before the clock runs, or far too early to be an attempt (as in a
    // round, R-RUNDA-4, R-RUNDA-5a).
    if (since < 0.25 || _from + since < _target - 1) return;
    final error = _from + since - _target;
    _errors.add(error);
    _lastError = error;
    _noTap = false;
    if (_errors.length >= Calibration.taps) {
      _running = false;
      _ticker.stop();
      _result = Calibration.analyse(_errors);
    } else {
      _start = t + _gap;
    }
    setState(() {});
  }

  void _apply(int offsetMs) {
    final r = _result;
    if (r != null) {
      c.calibrationDone(
        offsetMs: r.offsetMs,
        spreadMs: r.spreadMs,
        used: r.used,
        applied: offsetMs == r.offsetMs,
      );
    }
    c.settings.inputOffsetMs = offsetMs.toDouble();
    c.applySettings();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = c.settings.inputOffsetMs;
    final result = _result;
    final body = TextStyle(
      fontSize: 15,
      color: Palette.outline.withValues(alpha: 0.85),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Text(l.calibIntro, style: body),
        const SizedBox(height: 6),
        Text(l.calibCurrent(formatOffsetMs(current)), style: body),
        const SizedBox(height: 16),
        Listener(
          key: const Key('calib-dial'),
          behavior: HitTestBehavior.opaque,
          onPointerDown: _tap,
          child: SizedBox(height: 240, child: Center(child: _dial(l))),
        ),
        const SizedBox(height: 16),
        if (result == null && !_running)
          _button(l.calibStart, _begin, key: const Key('calib-start')),
        if (result != null) ..._resultView(l, result, current),
      ],
    );
  }

  Widget _dial(AppLocalizations l) {
    final shown = _shown;
    final progress = ((shown - _from) / (_target - _from)).clamp(0.0, 1.0);
    final last = _lastError;
    final caption = !_running
        ? (_result == null ? l.calibTapHint : '')
        : _noTap
        ? l.calibNoTap
        : last != null
        ? formatError(last)
        : l.calibTapHint;
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              color: Palette.perfect,
              backgroundColor: Palette.outline.withValues(alpha: 0.12),
            ),
          ),
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: Palette.dial,
              shape: BoxShape.circle,
              border: Border.all(color: Palette.outline, width: 5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatStopwatch(shown),
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 46,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: Palette.outline,
                  ),
                ),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Palette.missText,
                  ),
                ),
                if (_running)
                  Text(
                    '${_errors.length}/${Calibration.taps}',
                    style: const TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _resultView(
    AppLocalizations l,
    CalibrationResult r,
    double current,
  ) {
    final text = r.offsetMs.abs() < 5
        ? l.calibResultZero
        : r.offsetMs > 0
        ? l.calibResultLate(r.offsetMs)
        : l.calibResultEarly(-r.offsetMs);
    return [
      Text(
        text,
        key: const Key('calib-result'),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      if (r.unreliable) ...[
        const SizedBox(height: 6),
        Text(l.calibUnreliable, style: const TextStyle(fontSize: 14)),
      ],
      const SizedBox(height: 14),
      _button(
        l.calibApply(formatOffsetMs(r.offsetMs)),
        () => _apply(r.offsetMs),
        key: const Key('calib-apply'),
        filled: !r.unreliable,
      ),
      const SizedBox(height: 10),
      _button(l.calibRepeat, _begin, key: const Key('calib-repeat')),
      if (current != 0) ...[
        const SizedBox(height: 10),
        _button(l.calibReset, () => _apply(0), key: const Key('calib-reset')),
      ],
    ];
  }

  Widget _button(
    String label,
    VoidCallback onTap, {
    Key? key,
    bool filled = false,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    const text = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
    return SizedBox(
      width: double.infinity,
      child: filled
          ? FilledButton(
              key: key,
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: Palette.accent,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: shape,
              ),
              child: Text(label, style: text),
            )
          : OutlinedButton(
              key: key,
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.outline,
                side: const BorderSide(color: Palette.outline, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: shape,
              ),
              child: Text(label, style: text),
            ),
    );
  }
}
