import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'burst.dart';

/// Always-visible combo (R-COMBO-4): multiplier, flame that grows with the
/// streak, shield charges. Shakes red when the streak breaks.
class ComboMeter extends StatefulWidget {
  const ComboMeter({super.key, required this.controller});
  final GameController controller;

  @override
  State<ComboMeter> createState() => _ComboMeterState();
}

class _ComboMeterState extends State<ComboMeter>
    with SingleTickerProviderStateMixin {
  /// The flame at full heat: as tall as the row.
  static const _flame = 30.0;

  late final AnimationController _break = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  int _last = 0;

  @override
  void didUpdateWidget(ComboMeter old) {
    super.didUpdateWidget(old);
    final now = widget.controller.state.comboStreak;
    if (now < _last && _last >= 3) {
      _break.forward(from: 0);
      // The counter "shatters" (docs/04 §3).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showBurst(
          context,
          colors: shardColors,
          count: 12,
          spread: 0.7,
          reduceMotion: widget.controller.settings.reduceMotion,
        );
      });
    }
    _last = now;
  }

  @override
  void dispose() {
    _break.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final l = AppLocalizations.of(context);
    final streak = c.state.comboStreak;
    final cap = c.econ.comboCap();
    final mult = c.engine.comboMultiplier();
    // A streak above the cap (it counts on, only the multiplier stops) is
    // full heat, not a flame that outgrows its box.
    final heat = cap == 0 ? 0.0 : (streak / cap).clamp(0.0, 1.0);
    final shields = c.engine.maxShieldCharges();
    return AnimatedBuilder(
      animation: _break,
      builder: (context, child) {
        final k = _break.value;
        final dx = k == 0
            ? 0.0
            : 8 * (1 - k) * (k * 40).remainder(2) - 4 * (1 - k);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: SizedBox(
        height: 30,
        // At full heat (big label, shields) the row can outgrow a narrow
        // phone: shrink it instead of overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l.comboLabel} ×${mult.toStringAsFixed(2).replaceAll('.', l.decimalSeparator)}',
                key: const Key('combo'),
                style: TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 18 + 6 * heat,
                  color: Color.lerp(Palette.outline, Palette.accent, heat),
                ),
              ),
              const SizedBox(width: 6),
              // The flame grows inside a box sized for its largest size:
              // a scale alone only paints bigger, and at full heat it
              // covered the multiplier, the streak and the dial's foot
              // (playtest).
              SizedBox.square(
                dimension: _flame,
                child: Center(
                  child: AnimatedScale(
                    scale: 0.5 + 0.5 * heat,
                    duration: const Duration(milliseconds: 200),
                    child: Opacity(
                      opacity: streak > 0 ? 1 : 0.3,
                      child: Image.asset(
                        EmojiArt.path('fire'),
                        width: _flame,
                        height: _flame,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l.streakLabel(streak),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Palette.outline.withValues(alpha: 0.7),
                ),
              ),
              for (var i = 0; i < shields; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Opacity(
                    opacity: i < c.state.shieldCharges ? 1 : 0.25,
                    child: Image.asset(
                      EmojiArt.path('shield'),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
