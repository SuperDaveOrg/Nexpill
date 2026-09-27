import 'package:sqflite/sqflite.dart';

export 'package:nexpill/models/care_snapshot.dart';

import 'package:nexpill/data/database.dart';
import 'package:nexpill/data/ids.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// Reads and writes patients, their medications, and dose history.
class CareRepository {
  CareRepository({NexpillDatabase? db}) : _db = db ?? NexpillDatabase.instance;

  final NexpillDatabase _db;

  // --- Patients ------------------------------------------------------------

  Future<List<Patient>> patients() async {
    final db = await _db.database;
    final rows =
        await db.query('patients', orderBy: 'display_name COLLATE NOCASE');
    return rows.map(Patient.fromRow).toList();
  }

  /// Adds [patient], or updates it if its id exists. Never replaces the row,
  /// which would cascade away its medications.
  Future<void> savePatient(Patient patient) async {
    final db = await _db.database;
    await db.transaction((txn) => _upsert(txn, 'patients', patient.toRow()));
  }

  /// Removes [id] and, with it, their medications and dose history.
  Future<void> deletePatient(String id) async {
    final db = await _db.database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // --- Medications ---------------------------------------------------------

  /// Medications, optionally one patient's, in name order.
  Future<List<Medication>> medications({String? patientId}) async {
    final db = await _db.database;
    return _medications(db, patientId: patientId);
  }

  Future<Medication?> medication(String id) async {
    final db = await _db.database;
    final found = await _medications(db, id: id);
    return found.firstOrNull;
  }

  Future<List<Medication>> _medications(DatabaseExecutor db,
      {String? patientId, String? id}) async {
    final rows = await db.query(
      'medications',
      where: id != null
          ? 'id = ?'
          : patientId != null
              ? 'patient_id = ?'
              : null,
      whereArgs: [?id ?? patientId],
      orderBy: 'name COLLATE NOCASE',
    );
    final tapering = [
      for (final r in rows)
        if (r['schedule_type'] == TaperSchedule.name) r['id'] as String,
    ];
    final rules = <String, List<TaperRule>>{};
    if (tapering.isNotEmpty) {
      final ruleRows = await db.query(
        'taper_rules',
        where: 'medication_id IN (${List.filled(tapering.length, '?').join(',')})',
        whereArgs: tapering,
        orderBy: 'medication_id, position',
      );
      for (final r in ruleRows) {
        rules
            .putIfAbsent(r['medication_id'] as String, () => [])
            .add(TaperRule.fromRow(r));
      }
    }
    return [
      for (final r in rows)
        Medication.fromRow(r, taperRules: rules[r['id']] ?? const []),
    ];
  }

  /// Adds or updates [medication], with its taper steps, in one transaction.
  Future<void> saveMedication(Medication medication) async {
    final db = await _db.database;
    await db.transaction((txn) => _saveMedication(txn, medication));
  }

  static Future<void> _saveMedication(
      DatabaseExecutor txn, Medication medication) async {
    await _upsert(txn, 'medications', medication.toRow());
    await txn.delete('taper_rules',
        where: 'medication_id = ?', whereArgs: [medication.id]);
    if (medication.schedule case TaperSchedule(:final rules)) {
      for (final (i, rule) in rules.indexed) {
        await txn.insert('taper_rules', rule.toRow(medication.id, i));
      }
    }
  }

  Future<void> setMedicationActive(String id, bool active) async {
    final db = await _db.database;
    await db.update('medications', {'active': active ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Removes [id] and its dose history. To stop a medication but keep its
  /// history, deactivate it instead.
  Future<void> deleteMedication(String id) async {
    final db = await _db.database;
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // --- Doses ---------------------------------------------------------------

  /// Dose history, newest first: one medication's, one patient's, or all.
  Future<List<DoseEvent>> doses({String? medicationId, String? patientId}) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT d.* FROM dose_events d
      JOIN medications m ON m.id = d.medication_id
      ${medicationId != null ? 'WHERE d.medication_id = ?' : patientId != null ? 'WHERE m.patient_id = ?' : ''}
      ORDER BY d.given_at DESC, d.id DESC
    ''', [?medicationId ?? patientId]);
    return rows.map(DoseEvent.fromRow).toList();
  }

  Future<DoseEvent?> dose(String id) async {
    final db = await _db.database;
    final rows =
        await db.query('dose_events', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : DoseEvent.fromRow(rows.first);
  }

  /// Logs a dose of [medicationId] given at [givenAt] (now if null), and
  /// returns it.
  Future<DoseEvent> logDose(
    String medicationId, {
    DateTime? givenAt,
    String? doseText,
    String? givenBy,
    String? notes,
  }) async {
    final dose = DoseEvent(
      id: newId(),
      medicationId: medicationId,
      givenAt: (givenAt ?? DateTime.now()).toUtc(),
      doseText: doseText,
      givenBy: givenBy,
      notes: notes,
    );
    final db = await _db.database;
    await db.insert('dose_events', dose.toRow());
    return dose;
  }

  /// Replaces [original] with a corrected entry, leaving the original in
  /// history. Details not given are carried over.
  Future<DoseEvent> correctDose(
    DoseEvent original, {
    DateTime? givenAt,
    String? doseText,
    String? givenBy,
    String? notes,
  }) async {
    final correction = DoseEvent(
      id: newId(),
      medicationId: original.medicationId,
      givenAt: (givenAt ?? original.givenAt).toUtc(),
      doseText: doseText ?? original.doseText,
      givenBy: givenBy ?? original.givenBy,
      notes: notes ?? original.notes,
      supersedesId: original.id,
    );
    final db = await _db.database;
    await db.insert('dose_events', correction.toRow());
    return correction;
  }

  /// Removes a dose logged by mistake, with any corrections of it.
  Future<void> deleteDose(String id) async {
    final db = await _db.database;
    await db.delete('dose_events', where: 'id = ?', whereArgs: [id]);
  }

  // --- Everything ----------------------------------------------------------

  Future<CareSnapshot> snapshot() async {
    final db = await _db.database;
    final patients =
        (await db.query('patients', orderBy: 'display_name COLLATE NOCASE'))
            .map(Patient.fromRow)
            .toList();
    return CareSnapshot(
      patients: patients,
      medications: await _medications(db),
      doses: (await db.query('dose_events', orderBy: 'given_at DESC, id DESC'))
          .map(DoseEvent.fromRow)
          .toList(),
    );
  }

  /// Replaces everything with [snapshot], in one transaction: if any row
  /// fails, the database is left exactly as it was.
  Future<void> replaceAll(CareSnapshot snapshot) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await NexpillDatabase.resetAll(txn);
      for (final p in snapshot.patients) {
        await txn.insert('patients', p.toRow());
      }
      for (final m in snapshot.medications) {
        await _saveMedication(txn, m);
      }
      for (final d in _referencedFirst(snapshot.doses)) {
        await txn.insert('dose_events', d.toRow());
      }
    });
  }

  /// Orders [doses] so that every correction comes after what it corrects,
  /// including corrections of corrections.
  static List<DoseEvent> _referencedFirst(List<DoseEvent> doses) {
    final byId = {for (final d in doses) d.id: d};
    final done = <String>{};
    final ordered = <DoseEvent>[];
    void add(DoseEvent d) {
      if (!done.add(d.id)) return;
      final target = byId[d.supersedesId];
      if (target != null) add(target);
      ordered.add(d);
    }

    doses.forEach(add);
    return ordered;
  }

  Future<void> deleteAllData() => _db.deleteAllData();

  static Future<void> _upsert(
      DatabaseExecutor txn, String table, Map<String, Object?> row) async {
    final updated = await txn
        .update(table, row, where: 'id = ?', whereArgs: [row['id']]);
    if (updated == 0) await txn.insert(table, row);
  }
}
