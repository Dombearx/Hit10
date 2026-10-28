import 'package:flutter/material.dart';

import '../../model/number_format.dart';
import '../theme.dart';

/// Tiki balance that rolls towards its new value and bounces on gains
/// (docs/04 U-3).
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.decimalSeparator,
    this.style,
  });

  final double value;
  final String decimalSeparator;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (widget.value != _to) {
      _from = _current;
      _to = widget.value;
      _roll.forward(from: 0);
      if (_to > _from) _bump.forward(from: 0);
    }
  }

  double get _current {
    final v = _from + (_to - _from) * Curves.easeOut.transform(_roll.value);
    // Rolling between whole numbers shows whole numbers ("9,6" looks broken).
    final whole = _from == _from.roundToDouble() && _to == _to.roundToDouble();
    return whole ? v.roundToDouble() : v;
  }

  @override
  void dispose() {
    _roll.dispose();
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_roll, _bump]),
      builder: (context, _) {
        final b = _bump.value;
        final scale = 1 + 0.12 * (b < 0.4 ? b / 0.4 : (1 - b) / 0.6);
        return Transform.scale(
          scale: scale,
          child: Text(
            formatNumber(_current, decimalSeparator: widget.decimalSeparator),
            style:
                widget.style ??
                const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 40,
                  color: Palette.outline,
                ),
          ),
        );
      },
    );
  }
}
