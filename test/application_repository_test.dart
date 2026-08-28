import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/application_database.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/domain/application_event.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';

void main() {
  test('changing status creates a status event', () async {
    final repository = InMemoryApplicationRepository();
    final current = sampleApplications.first;
    final updated = _updatedApplication(
      current,
      status: ApplicationStatus.offer,
    );

    await repository.update(current, updated);
    final events = await repository.getEvents(current.id);

    final statusEvents = events.where(
      (event) => event.type == ApplicationEventType.statusChanged,
    );
    expect(statusEvents, hasLength(1));
    expect(statusEvents.single.title, contains('Offer'));
  });

  test('saving without changes does not create duplicate events', () async {
    final repository = InMemoryApplicationRepository();
    final current = sampleApplications.first;
    final before = await repository.getEvents(current.id);

    await repository.update(current, current);
    final after = await repository.getEvents(current.id);

    expect(after, hasLength(before.length));
  });

  test('deleting an application removes its events', () async {
    final repository = InMemoryApplicationRepository();
    final application = sampleApplications.first;

    await repository.delete(application);

    expect(await repository.getEvents(application.id), isEmpty);
  });
}

JobApplication _updatedApplication(
  JobApplication application, {
  required ApplicationStatus status,
}) {
  return JobApplication(
    id: application.id,
    company: application.company,
    role: application.role,
    location: application.location,
    status: status,
    appliedDate: application.appliedDate,
    interviewDate: application.interviewDate,
    updatedLabel: 'Updated just now',
    notes: application.notes,
  );
}
