import 'package:flutter/material.dart';

import '../ads/rewarded_ads.dart';
import '../engine/ad_offers.dart';
import '../engine/game_engine.dart';
import '../l10n/gen/app_localizations.dart';
import 'catalog.dart';
import 'format.dart';
import 'game_controller.dart';
import 'seasons_ui.dart';
import 'theme.dart';
import 'widgets/ad_buttons.dart';
import 'widgets/ad_offer_sheet.dart';
import 'widgets/buy_button.dart';
import 'widgets/choice_dialog.dart';
import 'widgets/emoji_card.dart';
import 'widgets/res_text.dart';
import 'widgets/springs.dart';
import 'widgets/story_scene.dart';

/// "Welcome back" (R-OFF-2, R-DZIEN-1, docs/04 U-34): what the clocks
/// earned while the player was away and today's daily bonus, in one
/// window with one "Collect" — instead of one dialog after another. A
/// season that just started gets a line here instead of its own window.
/// Then, once, the notification question (R-OFF-5).
///
/// Returns whether a season line was shown (its intro counts as seen).
Future<bool> showWelcomeDialog(
  BuildContext context,
  GameController c,
  RewardedAds ads, {
  bool withSeason = false,
}) async {
  final offline = c.pendingOffline;
  final daily = c.pendingDaily;
  if (offline == null && daily == null) return false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _Welcome(
      controller: c,
      ads: ads,
      offline: offline,
      daily: daily,
      withSeason: withSeason,
    ),
  );
  // R-OFF-5: then ask for notification permission, once, with a reason —
  // right after the player has seen what waiting pays.
  if (offline != null && context.mounted) await _askNotifications(context, c);
  return withSeason;
}

Future<void> _askNotifications(BuildContext context, GameController c) async {
  if (c.state.tipsSeen.contains('notifyAsked') || !c.settings.notifications) {
    return;
  }
  c.state.tipsSeen.add('notifyAsked');
  final l = AppLocalizations.of(context);
  final yes = await showChoiceDialog(
    context,
    art: const EmojiArt('bell', Color(0xFFFFE29A)),
    title: l.notificationAsk,
    body: l.notificationAskBody,
    yes: l.notificationAskYes,
    no: l.notificationAskNo,
    yesKey: const Key('notify-yes'),
  );
  if (yes) {
    await c.notifications.requestPermission();
  } else {
    c.settings.notifications = false;
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.controller,
    required this.ads,
    required this.offline,
    required this.daily,
    required this.withSeason,
  });

  final GameController controller;
  final RewardedAds ads;
  final OfflineReport? offline;
  final DailyBonus? daily;
  final bool withSeason;

  void _collectAll(BuildContext context) {
    controller
      ..collectOffline()
      ..collectDaily();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final offline = this.offline;
    final daily = this.daily;
    final both = offline != null && daily != null;
    final title = both
        ? l.welcomeTitle
        : offline != null
        ? l.offlineTitle
        : l.dailyTitle;
    final season = c.season;
    final canDouble =
        offline != null &&
        offline.awaySeconds >= c.balance.ads.offlineMinAwaySeconds &&
        c.ads.unlocked;
    if (canDouble) c.adOfferShown(AdOffer.offline);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        key: const Key('welcome'),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Palette.outline, width: 3),
        ),
        // The buttons stay on screen; what is above them scrolls if a
        // small phone with large text cannot show it all (U-35).
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmojiCard(
                      art: offline != null
                          ? const EmojiArt('sleeping_face', Color(0xFFB4D8FF))
                          : const EmojiArt('glowing_star', Color(0xFFFFE6A7)),
                      size: 52,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 24,
                      ),
                    ),
                    if (offline != null)
                      _OfflinePart(controller: c, report: offline),
                    if (both) const Divider(height: 22, thickness: 1.5),
                    if (daily != null)
                      _DailyPart(controller: c, bonus: daily, showTitle: both),
                    // One line from Grandpa or Grandma, a new one each day
                    // (docs/16-fabula.md §5).
                    if (daily != null && c.state.tutorialDone) ...[
                      const SizedBox(height: 12),
                      StoryTranscript(
                        key: const Key('welcome-story'),
                        script: welcomeLine(l, c.state.lifetime.dailyClaims),
                      ),
                    ],
                    if (withSeason && season != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        l.welcomeSeason(seasonName(l, season.id)),
                        key: const Key('welcome-season'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                BuyButton(
                  key: const Key('welcome-collect'),
                  price: both ? l.collectAll : l.collect,
                  enabled: true,
                  minWidth: 130,
                  onPressed: () => _collectAll(context),
                ),
                // R-OFF-2 / adOffline: ×2 for an ad after ≥ 30 min away.
                if (canDouble)
                  // After a cold start the ad is often still loading when
                  // this opens: the button lights up once it is ready.
                  AdWatchButton(
                    key: const Key('offline-double'),
                    ads: ads,
                    price: l.adDouble,
                    onPressed: () async {
                      final ok = await watchAdWithReward(
                        context,
                        c,
                        AdOffer.offline,
                        ads,
                      );
                      if (!context.mounted) return;
                      confirmAdResult(context, c, AdOffer.offline, ok);
                      // No reward: the plain "Collect" stays available.
                      if (ok) _collectAll(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The amount counting up, with the Tiki coin beside it.
class _Amount extends StatelessWidget {
  const _Amount({required this.controller, required this.amount});
  final GameController controller;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final f = Fmt.of(context, controller);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${f.n(v)}',
              style: const TextStyle(
                fontFamily: Fonts.display,
                fontSize: 36,
                color: Palette.perfectDeep,
              ),
            ),
            const SizedBox(width: 6),
            const ResIcon(Res.tiki, size: 30),
          ],
        ),
      ),
    );
  }
}

