import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../engine/notification_plan.dart';
import 'notifications.dart';

OfflineNotifications createNotifications() =>
    Platform.isAndroid ? LocalOfflineNotifications() : const NoNotifications();

/// Local, on-device scheduling: no backend, no Firebase (docs/05 §1).
/// Inexact scheduling, so no exact-alarm permission is needed. Each kind
/// has its own Android channel, so the player can also silence one kind
/// in the system settings.
class LocalOfflineNotifications implements OfflineNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Notification ids: 10 was the only one before, kept for the first.
  static int _id(NotificationKind k) => 10 + k.index;

  static const _channels = {
    NotificationKind.offlineFull: (
      'offline',
      'Offline income',
      'When your clocks reach the offline limit',
    ),
    NotificationKind.dailyBonus: (
      'daily',
      'Daily bonus',
      'When the daily bonus streak is waiting',
    ),
    NotificationKind.reserveFull: (
      'winding',
      'Winding reserve',
      'When exact hits wind Mainsprings again',
    ),
  };

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _init();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } on Object catch (e) {
      debugPrint('notification permission failed: $e');
      return false;
    }
  }

  @override
  Future<void> schedule(List<Reminder> reminders) async {
    try {
      await _init();
      await _cancelAll();
      for (final r in reminders) {
        final (id, name, description) = _channels[r.kind]!;
        await _plugin.zonedSchedule(
          id: _id(r.kind),
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              id,
              name,
              channelDescription: description,
              importance: Importance.defaultImportance,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } on Object catch (e) {
      debugPrint('notification schedule failed: $e');
    }
  }

  Future<void> _cancelAll() async {
    for (final k in NotificationKind.values) {
      await _plugin.cancel(id: _id(k));
    }
  }

  @override
  Future<void> cancel() async {
    try {
      if (_ready) await _cancelAll();
    } on Object catch (e) {
      debugPrint('notification cancel failed: $e');
    }
  }
}
