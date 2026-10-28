import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../model/number_format.dart';
import 'notifications.dart';

OfflineNotifications createNotifications() =>
    Platform.isAndroid ? LocalOfflineNotifications() : const NoNotifications();

/// Local, on-device scheduling: no backend, no Firebase (docs/05 §1).
/// Inexact scheduling, so no exact-alarm permission is needed.
class LocalOfflineNotifications implements OfflineNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const _id = 10;

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
  Future<void> scheduleOfflineFull(
    DateTime at,
    double amount,
    String Function(String amount) title,
  ) async {
    try {
      await _init();
      await _plugin.cancel(id: _id);
      await _plugin.zonedSchedule(
        id: _id,
        title: title(formatNumber(amount)),
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'offline',
            'Offline income',
            channelDescription: 'Tells you when your clocks are full',
            importance: Importance.defaultImportance,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object catch (e) {
      debugPrint('notification schedule failed: $e');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      if (_ready) await _plugin.cancel(id: _id);
    } on Object catch (e) {
      debugPrint('notification cancel failed: $e');
    }
  }
}
