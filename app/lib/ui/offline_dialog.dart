import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'format.dart';
import 'game_controller.dart';
import 'theme.dart';
import 'widgets/buy_button.dart';
import 'widgets/emoji_card.dart';
import 'catalog.dart';
import '../ads/rewarded_ads.dart';
import '../engine/ad_offers.dart';
import '../engine/game_engine.dart';

/// "While you were away…" (R-OFF-2): the amount counts up, then Collect.
Future<void> showOfflineDialog(
  BuildContext context,
  GameController c,
  RewardedAds ads,
) async {
  final r = c.pendingOffline;
  if (r == null) return;
  await _show(context, c, ads, r);
  // R-OFF-5: then ask for notification permission, once, with a reason —
  // right after the player has seen what waiting pays.
  if (!context.mounted) return;
  await _askNotifications(context, c);
}

Future<void> _askNotifications(BuildContext context, GameController c) async {
  if (c.state.tipsSeen.contains('notifyAsked') || !c.settings.notifications) {
    return;
  }
  c.state.tipsSeen.add('notifyAsked');
  final l = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(l.notificationAsk),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.no),
        ),
        TextButton(
          key: const Key('notify-yes'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.yes),
        ),
      ],
    ),
  );
  if (yes == true) {
    await c.notifications.requestPermission();
  } else {
    c.settings.notifications = false;
  }
}

Future<void> _show(
  BuildContext context,
  GameController c,
  RewardedAds ads,
  OfflineReport r,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final f = Fmt.of(context, c);
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmojiCard(
                art: const EmojiArt('sleeping_face', Color(0xFFB4D8FF)),
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                l.offlineTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                l.offlineBody(f.duration(r.awaySeconds)),
                textAlign: TextAlign.center,
              ),
              if (r.countedSeconds < r.awaySeconds)
                Text(
                  l.offlineCapped(f.duration(r.countedSeconds)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Palette.outline.withValues(alpha: 0.6),
                  ),
                ),
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: r.amount),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '+${f.n(v)}',
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 40,
                    color: Palette.perfectDeep,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  BuyButton(
                    key: const Key('offline-collect'),
                    price: l.collect,
                    enabled: true,
                    minWidth: 120,
                    onPressed: () {
                      c.collectOffline();
                      Navigator.of(context).pop();
                    },
                  ),
                  // R-OFF-2 / adOffline: ×2 for an ad after ≥ 30 min away.
                  if (r.awaySeconds >= c.balance.ads.offlineMinAwaySeconds &&
                      c.ads.unlocked)
                    BuyButton(
                      key: const Key('offline-double'),
                      label: '📺',
                      price: l.adDouble,
                      enabled: ads.isReady,
                      minWidth: 120,
                      onPressed: () async {
                        final ok = await c.watchAd(AdOffer.offline, ads);
                        if (ok) {
                          c.collectOffline();
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
