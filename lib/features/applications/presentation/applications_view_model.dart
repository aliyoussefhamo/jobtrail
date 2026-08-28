import 'package:flutter/foundation.dart';

import '../../../core/notifications/notification_service.dart';
import '../data/application_repository.dart';
import '../domain/job_application.dart';

enum ApplicationSort {
  newest('Newest first'),
  company('Company A-Z'),
  status('Status');

  const ApplicationSort(this.label);

  final String label;
}

enum ApplicationDateFilter {
  anyTime('Any time', null),
  last7Days('Last 7 days', 7),
  last30Days('Last 30 days', 30);

  const ApplicationDateFilter(this.label, this.days);

  final String label;
  final int? days;
}

class ApplicationsViewModel extends ChangeNotifier {
  ApplicationsViewModel(
    this._repository, {
    this.notificationService = const NoopNotificationService(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ApplicationRepository _repository;
  final NotificationService notificationService;
  final DateTime Function() _now;
  final List<JobApplication> _applications = [];

  final Set<ApplicationStatus> selectedStatuses = {};
  String searchQuery = '';
  ApplicationSort selectedSort = ApplicationSort.newest;
  ApplicationDateFilter selectedDateFilter = ApplicationDateFilter.anyTime;
  bool isLoading = true;
  String? errorMessage;

  List<JobApplication> get allApplications => List.unmodifiable(_applications);

  List<JobApplication> get upcomingInterviews {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final interviews =
        allApplications.where((application) {
          if (application.status != ApplicationStatus.interview) return false;
          final interviewDate = application.interviewDate;
          if (interviewDate == null) return false;
          final date = DateTime(
            interviewDate.year,
            interviewDate.month,
            interviewDate.day,
          );
          return !date.isBefore(today);
        }).toList()..sort(
          (first, second) =>
              first.interviewDate!.compareTo(second.interviewDate!),
        );
    return interviews;
  }

  List<JobApplication> get visibleApplications {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final results = allApplications.where((item) {
      final matchesStatus =
          selectedStatuses.isEmpty || selectedStatuses.contains(item.status);
      final matchesDate = _matchesDateFilter(item);
      final matchesSearch =
          normalizedQuery.isEmpty ||
          item.company.toLowerCase().contains(normalizedQuery) ||
          item.role.toLowerCase().contains(normalizedQuery) ||
          item.location.toLowerCase().contains(normalizedQuery) ||
          item.status.label.toLowerCase().contains(normalizedQuery);
      return matchesStatus && matchesDate && matchesSearch;
    }).toList();

    switch (selectedSort) {
      case ApplicationSort.newest:
        results.sort(
          (first, second) => second.appliedDate.compareTo(first.appliedDate),
        );
      case ApplicationSort.company:
        results.sort(
          (first, second) => first.company.toLowerCase().compareTo(
            second.company.toLowerCase(),
          ),
        );
      case ApplicationSort.status:
        results.sort((first, second) {
          final statusComparison = first.status.index.compareTo(
            second.status.index,
          );
          if (statusComparison != 0) return statusComparison;
          return first.company.toLowerCase().compareTo(
            second.company.toLowerCase(),
          );
        });
    }

    return results;
  }

  int count(ApplicationStatus status) =>
      allApplications.where((item) => item.status == status).length;

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      selectedStatuses.isNotEmpty ||
      selectedDateFilter != ApplicationDateFilter.anyTime;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _applications
        ..clear()
        ..addAll(await _repository.getAll());
    } catch (_) {
      errorMessage = 'Could not load applications.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleFilter(ApplicationStatus status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setSort(ApplicationSort value) {
    selectedSort = value;
    notifyListeners();
  }

  void setDateFilter(ApplicationDateFilter value) {
    selectedDateFilter = value;
    notifyListeners();
  }

  bool _matchesDateFilter(JobApplication application) {
    final days = selectedDateFilter.days;
    if (days == null) return true;

    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final earliestDate = today.subtract(Duration(days: days - 1));
    final appliedDate = DateTime(
      application.appliedDate.year,
      application.appliedDate.month,
      application.appliedDate.day,
    );
    return !appliedDate.isBefore(earliestDate) && !appliedDate.isAfter(today);
  }

  Future<void> add(JobApplication application) async {
    await _repository.add(application);
    _applications.insert(0, application);
    await _syncInterviewReminder(application);
    selectedStatuses.clear();
    notifyListeners();
  }

  Future<void> update(JobApplication current, JobApplication updated) async {
    await _repository.update(current, updated);
    final index = _applications.indexWhere((item) => item.id == current.id);
    if (index != -1) _applications[index] = updated;
    await _syncInterviewReminder(updated);
    selectedStatuses.clear();
    notifyListeners();
  }

  Future<void> delete(JobApplication application) async {
    await _repository.delete(application);
    _applications.removeWhere((item) => item.id == application.id);
    await notificationService.cancelInterviewReminder(application.id);
    selectedStatuses.clear();
    notifyListeners();
  }

  Future<int> syncInterviewReminders() async {
    for (final application in _applications) {
      await _syncInterviewReminder(application);
    }
    return upcomingInterviews.length;
  }

  Future<void> _syncInterviewReminder(JobApplication application) async {
    final interviewDate = application.interviewDate;
    if (application.status != ApplicationStatus.interview ||
        interviewDate == null) {
      await notificationService.cancelInterviewReminder(application.id);
      return;
    }
    await notificationService.scheduleInterviewReminder(
      applicationId: application.id,
      company: application.company,
      role: application.role,
      interviewDate: interviewDate,
    );
  }
}
