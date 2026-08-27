import '../domain/job_application.dart';

extension JobApplicationMapper on JobApplication {
  Map<String, Object?> toMap() => {
    'id': id,
    'company': company,
    'role': role,
    'location': location,
    'status': status.name,
    'updated_label': updatedLabel,
    'notes': notes,
  };
}

JobApplication jobApplicationFromMap(Map<String, Object?> map) {
  return JobApplication(
    id: map['id'] as String,
    company: map['company'] as String,
    role: map['role'] as String,
    location: map['location'] as String,
    status: ApplicationStatus.values.byName(map['status'] as String),
    updatedLabel: map['updated_label'] as String,
    notes: map['notes'] as String,
  );
}
