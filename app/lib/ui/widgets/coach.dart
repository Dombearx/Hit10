import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../format.dart';
import '../game_controller.dart';
import '../theme.dart';

/// What the coach can point at. Each is put on one widget of the game
/// screen; the coach measures it after layout.
abstract final class CoachTargets {
  static final arena = GlobalKey(debugLabel: 'coach-arena');
  static final balance = GlobalKey(debugLabel: 'coach-balance');
  static final perSecond = GlobalKey(debugLabel: 'coach-per-second');
  static final grandpaBuy = GlobalKey(debugLabel: 'coach-grandpa-buy');
  static final clocksTab = GlobalKey(debugLabel: 'coach-clocks-tab');
  static final skillsTab = GlobalKey(debugLabel: 'coach-skills-tab');
  static final upgradeStrip = GlobalKey(debugLabel: 'coach-upgrades');
  static final modeRow = GlobalKey(debugLabel: 'coach-modes');
  static final combo = GlobalKey(debugLabel: 'coach-combo');
  static final prestige = GlobalKey(debugLabel: 'coach-prestige');

  /// The bubble itself (QA builds measure where it ended up).
  static final bubble = GlobalKey(debugLabel: 'coach-bubble');

  /// The target the shown mark is pinned to, for QA.
  static GlobalKey? pinned;
}

/// One coach mark: a short line pinned to the thing it is about.
class _Mark {
  const _Mark({
    required this.id,
    required this.text,
    required this.targets,
    this.dim = false,
    this.ok,
    this.onOk,
    this.onSkip,
    this.onClose,
  });

  /// Widget key suffix ('tutorial-aim', 'tip-skills').
  final String id;
  final String text;

  /// First one on screen wins (a tab stands in for a card it hides).
  final List<GlobalKey> targets;

  /// Darken everything but the target (steps that wait for one action).
  final bool dim;
  final String? ok;
  final VoidCallback? onOk;
  final VoidCallback? onSkip;
  final VoidCallback? onClose;
}

/// First-run guidance (R-TUT-1) and one-time tips (R-TUT-2) as coach
/// marks: a speech bubble with an arrow pinned to its target, a pulsing
/// ring around the target, and for the "do this now" steps a dimmed
/// screen with a hole over it. Nothing here blocks a tap: the dim and the
/// ring let touches through, so the player can always keep playing.
class CoachOverlay extends StatefulWidget {
  const CoachOverlay({super.key, required this.controller});
  final GameController controller;

