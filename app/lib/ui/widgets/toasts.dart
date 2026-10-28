import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../model/achievements.dart';
import '../achievement_text.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'emoji_card.dart';

/// Achievement toasts sliding in from the top (R-OSIAG-1), one at a time.
class AchievementToasts extends StatefulWidget {
  const AchievementToasts({super.key, required this.controller});
  final GameController controller;

  @override
  State<AchievementToasts> createState() => _AchievementToastsState();
}

class _AchievementToastsState extends State<AchievementToasts> {
  final _queue = <AchievementDef>[];
  AchievementDef? _current;
  int _extra = 0;
  late final StreamSubscription<AchievementDef> _sub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sub = widget.controller.achievementUnlocked.listen((a) {
      _queue.add(a);
      _next();
    });
  }

  void _next() {
    if (_current != null || _queue.isEmpty) return;
    // A burst (an import, a prestige, a big payout) shows as one toast.
    final burst = _queue.length >= 3;
    setState(() {
      _extra = burst ? _queue.length - 1 : 0;
      _current = burst ? _queue.last : _queue.first;
      burst ? _queue.clear() : _queue.removeAt(0);
    });
    final ms = _queue.isEmpty ? 2600 : 1600;
    _timer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() => _current = null);
      Timer(const Duration(milliseconds: 350), _next);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = _current;
    final l = AppLocalizations.of(context);
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
                    EmojiCard(art: achievementArt(a), size: 44, circle: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _extra > 0
                                ? l.achievementsUnlocked(_extra + 1)
                                : l.achievementUnlocked,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Palette.accent,
                            ),
                          ),
                          Text(
                            achievementText(
                              l,
                              Fmt.of(context, widget.controller),
                              a,
                            ).$1,
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
                      '+${((_extra + 1) * widget.controller.balance.achievements.bonusEach * 100).round()}%',
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
