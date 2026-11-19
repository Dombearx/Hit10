import 'package:flutter_test/flutter_test.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/engine/notification_plan.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/persistence/memory_save_store.dart';
import 'package:hit10/ui/game_controller.dart';
import 'package:hit10/ui/notifications.dart';

import 'helpers.dart';

/// R-OFF-4, R-POW-1…3: few reminders, worth reading, never at night.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final balance = loadBalance();

  group('NotificationPlan', () {
    final now = DateTime(2026, 11, 18, 14);

    test('at night it waits for the morning', () {
      expect(
        NotificationPlan.awake(DateTime(2026, 11, 18, 23, 30)),
        DateTime(2026, 11, 19, 9),
      );
      expect(
        NotificationPlan.awake(DateTime(2026, 11, 19, 3)),
        DateTime(2026, 11, 19, 9),
      );
      final day = DateTime(2026, 11, 19, 15, 20);
      expect(NotificationPlan.awake(day), day);
    });

    test('two at most, the important first, never close together', () {
      final plan = NotificationPlan.choose(now, {
        NotificationKind.reserveFull: now.add(const Duration(hours: 4)),
        NotificationKind.offlineFull: now.add(const Duration(hours: 5)),
        NotificationKind.dailyBonus: NotificationPlan.dailyReminder(now),
      });
      // The reserve is an hour from the offline limit: it gives way.
      expect(plan.map((p) => p.kind), [
        NotificationKind.offlineFull,
        NotificationKind.dailyBonus,
      ]);
      expect(plan.first.at, now.add(const Duration(hours: 5)));
    });

    test('a quiet-hours move can make two collide: one is kept', () {
      final late = DateTime(2026, 11, 18, 21);
      final plan = NotificationPlan.choose(late, {
        NotificationKind.offlineFull: late.add(const Duration(hours: 8)),
        NotificationKind.reserveFull: late.add(const Duration(hours: 4)),
      });
      expect(plan, hasLength(1));
      expect(plan.single.kind, NotificationKind.offlineFull);
      expect(plan.single.at, DateTime(2026, 11, 19, 9));
    });
  });

  group('what leaving the game schedules', () {
    final now = DateTime(2026, 11, 18, 14);

    GameController controller(GameState s) => GameController(
      balance: balance,
      state: s,
      store: MemorySaveStore(),
      wallClockMs: () => now.millisecondsSinceEpoch,
      localNow: () => now,
    );

    test('a new player: only the offline limit, once clocks earn', () {
      expect(
        controller(GameState()).plannedReminders(testReminderTexts),
        isEmpty,
      );
      final c = controller(GameState()..owned['grandma'] = 10);
      final r = c.plannedReminders(testReminderTexts);
      expect(r.map((e) => e.kind), [NotificationKind.offlineFull]);
      expect(r.single.title, startsWith('offline '));
    });

    test('a streak worth keeping and a spent reserve after a paradox', () {
      final s = GameState()
        ..tutorialDone = true
        ..prestiges = 1
        ..dailyKey = dateKey(now)
        ..dailyStreak = 4
        ..springReserve = 0
        ..springReserveMs = now.millisecondsSinceEpoch;
      final r = controller(s).plannedReminders(testReminderTexts);
      // No clocks this run: no offline reminder; the reserve refills in
      // 4 h (at 18:00), the daily one is due tomorrow at 18:00.
      expect(r.map((e) => e.kind), [
        NotificationKind.reserveFull,
        NotificationKind.dailyBonus,
      ]);
      expect(r.last.title, 'daily 5/7');
      expect(r.first.body, 'reserve 30 min');
    });

    test('turned off in the settings: nothing is scheduled', () async {
      final notes = RecordingNotifications();
      final c = GameController(
        balance: balance,
        state: GameState()..owned['grandma'] = 10,
        store: MemorySaveStore(),
        notifications: notes,
        localNow: () => now,
      );
      c.background(texts: testReminderTexts);
      await Future<void>.delayed(Duration.zero);
      expect(notes.scheduled, hasLength(1));
      c.settings.notifications = false;
      notes.scheduled = [];
      c.background(texts: testReminderTexts);
      await Future<void>.delayed(Duration.zero);
      expect(notes.scheduled, isEmpty);
    });
  });
}
