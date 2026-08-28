import 'package:flutter/foundation.dart';

import '../data/application_repository.dart';
import '../domain/job_application.dart';

enum ApplicationSort {
  newest('Newest first'),
  company('Company A-Z'),
  status('Status');

  const ApplicationSort(this.label);

  final String label;
}

class ApplicationsViewModel extends ChangeNotifier {
  ApplicationsViewModel(this._repository);
  final ApplicationRepository _repository;
  final List<JobApplication> _applications = [];

  ApplicationStatus? selectedStatus;
  String searchQuery = '';
  ApplicationSort selectedSort = ApplicationSort.newest;
  bool isLoading = true;
  String? errorMessage;

  List<JobApplication> get allApplications => List.unmodifiable(_applications);

  List<JobApplication> get visibleApplications {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final results = allApplications.where((item) {
      final matchesStatus =
          selectedStatus == null || item.status == selectedStatus;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          item.company.toLowerCase().contains(normalizedQuery) ||
          item.role.toLowerCase().contains(normalizedQuery) ||
          item.location.toLowerCase().contains(normalizedQuery) ||
          item.status.label.toLowerCase().contains(normalizedQuery);
      return matchesStatus && matchesSearch;
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
    selectedStatus = selectedStatus == status ? null : status;
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

  Future<void> add(JobApplication application) async {
    await _repository.add(application);
    _applications.insert(0, application);
    selectedStatus = null;
    notifyListeners();
  }

  Future<void> update(JobApplication current, JobApplication updated) async {
    await _repository.update(current, updated);
    final index = _applications.indexWhere((item) => item.id == current.id);
    if (index != -1) _applications[index] = updated;
    selectedStatus = null;
    notifyListeners();
  }

  Future<void> delete(JobApplication application) async {
    await _repository.delete(application);
    _applications.removeWhere((item) => item.id == application.id);
    selectedStatus = null;
    notifyListeners();
  }
}
