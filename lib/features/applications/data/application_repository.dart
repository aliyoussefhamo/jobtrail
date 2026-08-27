import '../domain/job_application.dart';

abstract interface class ApplicationRepository {
  List<JobApplication> getAll();
  void add(JobApplication application);
  void update(JobApplication current, JobApplication updated);
}

class InMemoryApplicationRepository implements ApplicationRepository {
  final List<JobApplication> _items = [
    const JobApplication(
      company: 'Nova Labs',
      role: 'Flutter Developer',
      location: 'Berlin - Remote',
      status: ApplicationStatus.interview,
      updatedLabel: 'Interview tomorrow, 10:00',
    ),
    const JobApplication(
      company: 'Northstar GmbH',
      role: 'Mobile Software Engineer',
      location: 'Frankfurt - Hybrid',
      status: ApplicationStatus.applied,
      updatedLabel: 'Applied 2 days ago',
    ),
    const JobApplication(
      company: 'Pixel Forge',
      role: 'iOS & Flutter Developer',
      location: 'Hamburg - Remote',
      status: ApplicationStatus.offer,
      updatedLabel: 'Offer received today',
    ),
    const JobApplication(
      company: 'Orbit Commerce',
      role: 'Junior Flutter Engineer',
      location: 'Munich - Onsite',
      status: ApplicationStatus.rejected,
      updatedLabel: 'Updated yesterday',
    ),
  ];

  @override
  List<JobApplication> getAll() => List.unmodifiable(_items);

  @override
  void add(JobApplication application) => _items.insert(0, application);

  @override
  void update(JobApplication current, JobApplication updated) {
    final index = _items.indexOf(current);
    if (index != -1) _items[index] = updated;
  }
}
