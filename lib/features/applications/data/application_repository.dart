import 'package:sqflite/sqflite.dart';

import '../domain/job_application.dart';
import 'application_database.dart';
import 'job_application_mapper.dart';

abstract interface class ApplicationRepository {
  Future<List<JobApplication>> getAll();
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
  Future<void> add(JobApplication application) async {
    final database = await _applicationDatabase.database;
    await database.insert(
      ApplicationDatabase.applicationsTable,
      application.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(JobApplication current, JobApplication updated) async {
    final database = await _applicationDatabase.database;
    await database.update(
      ApplicationDatabase.applicationsTable,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [current.id],
    );
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

  @override
  Future<List<JobApplication>> getAll() async => List.unmodifiable(_items);

  @override
  Future<void> add(JobApplication application) async {
    _items.insert(0, application);
  }

  @override
  Future<void> update(JobApplication current, JobApplication updated) async {
    final index = _items.indexWhere((item) => item.id == current.id);
    if (index != -1) _items[index] = updated;
  }

  @override
  Future<void> delete(JobApplication application) async {
    _items.removeWhere((item) => item.id == application.id);
  }
}
