import 'package:flutter/material.dart';

import '../catalog.dart';
import '../theme.dart';
import 'buy_button.dart';
import 'emoji_card.dart';

/// A yes/no question in the game's look: an icon, the question, a chunky
/// "yes" and a quiet "no" (playtest: the plain system dialog looked out of
/// place). Returns true only for "yes"; closing it counts as "no".
/// [extra] goes under the question (a second line, a text field).
Future<bool> showChoiceDialog(
  BuildContext context, {
  required String body,
  required String yes,
  required String no,
  EmojiArt? art,
  String? title,
  Widget? extra,
  Key? dialogKey,
  Key? yesKey,
  Key? noKey,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => ChoiceDialogFrame(
        key: dialogKey,
        body: body,
        yes: yes,
        no: no,
        art: art,
        title: title,
        extra: extra,
        yesKey: yesKey,
        noKey: noKey,
        onYes: () => Navigator.pop(context, true),
        onNo: () => Navigator.pop(context, false),
      ),
    ) ??
    false;

/// The frame of [showChoiceDialog], for dialogs that return more than
/// yes/no (a typed answer).
class ChoiceDialogFrame extends StatelessWidget {
  const ChoiceDialogFrame({
    super.key,
    required this.body,
    required this.yes,
    required this.no,
    required this.onYes,
    required this.onNo,
    this.art,
    this.title,
    this.extra,
    this.yesKey,
    this.noKey,
  });
  final String body;
  final String yes;
  final String no;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final EmojiArt? art;
  final String? title;
  final Widget? extra;
  final Key? yesKey;
  final Key? noKey;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Palette.paper,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Palette.outline, width: 3),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (art != null) ...[
                EmojiCard(art: art!, size: 64),
                const SizedBox(height: 12),
              ],
              if (title != null) ...[
                Text(
                  title!,
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
              if (extra != null) ...[const SizedBox(height: 12), extra!],
              const SizedBox(height: 18),
              BuyButton(
                key: yesKey,
                price: yes,
                enabled: true,
                celebrate: false,
                minWidth: 160,
                onPressed: onYes,
              ),
              const SizedBox(height: 4),
              TextButton(key: noKey, onPressed: onNo, child: Text(no)),
            ],
          ),
        ),
      ),
    );
  }
}
