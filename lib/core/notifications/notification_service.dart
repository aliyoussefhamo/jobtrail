import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> showTestNotification();
  Future<void> scheduleInterviewReminder({
    required String applicationId,
    required String company,
    required String role,
    required DateTime interviewDate,
  });
  Future<void> cancelInterviewReminder(String applicationId);
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
  }

  @override
  Future<bool> requestPermission() async {
    final androidResult = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (androidResult != null) return androidResult;

    final iosResult = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return iosResult ?? true;
  }

  @override
  Future<void> showTestNotification() => _plugin.show(
    id: 0,
    title: 'JobTrail reminders are ready',
    body: 'You will be reminded before upcoming interviews.',
    notificationDetails: _notificationDetails,
  );

  @override
  Future<void> scheduleInterviewReminder({
    required String applicationId,
    required String company,
    required String role,
    required DateTime interviewDate,
  }) async {
    final reminderDate = tz.TZDateTime(
      tz.local,
      interviewDate.year,
      interviewDate.month,
      interviewDate.day,
      9,
    ).subtract(const Duration(days: 1));
    final id = _notificationId(applicationId);
    if (!reminderDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.cancel(id: id);
      return;
    }

    await _plugin.zonedSchedule(
      id: id,
      title: 'Interview tomorrow at $company',
      body: 'Prepare for your $role interview.',
      scheduledDate: reminderDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: applicationId,
    );
  }

  @override
  Future<void> cancelInterviewReminder(String applicationId) =>
      _plugin.cancel(id: _notificationId(applicationId));

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'interview_reminders',
      'Interview reminders',
      channelDescription: 'Reminders for upcoming job interviews',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  int _notificationId(String applicationId) {
    var hash = 0x811C9DC5;
    for (final codeUnit in applicationId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> scheduleInterviewReminder({
    required String applicationId,
    required String company,
    required String role,
    required DateTime interviewDate,
  }) async {}

  @override
  Future<void> cancelInterviewReminder(String applicationId) async {}
}
