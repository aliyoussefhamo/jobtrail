import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/app/jobtrail_app.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';

Future<void> pumpJobTrail(WidgetTester tester) async {
  await tester.pumpWidget(
    JobTrailApp(repository: InMemoryApplicationRepository()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dashboard shows application overview', (tester) async {
    await pumpJobTrail(tester);
    expect(find.text('JobTrail'), findsOneWidget);
    expect(find.text('Good morning, Ali'), findsOneWidget);
    expect(find.text('Recent applications'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
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
    expect(find.textContaining('Nova Labs'), findsOneWidget);
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

  testWidgets('add application form includes optional notes', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Add application'));
    await tester.pumpAndSettle();

    expect(find.text('Add a new application'), findsOneWidget);
    expect(find.text('Notes (optional)'), findsOneWidget);
  });

  testWidgets('application card opens its details', (tester) async {
    await pumpJobTrail(tester);

    await tester.tap(find.text('Flutter Developer'));
    await tester.pumpAndSettle();

    expect(find.text('Application details'), findsOneWidget);
    expect(find.text('Berlin - Remote'), findsOneWidget);
    expect(find.text('Interview tomorrow, 10:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('No notes added yet.'), 200);
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
