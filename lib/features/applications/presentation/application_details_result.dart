import '../domain/job_application.dart';

sealed class ApplicationDetailsResult {
  const ApplicationDetailsResult();
}

final class ApplicationUpdated extends ApplicationDetailsResult {
  const ApplicationUpdated(this.application);

  final JobApplication application;
}

final class ApplicationDeleted extends ApplicationDetailsResult {
  const ApplicationDeleted();
}
