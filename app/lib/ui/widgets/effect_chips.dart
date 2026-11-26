import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/number_format.dart';
import '../format.dart';
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

    // At 0:00 a chip stays, faded, while a round that started inside the
    // effect is still running: that round gets it (R-ZLOTA-7).
    final frenzy = l.chipFrenzy(
      formatNumber(controller.balance.golden.effect('frenzy').multiplier),
    );
    final chips = <Widget>[
      if (e.frenzyLeft > 0 || e.frenzyLastRound)
        _Chip(
          key: const Key('chip-frenzy'),
          text: e.frenzyLeft > 0
              ? '$frenzy · ${clock(e.frenzyLeft)}'
              : '$frenzy · ${l.chipLastRound}',
          color: Palette.neonMagenta,
          faded: e.frenzyLeft <= 0,
        ),
      if (e.hotHandLeft > 0 || e.hotHandLastRound)
        _Chip(
          key: const Key('chip-hothand'),
          text: e.hotHandLeft > 0
              ? '${l.chipHotHand} · ${clock(e.hotHandLeft)}'
              : '${l.chipHotHand} · ${l.chipLastRound}',
          color: Palette.perfectDeep,
          faded: e.hotHandLeft <= 0,
        ),
      // "Na start!" (Sprint judge, docs/18): the hits left that pay more.
      if (controller.state.warmUpHits > 0)
        _Chip(
          key: const Key('chip-warmup'),
          text: l.chipWarmUp(
            Fmt.of(context, controller).mult(controller.state.warmUpMultiplier),
            controller.state.warmUpHits,
          ),
          color: Palette.great,
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
  const _Chip({
    super.key,
    required this.text,
    required this.color,
    this.faded = false,
  });
  final String text;
  final Color color;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: faded ? 0.6 : 1, child: _box());
  }

  Widget _box() {
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
