import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/number_format.dart';
import '../game_controller.dart';
import '../theme.dart';

/// Active golden-second effects with a countdown (R-ZLOTA-4).
class EffectChips extends StatelessWidget {
  const EffectChips({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final e = controller.engine;
    final l = AppLocalizations.of(context);
    String clock(double s) {
      final t = s.ceil();
      return '${t ~/ 60}:${(t % 60).toString().padLeft(2, '0')}';
    }

    final chips = <Widget>[
      if (e.frenzyLeft > 0)
        _Chip(
          key: const Key('chip-frenzy'),
          text:
              '${l.chipFrenzy(formatNumber(controller.balance.golden.effect('frenzy').multiplier))} · ${clock(e.frenzyLeft)}',
          color: Palette.neonMagenta,
        ),
      if (e.hotHandLeft > 0)
        _Chip(
          key: const Key('chip-hothand'),
          text: '${l.chipHotHand} · ${clock(e.hotHandLeft)}',
          color: Palette.perfectDeep,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Wrap(spacing: 6, children: chips),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.outline, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: Fonts.display,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
