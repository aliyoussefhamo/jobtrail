import 'package:flutter/foundation.dart';

import '../data/application_repository.dart';
import '../domain/job_application.dart';

class ApplicationsViewModel extends ChangeNotifier {
  ApplicationsViewModel(this._repository);
  final ApplicationRepository _repository;
  final List<JobApplication> _applications = [];

  ApplicationStatus? selectedStatus;
  bool isLoading = true;
  String? errorMessage;

  List<JobApplication> get allApplications => List.unmodifiable(_applications);

  List<JobApplication> get visibleApplications {
    if (selectedStatus == null) return allApplications;
    return allApplications
        .where((item) => item.status == selectedStatus)
        .toList();
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
