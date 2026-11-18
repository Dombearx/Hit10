import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'catalog.dart';
import 'game_controller.dart';
import 'theme.dart';
import 'widgets/buy_button.dart';
import 'widgets/emoji_card.dart';
import 'widgets/res_text.dart';

/// The story before the first round (playtest: the Chronicle only started
/// after the first loop, so nothing said what the game was heading for).
/// Chronos on the top shelf, Grandpa's plan, and the goal in one line.
Future<void> showPrologue(BuildContext context, GameController c) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final l = AppLocalizations.of(context);
      final size = MediaQuery.sizeOf(context);
      return Dialog(
        key: const Key('prologue'),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Palette.paper,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          // The story scrolls on a short screen; the button stays in view.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmojiCard(art: generatorArt['grandpa']!, size: 60),
                          const SizedBox(width: 14),
                          EmojiCard(art: generatorArt['chronos']!, size: 76),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.prologue_t,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ResText(
                        l.prologue,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.perfect.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Palette.outline, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              EmojiArt.path('chronos'),
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l.prologueGoal,
                                style: const TextStyle(
                                  fontFamily: Fonts.display,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: BuyButton(
                  key: const Key('prologue-go'),
                  price: l.prologueGo,
                  enabled: true,
                  celebrate: false,
                  minWidth: 160,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
