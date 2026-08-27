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
}
