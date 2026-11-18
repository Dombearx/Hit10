import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../catalog.dart';
import '../theme.dart';
import 'emoji_card.dart';

/// Illustration slots of the story: the prologue and the seven chapters of
/// the Chronicle (`prologue`, `chapter_1` … `chapter_7`).
///
/// The picture is `assets/story/<id>.jpg` (made with tools/art/story.py,
/// docs/10). Until a file is there, a placeholder scene of the chapter's
/// characters stands in its place, so adding a picture needs no code.
class StoryArt extends StatelessWidget {
  const StoryArt(this.id, {super.key});
  final String id;

  static String asset(String id) => 'assets/story/$id.jpg';

  /// The story pictures in the app bundle, read once.
  static Future<Set<String>>? _available;
  static Future<Set<String>> _load() =>
      _available ??= AssetManifest.loadFromAssetBundle(rootBundle)
          .then((m) => m.listAssets().toSet(), onError: (_) => <String>{});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Palette.outline, width: 2.5),
          ),
          child: FutureBuilder<Set<String>>(
            future: _load(),
            builder: (context, snap) {
              final have = snap.data?.contains(asset(id)) ?? false;
              return have
                  ? Image.asset(
                      asset(id),
                      key: Key('story-art-$id'),
                      fit: BoxFit.cover,
                    )
                  : _Placeholder(key: Key('story-placeholder-$id'), id: id);
            },
          ),
        ),
      ),
    );
  }
}

/// Who appears in each scene, and the colour of its sky.
const _scenes = <String, (List<String>, List<Color>)>{
  'prologue': (['grandpa', 'chronos'], [Color(0xFFFFE6A7), Color(0xFFFFB38A)]),
  'chapter_1': (['chronos', 'grandpa'], [Color(0xFFFFE29A), Color(0xFFFF9F7A)]),
  'chapter_2': (
    ['chronos', 'see_no_evil_monkey'],
    [Color(0xFFC8F2FF), Color(0xFFB9A7FF)],
  ),
  'chapter_3': (
    ['grandma', 'chronos', 'grandpa'],
    [Color(0xFFFFD36E), Color(0xFFFF8A5B)],
  ),
  'chapter_4': (['chronos', 'grandpa'], [Color(0xFFDCE3EE), Color(0xFF9DAAC2)]),
  'chapter_5': (['chronos', 'fire'], [Color(0xFFFFC2A8), Color(0xFFFF6F61)]),
  'chapter_6': (
    ['grandpa', 'chronos', 'grandma'],
    [Color(0xFFFFC9DE), Color(0xFFE2D2FF)],
  ),
  'chapter_7': (['chronos', 'grandma'], [Color(0xFFFFE6A7), Color(0xFFFFC9DE)]),
};

/// A stand-in until the picture is drawn: the chapter's characters on a
/// soft sky, the middle one larger.
class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final (who, sky) = _scenes[id] ?? _scenes['prologue']!;
    final lead = who.length == 3 ? 1 : who.indexOf('chronos');
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final big = box.maxHeight * 0.62;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, name) in who.indexed)
                Padding(
                  padding: EdgeInsets.fromLTRB(6, 0, 6, box.maxHeight * 0.12),
                  child: EmojiCard(
                    art: generatorArt[name] ?? EmojiArt(name, sky.first),
                    size: i == lead ? big : big * 0.72,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
