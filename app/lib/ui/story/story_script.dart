/// A story scene as the translators write it (docs/16-fabula.md): one line
/// per row, `speaker (stage direction): text`. The speaker is `grandpa`,
/// `grandma`, `chronos`, or `*` for a caption; the stage direction is
/// optional. A row that does not match is shown as a caption, so a
/// translation slip never hides text.
class StoryLine {
  const StoryLine({this.who, this.direction, required this.text});

  /// `grandpa`, `grandma` or `chronos`; null for a caption.
  final String? who;
  final String? direction;
  final String text;

  bool get caption => who == null;
}

const storySpeakers = {'grandpa', 'grandma', 'chronos'};

final _row = RegExp(r'^\s*([A-Za-z*]+)\s*(?:\(([^)]*)\))?\s*:\s*(.*)$');

List<StoryLine> parseStory(String script) => [
  for (final raw in script.split('\n'))
    if (raw.trim().isNotEmpty) _parse(raw),
];

StoryLine _parse(String raw) {
  final m = _row.firstMatch(raw);
  if (m == null) return StoryLine(text: raw.trim());
  final who = m.group(1)!;
  final direction = m.group(2)?.trim();
  final text = m.group(3)!.trim();
  if (who == '*') return StoryLine(text: text);
  if (!storySpeakers.contains(who)) return StoryLine(text: raw.trim());
  return StoryLine(
    who: who,
    direction: direction == null || direction.isEmpty ? null : direction,
    text: text,
  );
}
