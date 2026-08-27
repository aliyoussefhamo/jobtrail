import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/main.dart';

void main() {
  testWidgets('dashboard shows application overview', (tester) async {
    await tester.pumpWidget(const JobTrailApp());
    expect(find.text('JobTrail'), findsOneWidget);
    expect(find.text('Good morning, Ali'), findsOneWidget);
    expect(find.text('Recent applications'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget);
  });
}
