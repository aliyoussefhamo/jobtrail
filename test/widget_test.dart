import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/app/jobtrail_app.dart';
import 'package:jobtrail/core/notifications/notification_service.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';

Future<void> pumpJobTrail(
  WidgetTester tester, {
  NotificationService notificationService = const NoopNotificationService(),
  ApplicationRepository? repository,
}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    JobTrailApp(
      repository: repository ?? InMemoryApplicationRepository(),
      notificationService: notificationService,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard shows application overview', (tester) async {
    await pumpJobTrail(tester);
    expect(find.text('JobTrail'), findsOneWidget);
    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('Recent applications'), findsOneWidget);
    expect(find.text('Upcoming interview'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
  });

  testWidgets('notification button enables interview reminders', (
    tester,
  ) async {
    await pumpJobTrail(tester);

    await tester.tap(find.byTooltip('Enable interview reminders'));
    await tester.pump();

    expect(
      find.text('Interview reminders enabled for 1 upcoming interview.'),
      findsOneWidget,
    );
  });

  testWidgets('notification denial is explained to the user', (tester) async {
    await pumpJobTrail(
      tester,
      notificationService: const DeniedNotificationService(),
    );

    await tester.tap(find.byTooltip('Enable interview reminders'));
    await tester.pump();

    expect(
      find.text('Notification permission was not granted.'),
      findsOneWidget,
    );
  });

  testWidgets('search filters applications and can be cleared', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpJobTrail(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search applications'),
      'PIXEL',
    );
    await tester.pump();

    expect(find.textContaining('Pixel Forge'), findsOneWidget);
    expect(find.textContaining('Nova Labs'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.textContaining('Pixel Forge'), findsOneWidget);
    expect(find.textContaining('Nova Labs'), findsWidgets);
  });

  testWidgets('search keeps focus while results are filtered', (tester) async {
    await pumpJobTrail(tester);
    final searchField = find.widgetWithText(TextField, 'Search applications');

    await tester.tap(searchField);
    await tester.enterText(searchField, 'p');
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('search finds applications by status', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpJobTrail(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search applications'),
      'offer',
    );
    await tester.pump();

    expect(find.textContaining('Pixel Forge'), findsOneWidget);
    expect(find.textContaining('Nova Labs'), findsNothing);
  });

  testWidgets('empty dashboard invites the user to add an application', (
    tester,
  ) async {
    await pumpJobTrail(tester, repository: EmptyApplicationRepository());

    expect(find.text('Start your job trail'), findsOneWidget);
    expect(find.text('Add first application'), findsOneWidget);
  });

  testWidgets('empty search can clear all active filters', (tester) async {
    await pumpJobTrail(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search applications'),
      'company that does not exist',
    );
    await tester.pump();

    expect(find.text('No matching applications'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pump();

    expect(find.textContaining('Nova Labs'), findsWidgets);
    expect(
      tester
          .widget<TextField>(
            find.widgetWithText(TextField, 'Search applications'),
          )
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('load error can be retried from the dashboard', (tester) async {
    final repository = RecoveringApplicationRepository();
    await pumpJobTrail(tester, repository: repository);

    expect(find.text('Could not load applications.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.loadAttempts, 2);
    expect(find.textContaining('Nova Labs'), findsWidgets);
  });

  testWidgets('multiple status filters can be selected together', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpJobTrail(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Interview'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, 'Offer'));
    await tester.pump();

    expect(find.textContaining('Nova Labs'), findsOneWidget);
    expect(find.textContaining('Pixel Forge'), findsOneWidget);
    expect(find.textContaining('Northstar GmbH'), findsNothing);
  });

  testWidgets('applications can be sorted by company', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpJobTrail(tester);

    await tester.tap(find.byTooltip('Sort applications'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Company A-Z').last);
    await tester.pumpAndSettle();

    final northstarPosition = tester.getTopLeft(
      find.textContaining('Northstar GmbH'),
    );
    final novaPosition = tester.getTopLeft(
      find.textContaining('Nova Labs').last,
    );

    expect(northstarPosition.dy, lessThan(novaPosition.dy));
  });

  testWidgets('add application form includes optional notes', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Add application'));
    await tester.pumpAndSettle();

    expect(find.text('Add a new application'), findsOneWidget);
    expect(find.text('Application date'), findsOneWidget);
    expect(find.text('Interview date (optional)'), findsOneWidget);
    expect(find.text('Notes (optional)'), findsOneWidget);
  });

  testWidgets('saving an application shows progress and succeeds', (
    tester,
  ) async {
    final repository = DelayedAddApplicationRepository();
    await pumpJobTrail(tester, repository: repository);
    await openAndCompleteAddForm(tester);

    expect(find.text('Saving application'), findsOneWidget);
    expect(repository.addCalls, 1);

    repository.completeAdd();
    await tester.pumpAndSettle();

    expect(find.text('Application saved.'), findsOneWidget);
    expect(find.textContaining('Test Company'), findsOneWidget);
  });

  testWidgets('failed application save is explained', (tester) async {
    await pumpJobTrail(tester, repository: FailingAddApplicationRepository());
    await openAndCompleteAddForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Could not save the application.'), findsOneWidget);
  });

  testWidgets('upcoming interview opens application details', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Upcoming interview'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Nova Labs'), findsWidgets);
  });

  testWidgets('application card opens its details', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Flutter Developer'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Berlin - Remote'), findsOneWidget);
    expect(find.text('Interview tomorrow, 10:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('No notes added yet.'), 200);
    expect(find.text('Application timeline'), findsOneWidget);
    expect(find.text('Application submitted'), findsOneWidget);
    expect(find.text('No notes added yet.'), findsOneWidget);
  });

  testWidgets('editing an application updates the dashboard', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Flutter Developer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit application'));
    await tester.pumpAndSettle();

    expect(find.text('Edit application'), findsOneWidget);
    final roleField = find.widgetWithText(TextFormField, 'Job title');
    await tester.enterText(roleField, 'Senior Flutter Developer');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Senior Flutter Developer'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.text('Updated just now'), findsOneWidget);
  });

  testWidgets('deleting an application removes it from the dashboard', (
    tester,
  ) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Flutter Developer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete application'));
    await tester.pumpAndSettle();

    expect(find.text('Delete application?'), findsOneWidget);
    expect(
      find.text('This will permanently remove the application at Nova Labs.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Developer'), findsNothing);
  });
}

class DeniedNotificationService implements NotificationService {
  const DeniedNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

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

class EmptyApplicationRepository extends InMemoryApplicationRepository {
  @override
  Future<List<JobApplication>> getAll() async => const [];
}

class RecoveringApplicationRepository extends InMemoryApplicationRepository {
  int loadAttempts = 0;

  @override
  Future<List<JobApplication>> getAll() async {
    loadAttempts++;
    if (loadAttempts == 1) throw Exception('Database failed');
    return super.getAll();
  }
}

class DelayedAddApplicationRepository extends InMemoryApplicationRepository {
  final Completer<void> _addCompleter = Completer<void>();
  int addCalls = 0;

  @override
  Future<void> add(JobApplication application) async {
    addCalls++;
    await _addCompleter.future;
    await super.add(application);
  }

  void completeAdd() => _addCompleter.complete();
}

class FailingAddApplicationRepository extends InMemoryApplicationRepository {
  @override
  Future<void> add(JobApplication application) =>
      throw Exception('Database failed');
}

Future<void> openAndCompleteAddForm(WidgetTester tester) async {
  await tester.tap(find.text('Add application'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Company'),
    'Test Company',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Job title'),
    'Flutter Developer',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Location'),
    'Remote',
  );
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  await tester.drag(
    find.byType(SingleChildScrollView).last,
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save application'));
  await tester.pump();
}
