import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/rewarded_ads.dart';
import '../../engine/ad_offers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../theme.dart';
import 'ad_offer_sheet.dart';
import 'burst.dart';

String clockText(double seconds) {
  final t = seconds.ceil();
  final h = t ~/ 3600;
  final m = (t % 3600) ~/ 60;
  final s = t % 60;
  return h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
      : '$m:${s.toString().padLeft(2, '0')}';
}

/// Turbo and Golden-second tiles beside the clock (U-22). They sit outside
/// the tap area of the arena so nobody hits an ad by accident.
class AdCornerButtons extends ConsumerWidget {
  const AdCornerButtons({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = controller;
    if (!c.ads.unlocked) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final adsProvider = ref.watch(rewardedAdsProvider);
    final now = c.wallMs();
    Widget tile(AdOffer o, String label, Key key) {
      final can = c.ads.available(o, now) && adsProvider.isReady;
      final cd = c.ads.cooldownLeftMs(o, now);
      final sub = cd > 0
          ? l.adCooldown(clockText(cd / 1000))
          : (!can && o == AdOffer.turbo ? l.adFull : null);
      return GestureDetector(
        key: key,
        onTap: can
            ? () => unawaited(offerAd(context, c, o, adsProvider))
            : null,
        child: Opacity(
          opacity: can ? 1 : 0.55,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
            decoration: BoxDecoration(
              color: o == AdOffer.turbo ? Palette.great : Palette.perfect,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Palette.outline, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(EmojiArt.path('television'), width: 22, height: 22),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 12,
                        color: Palette.outline,
                        height: 1.1,
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub,
                        style: const TextStyle(fontSize: 10, height: 1.1),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tile(
          AdOffer.turbo,
          c.state.turboLeft > 0
              ? l.adTurboLeft(clockText(c.state.turboLeft))
              : l.adTurbo,
          const Key('ad-turbo'),
        ),
        tile(AdOffer.golden, l.adGolden, const Key('ad-golden')),
      ],
    );
  }
}

/// "Streak 18 lost! 📺 Restore" with a 5 s fuse (U-24).
class RescuePopup extends ConsumerWidget {
  const RescuePopup({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = controller;
    final r = c.ads.rescue;
    final adsProvider = ref.watch(rewardedAdsProvider);
    if (r == null || !c.ads.available(AdOffer.rescue, c.wallMs())) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final left = (r.expiresAtPlay - c.state.playSeconds).clamp(0.0, 9.0);
    return GestureDetector(
      key: const Key('ad-rescue'),
      // The 5 s offer says it all on the button: no second screen.
      onTap: () => unawaited(() async {
        final ok = await watchAdWithReward(
          context,
          c,
          AdOffer.rescue,
          adsProvider,
        );
        if (context.mounted) confirmAdResult(context, c, AdOffer.rescue, ok);
      }()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Palette.accent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Palette.outline, width: 2.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(EmojiArt.path('television'), width: 22, height: 22),
            const SizedBox(width: 6),
            Text(
              '${l.adRescue(r.streak)} · ${left.ceil()}',
              style: const TextStyle(
                fontFamily: Fonts.display,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plays the ad and, once the reward lands, a full burst where the offer
/// was (U-25). The button itself may be gone by then (cooldown), so its
/// place is taken before the ad.
Future<bool> watchAdWithReward(
  BuildContext context,
  GameController c,
  AdOffer offer,
  RewardedAds ads,
) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final at = centerOf(context);
  final ok = await c.watchAd(offer, ads);
  if (ok && overlay != null && overlay.mounted && at != null) {
    showBurst(
      null,
      overlay: overlay,
      at: at,
      count: 28,
      spread: 1.3,
      reduceMotion: c.settings.reduceMotion,
    );
  }
  return ok;
}
