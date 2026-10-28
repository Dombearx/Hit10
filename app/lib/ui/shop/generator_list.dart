import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/ad_offers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../providers.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/ad_buttons.dart';
import '../widgets/buy_button.dart';
import '../widgets/emoji_card.dart';

enum BuyAmount { one, ten, hundred, max }

/// The "Clocks" tab: revealed generators, then one silhouette (R-GEN-4).
class GeneratorList extends StatefulWidget {
  const GeneratorList({
    super.key,
    required this.controller,
    required this.amount,
  });

  final GameController controller;
  final BuyAmount amount;

  @override
  State<GeneratorList> createState() => _GeneratorListState();
}

class _GeneratorListState extends State<GeneratorList> {
  /// Generators already on show; one that joins later gets the reveal
  /// flash (docs/04 §3 "Nowy generator odkryty"). Null until first build,
  /// so nothing flashes at launch.
  Set<String>? _seen;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final amount = widget.amount;
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
    // One bag offer, on the newest clock the player is saving for.
    final bagId = ids.lastWhere(
      (id) => c.econ.generatorCost(id) > c.state.tiki,
      orElse: () => '',
    );
    final seen = _seen ??= ids.toSet();
    final fresh = ids.where((id) => !seen.contains(id)).toSet();
    seen.addAll(ids);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        for (final id in ids)
          _RevealFlash(
            key: ValueKey(id),
            active: fresh.contains(id),
            reduceMotion: c.settings.reduceMotion,
            child: _GeneratorTile(
              controller: c,
              id: id,
              amount: amount,
              totalIncome: total,
              offerBag: id == bagId,
            ),
          ),
        if (silhouette != null) _LockedTile(controller: c, id: silhouette),
      ],
    );
  }
}

/// A white flash and a pop when a generator first appears.
class _RevealFlash extends StatefulWidget {
  const _RevealFlash({
    super.key,
    required this.active,
    required this.reduceMotion,
    required this.child,
  });
  final bool active;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_RevealFlash> createState() => _RevealFlashState();
}

class _RevealFlashState extends State<_RevealFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _a.forward(from: 0);
  }

  @override
  void didUpdateWidget(_RevealFlash old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _a.forward(from: 0);
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (context, child) {
        final k = _a.value;
        if (k >= 1) return child!;
        final pop = 1 + 0.06 * math.sin(k * math.pi);
        final flash = widget.reduceMotion ? 0.0 : (1 - k) * 0.85;
        return Transform.scale(
          scale: pop,
          child: Stack(
            children: [
              child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: flash),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GeneratorTile extends StatelessWidget {
  const _GeneratorTile({
    required this.controller,
    required this.id,
    required this.amount,
    required this.totalIncome,
    required this.offerBag,
  });

  final GameController controller;
  final String id;
  final BuyAmount amount;
  final double totalIncome;
  final bool offerBag;

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
    final bag = offerBag ? _bagButton(context, c) : null;
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
                // Long names (EN, small screens) shrink rather than cut.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    generatorName(l, id),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
          if (!affordable && bag != null) ...[bag, const SizedBox(width: 6)],
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

/// adBag (U-23): "📺 +5 min" on a card the player cannot afford yet.
Widget? _bagButton(BuildContext context, GameController c) {
  if (!c.ads.available(AdOffer.bag, c.wallMs())) return null;
  final l = AppLocalizations.of(context);
  final ads = ProviderScope.containerOf(context).read(rewardedAdsProvider);
  return GestureDetector(
    key: const Key('ad-bag'),
    onTap: () => watchAdWithReward(context, c, AdOffer.bag, ads),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.perfect,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.outline, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(EmojiArt.path('television'), width: 18, height: 18),
          Text(
            l.adBag((c.balance.ads.bagProductionSeconds / 60).round()),
            style: const TextStyle(fontFamily: Fonts.display, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
