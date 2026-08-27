import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../domain/job_application.dart';
import 'job_application_mapper.dart';

class ApplicationDatabase {
  ApplicationDatabase._();

  static final ApplicationDatabase instance = ApplicationDatabase._();
  static const applicationsTable = 'applications';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, 'jobtrail.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _createDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $applicationsTable(
        id TEXT PRIMARY KEY,
        company TEXT NOT NULL,
        role TEXT NOT NULL,
        location TEXT NOT NULL,
        status TEXT NOT NULL,
        updated_label TEXT NOT NULL,
        notes TEXT NOT NULL
      )
    ''');

    final batch = database.batch();
    for (final application in sampleApplications.reversed) {
      batch.insert(applicationsTable, application.toMap());
    }
    await batch.commit(noResult: true);
  }
}

const sampleApplications = [
  JobApplication(
    id: 'nova-labs-flutter-developer',
    company: 'Nova Labs',
    role: 'Flutter Developer',
    location: 'Berlin - Remote',
    status: ApplicationStatus.interview,
    updatedLabel: 'Interview tomorrow, 10:00',
  ),
  JobApplication(
    id: 'northstar-mobile-engineer',
    company: 'Northstar GmbH',
    role: 'Mobile Software Engineer',
    location: 'Frankfurt - Hybrid',
    status: ApplicationStatus.applied,
    updatedLabel: 'Applied 2 days ago',
  ),
  JobApplication(
    id: 'pixel-forge-ios-flutter',
    company: 'Pixel Forge',
    role: 'iOS & Flutter Developer',
    location: 'Hamburg - Remote',
    status: ApplicationStatus.offer,
    updatedLabel: 'Offer received today',
  ),
  JobApplication(
    id: 'orbit-commerce-junior-flutter',
    company: 'Orbit Commerce',
    role: 'Junior Flutter Engineer',
    location: 'Munich - Onsite',
    status: ApplicationStatus.rejected,
    updatedLabel: 'Updated yesterday',
  ),
];
