import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads/rewarded_ads.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../model/number_format.dart';
import '../../persistence/save_codec.dart';
import '../game_controller.dart';
import '../providers.dart';
import '../seasons_ui.dart';
import '../theme.dart';
import 'sheet.dart';

/// Settings (docs/04 §2).
Future<void> showSettings(BuildContext context, GameController c) =>
    showGameSheet(
      context,
      c,
      title: (l) => l.settingsTitle,
      builder: (context) => _Settings(controller: c),
    );

class _Settings extends ConsumerWidget {
  const _Settings({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = controller;
    final s = c.settings;
    final l = AppLocalizations.of(context);
    void apply(void Function() change) {
      change();
      c.applySettings();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _Group(
          children: [
            _Slider(
              key: const Key('set-sfx'),
              label: l.settingsSound,
              value: s.sfxVolume,
              onChanged: (v) => apply(() => s.sfxVolume = v),
            ),
            _Slider(
              key: const Key('set-music'),
              label: l.settingsMusic,
              value: s.musicVolume,
              onChanged: (v) => apply(() {
                s.musicVolume = v;
                c.sfx.musicSuppressed = false; // the player chose (U-20)
              }),
            ),
            _Switch(
              key: const Key('set-haptics'),
              label: l.settingsHaptics,
              value: s.haptics,
              onChanged: (v) => apply(() => s.haptics = v),
            ),
            _Switch(
              key: const Key('set-notifications'),
              label: l.settingsNotifications,
              value: s.notifications,
              onChanged: (v) {
                apply(() => s.notifications = v);
                if (v) unawaited(c.notifications.requestPermission());
              },
            ),
          ],
        ),
        _Group(
          children: [
            _Choice<String?>(
              key: const Key('set-language'),
              label: l.settingsLanguage,
              value: s.language,
              options: {
                null: l.languageSystem,
                'pl': 'Polski',
                'en': 'English',
              },
              onChanged: (v) => apply(() => s.language = v),
            ),
            _Choice<Notation>(
              key: const Key('set-notation'),
              label: l.settingsNotation,
              value: s.notation,
              options: {
                Notation.short: l.notationShort,
                Notation.scientific: l.notationScientific,
              },
              onChanged: (v) => apply(() => s.notation = v),
            ),
            _Switch(
              key: const Key('set-reduce-motion'),
              label: l.settingsReduceMotion,
              hint: l.settingsReduceMotionHint,
              value: s.reduceMotion,
              onChanged: (v) => apply(() => s.reduceMotion = v),
            ),
            // Seasons (docs/02 §14): completed events leave their theme.
            ListenableBuilder(
              listenable: c,
              builder: (context, _) => _Choice<String>(
                key: const Key('set-theme'),
                label: l.themeTitle,
                hint: l.themeHint,
                value: c.state.theme,
                options: {
                  '': l.themeAuto,
                  'classic': l.themeClassic,
                  for (final id in c.unlockedThemes) id: seasonName(l, id),
                },
                onChanged: c.setTheme,
              ),
            ),
          ],
        ),
        _Group(
          title: l.settingsSave,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Action(
                    key: const Key('set-export'),
                    label: l.settingsExport,
                    onTap: () => _export(context, c),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Action(
                    key: const Key('set-import'),
                    label: l.settingsImport,
                    onTap: () => _import(context, ref, c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Action(
              key: const Key('set-reset'),
              label: l.settingsReset,
              danger: true,
              onTap: () => _reset(context, ref, c),
            ),
          ],
        ),
        _Group(
          title: l.settingsOther,
          children: [
            _Action(
              key: const Key('set-privacy'),
              label: l.settingsPrivacyPolicy,
              onTap: () => launchUrl(
                Uri.parse(privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: 10),
            if (ref.watch(rewardedAdsProvider) case final AdPrivacy p)
              _AdPrivacyButton(privacy: p),
            _Action(
              key: const Key('set-credits'),
              label: l.settingsCredits,
              onTap: () => showLicensePage(
                context: context,
                applicationName: l.appTitle,
                applicationLegalese: l.creditsLegalese,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, GameController c) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: c.exportText()));
    messenger.showSnackBar(SnackBar(content: Text(l.settingsExportDone)));
  }

  Future<void> _import(
    BuildContext context,
    WidgetRef ref,
    GameController c,
  ) async {
    final l = AppLocalizations.of(context);
    final restart = ref.read(restartProvider);
    final text = await _ask(
      context,
      body: l.settingsImportConfirm,
      field: l.settingsImportHint,
      ok: l.settingsImport,
    );
    if (text == null || text.trim().isEmpty || !context.mounted) return;
    try {
      importSave(text); // validate before touching anything
    } on SaveFormatException {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.settingsImportBad)));
      return;
    }
    await c.importText(text);
    await restart();
  }

  /// Two confirmations, the second one typed (docs/04 §2).
  Future<void> _reset(
    BuildContext context,
    WidgetRef ref,
    GameController c,
  ) async {
    final l = AppLocalizations.of(context);
    final restart = ref.read(restartProvider);
    final first = await _ask(
      context,
      body: l.settingsResetConfirm1,
      ok: l.settingsReset,
    );
    if (first == null || !context.mounted) return;
    final typed = await _ask(
      context,
      body: l.settingsResetConfirm2(l.resetWord),
      field: l.resetWord,
      ok: l.settingsReset,
    );
    if (typed?.trim().toUpperCase() != l.resetWord.toUpperCase()) return;
    await c.resetProgress();
    await restart();
  }

  /// A confirm dialog, optionally with a text field. Returns the text (or ''
  /// without a field) when confirmed, null when cancelled.
  Future<String?> _ask(
    BuildContext context, {
    required String body,
    String? field,
    required String ok,
  }) => showDialog<String>(
    context: context,
    builder: (context) => _AskDialog(body: body, field: field, ok: ok),
  );
}

/// Owns its text controller, so it lives exactly as long as the dialog
/// (including the closing animation).
class _AskDialog extends StatefulWidget {
  const _AskDialog({required this.body, this.field, required this.ok});
  final String body;
  final String? field;
  final String ok;

  @override
  State<_AskDialog> createState() => _AskDialogState();
}

class _AskDialogState extends State<_AskDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final field = widget.field;
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.body),
          if (field != null) ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('dialog-field'),
              controller: _text,
              autofocus: true,
              maxLines: field == l.resetWord ? 1 : 4,
              decoration: InputDecoration(
                hintText: field,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const Key('dialog-ok'),
          onPressed: () => Navigator.pop(context, _text.text),
          child: Text(widget.ok),
        ),
      ],
    );
  }
}

