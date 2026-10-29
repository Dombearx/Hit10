import 'package:flutter/painting.dart';

import '../l10n/gen/app_localizations.dart';
import '../model/achievements.dart';
import 'catalog.dart';
import 'format.dart';

/// Localized name and description of an achievement (templates for the
/// counted ones, fixed texts for the rest).
(String, String) achievementText(AppLocalizations l, Fmt f, AchievementDef a) {
  final n = a.threshold;
  final count = f.round(n);
  switch (a.category) {
    case AchievementCategory.earned:
      return (l.ach_earned(count), l.ach_earned_desc(count));
    case AchievementCategory.owned:
      final g = generatorName(l, a.generator!);
      return (l.ach_owned(g, count), l.ach_owned_desc(g, count));
    case AchievementCategory.perfects:
      return (l.ach_perfects(count), l.ach_perfects_desc(count));
    case AchievementCategory.perfectStreak:
      return (l.ach_perfectStreak(count), l.ach_perfectStreak_desc(count));
    case AchievementCategory.combo:
      return (l.ach_combo(count), l.ach_combo_desc(count));
    case AchievementCategory.golden:
      return (l.ach_golden(count), l.ach_golden_desc(count));
    case AchievementCategory.prestige:
      return (l.ach_prestige(count), l.ach_prestige_desc(count));
    case AchievementCategory.mode:
    case AchievementCategory.hidden:
      return (
        fixedAchievementName(l, a.id) ?? a.id,
        fixedAchievementDescription(l, a.id) ?? '',
      );
  }
}

/// Badge emoji per category (docs/04 U-12).
EmojiArt achievementArt(AchievementDef a) {
  const bg = EmojiArt('money_bag', _gold);
  return switch (a.category) {
    AchievementCategory.earned => bg,
    AchievementCategory.owned => EmojiArt(
      generatorArt[a.generator]!.main,
      generatorArt[a.generator]!.background,
    ),
    AchievementCategory.perfects => const EmojiArt('bullseye', _gold),
    AchievementCategory.perfectStreak => const EmojiArt('fire', _peach),
    AchievementCategory.combo => const EmojiArt('fire', _peach),
    AchievementCategory.golden => const EmojiArt('glowing_star', _gold),
    AchievementCategory.prestige => const EmojiArt('cyclone', _lilac),
    AchievementCategory.mode => EmojiArt(
      a.id == 'mode_fast' ? 'musical_note' : 'see_no_evil_monkey',
      _lilac,
    ),
    AchievementCategory.hidden => const EmojiArt('trophy', _gold),
  };
}

const _gold = Color(0xFFFFE6A7);
const _peach = Color(0xFFFFC2A8);
const _lilac = Color(0xFFD7C4FF);
