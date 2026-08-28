import 'package:sqflite/sqflite.dart';

import '../domain/application_event.dart';
import '../domain/job_application.dart';
import 'application_database.dart';
import 'application_event_mapper.dart';
import 'job_application_mapper.dart';

abstract interface class ApplicationRepository {
  Future<List<JobApplication>> getAll();
  Future<List<ApplicationEvent>> getEvents(String applicationId);
  Future<void> add(JobApplication application);
  Future<void> update(JobApplication current, JobApplication updated);
  Future<void> delete(JobApplication application);
}

class SqliteApplicationRepository implements ApplicationRepository {
  SqliteApplicationRepository(this._applicationDatabase);

  final ApplicationDatabase _applicationDatabase;

  @override
  Future<List<JobApplication>> getAll() async {
    final database = await _applicationDatabase.database;
    final rows = await database.query(
      ApplicationDatabase.applicationsTable,
      orderBy: 'rowid DESC',
    );
    return rows.map(jobApplicationFromMap).toList();
  }

  @override
  Future<List<ApplicationEvent>> getEvents(String applicationId) async {
    final database = await _applicationDatabase.database;
    final rows = await database.query(
      ApplicationDatabase.eventsTable,
      where: 'application_id = ?',
      whereArgs: [applicationId],
      orderBy: 'occurred_at DESC',
    );
    return rows.map(applicationEventFromMap).toList();
  }

  @override
  Future<void> add(JobApplication application) async {
    final database = await _applicationDatabase.database;
    await database.transaction((transaction) async {
      await transaction.insert(
        ApplicationDatabase.applicationsTable,
        application.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final event in _eventsForNewApplication(application)) {
        await transaction.insert(
          ApplicationDatabase.eventsTable,
          event.toMap(),
        );
      }
    });
  }

  @override
  Future<void> update(JobApplication current, JobApplication updated) async {
    final database = await _applicationDatabase.database;
    await database.transaction((transaction) async {
      await transaction.update(
        ApplicationDatabase.applicationsTable,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [current.id],
      );
      for (final event in _eventsForChanges(current, updated)) {
        await transaction.insert(
          ApplicationDatabase.eventsTable,
          event.toMap(),
        );
      }
    });
  }

  @override
  Future<void> delete(JobApplication application) async {
    final database = await _applicationDatabase.database;
    await database.delete(
      ApplicationDatabase.applicationsTable,
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }
}

class InMemoryApplicationRepository implements ApplicationRepository {
  final List<JobApplication> _items = [...sampleApplications];
  final Map<String, List<ApplicationEvent>> _events = {};

  InMemoryApplicationRepository() {
    for (final application in _items) {
      _events[application.id] = _eventsForNewApplication(application);
    }
  }

  @override
  Future<List<JobApplication>> getAll() async => List.unmodifiable(_items);

  @override
  Future<List<ApplicationEvent>> getEvents(String applicationId) async {
    final events = [...?_events[applicationId]]
      ..sort((first, second) => second.occurredAt.compareTo(first.occurredAt));
    return events;
  }

  @override
  Future<void> add(JobApplication application) async {
    _items.insert(0, application);
    _events[application.id] = _eventsForNewApplication(application);
  }

  @override
  Future<void> update(JobApplication current, JobApplication updated) async {
    final index = _items.indexWhere((item) => item.id == current.id);
    if (index != -1) _items[index] = updated;
    _events
        .putIfAbsent(updated.id, () => [])
        .addAll(_eventsForChanges(current, updated));
  }

  @override
  Future<void> delete(JobApplication application) async {
    _items.removeWhere((item) => item.id == application.id);
    _events.remove(application.id);
  }
}

List<ApplicationEvent> _eventsForNewApplication(JobApplication application) {
  return [
    ApplicationEvent(
      id: _newEventId(application.id, ApplicationEventType.applicationCreated),
      applicationId: application.id,
      type: ApplicationEventType.applicationCreated,
      title: 'Application submitted',
      occurredAt: application.appliedDate,
    ),
    if (application.interviewDate != null)
      ApplicationEvent(
        id: _newEventId(
          application.id,
          ApplicationEventType.interviewScheduled,
        ),
        applicationId: application.id,
        type: ApplicationEventType.interviewScheduled,
        title: 'Interview scheduled',
        occurredAt: application.interviewDate!,
      ),
    if (application.notes.isNotEmpty)
      ApplicationEvent(
        id: _newEventId(application.id, ApplicationEventType.noteAdded),
        applicationId: application.id,
        type: ApplicationEventType.noteAdded,
        title: 'Notes added',
        occurredAt: DateTime.now(),
      ),
  ];
}

List<ApplicationEvent> _eventsForChanges(
  JobApplication current,
  JobApplication updated,
) {
  final now = DateTime.now();
  return [
    if (current.status != updated.status)
      ApplicationEvent(
        id: _newEventId(updated.id, ApplicationEventType.statusChanged),
        applicationId: updated.id,
        type: ApplicationEventType.statusChanged,
        title:
            'Status changed from ${current.status.label} '
            'to ${updated.status.label}',
        occurredAt: now,
      ),
    if (current.interviewDate != updated.interviewDate)
      ApplicationEvent(
        id: _newEventId(updated.id, ApplicationEventType.interviewScheduled),
        applicationId: updated.id,
        type: ApplicationEventType.interviewScheduled,
        title: updated.interviewDate == null
            ? 'Interview date removed'
            : current.interviewDate == null
            ? 'Interview scheduled'
            : 'Interview rescheduled',
        occurredAt: now,
      ),
    if (current.notes != updated.notes)
      ApplicationEvent(
        id: _newEventId(updated.id, ApplicationEventType.noteAdded),
        applicationId: updated.id,
        type: ApplicationEventType.noteAdded,
        title: updated.notes.isEmpty ? 'Notes removed' : 'Notes updated',
        occurredAt: now,
      ),
  ];
}

String _newEventId(String applicationId, ApplicationEventType type) {
  return '$applicationId-${type.name}-'
      '${DateTime.now().microsecondsSinceEpoch}';
}
