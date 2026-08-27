import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/app/jobtrail_app.dart';

void main() {
  testWidgets('dashboard shows application overview', (tester) async {
    await tester.pumpWidget(const JobTrailApp());
    expect(find.text('JobTrail'), findsOneWidget);
    expect(find.text('Good morning, Ali'), findsOneWidget);
    expect(find.text('Recent applications'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
  });

  testWidgets('add application form includes optional notes', (tester) async {
    await tester.pumpWidget(const JobTrailApp());

    await tester.tap(find.text('Add application'));
    await tester.pumpAndSettle();

    expect(find.text('Add a new application'), findsOneWidget);
    expect(find.text('Notes (optional)'), findsOneWidget);
  });

  testWidgets('application card opens its details', (tester) async {
    await tester.pumpWidget(const JobTrailApp());

    await tester.tap(find.text('Flutter Developer'));
    await tester.pumpAndSettle();

    expect(find.text('Application details'), findsOneWidget);
    expect(find.text('Berlin - Remote'), findsOneWidget);
    expect(find.text('Interview tomorrow, 10:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('No notes added yet.'), 200);
    expect(find.text('No notes added yet.'), findsOneWidget);
  });

  testWidgets('editing an application updates the dashboard', (tester) async {
    await tester.pumpWidget(const JobTrailApp());

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
}
