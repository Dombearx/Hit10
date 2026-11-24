import 'package:flutter/material.dart';

import '../../balance/balance.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../l10n/master_texts.dart';
import '../dial_skins.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'sheet.dart';

/// The stopwatch faces (docs/12 §3.3), opened from the dial button in the
/// top bar. They used to sit at the bottom of the settings, where players
/// did not look for them (playtest: "skins in settings are not intuitive").
Future<void> showDialsSheet(BuildContext context, GameController c) {
  return showGameSheet(
    context,
    c,
    title: (l) => l.help_dials_t,
    builder: (context) => ListView(
      key: const Key('dials-sheet'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [DialGallery(controller: c)],
    ),
  );
}

/// The top-bar button: the face in use, drawn small.
class DialButton extends StatelessWidget {
  const DialButton({super.key, required this.controller, required this.onTap});
  final GameController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.help_dials_t,
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('open-dials'),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Palette.outline, width: 2),
          ),
          child: DialPreview(skin: dialSkin(controller.econ.dialId), size: 28),
        ),
      ),
    );
  }
}

/// Every stopwatch face by track (docs/17 §5): unlocked ones to pick; on
/// each track the next one fills up and says what it takes, the rest are
/// "???". The feat stays a mystery until the first Chronos.
class DialGallery extends StatelessWidget {
  const DialGallery({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final e = c.econ;
    final l = AppLocalizations.of(context);
    final f = Fmt.of(context, c);
    final current = e.dialId;
    final dim = TextStyle(
      fontSize: 13,
      color: Palette.outline.withValues(alpha: 0.7),
    );
    String trackName(DialTrack t) => switch (t) {
      DialTrack.earned => l.dialTrack_earned,
      DialTrack.mastery => l.dialTrack_mastery,
      DialTrack.loops => l.dialTrack_loops,
      DialTrack.feat => l.dialTrack_feat,
      DialTrack.loyalty => l.dialTrack_loyalty,
    };
    // The feat is for staying on after Chronos: hidden before the first.
    bool hidden(DialConfig d) =>
        d.track == DialTrack.feat && c.state.loopsDone == 0;
    String need(DialConfig d) => switch (d.track) {
      DialTrack.earned => l.dialLocked(f.round(d.earned)),
      DialTrack.mastery => l.dialLockedTiers(d.tiers),
      DialTrack.loops => d.seal != null ? l.dialLockedSeal : l.dialLockedLoop,
      DialTrack.feat => l.dialLockedChronos(d.chronosInLoop),
      DialTrack.loyalty => l.dialLockedDays(d.dailyClaims),
    };
    String? progress(DialConfig d) {
      if (d.seal != null || hidden(d)) return null;
      final have = e.dialHave(d);
      return d.track == DialTrack.earned
          ? l.dialProgress(f.n(have), f.round(d.earned))
          : l.dialProgressCount('${have.toInt()}', '${d.need.toInt()}');
    }

    return Column(
      key: const Key('set-dial'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.dialHint, style: dim),
        for (final t in e.dialTracks) ...[
          const SizedBox(height: 14),
          Text(
            trackName(t),
            key: Key('dial-track-${t.name}'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          if (e.nextDialOn(t) case final next? when progress(next) != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                progress(next)!,
                key: Key(
                  t == DialTrack.earned
                      ? 'dial-progress'
                      : 'dial-progress-${t.name}',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final d in c.balance.dials)
                if (d.track == t && e.dialUnlocked(d))
                  _DialTile(
                    key: Key('dial-${d.id}'),
                    selected: d.id == current,
                    onTap: () => c.setDial(d.id),
                    preview: DialPreview(skin: dialSkin(d.id), size: 58),
                    label: dialTexts(l, d.id)?.$1 ?? d.id,
                  )
                else if (d.track == t)
                  _DialTile(
                    key: Key('dial-${d.id}'),
                    selected: false,
                    preview: DialPreview(
                      skin: dialSkin(d.id),
                      size: 58,
                      locked: true,
                      progress: d == e.nextDialOn(t) && progress(d) != null
                          ? e.dialProgress(d)
                          : null,
                    ),
                    label: d == e.nextDialOn(t) && !hidden(d) ? need(d) : '???',
                  ),
            ],
          ),
        ],
        if (dialTexts(l, current)?.$2 case final line?)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              line,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}

class _DialTile extends StatelessWidget {
  const _DialTile({
    super.key,
    required this.selected,
    required this.preview,
    required this.label,
    this.onTap,
  });
  final bool selected;
  final Widget preview;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 84,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFE08A) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Palette.outline : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          preview,
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}
