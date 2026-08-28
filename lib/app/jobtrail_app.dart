import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/notifications/notification_service.dart';
import '../features/applications/data/application_database.dart';
import '../features/applications/data/application_repository.dart';
import '../features/applications/presentation/dashboard_page.dart';

class JobTrailApp extends StatelessWidget {
  const JobTrailApp({
    this.repository,
    this.notificationService = const NoopNotificationService(),
    super.key,
  });

  final ApplicationRepository? repository;
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JobTrail',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: DashboardPage(
      repository:
          repository ??
          SqliteApplicationRepository(ApplicationDatabase.instance),
      notificationService: notificationService,
    ),
  );
}
