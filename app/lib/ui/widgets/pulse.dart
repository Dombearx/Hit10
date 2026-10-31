import 'package:flutter/material.dart';

import '../theme.dart';

/// A breathing golden glow around [child] while [active]: "tap here"
/// (the tutorial's buy step, R-TUT-1). Idle, it is just the child.
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    if (widget.active) {
      _a.repeat(reverse: true);
    } else {
      _a
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (context, child) {
        final k = Curves.easeInOut.transform(_a.value);
        return Transform.scale(
          scale: 1 + 0.08 * k,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Palette.perfect.withValues(alpha: 0.5 + 0.5 * k),
                  blurRadius: 6 + 14 * k,
                  spreadRadius: 1 + 4 * k,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// A small red dot on a tab or icon: something new or affordable there.
class AlertDot extends StatelessWidget {
  const AlertDot({super.key, required this.show, required this.child});
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
