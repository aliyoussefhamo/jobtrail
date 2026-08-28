import '../domain/job_application.dart';

extension JobApplicationMapper on JobApplication {
  Map<String, Object?> toMap() => {
    'id': id,
    'company': company,
    'role': role,
    'location': location,
    'status': status.name,
    'applied_date': appliedDate.millisecondsSinceEpoch,
    'interview_date': interviewDate?.millisecondsSinceEpoch,
    'updated_label': updatedLabel,
    'notes': notes,
  };
}

JobApplication jobApplicationFromMap(Map<String, Object?> map) {
  final interviewDateValue = map['interview_date'] as int?;
  return JobApplication(
    id: map['id'] as String,
    company: map['company'] as String,
    role: map['role'] as String,
    location: map['location'] as String,
    status: ApplicationStatus.values.byName(map['status'] as String),
    appliedDate: DateTime.fromMillisecondsSinceEpoch(
      map['applied_date'] as int,
    ),
    interviewDate: interviewDateValue == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(interviewDateValue),
    updatedLabel: map['updated_label'] as String,
    notes: map['notes'] as String,
  );
}