class _OfflinePart extends StatelessWidget {
  const _OfflinePart({required this.controller, required this.report});
  final GameController controller;
  final OfflineReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, controller);
    final r = report;
    return Column(
      children: [
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
        const SizedBox(height: 8),
        _Amount(controller: controller, amount: r.amount),
      ],
    );
  }
}

class _DailyPart extends StatelessWidget {
  const _DailyPart({
    required this.controller,
    required this.bonus,
    required this.showTitle,
  });
  final GameController controller;
  final DailyBonus bonus;

  /// Under the offline part it needs its own heading.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = bonus;
    final days = controller.balance.daily.minutes.length;
    final muted = TextStyle(
      fontSize: 12.5,
      color: Palette.outline.withValues(alpha: 0.7),
    );
    return Column(
      children: [
        if (showTitle)
          Text(
            l.dailyTitle,
            style: const TextStyle(fontFamily: Fonts.display, fontSize: 19),
          ),
        Text(l.dailyDay(d.day, days), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= days; i++)
              _DayTile(
                day: i,
                state: i.compareTo(d.day),
                // The last day's Mainspring shows once they exist.
                spring: i == days && controller.econ.springsUnlocked,
              ),
          ],
        ),
        const SizedBox(height: 8),
        _Amount(controller: controller, amount: d.amount),
        if (d.springs > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              key: const Key('daily-springs'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${d.springs}',
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 24,
                    color: Palette.perfectDeep,
                  ),
                ),
                const SizedBox(width: 6),
                const SpringIcon(size: 26),
              ],
            ),
          ),
        if (d.grace)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              l.dailyGrace,
              key: const Key('daily-grace'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Palette.perfectText,
              ),
            ),
          ),
        Text(
          l.dailyHint(days, controller.econ.springsUnlocked ? 'yes' : 'no'),
          textAlign: TextAlign.center,
          style: muted,
        ),
      ],
    );
  }
}

/// One day of the streak: done (<0), today (0) or still ahead (>0).
/// [spring]: the day also brings a Mainspring, drawn in place of its number.
class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.state, this.spring = false});
  final int day;
  final int state;
  final bool spring;

  @override
  Widget build(BuildContext context) {
    final today = state == 0;
    final done = state < 0;
    return Container(
      width: 30,
      height: today ? 40 : 34,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: today
            ? Palette.perfect
            : done
            ? Palette.great.withValues(alpha: 0.35)
            : const Color(0xFFF1ECE4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.outline, width: today ? 2.5 : 1.5),
      ),
      child: spring && !done
          ? SpringIcon(key: Key('daily-day-spring'), size: today ? 26 : 22)
          : Text(
              done ? '✓' : '$day',
              style: TextStyle(
                fontFamily: Fonts.display,
                fontSize: today ? 17 : 14,
                color: Palette.outline.withValues(
                  alpha: today || done ? 1 : 0.5,
                ),
              ),
            ),
    );
  }
}
