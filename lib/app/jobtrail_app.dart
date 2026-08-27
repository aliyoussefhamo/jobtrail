import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../features/applications/presentation/dashboard_page.dart';

class JobTrailApp extends StatelessWidget {
  const JobTrailApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JobTrail',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const DashboardPage(),
  );
}
