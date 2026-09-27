import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The on-device SQLite database.
///
/// This file is the whole of Nexpill's storage. There is no server, no
/// account and no sync — see docs/privacy.md for why that is a design
/// commitment rather than an unfinished feature.
class NexpillDatabase {
  /// [path] and [factory] exist for tests, which run against SQLite on the
  /// host; the app always uses [instance].
  NexpillDatabase({this._path, this._factory});

  static final NexpillDatabase instance = NexpillDatabase();

  static const _fileName = 'nexpill.db';
  static const version = 1;

  final String? _path;
  final DatabaseFactory? _factory;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final factory = _factory ?? databaseFactory;
    final path = _path ?? p.join(await factory.getDatabasesPath(), _fileName);
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
  }

  /// A fresh install builds the version-1 schema and then replays every
  /// migration, so new and upgraded phones cannot drift apart. Never edit
  /// this once shipped; add a version to [_upgrade].
  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id                    TEXT PRIMARY KEY,
        display_name          TEXT NOT NULL,
        notes                 TEXT,
        notifications_enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');
    // One row per medication. The schedule is spread over columns by type:
    // interval_minutes for interval and as-needed (the minimum gap),
    // times_of_day ("08:00,20:00") for fixed times, and taper_rules for
    // tapers.
    await db.execute('''
      CREATE TABLE medications (
        id                     TEXT PRIMARY KEY,
        patient_id             TEXT NOT NULL
                               REFERENCES patients(id) ON DELETE CASCADE,
        name                   TEXT NOT NULL,
        strength_text          TEXT,
        instructions           TEXT,
        active                 INTEGER NOT NULL DEFAULT 1,
        default_dose_text      TEXT NOT NULL,
        schedule_type          TEXT NOT NULL,
        interval_minutes       INTEGER,
        times_of_day           TEXT,
        reminders_enabled      INTEGER NOT NULL,
        early_reminder_minutes INTEGER NOT NULL DEFAULT 0,
        overdue_repeat_minutes INTEGER NOT NULL DEFAULT 30,
        alarm_enabled          INTEGER NOT NULL DEFAULT 0,
        inventory_enabled      INTEGER NOT NULL DEFAULT 0,
        initial_quantity       REAL,
        dose_amount            REAL,
        dose_unit              TEXT,
        low_supply_threshold   REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE taper_rules (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id    TEXT NOT NULL
                         REFERENCES medications(id) ON DELETE CASCADE,
        position         INTEGER NOT NULL,
        start_date       TEXT NOT NULL,
        end_date         TEXT,
        interval_minutes INTEGER NOT NULL
      )
    ''');
    // given_at is UTC milliseconds. A correction names the dose it replaces;
    // deleting a dose takes its corrections with it.
    await db.execute('''
      CREATE TABLE dose_events (
        id            TEXT PRIMARY KEY,
        medication_id TEXT NOT NULL
                      REFERENCES medications(id) ON DELETE CASCADE,
        given_at      INTEGER NOT NULL,
        dose_text     TEXT,
        given_by      TEXT,
        notes         TEXT,
        supersedes_id TEXT REFERENCES dose_events(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_medications_patient ON medications(patient_id)');
    await db.execute(
        'CREATE INDEX idx_taper_rules_medication ON taper_rules(medication_id, position)');
    await db.execute(
        'CREATE INDEX idx_doses_medication ON dose_events(medication_id, given_at)');
    await db.execute(
        'CREATE INDEX idx_doses_supersedes ON dose_events(supersedes_id)');
    await _upgrade(db, 1, version);
  }

  /// Each step brings a database from the previous version to the next, so a
  /// phone that skipped several releases replays them in order.
  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {}

  /// Empties every table. Used by "delete everything" and by restore, which
  /// rebuilds from a backup inside the same transaction.
  static Future<void> resetAll(DatabaseExecutor txn) async {
    // Children first; cascades would do it, but this doesn't rely on them.
    await txn.delete('dose_events');
    await txn.delete('taper_rules');
    await txn.delete('medications');
    await txn.delete('patients');
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction(resetAll);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
