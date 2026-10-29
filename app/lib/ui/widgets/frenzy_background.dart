import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game_controller.dart';
import '../seasons_ui.dart';
import '../theme.dart';

/// The warm gradient (or the season's, §3.1); during Frenzy it turns neon
/// and pulses (docs/04 §3).
class FrenzyBackground extends StatefulWidget {
  const FrenzyBackground({
    super.key,
    required this.controller,
    required this.child,
  });
  final GameController controller;
  final Widget child;

  @override
  State<FrenzyBackground> createState() => _FrenzyBackgroundState();
}

class _FrenzyBackgroundState extends State<FrenzyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  double _mix = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    widget.controller.bulletZone.addListener(_onZone);
  }

  void _onZone() {
    final zone = widget.controller.inBulletZone;
    if (zone != _zone) setState(() => _zone = zone);
  }

  bool _zone = false;
  late String? _theme = widget.controller.themeId;

  void _onChange() {
    final theme = widget.controller.themeId;
    if (theme != _theme) setState(() => _theme = theme);
    final on = widget.controller.engine.frenzyLeft > 0;
    if (on && !_pulse.isAnimating) _pulse.repeat();
    if (!on && _pulse.isAnimating) {
      _pulse.stop();
      setState(() => _mix = 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    widget.controller.bulletZone.removeListener(_onZone);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        if (_pulse.isAnimating) {
          _mix = math.min(1, _mix + 0.05);
        }
        // "Reduce motion" (U-6): neon stays, the pulsing doesn't.
        final p = widget.controller.settings.reduceMotion
            ? 0.5
            : 0.5 + 0.5 * math.sin(_pulse.value * math.pi * 2);
        final look = seasonLooks[_theme];
        final top = Color.lerp(
          look?.bgTop ?? Palette.bgTop,
          Color.lerp(Palette.neonMagenta, Palette.neonCyan, p),
          _mix * 0.85,
        )!;
        final bottom = Color.lerp(
          look?.bgBottom ?? Palette.bgBottom,
          Color.lerp(Palette.neonCyan, Palette.neonMagenta, p),
          _mix * 0.85,
        )!;
        // Zimna krew's focus zone: the world drains of colour, edges darken.
        return TweenAnimationBuilder<double>(
          tween: Tween(end: _zone ? 1 : 0),
          duration: const Duration(milliseconds: 250),
          child: child,
          builder: (context, z, child) => Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_grey(top, z), _grey(bottom, z)],
                  ),
                ),
                child: child,
              ),
              if (z > 0)
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.95,
                        colors: [
                          const Color(0x00000000),
                          Palette.outline.withValues(alpha: 0.45 * z),
                        ],
                        stops: const [0.55, 1],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      // The game repaints on its own; the pulsing background and the
      // vignette must not drag the whole screen into every frame.
      child: RepaintBoundary(child: widget.child),
    );
  }

  static Color _grey(Color c, double k) {
    final l = c.computeLuminance();
    final g = Color.fromARGB(
      255,
      (l * 255).round(),
      (l * 255).round(),
      (l * 255).round(),
    );
    return Color.lerp(c, Color.lerp(g, c, 0.25), k * 0.75)!;
  }
}
