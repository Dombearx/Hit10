import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../persistence/cloud_save.dart';
import 'catalog.dart';
import 'format.dart';
import 'game_controller.dart';
import 'widgets/choice_dialog.dart';

/// "A cloud save has more progress — load it?" (docs/05 T-35): both sides
/// in numbers, and nothing is replaced without a yes.
Future<bool> showCloudOffer(
  BuildContext context,
  GameController c,
  CloudOffer offer,
) {
  final l = AppLocalizations.of(context);
  final f = Fmt.of(context, c);
  final here = c.state.lifetime;
  return showChoiceDialog(
    context,
    art: const EmojiArt('package', Color(0xFFB4D8FF)),
    title: l.cloudOfferTitle,
    body: l.cloudOfferBody(
      f.duration(offer.playSeconds),
      f.n(offer.earnedEver),
      f.duration(here.secondsPlayed),
      f.n(here.earnedEver),
    ),
    yes: l.cloudLoad,
    no: l.cloudKeep,
    yesKey: const Key('cloud-load'),
    noKey: const Key('cloud-keep'),
  );
}