  @override
  State<CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<CoachOverlay>
    with SingleTickerProviderStateMixin {
  /// A few pulses when a mark appears, then the ring stays still (an
  /// endless animation would also keep tests from settling).
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  String? _lastId;
  Rect? _rect;
  Rect? _arena;
  double _bubbleH = 62;

  void _measure(_Mark mark) {
    if (!mounted || mark.id != _lastId) return;
    Rect? r;
    CoachTargets.pinned = null;
    for (final t in mark.targets) {
      r = _rectOf(t);
      if (r != null) {
        CoachTargets.pinned = t;
        break;
      }
    }
    final arena = _rectOf(CoachTargets.arena);
    final h = _rectOf(CoachTargets.bubble)?.height;
    if (h != null) _bubbleH = h; // used from the next layout on
    if (r != _rect || arena != _arena) {
      setState(() {
        _rect = r;
        _arena = arena;
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  _Mark? _mark(AppLocalizations l, Fmt f) {
    final c = widget.controller;
    final grandpa = c.balance.generators.first;
    switch (c.tutorialStep) {
      case TutorialStep.aim:
        return _Mark(
          id: 'tutorial-aim',
          text: l.tutorialAim,
          targets: [CoachTargets.arena],
          onSkip: c.finishTutorial,
        );
      case TutorialStep.earned:
        return _Mark(
          id: 'tutorial-earned',
          text: l.tutorialEarned(f.n(grandpa.baseCost)),
          targets: [CoachTargets.balance],
          onSkip: c.finishTutorial,
        );
      case TutorialStep.buyGrandpa:
        return _Mark(
          id: 'tutorial-buyGrandpa',
          text: l.tutorialBuy,
          targets: [CoachTargets.grandpaBuy, CoachTargets.clocksTab],
          dim: true,
          onSkip: c.finishTutorial,
        );
      case TutorialStep.grandpaInfo:
        return _Mark(
          id: 'tutorial-grandpaInfo',
          text: l.tutorialInfo(
            f.n(c.econ.unitRate(grandpa.id) * c.econ.permanentMultiplier()),
          ),
          // No dim: it asks for nothing and the player is still timing
          // taps (onboarding playtest).
          targets: [CoachTargets.perSecond, CoachTargets.balance],
          ok: l.tutorialGotIt,
          onOk: c.nextTutorialStep,
        );
      case TutorialStep.done:
        final tip = c.pendingTip;
        if (tip == null) return null;
        final (text, target) = switch (tip) {
          'skills' => (l.tip_skills, CoachTargets.skillsTab),
          'upgrade' => (l.tip_upgrade, CoachTargets.upgradeStrip),
          'modes' => (l.tip_modes, CoachTargets.modeRow),
          'combo' => (l.tip_combo, CoachTargets.combo),
          'prestige' => (l.tip_prestige, CoachTargets.prestige),
          'golden' => (l.tip_golden, CoachTargets.arena),
          _ => ('', CoachTargets.arena),
        };
        if (text.isEmpty) return null;
        return _Mark(
          id: 'tip-$tip',
          text: text,
          targets: [target, CoachTargets.arena],
          onClose: c.dismissTip,
        );
    }
  }

  /// [key]'s box in this overlay's coordinates, from the last layout.
  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    final me = context.findRenderObject();
    if (box is! RenderBox || me is! RenderBox) return null;
    if (!box.attached || !box.hasSize || !me.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: me);
    final r = topLeft & box.size;
    // Off screen (scrolled away) counts as missing.
    if (!(Offset.zero & me.size).overlaps(r)) return null;
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final f = Fmt.of(context, widget.controller);
        final mark = _mark(l, f);
        if (mark == null) {
          _lastId = null;
          _rect = null;
          return const SizedBox.shrink();
        }
        // Measured after layout ([_measure]); a target that moved shows up
        // one frame later.
        final rect = _lastId == mark.id ? _rect : null;
        if (mark.id != _lastId) {
          _lastId = mark.id;
          _rect = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _pulse
              ..value = 0
              ..repeat(reverse: true, count: 6);
          });
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure(mark));
        return LayoutBuilder(
          builder: (context, box) => _layout(mark, rect, _arena, box.biggest),
        );
      },
    );
  }

