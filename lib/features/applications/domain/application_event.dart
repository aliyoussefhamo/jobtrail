enum ApplicationEventType {
  applicationCreated,
  statusChanged,
  interviewScheduled,
  noteAdded,
}

class ApplicationEvent {
  const ApplicationEvent({
    required this.id,
    required this.applicationId,
    required this.type,
    required this.title,
    required this.occurredAt,
  });

  final String id;
  final String applicationId;
  final ApplicationEventType type;
  final String title;
  final DateTime occurredAt;
}
