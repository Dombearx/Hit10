import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'alert_dot.dart';
import 'emoji_card.dart';
import 'mode_row.dart';

/// The auto buyer's chip in the mode row (docs/02 §9.3). Off: a plain
/// switch. Buying: green, the clock and how far to its bonus. Waiting:
/// orange with a dot until the player picks again, and one pulse after a
/// while (GameController.autoNudge), never more.
class AutoBuyerChip extends StatefulWidget {
  const AutoBuyerChip({super.key, required this.controller});
  final GameController controller;

  @override
  State<AutoBuyerChip> createState() => _AutoBuyerChipState();
}

class _AutoBuyerChipState extends State<AutoBuyerChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late int _nudge = widget.controller.autoNudge;

  @override
  void didUpdateWidget(AutoBuyerChip old) {
    super.didUpdateWidget(old);
    final n = widget.controller.autoNudge;
    if (n != _nudge) {
      _nudge = n;
      if (!widget.controller.settings.reduceMotion) _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final e = c.engine;
    final s = c.state;
    final l = AppLocalizations.of(context);
    final on = s.autoBuyerOn;
    final waiting = e.autoBuyerWaiting;
    final target = s.autoTarget;
    final String label;
    // On with no clock yet: just its name; the cart, the orange and the
    // dot already say it waits for a pick (the sheet explains the rest).
    if (!on || target == null) {
      label = l.modeAuto;
    } else if (waiting) {
      label = l.autoDone('${s.autoUntil}');
    } else {
      label = l.autoBuying('${c.econ.owned(target)}', '${s.autoUntil}');
    }
    final color = !on
        ? Colors.white.withValues(alpha: 0.65)
        : waiting
        ? Palette.perfectDeep
        : Palette.great;
    final chip = ModeChip(
      label: label,
      labelKey: const Key('mode-auto-label'),
      color: color,
      textColor: on ? Colors.white : Palette.outline,
      leading: [
        if (on)
          Image.asset(EmojiArt.path('shopping_cart'), width: 16, height: 16),
        // The clock by its picture: the names are too long for a chip.
        if (on && target != null)
          Image.asset(
            EmojiArt.path(generatorArt[target]!.main),
            key: Key('mode-auto-clock-$target'),
            width: 18,
            height: 18,
          ),
      ],
    );
    return GestureDetector(
      key: Key('mode-auto${waiting ? '-waiting' : ''}'),
      onTap: () {
        if (!on && target != null && !waiting) {
          c.setMode(autoBuyer: true);
        } else {
          showAutoBuyerSheet(context, c);
        }
      },
      child: AnimatedBuilder(
        animation: _pulse,
        child: AlertDot(
          show: waiting,
          dotKey: Key('mode-auto-alert-$waiting'),
          child: chip,
        ),
        builder: (context, child) {
          final k = _pulse.value;
          // Two soft beats, then still.
          final scale = k == 0 || k == 1
              ? 1.0
              : 1 + 0.12 * math.sin(k * 4 * math.pi).abs();
          return Transform.scale(scale: scale, child: child);
        },
      ),
    );
  }
}

/// Pick the auto buyer's clock: the clocks the shop shows, in its order,
/// with how far the next bonus is. Nothing is recommended: choosing is the
/// player's part (docs/02 §9.3).
Future<void> showAutoBuyerSheet(BuildContext context, GameController c) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final e = c.engine;
        final s = c.state;
        final ids = [
          for (final g in c.balance.generators)
            if (e.shopShows(g.id)) g.id,
        ];
        final target = s.autoTarget;
        final again =
            target != null && e.autoBuyerWaiting && e.shopShows(target);
        void pick(String id) {
          c.setAutoTarget(id);
          Navigator.of(context).pop();
        }

        final every = c.balance.perk('autoBuyer').params['intervalSeconds']!;
        return Container(
          key: const Key('auto-sheet'),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.modeAuto,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.autoSheetHint(every.round().toString()),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (again) ...[
                  _SheetButton(
                    key: const Key('auto-continue'),
                    text: l.autoContinue(
                      generatorName(l, target),
                      '${e.autoGoalFor(target)}',
                    ),
                    color: Palette.great,
                    onTap: () => pick(target),
                  ),
                  const SizedBox(height: 10),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final id in ids)
                          _ClockRow(
                            controller: c,
                            id: id,
                            selected: id == target,
                            onTap: () => pick(id),
                          ),
                      ],
                    ),
                  ),
                ),
                if (s.autoBuyerOn) ...[
                  const SizedBox(height: 6),
                  _SheetButton(
                    key: const Key('auto-off'),
                    text: l.autoOff,
                    color: Colors.white,
                    onTap: () {
                      c.setMode(autoBuyer: false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _ClockRow extends StatelessWidget {
  const _ClockRow({
    required this.controller,
    required this.id,
    required this.selected,
    required this.onTap,
  });
  final GameController controller;
  final String id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final owned = c.econ.owned(id);
    return GestureDetector(
      key: Key('auto-pick-$id'),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? Palette.great.withValues(alpha: 0.18)
              : Palette.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Palette.outline,
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            EmojiCard(art: generatorArt[id]!, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                generatorName(l, id),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$owned → ${c.engine.autoGoalFor(id)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Palette.perfectText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });
  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = color != Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Palette.outline, width: 2.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: Fonts.display,
            fontSize: 16,
            color: dark ? Colors.white : Palette.outline,
          ),
        ),
      ),
    );
  }
}