  Widget _layout(_Mark mark, Rect? rect, Rect? arena, Size size) {
    const gap = 10.0;
    final width = (size.width - 24).clamp(0.0, 320.0);
    final hole = rect?.inflate(6);
    // Below the target when it sits in the top half, above otherwise —
    // but never up over the dial: a target right under the arena (combo,
    // upgrades, toggles) gets its bubble below it (onboarding playtest).
    final bubbleH = _bubbleH.clamp(40.0, 120.0);
    // The dial ends a little above the arena's foot.
    final underArena =
        rect != null &&
        arena != null &&
        rect.top >= arena.bottom - 4 &&
        rect.top - gap - bubbleH < arena.bottom - arena.height * 0.08;
    final below =
        rect == null || underArena || rect.center.dy < size.height / 2;
    final anchorX = rect?.center.dx ?? size.width / 2;
    final left = (anchorX - width / 2).clamp(12.0, size.width - width - 12);
    // A target as tall as the arena: the bubble goes over its lower part.
    // So does one above the arena (the Tiki counter, "/s", the swirl): a
    // bubble right under it would sit on the dial's top, over the target
    // marker, while the player is timing a tap (onboarding playtest). The
    // target keeps its glowing ring; the arrow goes.
    final aboveArena =
        rect != null && arena != null && rect.bottom <= arena.top + 4;
    final big = rect != null && (rect.height > size.height * 0.3 || aboveArena);
    final slot = aboveArena ? arena : rect;
    final top = rect == null
        ? size.height * 0.4
        : big
        ? slot!.bottom - 8
        : rect.bottom + gap;
    final bubble = _Bubble(
      key: Key(mark.id),
      mark: mark,
      arrowX: (anchorX - left).clamp(22.0, width - 22.0),
      arrowUp: below && !big,
      showArrow: rect != null && !big,
    );
    return Stack(
      children: [
        if (mark.dim && hole != null)
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('dim-${mark.id}'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, k, _) =>
                    CustomPaint(painter: _DimPainter(hole, 0.5 * k)),
              ),
            ),
          ),
        if (hole != null && rect!.height <= size.height * 0.3)
          Positioned.fromRect(
            rect: hole,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  final k = Curves.easeInOut.transform(_pulse.value);
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Palette.perfect,
                        width: 3 + 2 * k,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.perfect.withValues(alpha: 0.6 * k),
                          blurRadius: 12 * k,
                          spreadRadius: 2 * k,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        if (below)
          Positioned(
            left: left,
            width: width,
            top: top,
            child: KeyedSubtree(key: CoachTargets.bubble, child: bubble),
          )
        else
          Positioned(
            left: left,
            width: width,
            bottom: size.height - rect.top + gap,
            child: KeyedSubtree(key: CoachTargets.bubble, child: bubble),
          ),
      ],
    );
  }
}

class _DimPainter extends CustomPainter {
  _DimPainter(this.hole, this.alpha);
  final Rect hole;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16)));
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole || old.alpha != alpha;
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.mark,
    required this.arrowX,
    required this.arrowUp,
    required this.showArrow,
  });
  final _Mark mark;
  final double arrowX;
  final bool arrowUp;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final arrow = showArrow
        ? Padding(
            padding: EdgeInsets.only(left: arrowX - 9),
            child: CustomPaint(
              size: const Size(18, 9),
              painter: _ArrowPainter(up: arrowUp),
            ),
          )
        : const SizedBox.shrink();
    final Widget? action = mark.ok != null
        ? TextButton(
            key: const Key('tutorial-ok'),
            onPressed: mark.onOk,
            style: TextButton.styleFrom(
              backgroundColor: Palette.perfect,
              foregroundColor: Palette.outline,
              minimumSize: const Size(48, 36),
            ),
            child: Text(
              mark.ok!,
              style: const TextStyle(fontFamily: Fonts.display, fontSize: 15),
            ),
          )
        : mark.onSkip != null
        ? TextButton(
            key: const Key('tutorial-skip'),
            onPressed: mark.onSkip,
            child: Text(
              l.skip,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
          )
        : mark.onClose != null
        ? IconButton(
            key: const Key('tip-close'),
            onPressed: mark.onClose,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close,
              size: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          )
        : null;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, k, child) => Transform.scale(
        scale: k,
        alignment: arrowUp ? Alignment.topCenter : Alignment.bottomCenter,
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arrowUp) arrow,
          // Painted, not a Material/DecoratedBox: the bubble lets taps
          // through to whatever is under it; only its button takes them.
          CustomPaint(
            painter: const _BubblePainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
              child: Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: Text(
                        mark.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (action != null) ...[const SizedBox(width: 4), action],
                ],
              ),
            ),
          ),
          if (!arrowUp) arrow,
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.up});
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    if (up) {
      p
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      p
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }
    canvas.drawPath(p..close(), Paint()..color = Palette.outline);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.up != up;

  @override
  bool hitTest(Offset position) => false;
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    canvas.drawRRect(
      r.shift(const Offset(0, 3)),
      Paint()..color = const Color(0x55000000),
    );
    canvas.drawRRect(r, Paint()..color = Palette.outline);
    canvas.drawRRect(
      r.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Palette.perfect,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;

  @override
  bool hitTest(Offset position) => false;
}
