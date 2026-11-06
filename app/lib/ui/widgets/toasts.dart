import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/achievements.dart';
import '../../l10n/upgrade_texts.dart';
import '../achievement_text.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'burst.dart';
import 'emoji_card.dart';

/// One toast: an achievement or a free bonus (R-ULEP-1, R-SYN-1).
typedef _Toast = ({AchievementDef? achievement, MilestoneEvent? bonus});

/// Achievement and bonus toasts sliding in from the top (R-OSIAG-1), one
/// at a time.
class AchievementToasts extends StatefulWidget {
  const AchievementToasts({super.key, required this.controller});
  final GameController controller;

  @override
  State<AchievementToasts> createState() => _AchievementToastsState();
}

class _AchievementToastsState extends State<AchievementToasts> {
  final _queue = <_Toast>[];
  _Toast? _current;
  int _extra = 0;
  late final StreamSubscription<AchievementDef> _sub;
  late final StreamSubscription<MilestoneEvent> _bonusSub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sub = widget.controller.achievementUnlocked.listen((a) {
      _queue.add((achievement: a, bonus: null));
      _next();
    });
    _bonusSub = widget.controller.milestoneReached.listen((m) {
      _queue.add((achievement: null, bonus: m));
      _next();
    });
  }

  void _next() {
    if (_current != null || _queue.isEmpty) return;
    // A burst of achievements (an import, a prestige, a big payout) shows
    // as one toast.
    final burst =
        _queue.length >= 3 && _queue.every((t) => t.achievement != null);
    setState(() {
      _extra = burst ? _queue.length - 1 : 0;
      _current = burst ? _queue.last : _queue.first;
      burst ? _queue.clear() : _queue.removeAt(0);
    });
    final ms = _queue.isEmpty ? 2600 : 1600;
    // Confetti from the toast once it has slid in (docs/04 §3).
    Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      showBurst(
        context,
        at: box.localToGlobal(Offset(box.size.width / 2, box.size.height)),
        colors: confettiColors,
        count: 24,
        fall: true,
        reduceMotion: widget.controller.settings.reduceMotion,
      );
    });
    _timer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() => _current = null);
      Timer(const Duration(milliseconds: 350), _next);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _bonusSub.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _current;
    final l = AppLocalizations.of(context);
    final c = widget.controller;
    // What the toast shows: art, small header, title, the bonus on the right.
    final (EmojiArt?, String, String, String) look = switch (t) {
      null => (null, '', '', ''),
      (achievement: final AchievementDef a, bonus: _) => (
        achievementArt(a),
        _extra > 0 ? l.achievementsUnlocked(_extra + 1) : l.achievementUnlocked,
        achievementText(l, Fmt.of(context, c), a).$1,
        '+${((_extra + 1) * c.balance.achievements.bonusEach * 100).round()}%',
      ),
      (achievement: null, bonus: final MilestoneEvent m)
          when m.generator != null =>
        (
          generatorArt[m.generator]!,
          l.milestoneToast(
            upgradeTexts(l, m.generator!, m.index + 1)?.$1 ?? roman(m.index),
          ),
          l.milestoneTitle(
            generatorName(l, m.generator!),
            Fmt.of(context, c).round(c.econ.milestoneMultiplier(m.generator!)),
          ),
          '×${Fmt.of(context, c).round(c.econ.milestoneMultiplier(m.generator!))}',
        ),
      (achievement: null, bonus: final MilestoneEvent m) => (
        generatorArt[c.balance.synergies
            .firstWhere((x) => x.id == m.synergy)
            .b]!,
        l.synergyToast,
        synergyName(l, m.synergy!),
        '',
      ),
      _ => (null, '', '', ''),
    };
    final a = look.$1;
    return IgnorePointer(
      child: AnimatedSlide(
        offset: a == null ? const Offset(0, -1.6) : Offset.zero,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: a == null
            ? const SizedBox(height: 64)
            : Container(
                key: const Key('achievement-toast'),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Palette.outline, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    EmojiCard(art: a, size: 44, circle: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            look.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Palette.accent,
                            ),
                          ),
                          Text(
                            look.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: Fonts.display,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      look.$4,
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 16,
                        color: Palette.great,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
