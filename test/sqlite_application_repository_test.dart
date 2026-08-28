import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jobtrail/features/applications/data/application_database.dart';
import 'package:jobtrail/features/applications/data/application_repository.dart';
import 'package:jobtrail/features/applications/domain/application_event.dart';
import 'package:jobtrail/features/applications/domain/job_application.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late ApplicationDatabase applicationDatabase;
  late SqliteApplicationRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'jobtrail_database_test_',
    );
    databasePath = path.join(temporaryDirectory.path, 'jobtrail_test.db');
    applicationDatabase = ApplicationDatabase.forTesting(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    repository = SqliteApplicationRepository(applicationDatabase);
  });

  tearDown(() async {
    await applicationDatabase.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('SQLite repository persists CRUD and cascades event deletion', () async {
    final application = JobApplication(
      id: 'integration-test-application',
      company: 'Test Company',
      role: 'Flutter Engineer',
      location: 'Berlin - Remote',
      status: ApplicationStatus.interview,
      appliedDate: DateTime(2026, 8, 28),
      interviewDate: DateTime(2026, 9, 10),
      updatedLabel: 'Added in integration test',
      notes: 'Prepare architecture questions',
    );

    await repository.add(application);

    final stored = (await repository.getAll()).singleWhere(
      (item) => item.id == application.id,
    );
    expect(stored.company, application.company);
    expect(stored.interviewDate, application.interviewDate);
    expect(await repository.getEvents(application.id), hasLength(3));

    final updated = JobApplication(
      id: stored.id,
      company: stored.company,
      role: stored.role,
      location: stored.location,
      status: ApplicationStatus.offer,
      appliedDate: stored.appliedDate,
      interviewDate: stored.interviewDate,
      updatedLabel: 'Offer received',
      notes: stored.notes,
    );
    await repository.update(stored, updated);

    final events = await repository.getEvents(application.id);
    expect(
      events.where((event) => event.type == ApplicationEventType.statusChanged),
      hasLength(1),
    );

    await repository.delete(updated);

    expect(
      (await repository.getAll()).where((item) => item.id == application.id),
      isEmpty,
    );
    expect(await repository.getEvents(application.id), isEmpty);
  });

  test('version 3 database migrates to version 4 with seeded events', () async {
    final legacyDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE ${ApplicationDatabase.applicationsTable}(
              id TEXT PRIMARY KEY,
              company TEXT NOT NULL,
              role TEXT NOT NULL,
              location TEXT NOT NULL,
              status TEXT NOT NULL,
              applied_date INTEGER NOT NULL,
              interview_date INTEGER,
              updated_label TEXT NOT NULL,
              notes TEXT NOT NULL
            )
          ''');
          await database.insert(ApplicationDatabase.applicationsTable, {
            'id': 'legacy-application',
            'company': 'Legacy Company',
            'role': 'Mobile Engineer',
            'location': 'Remote',
            'status': ApplicationStatus.interview.name,
            'applied_date': DateTime(2026, 8, 1).millisecondsSinceEpoch,
            'interview_date': DateTime(2026, 9, 1).millisecondsSinceEpoch,
            'updated_label': 'Interview scheduled',
            'notes': '',
          });
        },
      ),
    );
    await legacyDatabase.close();

    final database = await applicationDatabase.database;
    final version = await database.getVersion();
    final events = await repository.getEvents('legacy-application');

    expect(version, 4);
    expect(events, isNotEmpty);
    expect(
      events.map((event) => event.type),
      contains(ApplicationEventType.applicationCreated),
    );
  });
}
