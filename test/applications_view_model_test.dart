import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/presentation/applications_view_model.dart';

void main() {
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
