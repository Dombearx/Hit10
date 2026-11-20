import 'package:flutter/material.dart';

import '../catalog.dart';
import '../theme.dart';
import 'emoji_card.dart';
import 'res_text.dart';

/// A short message at the bottom in the game's look: a paper card with the
/// dark outline, an optional icon and header, and a chunky pink button for
/// the action (playtest: the grey system snackbar looked out of place next
/// to the achievement toasts and dialogs).
SnackBar gameSnack({
  Key? key,
  required String text,
  String? title,
  EmojiArt? art,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  return SnackBar(
    key: key,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    content: _GameSnackCard(
      text: text,
      title: title,
      art: art,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

/// Shows [gameSnack] in place of the current message.
void showGameSnack(
  ScaffoldMessengerState messenger, {
  Key? key,
  required String text,
  String? title,
  EmojiArt? art,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      gameSnack(
        key: key,
        text: text,
        title: title,
        art: art,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
}

class _GameSnackCard extends StatelessWidget {
  const _GameSnackCard({
    required this.text,
    this.title,
    this.art,
    this.actionLabel,
    this.onAction,
  });
  final String text;
  final String? title;
  final EmojiArt? art;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: Palette.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Palette.outline, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          if (art != null) ...[
            EmojiCard(art: art!, size: 40),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  ResText(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Palette.accent,
                    ),
                  ),
                ResText(
                  text,
                  style: TextStyle(
                    fontFamily: title != null ? Fonts.display : Fonts.body,
                    fontWeight: title != null ? null : FontWeight.w700,
                    fontSize: title != null ? 15 : 14.5,
                    height: 1.25,
                    color: Palette.outline,
                  ),
                ),
              ],
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            _SnackButton(label: label, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// The snack's action: a small version of the pink price button. Closes
/// the message first, like [SnackBarAction].
class _SnackButton extends StatelessWidget {
  const _SnackButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Palette.outline, width: 2.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ScaffoldMessenger.maybeOf(context)
              ?.hideCurrentSnackBar(reason: SnackBarClosedReason.action);
          onPressed?.call();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: ResText(
                label,
                style: const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
