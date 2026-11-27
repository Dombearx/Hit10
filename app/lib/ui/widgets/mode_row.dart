import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../screens/loop_screen.dart';
import '../theme.dart';
import 'auto_buyer.dart';

/// Risk modes, second clock and auto buyer, shown once unlocked
/// (docs/02 §7, §9). Changes apply from the next round, Blind switched on
/// before 4.00 at once (R-TRYB-1).
class ModeRow extends StatelessWidget {
  const ModeRow({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final e = c.engine;
    final s = c.state;
    final l = AppLocalizations.of(context);
    final chips = <Widget>[
      if (e.blindForced)
        _Toggle(
          key: const Key('mode-blind'),
          label: l.modeBlind(e.blindMultiplier().round()),
          on: true,
          onTap: () => showChronicle(context, c),
        )
      else if (e.blindUnlocked())
        _Toggle(
          key: const Key('mode-blind'),
          label: l.modeBlind(e.blindMultiplier().round()),
          on: s.modeBlind,
          note: c.blindPending ? l.modeNextRound : null,
          onTap: () => c.setMode(blind: !s.modeBlind),
        ),
      if (s.perks.contains('secondClock'))
        _Toggle(
          key: const Key('mode-second'),
          label: l.modeSecond,
          on: s.secondClockOn,
          onTap: () => c.setMode(secondClock: !s.secondClockOn),
        ),
      if (s.perks.contains('autoBuyer')) AutoBuyerChip(controller: c),
      // The loop and its rule, after the switches: a tap says what it
      // changes (R-PETLA-4).
      if (s.loop > 1)
        _Toggle(
          key: const Key('loop-chip'),
          label: s.loopRules.isEmpty
              ? l.loopNumber(s.loop)
              : '${l.loopNumber(s.loop)} · ${s.loopRules.map((r) => ruleName(l, r)).join(' + ')}',
          on: false,
          onTap: () => showChronicle(context, c),
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    // Wrapped, not scrolled: every switch stays in sight whichever ones
    // are unlocked, on any width and text size. A chip wider than the row
    // shortens its label (ModeChip) instead of spilling over the edge.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: LayoutBuilder(
        builder: (context, box) => Wrap(
          key: const Key('mode-row'),
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final ch in chips)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth),
                child: ch,
              ),
          ],
        ),
      ),
    );
  }
}

/// The one look and layout of every chip in the mode row: at least a
/// finger high, never wider than it is given, the label on one line and
/// shortened with "…" rather than overflowing. New chips build on this so
/// a longer text or a translation can't break the row.
class ModeChip extends StatelessWidget {
  const ModeChip({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    this.leading = const [],
    this.note,
    this.labelKey,
  });
  final String label;
  final Color color;
  final Color textColor;

  /// Small pictures before the label (the auto buyer's cart and clock).
  final List<Widget> leading;

  /// A second, smaller line: "from the next round" while a switch waits.
  final String? note;
  final Key? labelKey;

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      label,
      key: labelKey,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: Fonts.display,
        fontSize: 13,
        color: textColor,
      ),
    );
    if (note != null) {
      text = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          Text(
            note!,
            key: const Key('mode-note'),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: textColor),
          ),
        ],
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      // 36 high: a finger's target without crowding the arena.
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.outline, width: 2),
      ),
      // A Row sized to its content (not an Align, which would stretch the
      // chip to the whole row) that centres the label in the 36 height.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final w in leading) ...[w, const SizedBox(width: 4)],
          Flexible(child: text),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
    this.note,
  });
  final String label;
  final bool on;
  final VoidCallback onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ModeChip(
        label: label,
        note: note,
        color: on ? Palette.great : Colors.white.withValues(alpha: 0.65),
        textColor: on ? Colors.white : Palette.outline,
      ),
    );
  }
}
