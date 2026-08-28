import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/application_event_mapper.dart';
import 'package:jobtrail/features/applications/domain/application_event.dart';

void main() {
  test('application event survives a map round trip', () {
    final original = ApplicationEvent(
      id: 'event-1',
      applicationId: 'application-1',
      type: ApplicationEventType.statusChanged,
      title: 'Status changed to Interview',
      occurredAt: DateTime(2026, 8, 28, 10, 30),
    );

    final restored = applicationEventFromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.applicationId, original.applicationId);
    expect(restored.type, original.type);
    expect(restored.title, original.title);
    expect(restored.occurredAt, original.occurredAt);
  });
}
