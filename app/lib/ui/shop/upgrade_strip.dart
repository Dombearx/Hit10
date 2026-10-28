import 'package:flutter/material.dart';

import '../../balance/balance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../model/economy.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/buy_button.dart';
import '../widgets/emoji_card.dart';

/// Horizontal strip of upgrades and synergies that can be bought now,
/// cheapest first (R-ULEP-3). Tapping one opens its details.
class UpgradeStrip extends StatelessWidget {
  const UpgradeStrip({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final items = <_Item>[
      for (final u in c.econ.availableUpgrades()) _Item.upgrade(u),
      for (final syn in c.econ.availableSynergies()) _Item.synergy(syn),
    ]..sort((a, b) => a.cost.compareTo(b.cost));
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          final affordable = it.cost <= c.state.tiki;
          return GestureDetector(
            key: Key('upgrade-${it.key}'),
            onTap: () => _showDetails(context, c, it),
            child: AnimatedOpacity(
              opacity: affordable ? 1 : 0.55,
              duration: const Duration(milliseconds: 200),
              child: _ItemIcon(item: it, size: 50),
            ),
          );
        },
      ),
    );
  }

  static void _showDetails(BuildContext context, GameController c, _Item it) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final l = AppLocalizations.of(context);
          final f = Fmt.of(context, c);
          final (title, effect) = it.describe(l, c);
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Palette.outline, width: 3),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _ItemIcon(item: it, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: Fonts.display,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(effect, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BuyButton(
                    key: const Key('detail-buy'),
                    price: f.price(it.cost),
                    enabled: it.cost <= c.state.tiki && it.stillAvailable(c),
                    onPressed: () {
                      it.buy(c);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  _Item.upgrade(GeneratorUpgrade this.upgrade)
    : synergy = null,
      cost = upgrade.cost,
      key = '${upgrade.generator}-${upgrade.index}';
  _Item.synergy(SynergyConfig this.synergy)
    : upgrade = null,
      cost = synergy.cost,
      key = synergy.id;

  final GeneratorUpgrade? upgrade;
  final SynergyConfig? synergy;
  final double cost;
  final String key;

  bool stillAvailable(GameController c) {
    final u = upgrade;
    if (u != null) return c.econ.upgradesBought(u.generator) == u.index;
    return !c.state.synergies.contains(synergy!.id);
  }

  void buy(GameController c) {
    final u = upgrade;
    if (u != null) {
      c.buyUpgrade(u.generator);
    } else {
      c.buySynergy(synergy!.id);
    }
  }

  (String, String) describe(AppLocalizations l, GameController c) {
    final u = upgrade;
    if (u != null) {
      final name = generatorName(l, u.generator);
      return (l.upgradeName(name, roman(u.index)), l.upgradeEffect(name));
    }
    final s = synergy!;
    String pct(double v) => (v * 100).toStringAsFixed(v * 100 < 1 ? 1 : 0);
    return (
      synergyName(l, s.id),
      l.synergyEffect(
        generatorName(l, s.a),
        generatorName(l, s.b),
        pct(s.aPerB),
        pct(s.bPerA),
      ),
    );
  }
}

class _ItemIcon extends StatelessWidget {
  const _ItemIcon({required this.item, required this.size});
  final _Item item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final u = item.upgrade;
    if (u != null) {
      return EmojiCard(
        art: generatorArt[u.generator]!,
        size: size,
        badge: roman(u.index),
      );
    }
    final s = item.synergy!;
    return SizedBox(
      width: size * 1.25,
      height: size,
      child: Stack(
        children: [
          EmojiCard(art: generatorArt[s.a]!, size: size * 0.78),
          Positioned(
            right: 0,
            bottom: 0,
            child: EmojiCard(art: generatorArt[s.b]!, size: size * 0.78),
          ),
        ],
      ),
    );
  }
}
