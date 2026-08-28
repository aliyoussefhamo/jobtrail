import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../domain/application_event.dart';
import '../domain/job_application.dart';
import 'application_event_mapper.dart';
import 'job_application_mapper.dart';

class ApplicationDatabase {
  ApplicationDatabase._({this._factory, this._databasePath});

  ApplicationDatabase.forTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) : this._(factory: factory, databasePath: databasePath);

  static final ApplicationDatabase instance = ApplicationDatabase._();
  static const applicationsTable = 'applications';
  static const eventsTable = 'application_events';

  final DatabaseFactory? _factory;
  final String? _databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath =
        _databasePath ?? path.join(await getDatabasesPath(), 'jobtrail.db');
    _database = await (_factory ?? databaseFactory).openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      ),
    );
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _createDatabase(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $applicationsTable(
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

    await _createEventsTable(database);

    await _insertApplications(database, [
      ...sampleApplications,
      ...demoApplications,
    ]);
    await _seedEventsForExistingApplications(database);
  }

  Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      await database.execute(
        'ALTER TABLE $applicationsTable '
        'ADD COLUMN applied_date INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'ALTER TABLE $applicationsTable ADD COLUMN interview_date INTEGER',
      );

      final migrationDate = DateTime(2026, 8, 28).millisecondsSinceEpoch;
      final interviewDate = DateTime(2026, 9, 1).millisecondsSinceEpoch;
      await database.update(applicationsTable, {
        'applied_date': migrationDate,
      }, where: 'applied_date = 0');
      await database.update(
        applicationsTable,
        {'interview_date': interviewDate},
        where: 'status = ?',
        whereArgs: [ApplicationStatus.interview.name],
      );
    }

    if (oldVersion < 2) {
      await _insertApplications(database, demoApplications);
    }

    if (oldVersion < 4) {
      await _createEventsTable(database);
      await _seedEventsForExistingApplications(database);
    }
  }

  Future<void> _createEventsTable(Database database) async {
    await database.execute('''
      CREATE TABLE $eventsTable(
        id TEXT PRIMARY KEY,
        application_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        occurred_at INTEGER NOT NULL,
        FOREIGN KEY(application_id)
          REFERENCES $applicationsTable(id)
          ON DELETE CASCADE
      )
    ''');
    await database.execute(
      'CREATE INDEX idx_events_application_date '
      'ON $eventsTable(application_id, occurred_at)',
    );
  }

  Future<void> _seedEventsForExistingApplications(Database database) async {
    final rows = await database.query(applicationsTable);
    final batch = database.batch();

    for (final row in rows) {
      final application = jobApplicationFromMap(row);
      final events = <ApplicationEvent>[
        ApplicationEvent(
          id: 'seed-created-${application.id}',
          applicationId: application.id,
          type: ApplicationEventType.applicationCreated,
          title: 'Application submitted',
          occurredAt: application.appliedDate,
        ),
        if (application.interviewDate != null)
          ApplicationEvent(
            id: 'seed-interview-${application.id}',
            applicationId: application.id,
            type: ApplicationEventType.interviewScheduled,
            title: 'Interview scheduled',
            occurredAt: application.interviewDate!,
          ),
        if (application.status != ApplicationStatus.applied)
          ApplicationEvent(
            id: 'seed-status-${application.id}',
            applicationId: application.id,
            type: ApplicationEventType.statusChanged,
            title: 'Status changed to ${application.status.label}',
            occurredAt:
                application.interviewDate ??
                application.appliedDate.add(const Duration(days: 1)),
          ),
      ];

      for (final event in events) {
        batch.insert(
          eventsTable,
          event.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  Future<void> _insertApplications(
    Database database,
    List<JobApplication> applications,
  ) async {
    final batch = database.batch();
    for (final application in applications.reversed) {
      batch.insert(
        applicationsTable,
        application.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }
}

final sampleApplications = [
  JobApplication(
    id: 'nova-labs-flutter-developer',
    company: 'Nova Labs',
    role: 'Flutter Developer',
    location: 'Berlin - Remote',
    status: ApplicationStatus.interview,
    appliedDate: DateTime(2026, 8, 27),
    interviewDate: DateTime(2026, 9, 1),
    updatedLabel: 'Interview tomorrow, 10:00',
  ),
  JobApplication(
    id: 'northstar-mobile-engineer',
    company: 'Northstar GmbH',
    role: 'Mobile Software Engineer',
    location: 'Frankfurt - Hybrid',
    status: ApplicationStatus.applied,
    appliedDate: DateTime(2026, 8, 22),
    updatedLabel: 'Applied 2 days ago',
  ),
  JobApplication(
    id: 'pixel-forge-ios-flutter',
    company: 'Pixel Forge',
    role: 'iOS & Flutter Developer',
    location: 'Hamburg - Remote',
    status: ApplicationStatus.offer,
    appliedDate: DateTime(2026, 8, 15),
    updatedLabel: 'Offer received today',
  ),
  JobApplication(
    id: 'orbit-commerce-junior-flutter',
    company: 'Orbit Commerce',
    role: 'Junior Flutter Engineer',
    location: 'Munich - Onsite',
    status: ApplicationStatus.rejected,
    appliedDate: DateTime(2026, 8, 10),
    updatedLabel: 'Updated yesterday',
  ),
];

final demoApplications = [
  JobApplication(
    id: 'demo-google-flutter-developer',
    company: 'Google',
    role: 'Flutter Developer',
    location: 'Munich - Hybrid',
    status: ApplicationStatus.applied,
    appliedDate: DateTime(2026, 8, 25),
    updatedLabel: 'Applied recently',
    notes: 'Applied through LinkedIn',
  ),
  JobApplication(
    id: 'demo-amazon-mobile-engineer',
    company: 'Amazon',
    role: 'Mobile Engineer',
    location: 'Berlin - Onsite',
    status: ApplicationStatus.interview,
    appliedDate: DateTime(2026, 8, 18),
    interviewDate: DateTime(2026, 9, 3),
    updatedLabel: 'Interview scheduled',
    notes: 'Technical interview next Monday',
  ),
  JobApplication(
    id: 'demo-zalando-ios-developer',
    company: 'Zalando',
    role: 'iOS Developer',
    location: 'Berlin - Hybrid',
    status: ApplicationStatus.rejected,
    appliedDate: DateTime(2026, 8, 12),
    updatedLabel: 'Updated recently',
    notes: 'Rejected after first interview',
  ),
  JobApplication(
    id: 'demo-bmw-flutter-engineer',
    company: 'BMW Group',
    role: 'Flutter Engineer',
    location: 'Munich - Onsite',
    status: ApplicationStatus.offer,
    appliedDate: DateTime(2026, 8, 5),
    updatedLabel: 'Offer received',
    notes: 'Reviewing salary and benefits',
  ),
  JobApplication(
    id: 'demo-delivery-hero-senior-mobile',
    company: 'Delivery Hero',
    role: 'Senior Mobile Developer',
    location: 'Berlin - Remote',
    status: ApplicationStatus.interview,
    appliedDate: DateTime(2026, 8, 21),
    interviewDate: DateTime(2026, 9, 5),
    updatedLabel: 'Interview scheduled',
    notes: 'Prepare architecture questions',
  ),
  JobApplication(
    id: 'demo-sap-software-engineer',
    company: 'SAP',
    role: 'Software Engineer',
    location: 'Walldorf - Hybrid',
    status: ApplicationStatus.applied,
    appliedDate: DateTime(2026, 8, 26),
    updatedLabel: 'Applied recently',
    notes: 'Waiting for recruiter response',
  ),
  JobApplication(
    id: 'demo-adidas-mobile-developer',
    company: 'Adidas',
    role: 'Mobile App Developer',
    location: 'Herzogenaurach - Hybrid',
    status: ApplicationStatus.offer,
    appliedDate: DateTime(2026, 8, 8),
    updatedLabel: 'Offer received',
    notes: 'Offer deadline next Friday',
  ),
  JobApplication(
    id: 'demo-deutsche-bank-junior-flutter',
    company: 'Deutsche Bank',
    role: 'Junior Flutter Developer',
    location: 'Frankfurt - Hybrid',
    status: ApplicationStatus.applied,
    appliedDate: DateTime(2026, 8, 27),
    updatedLabel: 'Applied recently',
    notes: 'Application submitted through website',
  ),
];
