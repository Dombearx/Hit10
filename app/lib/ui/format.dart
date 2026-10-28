import 'package:flutter/widgets.dart';

import '../l10n/gen/app_localizations.dart';
import '../model/number_format.dart';
import 'game_controller.dart';

/// Number and duration formatting with the player's language and notation.
class Fmt {
  Fmt(this.l, this.notation);

  factory Fmt.of(BuildContext context, GameController c) =>
      Fmt(AppLocalizations.of(context), c.settings.notation);

  final AppLocalizations l;
  final Notation notation;

  String n(double v) =>
      formatNumber(v, decimalSeparator: l.decimalSeparator, notation: notation);

  String perSecond(double v) => l.perSecond(n(v));

  /// Prices round up to whole Tiki below 1000 ("18", not "17,3").
  String price(double v) => n(v < 1000 ? v.ceilToDouble() : v);

  String duration(double seconds) {
    final m = (seconds / 60).floor();
    if (m < 60) return l.durationM(m);
    return l.durationHm(m ~/ 60, m % 60);
  }
}
