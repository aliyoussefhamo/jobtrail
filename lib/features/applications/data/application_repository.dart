import '../domain/job_application.dart';

abstract interface class ApplicationRepository {
  List<JobApplication> getAll();
  void add(JobApplication application);
}

class InMemoryApplicationRepository implements ApplicationRepository {
  final List<JobApplication> _items = [
    const JobApplication(
      company: 'Nova Labs',
      role: 'Flutter Developer',
      location: 'Berlin - Remote',
      status: ApplicationStatus.interview,
      note: 'Interview tomorrow, 10:00',
      initials: 'NL',
    ),
    const JobApplication(
      company: 'Northstar GmbH',
      role: 'Mobile Software Engineer',
      location: 'Frankfurt - Hybrid',
      status: ApplicationStatus.applied,
      note: 'Applied 2 days ago',
      initials: 'NG',
    ),
    const JobApplication(
      company: 'Pixel Forge',
      role: 'iOS & Flutter Developer',
      location: 'Hamburg - Remote',
      status: ApplicationStatus.offer,
      note: 'Offer received today',
      initials: 'PF',
    ),
    const JobApplication(
      company: 'Orbit Commerce',
      role: 'Junior Flutter Engineer',
      location: 'Munich - Onsite',
      status: ApplicationStatus.rejected,
      note: 'Updated yesterday',
      initials: 'OC',
    ),
  ];

  @override
  List<JobApplication> getAll() => List.unmodifiable(_items);

  @override
  void add(JobApplication application) => _items.insert(0, application);
}
