import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../l10n/master_texts.dart';
import '../catalog.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/buy_button.dart';
import '../widgets/choice_dialog.dart';
import '../widgets/emoji_card.dart';
import '../widgets/res_text.dart';
import 'sheet.dart';
import '../widgets/story_art.dart';
import '../widgets/story_scene.dart';

/// Time Loops (docs/13 §5.2): the ending of a loop, the confirmation of a
/// new one, and the Chronicle (chapters, seals, the rules).

const _paper = Palette.paper;

BoxDecoration _card([Color color = Colors.white]) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Palette.outline, width: 2),
);

TextStyle get _dim =>
    TextStyle(fontSize: 13, color: Palette.outline.withValues(alpha: 0.75));

/// A rule or its seal: icon, name, what it does.
class _RuleTile extends StatelessWidget {
  const _RuleTile({
    super.key,
    required this.art,
    required this.title,
    required this.body,
    this.header,
    this.quote,
    this.footer,
    this.locked = false,
    this.color = Colors.white,
  });
  final EmojiArt art;
  final String title;
  final String body;
  final String? header;
  final String? quote;
  final String? footer;
  final bool locked;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: _card(color),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmojiCard(art: art, size: 48, locked: locked),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) Text(header!, style: _dim),
              Text(
                title,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 16),
              ),
              if (quote != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    quote!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (body.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(body, style: const TextStyle(fontSize: 13.5)),
                ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(footer!, style: _dim),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// What Chronos brings next, or that the player picks from now on.
Widget _nextLoopCard(BuildContext context, GameController c) {
  final l = AppLocalizations.of(context);
  if (c.econ.storyDone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(const Color(0xFFE2D2FF)),
      child: Text(l.loopNextFree, style: const TextStyle(fontSize: 14)),
    );
  }
  final id = c.econ.nextLoopRules().first;
  return _RuleTile(
    key: const Key('loop-next-rule'),
    art: ruleArt(id),
    header: l.loopNextTitle,
    title: ruleName(l, id),
    quote: ruleQuote(l, id),
    body: ruleDescription(l, id),
    footer: l.loopNextSeal,
    color: const Color(0xFFE2D2FF),
  );
}

/// "Start a new loop?" with what resets and what stays (R-PETLA-3).
/// Returns whether a new loop started.
Future<bool> confirmNewLoop(BuildContext context, GameController c) async {
  final l = AppLocalizations.of(context);
  final yes = await showChoiceDialog(
    context,
    dialogKey: const Key('loop-confirm'),
    art: generatorArt[c.balance.loops.goal],
    title: l.loopConfirmTitle,
    body: l.loopConfirmResets,
    extra: ResText(
      l.loopConfirmKeeps,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    yes: l.loopConfirmYes,
    no: l.loopConfirmNo,
    yesKey: const Key('loop-confirm-yes'),
    noKey: const Key('loop-confirm-no'),
  );
  if (!yes) return false;
  c.rewindEffects();
  return c.startLoop();
}

/// The ending of a loop (R-PETLA-2, 5): the loop's figures, the chapter,
/// the seal and the dial face, what comes next, and the two ways on.
Future<void> showLoopEnd(BuildContext context, GameController c) async {
  c.pause();
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LoopEnd(controller: c),
  );
  // Seen once answered: an app closed over it shows it again.
  c.loopEndShown();
}

class _LoopEnd extends StatelessWidget {
  const _LoopEnd({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final s = c.state;
    final chapter = s.loop <= c.balance.loops.storyChapters
        ? chapterTexts(l, s.loop)
        : null;
    final goal = c.balance.loops.goal;
    final bonusesLeft =
        c.econ.milestoneThresholds(goal).length - s.loopBonusPaid;
    return Dialog(
      key: const Key('loop-end'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: _paper,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Palette.outline, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: EmojiCard(art: generatorArt[goal]!, size: 72),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.loopEndTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 26,
                      ),
                    ),
                    Text(
                      '${l.loopNumber(s.loop)} · ${l.loopEndStats(f.duration(s.loopGoalSeconds), s.loopPrestiges)}',
                      textAlign: TextAlign.center,
                      style: _dim,
                    ),
                    if (chapter != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        key: const Key('loop-end-chapter'),
                        padding: const EdgeInsets.all(12),
                        decoration: _card(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.loopRewardChapter, style: _dim),
                            Text(
                              '${l.chronicleChapter(s.loop)}: ${chapter.$1}',
                              style: const TextStyle(
                                fontFamily: Fonts.display,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StoryArt('chapter_${s.loop}'),
                            const SizedBox(height: 8),
                            // Played line by line; read again in the Chronicle.
                            StoryPlayer(script: chapter.$2),
                          ],
                        ),
                      ),
                    ],
                    for (final id in s.loopRules) ...[
                      const SizedBox(height: 8),
                      _RuleTile(
                        key: Key('loop-end-seal-$id'),
                        art: ruleArt(id, seal: true),
                        header: l.loopRewardSeal,
                        title: sealName(l, id),
                        body: sealDescription(l, id),
                        footer: [
                          for (final d in c.balance.dials)
                            if (d.seal == id)
                              l.loopRewardDial(dialTexts(l, d.id)?.$1 ?? d.id),
                        ].firstOrNull,
                        color: const Color(0xFFFFF1C4),
                      ),
                    ],
                    // The first loop has no seal, its face comes with the
                    // chapter (docs/17 §5).
                    for (final d in c.balance.dials)
                      if (d.loops == s.loop)
                        Padding(
                          key: const Key('loop-end-dial'),
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l.loopRewardDial(dialTexts(l, d.id)?.$1 ?? d.id),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                    const SizedBox(height: 8),
                    _nextLoopCard(context, c),
                    if (bonusesLeft > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ResText(
                          l.loopStayHint(bonusesLeft),
                          textAlign: TextAlign.center,
                          style: _dim,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      key: const Key('loop-stay'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l.loopStay,
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 16,
                          color: Palette.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BuyButton(
                      key: const Key('loop-new'),
                      price: l.loopStart,
                      enabled: true,
                      celebrate: false,
                      onPressed: () async {
                        if (await confirmNewLoop(context, c) &&
                            context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Chronicle (R-PETLA-7): this loop, the chapters, the seals — and,
/// after the story, the rules of the next loop (R-PETLA-8).
Future<void> showChronicle(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.chronicleTitle,
    builder: (context) => ListenableBuilder(
      listenable: c,
      builder: (context, _) => _Chronicle(controller: c),
    ),
  );
}

class _Chronicle extends StatelessWidget {
  const _Chronicle({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final s = c.state;
    final rules = c.balance.loops.rules;
    final open = c.econ.chaptersOpen;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontFamily: Fonts.display, fontSize: 18),
      ),
    );
    return ListView(
      key: const Key('chronicle'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // This loop: its rule, its goal, how it is going.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _card(const Color(0xFFE2D2FF)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.loopNumber(s.loop),
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 20),
              ),
              Text(
                s.loopGoal ? l.loopGoalDone : l.loopGoal,
                key: const Key('chronicle-goal'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l.chronicleLoopTime(
                  f.duration(s.loopPlaySeconds),
                  s.loopPrestiges,
                ),
                style: _dim,
              ),
            ],
          ),
        ),
        for (final id in s.loopRules) ...[
          const SizedBox(height: 8),
          _RuleTile(
            art: ruleArt(id),
            header: l.loopRuleLabel,
            title: ruleName(l, id),
            body: ruleDescription(l, id),
          ),
        ],
        if (s.loopGoal) ...[
          if (c.econ.storyDone) ...[
            heading(l.chroniclePick),
            Text(l.chroniclePickHint, style: _dim),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in rules)
                  GestureDetector(
                    key: Key('pick-rule-${r.id}'),
                    onTap: () => c.toggleNextRule(r.id),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: s.nextRules.contains(r.id)
                            ? Palette.great
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Palette.outline, width: 2),
                      ),
                      child: Text(
                        ruleName(l, r.id),
                        style: TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 14,
                          color: s.nextRules.contains(r.id)
                              ? Colors.white
                              : Palette.outline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            _nextLoopCard(context, c),
          ],
          const SizedBox(height: 10),
          Center(
            child: BuyButton(
              key: const Key('chronicle-new-loop'),
              price: l.loopStart,
              enabled: true,
              celebrate: false,
              minWidth: 200,
              onPressed: () async {
                if (await confirmNewLoop(context, c) && context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
            ),
          ),
        ],
        heading(l.chronicleChapters),
        // The prologue is always open: where it all started.
        Container(
          key: const Key('chapter-0'),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: _card(Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.chroniclePrologue,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const StoryArt('prologue'),
              const SizedBox(height: 8),
              StoryTranscript(script: l.prologue),
            ],
          ),
        ),
        for (var n = 1; n <= c.balance.loops.storyChapters; n++)
          Container(
            key: Key('chapter-$n'),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: _card(n <= open ? Colors.white : _paper),
            child: n <= open
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.chronicleChapter(n)}: ${chapterTexts(l, n)!.$1}',
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StoryArt('chapter_$n'),
                      const SizedBox(height: 8),
                      StoryTranscript(script: chapterTexts(l, n)!.$2),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l.chronicleChapter(n)}: ???',
                          style: TextStyle(
                            fontFamily: Fonts.display,
                            fontSize: 16,
                            color: Palette.outline.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      // Only the next one says what it takes.
                      if (n == open + 1)
                        Text(l.chronicleChapterLocked(n), style: _dim),
                    ],
                  ),
          ),
        heading(l.chronicleSeals),
        // Rules outside the story show once it is done (R-PETLA-8).
        for (final r in rules)
          if (r.story || c.econ.storyDone)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: s.seals.contains(r.id)
                  ? _RuleTile(
                      key: Key('seal-${r.id}'),
                      art: ruleArt(r.id, seal: true),
                      title: sealName(l, r.id),
                      body: sealDescription(l, r.id),
                      footer: s.loopBest[r.id] == null
                          ? null
                          : '${ruleName(l, r.id)} · ${l.chronicleBest(f.duration(s.loopBest[r.id]!))}',
                      color: const Color(0xFFFFF1C4),
                    )
                  // The rule of this loop is known; the ones after it are a
                  // mystery.
                  : _RuleTile(
                      key: Key('seal-${r.id}'),
                      art: ruleArt(r.id),
                      locked: !s.loopRules.contains(r.id),
                      title: '???',
                      body: s.loopRules.contains(r.id)
                          ? l.chronicleSealLocked
                          : '',
                      color: _paper,
                    ),
            ),
      ],
    );
  }
}

/// On the paradox screen: which loop this is, and the way to the
/// Chronicle. Nothing before the first Chronos.
class LoopCard extends StatelessWidget {
  const LoopCard({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final s = c.state;
    if (s.loop == 1 && !s.loopGoal) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        key: const Key('open-chronicle'),
        onTap: () => showChronicle(context, c),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: _card(const Color(0xFFFFF1C4)),
          child: Row(
            children: [
              EmojiCard(art: generatorArt[c.balance.loops.goal]!, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.loopRules.isEmpty
                          ? l.loopNumber(s.loop)
                          : '${l.loopNumber(s.loop)} · ${s.loopRules.map((r) => ruleName(l, r)).join(' + ')}',
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      s.loopGoal ? l.loopGoalDone : l.loopGoal,
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              Text(
                l.chronicleTitle,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 14),
              ),
              const Icon(Icons.chevron_right, color: Palette.outline),
            ],
          ),
        ),
      ),
    );
  }
}
