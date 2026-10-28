import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';
import 'burst.dart';

/// Chunky pink price button that squashes on press (docs/04 §3 "Zakup").
class BuyButton extends ConsumerStatefulWidget {
  const BuyButton({
    super.key,
    required this.price,
    required this.enabled,
    required this.onPressed,
    this.label,
    this.minWidth = 84,
    this.celebrate = true,
  });

  /// Coins and a bounce on press; off where the reward comes later (ads).
  final bool celebrate;

  final String price;

  /// Optional small line above the price ("×10").
  final String? label;
  final bool enabled;
  final VoidCallback onPressed;
  final double minWidth;

  @override
  ConsumerState<BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends ConsumerState<BuyButton>
    with SingleTickerProviderStateMixin {
  bool _down = false;

  /// After a purchase: 0.95 → 1.05 → 1 (docs/04 §3).
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1, // at rest: the sequence's end, scale 1
  );
  late final Animation<double> _popScale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _celebrate() {
    _pop.forward(from: 0);
    showBurst(
      context,
      count: 10,
      spread: 0.6,
      reduceMotion: ref.read(gameControllerProvider).settings.reduceMotion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.enabled;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: on
          ? (_) {
              setState(() => _down = false);
              widget.onPressed();
              if (widget.celebrate) _celebrate();
            }
          : null,
      child: ScaleTransition(
        scale: _popScale,
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            constraints: BoxConstraints(minWidth: widget.minWidth),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: on ? Palette.accent : const Color(0xFFD9D2C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Palette.outline, width: 2.5),
              boxShadow: [
                if (!_down)
                  const BoxShadow(color: Palette.outline, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : Palette.outline,
                      height: 1.1,
                    ),
                  ),
                Text(
                  widget.price,
                  style: TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 17,
                    color: on
                        ? Colors.white
                        : Palette.outline.withValues(alpha: 0.6),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