/// The privacy policy on the game's site (docs/05 T-26).
const privacyPolicyUrl = 'https://dombearx.github.io/hit10/privacy.html';

/// UMP's "privacy options" entry, shown only where the law requires it.
class _AdPrivacyButton extends StatelessWidget {
  const _AdPrivacyButton({required this.privacy});
  final AdPrivacy privacy;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: privacy.optionsRequired(),
      builder: (context, snap) => snap.data != true
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Action(
                key: const Key('set-ad-privacy'),
                label: AppLocalizations.of(context).settingsAdPrivacy,
                onTap: privacy.showOptions,
              ),
            ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                title!,
                style: const TextStyle(fontFamily: Fonts.display, fontSize: 18),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Palette.outline, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

const _labelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

class _Slider extends StatelessWidget {
  const _Slider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 4, child: Text(label, style: _labelStyle)),
        Expanded(
          flex: 5,
          child: Slider(
            value: value,
            activeColor: Palette.accent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _labelStyle),
                if (hint != null)
                  Text(
                    hint!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Palette.outline.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: Palette.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String? hint;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          if (hint != null)
            Text(
              hint!,
              style: TextStyle(
                fontSize: 12.5,
                color: Palette.outline.withValues(alpha: 0.7),
              ),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in options.entries)
                ChoiceChip(
                  key: Key('${(key as ValueKey?)?.value}-${e.key}'),
                  label: Text(e.value),
                  selected: e.key == value,
                  selectedColor: Palette.accent.withValues(alpha: 0.25),
                  side: const BorderSide(color: Palette.outline, width: 1.5),
                  onSelected: (_) => onChanged(e.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? Palette.accent : Palette.outline,
          side: BorderSide(
            color: danger ? Palette.accent : Palette.outline,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
