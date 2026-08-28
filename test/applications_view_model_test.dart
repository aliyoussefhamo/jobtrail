import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/core/notifications/notification_service.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/domain/application_event.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';
import 'package:jobtrail/features/applications/presentation/applications_view_model.dart';

void main() {
  test('sync schedules reminders only for upcoming interviews', () async {
    final notifications = RecordingNotificationService();
    final viewModel = ApplicationsViewModel(
      InMemoryApplicationRepository(),
      notificationService: notifications,
      now: () => DateTime(2026, 8, 28),
    );
    await viewModel.load();

    final count = await viewModel.syncInterviewReminders();

    expect(count, 1);
    expect(notifications.scheduledApplicationIds, [
      'nova-labs-flutter-developer',
    ]);
    expect(
      notifications.cancelledApplicationIds,
      containsAll([
        'northstar-mobile-engineer',
        'pixel-forge-ios-flutter',
        'orbit-commerce-junior-flutter',
      ]),
    );
  });

  test('changing an interview to offer cancels its reminder', () async {
    final repository = InMemoryApplicationRepository();
    final notifications = RecordingNotificationService();
    final viewModel = ApplicationsViewModel(
      repository,
      notificationService: notifications,
    );
    await viewModel.load();
    final nova = viewModel.allApplications.first;
    final offer = JobApplication(
      id: nova.id,
      company: nova.company,
      role: nova.role,
      location: nova.location,
      status: ApplicationStatus.offer,
      appliedDate: nova.appliedDate,
      interviewDate: nova.interviewDate,
      updatedLabel: 'Offer received just now',
      notes: nova.notes,
    );

    await viewModel.update(nova, offer);

    expect(notifications.cancelledApplicationIds, contains(nova.id));
  });

  test('deleting an application cancels its reminder', () async {
    final repository = InMemoryApplicationRepository();
    final notifications = RecordingNotificationService();
    final viewModel = ApplicationsViewModel(
      repository,
      notificationService: notifications,
    );
    await viewModel.load();
    final application = viewModel.allApplications.first;

    await viewModel.delete(application);

    expect(notifications.cancelledApplicationIds, contains(application.id));
  });

  test('load exposes an error when the repository fails', () async {
    final viewModel = ApplicationsViewModel(FailingApplicationRepository());

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, 'Could not load applications.');
    expect(viewModel.allApplications, isEmpty);
  });

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

class RecordingNotificationService implements NotificationService {
  final List<String> scheduledApplicationIds = [];
  final List<String> cancelledApplicationIds = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> scheduleInterviewReminder({
    required String applicationId,
    required String company,
    required String role,
    required DateTime interviewDate,
  }) async {
    scheduledApplicationIds.add(applicationId);
  }

  @override
  Future<void> cancelInterviewReminder(String applicationId) async {
    cancelledApplicationIds.add(applicationId);
  }
}

class FailingApplicationRepository implements ApplicationRepository {
  @override
  Future<List<JobApplication>> getAll() => throw Exception('Database failed');

  @override
  Future<List<ApplicationEvent>> getEvents(String applicationId) =>
      throw Exception('Database failed');

  @override
  Future<void> add(JobApplication application) =>
      throw Exception('Database failed');

  @override
  Future<void> update(JobApplication current, JobApplication updated) =>
      throw Exception('Database failed');

  @override
  Future<void> delete(JobApplication application) =>
      throw Exception('Database failed');
}
