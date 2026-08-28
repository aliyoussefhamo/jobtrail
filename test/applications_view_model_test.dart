import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';
import 'package:jobtrail/features/applications/presentation/applications_view_model.dart';

void main() {
  test(
    'upcoming interviews excludes past dates and sorts nearest first',
    () async {
      final viewModel = ApplicationsViewModel(
        InMemoryApplicationRepository(),
        now: () => DateTime(2026, 8, 28),
      );
      await viewModel.load();

      final interviews = viewModel.upcomingInterviews;

      expect(interviews, hasLength(1));
      expect(interviews.single.company, 'Nova Labs');
      expect(interviews.single.interviewDate, DateTime(2026, 9, 1));
    },
  );

  test(
    'upcoming interviews excludes applications that reached offer',
    () async {
      final repository = InMemoryApplicationRepository();
      final nova = (await repository.getAll()).first;
      await repository.update(
        nova,
        JobApplication(
          id: nova.id,
          company: nova.company,
          role: nova.role,
          location: nova.location,
          status: ApplicationStatus.offer,
          appliedDate: nova.appliedDate,
          interviewDate: nova.interviewDate,
          updatedLabel: nova.updatedLabel,
          notes: nova.notes,
        ),
      );
      final viewModel = ApplicationsViewModel(
        repository,
        now: () => DateTime(2026, 8, 28),
      );
      await viewModel.load();

      expect(viewModel.upcomingInterviews, isEmpty);
    },
  );

  test('date filter shows applications from the last seven days', () async {
    final viewModel = ApplicationsViewModel(
      InMemoryApplicationRepository(),
      now: () => DateTime(2026, 8, 28),
    );
    await viewModel.load();

    viewModel.setDateFilter(ApplicationDateFilter.last7Days);

    final companies = viewModel.visibleApplications
        .map((application) => application.company)
        .toList();
    expect(companies, containsAll(['Nova Labs', 'Northstar GmbH']));
    expect(companies, isNot(contains('Pixel Forge')));
    expect(companies, isNot(contains('Orbit Commerce')));
  });
}
