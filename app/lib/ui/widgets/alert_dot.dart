import 'package:flutter/material.dart';

/// A small red dot on a tab or icon: something new or affordable there.
class AlertDot extends StatelessWidget {
  const AlertDot({
    super.key,
    required this.show,
    required this.child,
    this.dotKey,
  });
  final bool show;
  final Key? dotKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        KeyedSubtree(key: dotKey, child: child),
        if (show) const Positioned(right: -3, top: -3, child: RedDot()),
      ],
    );
  }
}

/// The red "something new here" dot on its own, for placing in a row.
class RedDot extends StatelessWidget {
  const RedDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
