import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_controller.dart';
import '../theme.dart';

/// Full-height sheet over the game; opening it pauses the round
/// (R-RUNDA-8, U-4).
Future<void> showGameSheet(
  BuildContext context,
  GameController c, {
  required String Function(AppLocalizations l) title,
  required Widget Function(BuildContext context) builder,
}) {
  c.pause();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: Palette.outline, width: 3),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Palette.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      // Built here, not at open time, so a language change
                      // in the settings sheet retitles it at once.
                      title(AppLocalizations.of(context)),
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('sheet-close'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Palette.outline),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: c,
                builder: (context, _) => builder(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
