import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../l10n/gen/app_localizations.dart';
import 'game_controller.dart';
import 'seasons_ui.dart';
import 'theme.dart';

/// Hidden diagnostics (T-12): error histogram of the last 100 rounds, input
/// timestamp jitter and frame times, to verify fair timing on real phones.
class DiagnosticsPanel extends StatefulWidget {
  const DiagnosticsPanel({super.key, required this.controller});
  final GameController controller;

  @override
  State<DiagnosticsPanel> createState() => _DiagnosticsPanelState();
}

class _DiagnosticsPanelState extends State<DiagnosticsPanel>
    with SingleTickerProviderStateMixin {
  /// Frame-to-frame intervals; FrameTiming is not reliable on every platform.
  final List<double> _frameMs = [];
  late final Ticker _ticker;
  Duration? _lastFrame;
  late final Timer _refresh;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onFrame)..start();
    _refresh = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {}),
    );
  }

  void _onFrame(Duration elapsed) {
    final last = _lastFrame;
    _lastFrame = elapsed;
    if (last == null) return;
    _frameMs.add((elapsed - last).inMicroseconds / 1000);
    if (_frameMs.length > 240) _frameMs.removeAt(0);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _refresh.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.controller.state.stats;
    final d = widget.controller.diagnostics;
    final avgFrame = _frameMs.isEmpty
        ? 0
        : _frameMs.reduce((a, b) => a + b) / _frameMs.length;
    final maxFrame = _frameMs.isEmpty
        ? 0
        : _frameMs.reduce((a, b) => a > b ? a : b);
    const style = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12,
      color: Colors.white,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.outline.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'rounds ${s.rounds}  n=${s.recentErrors.length}  '
            'mean ${(s.meanError * 1000).toStringAsFixed(1)} ms  '
            'spread ${(s.spread * 1000).toStringAsFixed(1)} ms',
            style: style,
          ),
          Text(
            'input jitter ${d.jitterMs.toStringAsFixed(2)} ms (${d.samples})  '
            'frame avg ${avgFrame.toStringAsFixed(1)} max ${maxFrame.toStringAsFixed(1)} ms '
            '(${avgFrame > 0 ? (1000 / avgFrame).round() : 0} fps)',
            style: style,
          ),
          const SizedBox(height: 8),
          // QA: try any season without changing the phone's date (§14).
          Text(AppLocalizations.of(context).diagSeason, style: style),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final id in <String?>[
                null,
                ...widget.controller.balance.seasons.list.map((s) => s.id),
              ])
                GestureDetector(
                  key: Key('diag-season-${id ?? 'date'}'),
                  onTap: () => widget.controller.previewSeason(id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: widget.controller.seasonPreview == id
                          ? Palette.great
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      id == null
                          ? AppLocalizations.of(context).diagSeasonNone
                          : seasonName(AppLocalizations.of(context), id),
                      style: style,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 76,
            child: CustomPaint(
              size: Size.infinite,
              painter: _HistogramPainter(s.recentErrors),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  _HistogramPainter(this.errors);
  final List<double> errors;

  @override
  void paint(Canvas canvas, Size size) {
    const bins = 21; // 5 ms each, −52.5 … +52.5 ms
    final counts = List<int>.filled(bins, 0);
    for (final e in errors) {
      final i = ((e * 1000 + 52.5) / 5).floor();
      if (i >= 0 && i < bins) counts[i]++;
    }
    final peak = counts.fold<int>(1, (a, b) => a > b ? a : b);
    final w = size.width / bins;
    const axis = 16.0;
    final barsH = size.height - axis;
    final paint = Paint();
    for (var i = 0; i < bins; i++) {
      paint.color = i == bins ~/ 2 ? Palette.perfect : Palette.great;
      final h = barsH * counts[i] / peak;
      canvas.drawRect(Rect.fromLTWH(i * w + 1, barsH - h, w - 2, h), paint);
    }
    // Labels under the first, middle and last bins.
    for (final (i, text) in [
      (0, '−50'),
      (bins ~/ 2, '0'),
      (bins - 1, '+50 ms'),
    ]) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 11, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = (i * w + w / 2 - tp.width / 2).clamp(
        0.0,
        size.width - tp.width,
      );
      tp.paint(canvas, Offset(x, barsH + 2));
    }
  }

  @override
  bool shouldRepaint(_HistogramPainter old) => true;
}
