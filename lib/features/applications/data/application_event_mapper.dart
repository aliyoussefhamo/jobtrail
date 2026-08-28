import '../domain/application_event.dart';

extension ApplicationEventMapper on ApplicationEvent {
  Map<String, Object?> toMap() => {
    'id': id,
    'application_id': applicationId,
    'type': type.name,
    'title': title,
    'occurred_at': occurredAt.millisecondsSinceEpoch,
  };
}

ApplicationEvent applicationEventFromMap(Map<String, Object?> map) {
  return ApplicationEvent(
    id: map['id'] as String,
    applicationId: map['application_id'] as String,
    type: ApplicationEventType.values.byName(map['type'] as String),
    title: map['title'] as String,
    occurredAt: DateTime.fromMillisecondsSinceEpoch(map['occurred_at'] as int),
  );
}
