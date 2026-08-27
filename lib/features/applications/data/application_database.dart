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
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
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

    await _insertApplications(database, [
      ...sampleApplications,
      ...demoApplications,
    ]);
  }

  Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _insertApplications(database, demoApplications);
    }
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

const demoApplications = [
  JobApplication(
    id: 'demo-google-flutter-developer',
    company: 'Google',
    role: 'Flutter Developer',
    location: 'Munich - Hybrid',
    status: ApplicationStatus.applied,
    updatedLabel: 'Applied recently',
    notes: 'Applied through LinkedIn',
  ),
  JobApplication(
    id: 'demo-amazon-mobile-engineer',
    company: 'Amazon',
    role: 'Mobile Engineer',
    location: 'Berlin - Onsite',
    status: ApplicationStatus.interview,
    updatedLabel: 'Interview scheduled',
    notes: 'Technical interview next Monday',
  ),
  JobApplication(
    id: 'demo-zalando-ios-developer',
    company: 'Zalando',
    role: 'iOS Developer',
    location: 'Berlin - Hybrid',
    status: ApplicationStatus.rejected,
    updatedLabel: 'Updated recently',
    notes: 'Rejected after first interview',
  ),
  JobApplication(
    id: 'demo-bmw-flutter-engineer',
    company: 'BMW Group',
    role: 'Flutter Engineer',
    location: 'Munich - Onsite',
    status: ApplicationStatus.offer,
    updatedLabel: 'Offer received',
    notes: 'Reviewing salary and benefits',
  ),
  JobApplication(
    id: 'demo-delivery-hero-senior-mobile',
    company: 'Delivery Hero',
    role: 'Senior Mobile Developer',
    location: 'Berlin - Remote',
    status: ApplicationStatus.interview,
    updatedLabel: 'Interview scheduled',
    notes: 'Prepare architecture questions',
  ),
  JobApplication(
    id: 'demo-sap-software-engineer',
    company: 'SAP',
    role: 'Software Engineer',
    location: 'Walldorf - Hybrid',
    status: ApplicationStatus.applied,
    updatedLabel: 'Applied recently',
    notes: 'Waiting for recruiter response',
  ),
  JobApplication(
    id: 'demo-adidas-mobile-developer',
    company: 'Adidas',
    role: 'Mobile App Developer',
    location: 'Herzogenaurach - Hybrid',
    status: ApplicationStatus.offer,
    updatedLabel: 'Offer received',
    notes: 'Offer deadline next Friday',
  ),
  JobApplication(
    id: 'demo-deutsche-bank-junior-flutter',
    company: 'Deutsche Bank',
    role: 'Junior Flutter Developer',
    location: 'Frankfurt - Hybrid',
    status: ApplicationStatus.applied,
    updatedLabel: 'Applied recently',
    notes: 'Application submitted through website',
  ),
];
