import 'package:flutter/material.dart';

import '../catalog.dart';
import '../theme.dart';
import 'buy_button.dart';
import 'emoji_card.dart';

/// A yes/no question in the game's look: an icon, the question, a chunky
/// "yes" and a quiet "no" (playtest: the plain system dialog looked out of
/// place). Returns true only for "yes"; closing it counts as "no".
Future<bool> showChoiceDialog(
  BuildContext context, {
  required String body,
  required String yes,
  required String no,
  EmojiArt? art,
  String? title,
  Key? yesKey,
  Key? noKey,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          decoration: BoxDecoration(
            color: Palette.paper,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Palette.outline, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (art != null) ...[
                EmojiCard(art: art, size: 64),
                const SizedBox(height: 12),
              ],
              if (title != null) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.35),
              ),
              const SizedBox(height: 18),
              BuyButton(
                key: yesKey,
                price: yes,
                enabled: true,
                celebrate: false,
                minWidth: 160,
                onPressed: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 4),
              TextButton(
                key: noKey,
                onPressed: () => Navigator.pop(context, false),
                child: Text(no),
              ),
            ],
          ),
        ),
      ),
    ) ??
    false;
