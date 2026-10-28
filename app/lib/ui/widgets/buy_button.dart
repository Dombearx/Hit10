import 'package:flutter/material.dart';

import '../theme.dart';

/// Chunky pink price button that squashes on press (docs/04 §3 "Zakup").
class BuyButton extends StatefulWidget {
  const BuyButton({
    super.key,
    required this.price,
    required this.enabled,
    required this.onPressed,
    this.label,
    this.minWidth = 84,
  });

  final String price;

  /// Optional small line above the price ("×10").
  final String? label;
  final bool enabled;
  final VoidCallback onPressed;
  final double minWidth;

  @override
  State<BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<BuyButton> {
  bool _down = false;

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
            }
          : null,
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
    );
  }
}
