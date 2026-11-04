import 'package:flutter/painting.dart';

import '../l10n/gen/app_localizations.dart';
import '../model/achievements.dart';
import 'catalog.dart';
import 'format.dart';
import 'seasons_ui.dart';

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
    case AchievementCategory.season:
      final name = seasonName(l, a.id.substring('season_'.length));
      return (l.ach_season(name), l.ach_season_desc(name));
    case AchievementCategory.exact:
      return (l.ach_exact(count), l.ach_exact_desc(count));
    case AchievementCategory.rounds:
      return (l.ach_rounds(count), l.ach_rounds_desc(count));
    case AchievementCategory.income:
      return (l.ach_income(count), l.ach_income_desc(count));
    case AchievementCategory.clocks:
      return (l.ach_clocks(count), l.ach_clocks_desc(count));
    case AchievementCategory.skillLevels:
      return (l.ach_skillLevels(count), l.ach_skillLevels_desc(count));
    case AchievementCategory.blindPerfects:
      return (l.ach_blindPerfects(count), l.ach_blindPerfects_desc(count));
    case AchievementCategory.playTime:
      return (l.ach_playHours(count), l.ach_playHours_desc(count));
    case AchievementCategory.meta:
      return (l.ach_achievements(count), l.ach_achievements_desc(count));
    case AchievementCategory.daily:
      return (l.ach_daily(count), l.ach_daily_desc(count));
    case AchievementCategory.shield:
      return (l.ach_shield(count), l.ach_shield_desc(count));
    case AchievementCategory.mode:
    case AchievementCategory.hidden:
    case AchievementCategory.feat:
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
    AchievementCategory.season =>
      seasonLooks[a.id.substring('season_'.length)]?.art ??
          const EmojiArt('trophy', _gold),
    AchievementCategory.hidden => const EmojiArt('trophy', _gold),
    AchievementCategory.exact => const EmojiArt('bullseye', _peach),
    AchievementCategory.rounds => const EmojiArt('stopwatch', _lilac),
    AchievementCategory.income => const EmojiArt('high_voltage', _gold),
    AchievementCategory.clocks => const EmojiArt('gear', _lilac),
    AchievementCategory.skillLevels => const EmojiArt('flexed_biceps', _peach),
    AchievementCategory.blindPerfects => const EmojiArt(
      'see_no_evil_monkey',
      _lilac,
    ),
    AchievementCategory.playTime => const EmojiArt('sun_with_face', _gold),
    AchievementCategory.meta => const EmojiArt('trophy', _lilac),
    AchievementCategory.daily => const EmojiArt('wrapped_gift', _peach),
    AchievementCategory.shield => const EmojiArt('shield', _lilac),
    AchievementCategory.feat => const EmojiArt('party_popper', _gold),
  };
}

const _gold = Color(0xFFFFE6A7);
const _peach = Color(0xFFFFC2A8);
const _lilac = Color(0xFFD7C4FF);
