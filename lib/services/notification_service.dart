import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/user_provider.dart';

class NotificationService extends ChangeNotifier {
  static const String _scheduledIdsKey = 'scheduled_class_notification_ids';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  ApiService? _api;
  UserProvider? _user;
  bool _initialized = false;

  void updateDependencies(ApiService api, UserProvider user) {
    _api = api;
    _user = user;
    if (!_initialized) {
      unawaited(_init());
    } else {
      unawaited(_registerFcmToken());
    }
  }

  Future<void> _init() async {
    _initialized = true;

    await _initLocalNotifications();
    await _requestPermissions();
    await _initFirebaseHandlers();
    await _registerFcmToken();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _local.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'class_reminders',
      'Class reminders',
      description: 'Reminders for upcoming classes',
      importance: Importance.high,
    );

    final androidPlugin =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    await _configureTimezone();
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin =
        _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _local.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initFirebaseHandlers() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _showForegroundNotification(
        title: notification.title ?? 'OceanDojo',
        body: notification.body ?? '',
      );
    });

    _messaging.onTokenRefresh.listen((token) {
      _registerFcmToken(tokenOverride: token);
    });
  }

  Future<void> _registerFcmToken({String? tokenOverride}) async {
    final api = _api;
    if (api == null) return;
    if (_user?.user == null) return;

    try {
      final token = tokenOverride ?? await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      final platform = _resolvePlatform();
      await api.registerPushToken(
        token: token,
        platform: platform,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token: $e');
      }
    }
  }

  String _resolvePlatform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'unknown';
    }
  }

  Future<void> _showForegroundNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'class_reminders',
        'Class reminders',
        channelDescription: 'Reminders for upcoming classes',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> syncStudentClassNotifications(List<ClassModel> classes) async {
    final user = _user;
    if (user == null || !user.isStudent) return;
    final studentId = user.studentId;
    if (studentId == null) return;

    final enrolled = classes.where((c) {
      if (c.status.toLowerCase() != 'scheduled') return false;
      final ids = c.studentIds ?? [];
      return ids.contains(studentId);
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final existingIds =
        (prefs.getStringList(_scheduledIdsKey) ?? [])
            .map(int.parse)
            .toSet();
    final newIds = enrolled.map((c) => c.id).toSet();

    final toRemove = existingIds.difference(newIds);
    for (final classId in toRemove) {
      await _cancelClassNotifications(classId);
    }

    for (final classItem in enrolled) {
      await _cancelClassNotifications(classItem.id);
      await _scheduleClassNotifications(classItem);
    }

    await prefs.setStringList(
      _scheduledIdsKey,
      newIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _scheduleClassNotifications(ClassModel classItem) async {
    final now = DateTime.now();
    final start = classItem.startDatetime;
    if (start.isBefore(now)) return;

    final items = <_ScheduleItem>[
      _ScheduleItem(
        offset: const Duration(hours: 24),
        title: 'Sua aula começa em 24 horas',
      ),
      _ScheduleItem(
        offset: const Duration(hours: 2),
        title: 'Sua aula começa em 2 horas',
      ),
      _ScheduleItem(
        offset: const Duration(minutes: 30),
        title: 'Sua aula começa em 30 minutos',
      ),
      _ScheduleItem(
        offset: Duration.zero,
        title: 'Sua aula está começando',
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final scheduled = start.subtract(item.offset);
      if (scheduled.isBefore(now.add(const Duration(minutes: 1)))) {
        continue;
      }

      final id = _notificationId(classItem.id, i);
      await _local.zonedSchedule(
        id,
        item.title,
        _formatBody(classItem),
        tz.TZDateTime.from(scheduled, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'class_reminders',
            'Class reminders',
            channelDescription: 'Reminders for upcoming classes',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  String _formatBody(ClassModel classItem) {
    final timeRange =
        '${_formatTime(classItem.startDatetime)} - ${_formatTime(classItem.endDatetime)}';
    return 'Horário: $timeRange';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int _notificationId(int classId, int index) {
    return classId * 10 + index + 1;
  }

  Future<void> _cancelClassNotifications(int classId) async {
    for (var i = 0; i < 4; i++) {
      await _local.cancel(_notificationId(classId, i));
    }
  }
}

class _ScheduleItem {
  final Duration offset;
  final String title;

  const _ScheduleItem({required this.offset, required this.title});
}
