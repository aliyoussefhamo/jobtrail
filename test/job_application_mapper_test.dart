import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/job_application_mapper.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';

void main() {
  test('job application survives a map round trip', () {
    final original = JobApplication(
      id: 'test-id',
      company: 'Test Company',
      role: 'Flutter Developer',
      location: 'Remote',
      status: ApplicationStatus.interview,
      appliedDate: DateTime(2026, 8, 20),
      interviewDate: DateTime(2026, 9, 2),
      updatedLabel: 'Interview scheduled',
      notes: 'Prepare portfolio',
    );

    final restored = jobApplicationFromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.company, original.company);
    expect(restored.role, original.role);
    expect(restored.location, original.location);
    expect(restored.status, original.status);
    expect(restored.appliedDate, original.appliedDate);
    expect(restored.interviewDate, original.interviewDate);
    expect(restored.updatedLabel, original.updatedLabel);
    expect(restored.notes, original.notes);
  });
}
