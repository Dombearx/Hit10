import 'package:flutter/material.dart';

import '../../ads/rewarded_ads.dart';
import '../../engine/ad_offers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'ad_buttons.dart';
import 'buy_button.dart';
import 'emoji_card.dart';

/// The offer before a rewarded ad (docs/02 §13, AdMob policy): what the
/// player gets, that it is a short video, and a way to say no. Only "Watch"
/// plays the ad; the result is confirmed afterwards ([confirmAdResult]).
Future<void> offerAd(
  BuildContext context,
  GameController c,
  AdOffer offer,
  RewardedAds ads,
) async {
  c.pause(); // a running round must not end while the player reads
  final watch = await showDialog<bool>(
    context: context,
    builder: (context) => _OfferDialog(controller: c, offer: offer),
  );
  if (watch != true || !context.mounted) return;
  final ok = await watchAdWithReward(context, c, offer, ads);
  if (context.mounted) confirmAdResult(context, c, offer, ok);
}

/// After the ad: the reward in words, or why there is none (Poki, Unity:
/// the player must know they were rewarded).
void confirmAdResult(
  BuildContext context,
  GameController c,
  AdOffer offer,
  bool ok,
) {
  final l = AppLocalizations.of(context);
  final text = !ok
      ? l.adNoReward
      : switch (offer) {
          AdOffer.turbo => l.adDoneTurbo(clockText(c.state.turboLeft)),
          AdOffer.golden => l.adDoneGolden,
          AdOffer.bag => l.adDoneBag,
          AdOffer.rescue => l.adDoneRescue,
          AdOffer.offline => l.adDoneOffline,
        };
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: ok ? 3 : 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class _OfferDialog extends StatelessWidget {
  const _OfferDialog({required this.controller, required this.offer});
  final GameController controller;
  final AdOffer offer;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final cfg = c.balance.ads;
    final minutes = (cfg.turboDuration / 60).round();
    final (
      EmojiArt art,
      String title,
      String reward,
      String detail,
    ) = switch (offer) {
      AdOffer.turbo => (
        const EmojiArt('high_voltage', Color(0xFFB8F0E6)),
        l.adOfferTurboTitle,
        l.adOfferTurboReward(cfg.turboMultiplier.round(), minutes),
        l.adOfferTurboDetail((cfg.turboMaxStock / 3600).round()) +
            (c.state.turboLeft > 0
                ? '\n${l.adOfferTurboStock(clockText(c.state.turboLeft))}'
                : ''),
      ),
      AdOffer.golden => (
        const EmojiArt('glowing_star', Color(0xFFFFE6A7)),
        l.adOfferGoldenTitle,
        l.adOfferGoldenReward,
        l.adOfferGoldenDetail,
      ),
      AdOffer.bag => (
        const EmojiArt('money_bag', Color(0xFFFFE6A7)),
        l.adOfferBagTitle,
        '+${f.n(c.engine.passive() * cfg.bagProductionSeconds)}',
        l.adOfferBagDetail((cfg.bagProductionSeconds / 60).round()),
      ),
      // Rescue and offline say everything on their own buttons.
      _ => (const EmojiArt('television', Colors.white), '', '', ''),
    };
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Palette.outline, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmojiCard(art: art, size: 64),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: Fonts.display, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              reward,
              key: const Key('ad-offer-reward'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: Fonts.display,
                fontSize: 22,
                color: Palette.perfectDeep,
              ),
            ),
            const SizedBox(height: 6),
            Text(detail, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(EmojiArt.path('television'), width: 18, height: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.adOfferHow,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Palette.outline.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            BuyButton(
              key: const Key('ad-watch'),
              price: l.adWatch,
              enabled: true,
              celebrate: false,
              minWidth: 160,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              key: const Key('ad-not-now'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l.adNotNow,
                style: const TextStyle(color: Palette.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
