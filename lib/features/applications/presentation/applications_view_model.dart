import 'package:flutter/foundation.dart';

import '../data/application_repository.dart';
import '../domain/job_application.dart';

class ApplicationsViewModel extends ChangeNotifier {
  ApplicationsViewModel(this._repository);
  final ApplicationRepository _repository;
  ApplicationStatus? selectedStatus;

  List<JobApplication> get allApplications => _repository.getAll();

  List<JobApplication> get visibleApplications {
    if (selectedStatus == null) return allApplications;
    return allApplications
        .where((item) => item.status == selectedStatus)
        .toList();
  }

  int count(ApplicationStatus status) =>
      allApplications.where((item) => item.status == status).length;

  void toggleFilter(ApplicationStatus status) {
    selectedStatus = selectedStatus == status ? null : status;
    notifyListeners();
  }

  void add(JobApplication application) {
    _repository.add(application);
    selectedStatus = null;
    notifyListeners();
  }

  void update(JobApplication current, JobApplication updated) {
    _repository.update(current, updated);
    selectedStatus = null;
    notifyListeners();
  }

  void delete(JobApplication application) {
    _repository.delete(application);
    selectedStatus = null;
    notifyListeners();
  }
}
