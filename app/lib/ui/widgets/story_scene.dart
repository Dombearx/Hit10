import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../catalog.dart';
import '../story/story_script.dart';
import '../theme.dart';
import 'emoji_card.dart';

/// The name of a speaker in the story.
String storySpeakerName(AppLocalizations l, String who) => switch (who) {
  'grandpa' => l.who_grandpa,
  'grandma' => l.who_grandma,
  'chronos' => l.who_chronos,
  _ => who,
};

const _speakerColor = {
  'grandpa': Palette.great,
  'grandma': Color(0xFFFF9EC1),
  'chronos': Palette.perfect,
};

/// A story scene played one line at a time (docs/04 U-33a): the speaker's
/// portrait, a speech bubble with their name, a tap anywhere for the next
/// line, "Skip" to the end. When the last line is read, [end] shows below
/// (the goal and a button) — or, with no [end], [onDone] is called.
class StoryPlayer extends StatefulWidget {
  const StoryPlayer({super.key, required this.script, this.end, this.onDone});

  final String script;
  final Widget? end;
  final VoidCallback? onDone;

  @override
  State<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late List<StoryLine> _lines = parseStory(widget.script);
  int _at = 0;

  @override
  void didUpdateWidget(StoryPlayer old) {
    super.didUpdateWidget(old);
    if (old.script != widget.script) {
      _lines = parseStory(widget.script);
      _at = 0;
    }
  }

  bool get _done => _at >= _lines.length;

  void _next() {
    if (_done) return;
    setState(() => _at++);
    if (_done) widget.onDone?.call();
  }

  void _skip() {
    setState(() => _at = _lines.length);
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_done) {
      // The whole scene stays readable above the end.
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoryTranscript(script: widget.script, key: const Key('story-done')),
          if (widget.end != null) ...[const SizedBox(height: 12), widget.end!],
        ],
      );
    }
    final line = _lines[_at];
    return Semantics(
      button: true,
      label: l.storyNext,
      child: GestureDetector(
        key: const Key('story-next'),
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 132),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.96, end: 1.0).animate(a),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_at),
                  child: _LineView(line: line),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (var i = 0; i < _lines.length; i++)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= _at
                                ? Palette.outline
                                : Colors.transparent,
                            border: Border.all(
                              color: Palette.outline,
                              width: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l.storyTapHint,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Palette.missText,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('story-skip'),
                onPressed: _skip,
                child: Text(
                  l.storySkip,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Palette.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line on stage: a caption box, or a portrait with a speech bubble.
class _LineView extends StatelessWidget {
  const _LineView({required this.line});
  final StoryLine line;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (line.caption) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Palette.outline,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          line.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Palette.paper,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
      );
    }
    final who = line.who!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        EmojiCard(art: generatorArt[who]!, size: 64),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Palette.outline, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NameChip(who: who, name: storySpeakerName(l, who)),
                if (line.direction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '(${line.direction})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Palette.missText,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  line.text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({required this.who, required this.name});
  final String who;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: _speakerColor[who] ?? Palette.paper,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Palette.outline, width: 2),
    ),
    child: Text(
      name,
      style: const TextStyle(fontFamily: Fonts.display, fontSize: 13),
    ),
  );
}

/// The whole scene as a script to read (the Chronicle, the end of a
/// played scene): small portraits, names, lines.
class StoryTranscript extends StatelessWidget {
  const StoryTranscript({super.key, required this.script});
  final String script;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in parseStory(script))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: line.caption
                ? Text(
                    line.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Palette.missText,
                      height: 1.3,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiCard(art: generatorArt[line.who]!, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${storySpeakerName(l, line.who!)}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (line.direction != null)
                                TextSpan(
                                  text: '(${line.direction}) ',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Palette.missText,
                                  ),
                                ),
                              TextSpan(text: line.text),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14, height: 1.3),
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}

/// A story scene in a window of its own (the rare scenes of the first
/// loop): a title, the scene, and the window closes after the last line.
Future<void> showStoryScene(
  BuildContext context, {
  required String title,
  required String script,
  Key? key,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      return Dialog(
        key: key,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                StoryPlayer(
                  script: script,
                  onDone: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
