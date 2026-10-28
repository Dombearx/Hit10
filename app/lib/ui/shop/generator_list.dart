import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/buy_button.dart';
import '../widgets/emoji_card.dart';

enum BuyAmount { one, ten, hundred, max }

/// The "Clocks" tab: revealed generators, then one silhouette (R-GEN-4).
class GeneratorList extends StatelessWidget {
  const GeneratorList({
    super.key,
    required this.controller,
    required this.amount,
  });

  final GameController controller;
  final BuyAmount amount;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final ids = <String>[];
    String? silhouette;
    for (final g in c.balance.generators) {
      if (!c.econ.generatorUnlocked(g.id)) continue;
      final i = c.balance.generators.indexOf(g);
      final prevOwned =
          i == 0 || c.econ.owned(c.balance.generators[i - 1].id) > 0;
      if (prevOwned || c.econ.owned(g.id) > 0) {
        ids.add(g.id);
      } else {
        silhouette = g.id;
        break;
      }
    }
    final total = c.engine.passive();
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        for (final id in ids)
          _GeneratorTile(
            key: ValueKey(id),
            controller: c,
            id: id,
            amount: amount,
            totalIncome: total,
          ),
        if (silhouette != null) _LockedTile(controller: c, id: silhouette),
      ],
    );
  }
}

class _GeneratorTile extends StatelessWidget {
  const _GeneratorTile({
    super.key,
    required this.controller,
    required this.id,
    required this.amount,
    required this.totalIncome,
  });

  final GameController controller;
  final String id;
  final BuyAmount amount;
  final double totalIncome;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final owned = c.econ.owned(id);
    final count = switch (amount) {
      BuyAmount.one => 1,
      BuyAmount.ten => 10,
      BuyAmount.hundred => 100,
      BuyAmount.max => c.econ.maxAffordable(id, c.state.tiki).clamp(1, 1 << 30),
    };
    final price = c.econ.bulkCost(id, count);
    final affordable = price <= c.state.tiki;
    final unit = c.econ.unitRate(id) * c.econ.permanentMultiplier();
    final rate = unit * owned;
    final share = totalIncome > 0 ? rate / totalIncome * 100 : 0.0;
    final gain = c.econ.windowGain(id);
    final sub = owned == 0
        ? generatorDescription(l, id)
        : [
            l.unitRate(f.n(unit)),
            if (owned > 0)
              l.incomeShare(
                share
                    .toStringAsFixed(share < 10 ? 1 : 0)
                    .replaceAll('.', l.decimalSeparator),
              ),
            if (gain > 1.005)
              l.windowBonus(
                gain.toStringAsFixed(2).replaceAll('.', l.decimalSeparator),
              ),
          ].join(' · ');
    return _TileFrame(
      child: Row(
        children: [
          EmojiCard(
            art: generatorArt[id]!,
            size: 54,
            badge: owned > 0 ? f.n(owned.toDouble()) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  generatorName(l, id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.2,
                    color: Palette.outline.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BuyButton(
            key: Key('buy-$id'),
            label: amount == BuyAmount.one ? null : '×$count',
            price: f.price(price),
            enabled: affordable,
            onPressed: () => c.buyGenerators(id, count),
          ),
        ],
      ),
    );
  }
}

class _LockedTile extends StatelessWidget {
  const _LockedTile({required this.controller, required this.id});
  final GameController controller;
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Opacity(
      opacity: 0.75,
      child: _TileFrame(
        child: Row(
          children: [
            EmojiCard(art: generatorArt[id]!, size: 54, locked: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.lockedName,
                    style: const TextStyle(
                      fontFamily: Fonts.display,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    l.lockedHint,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Palette.outline.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileFrame extends StatelessWidget {
  const _TileFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Palette.outline, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}
