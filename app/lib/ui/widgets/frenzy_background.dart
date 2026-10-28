import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game_controller.dart';
import '../theme.dart';

/// The warm gradient; during Frenzy it turns neon and pulses (docs/04 §3).
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
  }

  void _onChange() {
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
        final p = 0.5 + 0.5 * math.sin(_pulse.value * math.pi * 2);
        final top = Color.lerp(
          Palette.bgTop,
          Color.lerp(Palette.neonMagenta, Palette.neonCyan, p),
          _mix * 0.85,
        )!;
        final bottom = Color.lerp(
          Palette.bgBottom,
          Color.lerp(Palette.neonCyan, Palette.neonMagenta, p),
          _mix * 0.85,
        )!;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
