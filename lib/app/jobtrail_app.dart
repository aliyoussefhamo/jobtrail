import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../features/applications/data/application_database.dart';
import '../features/applications/data/application_repository.dart';
import '../features/applications/presentation/dashboard_page.dart';

class JobTrailApp extends StatelessWidget {
  const JobTrailApp({this.repository, super.key});

  final ApplicationRepository? repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JobTrail',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: DashboardPage(
      repository:
          repository ??
          SqliteApplicationRepository(ApplicationDatabase.instance),
    ),
  );
}
