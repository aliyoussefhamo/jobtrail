import 'package:flutter/material.dart';

import 'app/jobtrail_app.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = LocalNotificationService();
  await notificationService.initialize();
  runApp(JobTrailApp(notificationService: notificationService));
}
