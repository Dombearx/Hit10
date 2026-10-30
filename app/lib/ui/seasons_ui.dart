import 'package:flutter/painting.dart';

import '../l10n/gen/app_localizations.dart';
import 'catalog.dart';

/// How a calendar event looks (docs/04 §3.1): the background, the badge
/// and what flies in place of the golden clock.
class SeasonLook {
  const SeasonLook({
    required this.badge,
    required this.item,
    required this.bgTop,
    required this.bgBottom,
    required this.tint,
  });
  final String badge;
  final String item;
  final Color bgTop;
  final Color bgBottom;

  /// Light background behind the badge emoji.
  final Color tint;

  EmojiArt get art => EmojiArt(badge, tint);
}

const seasonLooks = <String, SeasonLook>{
  'valentine': SeasonLook(
    badge: 'heart_with_ribbon',
    item: 'heart_with_ribbon',
    bgTop: Color(0xFFFFC7D9),
    bgBottom: Color(0xFFFF7A9C),
    tint: Color(0xFFFFE0EA),
  ),
  'easter': SeasonLook(
    badge: 'hatching_chick',
    item: 'hatching_chick',
    bgTop: Color(0xFFFFF1A6),
    bgBottom: Color(0xFF9EDF9A),
    tint: Color(0xFFFFF6C9),
  ),
  'summer': SeasonLook(
    badge: 'sun_with_face',
    item: 'sun_with_face',
    bgTop: Color(0xFFFFE680),
    bgBottom: Color(0xFF5CC8F2),
    tint: Color(0xFFFFF3B0),
  ),
  'fiveDay': SeasonLook(
    badge: 'keycap_5',
    item: 'keycap_5',
    bgTop: Color(0xFFB8F0E6),
    bgBottom: Color(0xFF6C9BFF),
    tint: Color(0xFFD8F5FF),
  ),
  'halloween': SeasonLook(
    badge: 'jack_o_lantern',
    item: 'jack_o_lantern',
    bgTop: Color(0xFFFFB347),
    bgBottom: Color(0xFF8B6BC2),
    tint: Color(0xFFFFE0B2),
  ),
  'christmas': SeasonLook(
    badge: 'christmas_tree',
    item: 'wrapped_gift',
    bgTop: Color(0xFFC9EED9),
    bgBottom: Color(0xFFE96565),
    tint: Color(0xFFDDF5E6),
  ),
  'newYear': SeasonLook(
    badge: 'fireworks',
    item: 'party_popper',
    bgTop: Color(0xFFBCC8FF),
    bgBottom: Color(0xFFFF8AD8),
    tint: Color(0xFFE3E8FF),
  ),
};

String seasonName(AppLocalizations l, String id) => switch (id) {
  'valentine' => l.season_valentine,
  'easter' => l.season_easter,
  'summer' => l.season_summer,
  'fiveDay' => l.season_fiveDay,
  'halloween' => l.season_halloween,
  'christmas' => l.season_christmas,
  'newYear' => l.season_newYear,
  _ => id,
};

/// What the season's flying items are called ("Dynie").
String seasonItems(AppLocalizations l, String id) => switch (id) {
  'valentine' => l.season_valentine_items,
  'easter' => l.season_easter_items,
  'summer' => l.season_summer_items,
  'fiveDay' => l.season_fiveDay_items,
  'halloween' => l.season_halloween_items,
  'christmas' => l.season_christmas_items,
  'newYear' => l.season_newYear_items,
  _ => id,
};
