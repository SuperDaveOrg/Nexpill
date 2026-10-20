import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/care_repository.dart';
import 'package:nexpill/data/database.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the real schema against SQLite on the host.
void main() {
  sqfliteFfiInit();

  late Directory dir;
  late NexpillDatabase db;
  late CareRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('nexpill_test');
    db = NexpillDatabase(path: '${dir.path}/nexpill.db', factory: databaseFactoryFfi);
    repo = CareRepository(db: db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  const sam = Patient(id: 'sam', displayName: 'Sam');
  Medication med(String id, MedicationSchedule schedule) => Medication(
        id: id,
        patientId: 'sam',
        name: id,
        defaultDoseText: '1 tablet',
        schedule: schedule,
        reminders: ReminderSettings.defaultsFor(schedule),
      );

  test('every schedule type round-trips', () async {
    await repo.savePatient(sam);
    final taper = TaperSchedule([
      TaperRule(startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 5), intervalMinutes: 480),
      TaperRule(startDate: DateTime(2026, 6, 5), intervalMinutes: 720),
    ]);
    await repo.saveMedication(med('a', const IntervalSchedule(285)));
    await repo.saveMedication(med('b', const FixedTimesSchedule([ClockTime(8, 0), ClockTime(20, 30)])));
    await repo.saveMedication(med('c', const PrnSchedule(360)));
    await repo.saveMedication(med('d', taper));

    final meds = {for (final m in await repo.medications()) m.id: m.schedule};
    expect((meds['a'] as IntervalSchedule).intervalMinutes, 285);
    expect((meds['b'] as FixedTimesSchedule).times, const [ClockTime(8, 0), ClockTime(20, 30)]);
    expect((meds['c'] as PrnSchedule).minimumIntervalMinutes, 360);
    final rules = (meds['d'] as TaperSchedule).rules;
    expect([for (final r in rules) isoDate(r.startDate)], ['2026-06-01', '2026-06-05']);
    expect(rules.first.endDate, DateTime(2026, 6, 5));
    expect(rules.last.endDate, isNull);
  });

  test('reminder settings are stored as set, including the PRN default', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('prn', const PrnSchedule(60)));
    await repo.saveMedication(med('iv', const IntervalSchedule(60)).copyWith(
        reminders: const ReminderSettings(enabled: true, earlyMinutes: 15, alarm: true, overdueRepeatMinutes: 20)));
    final byId = {for (final m in await repo.medications()) m.id: m.reminders};
    expect(byId['prn']!.enabled, isFalse);
    expect(byId['iv']!.earlyMinutes, 15);
    expect(byId['iv']!.alarm, isTrue);
    expect(byId['iv']!.overdueRepeatMinutes, 20);
  });

  test('saving a patient again updates it without losing medications', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const IntervalSchedule(60)));
    await repo.savePatient(sam.copyWith(displayName: 'Samantha'));
    expect((await repo.patients()).single.displayName, 'Samantha');
    expect(await repo.medications(patientId: 'sam'), hasLength(1));
  });

  test('editing a taper replaces its steps', () async {
    await repo.savePatient(sam);
    final m = med('t', TaperSchedule([
      TaperRule(startDate: DateTime(2026, 6, 1), intervalMinutes: 240),
      TaperRule(startDate: DateTime(2026, 6, 3), intervalMinutes: 480),
    ]));
    await repo.saveMedication(m);
    await repo.saveMedication(m.copyWith(schedule: const IntervalSchedule(60)));
    final saved = await repo.medication('t');
    expect(saved!.schedule, isA<IntervalSchedule>());
    final d = await db.database;
    expect(await d.query('taper_rules'), isEmpty);
  });

  test('a course with an end round-trips', () async {
    await repo.savePatient(sam);
    final m = med('a', const IntervalSchedule(480));
    await repo.saveMedication(Medication(
        id: 'day', patientId: 'sam', name: 'day', defaultDoseText: '1',
        schedule: m.schedule, reminders: m.reminders,
        course: EndsAfterDay(DateTime(2026, 6, 14))));
    await repo.saveMedication(Medication(
        id: 'doses', patientId: 'sam', name: 'doses', defaultDoseText: '1',
        schedule: m.schedule, reminders: m.reminders,
        course: const EndsAfterDoses(10)));
    await repo.saveMedication(m);

    expect((await repo.medication('day'))!.course,
        isA<EndsAfterDay>().having((c) => c.lastDay, 'lastDay', DateTime(2026, 6, 14)));
    expect((await repo.medication('doses'))!.course,
        isA<EndsAfterDoses>().having((c) => c.doses, 'doses', 10));
    expect((await repo.medication('a'))!.course, isNull);
  });

  test('a version 1 database upgrades, keeping its medications', () async {
    final path = '${dir.path}/old.db';
    final old = await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 1, onCreate: (d, _) => NexpillDatabase.createVersion1(d)));
    await old.insert('patients', sam.toRow()..remove('is_self'));
    final row = med('a', const IntervalSchedule(480)).toRow()
      ..remove('course_last_day')
      ..remove('course_doses')
      ..remove('purpose');
    await old.insert('medications', row);
    await old.close();

    final upgraded = NexpillDatabase(path: path, factory: databaseFactoryFfi);
    final upgradedRepo = CareRepository(db: upgraded);
    expect((await upgradedRepo.medication('a'))!.course, isNull);
    await upgradedRepo.saveMedication(Medication(
        id: 'b', patientId: 'sam', name: 'b', defaultDoseText: '1',
        schedule: const IntervalSchedule(60),
        reminders: const ReminderSettings(enabled: true),
        course: const EndsAfterDoses(3)));
    expect((await upgradedRepo.medication('b'))!.course, isA<EndsAfterDoses>());
    await upgraded.close();
  });

  test('a version 2 database upgrades, and then stores what a medication is for',
      () async {
    final path = '${dir.path}/v2.db';
    final old = await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 1, onCreate: (d, _) => NexpillDatabase.createVersion1(d)));
    await old.execute('ALTER TABLE medications ADD COLUMN course_last_day TEXT');
    await old.execute('ALTER TABLE medications ADD COLUMN course_doses INTEGER');
    await old.setVersion(2);
    await old.insert('patients', sam.toRow()..remove('is_self'));
    await old.insert('medications',
        med('a', const IntervalSchedule(480)).toRow()..remove('purpose'));
    await old.insert('dose_events', {
      'id': 'd', 'medication_id': 'a', 'given_at': 0,
    });
    await old.close();

    final upgraded = NexpillDatabase(path: path, factory: databaseFactoryFfi);
    final upgradedRepo = CareRepository(db: upgraded);
    expect((await upgradedRepo.medication('a'))!.purpose, isNull);
    expect((await upgradedRepo.doses(medicationId: 'a')).single.skipped, isFalse);
    await upgradedRepo.saveMedication(
        med('a', const IntervalSchedule(480)).copyWith(purpose: 'Blood pressure'));
    expect((await upgradedRepo.medication('a'))!.purpose, 'Blood pressure');
    await upgraded.close();
  });

  test('a version 4 database upgrades, and then has room for one of you',
      () async {
    final path = '${dir.path}/v4.db';
    final v4 = NexpillDatabase(path: path, factory: databaseFactoryFfi);
    final db = await v4.database;
    // Back to version 4's patients table.
    await db.execute('DROP INDEX idx_patients_self');
    await db.execute('ALTER TABLE patients DROP COLUMN is_self');
    await db.insert('patients', sam.toRow()..remove('is_self'));
    await db.setVersion(4);
    await v4.close();

    final upgraded = NexpillDatabase(path: path, factory: databaseFactoryFfi);
    final upgradedRepo = CareRepository(db: upgraded);
    expect((await upgradedRepo.patients()).single.isSelf, isFalse);
    const me = Patient(id: 'me', displayName: '', isSelf: true);
    await upgradedRepo.savePatient(me);
    expect((await upgradedRepo.patients()).map((p) => p.id), ['me', 'sam'],
        reason: 'you come first');
    await expectLater(
        upgradedRepo.savePatient(
            const Patient(id: 'me2', displayName: '', isSelf: true)),
        throwsA(isA<DatabaseException>()),
        reason: 'only one of you');
    await upgraded.close();
  });

  test('doses: log, correct, and read back newest first', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const IntervalSchedule(60)));
    final first = await repo.logDose('a', givenAt: DateTime.utc(2026, 6, 10, 8), givenBy: 'Jo');
    await repo.logDose('a', givenAt: DateTime.utc(2026, 6, 10, 9));
    final fix = await repo.correctDose(first,
        givenAt: DateTime.utc(2026, 6, 10, 7, 45), givenBy: 'Jo');

    expect(fix.supersedesId, first.id);
    expect(fix.givenBy, 'Jo');
    final doses = await repo.doses(medicationId: 'a');
    expect([for (final d in doses) d.givenAt.hour], [9, 8, 7]);
    expect(doses.first.givenAt.isUtc, isTrue);
  });

  test('a skipped dose is stored as skipped, at the time it was due', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const FixedTimesSchedule([ClockTime(8, 0)])));
    await repo.logDose('a', givenAt: DateTime.utc(2026, 6, 9, 8));
    await repo.skipDose('a', DateTime.utc(2026, 6, 10, 8));
    final doses = await repo.doses(medicationId: 'a');
    expect([for (final d in doses) (d.givenAt, d.skipped)], [
      (DateTime.utc(2026, 6, 10, 8), true),
      (DateTime.utc(2026, 6, 9, 8), false),
    ]);
  });

  test('a correction can clear details the original had', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const IntervalSchedule(60)));
    final at = DateTime.utc(2026, 6, 10, 8);
    final first = await repo.logDose('a',
        givenAt: at, doseText: '2 tablets', givenBy: 'Jo', notes: 'With food');
    final fix = await repo.correctDose(first, givenAt: at);

    final saved = await repo.dose(fix.id);
    expect(saved!.doseText, isNull, reason: 'back to the usual dose');
    expect(saved.givenBy, isNull);
    expect(saved.notes, isNull);
  });

  test('deleting a dose takes its corrections with it', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const IntervalSchedule(60)));
    final d = await repo.logDose('a');
    await repo.correctDose(d, givenAt: DateTime.now().subtract(const Duration(minutes: 5)));
    await repo.deleteDose(d.id);
    expect(await repo.doses(), isEmpty);
  });

  test('deleting a patient removes their medications and history', () async {
    await repo.replaceAll(sampleCare(DateTime(2026, 6, 10, 12)));
    await repo.deletePatient('sample-alex');
    final left = await repo.snapshot();
    expect([for (final p in left.patients) p.id], ['sample-jordan']);
    expect(left.medications.every((m) => m.patientId == 'sample-jordan'), isTrue);
    expect(left.doses.every((d) => d.medicationId == 'sample-vitd'), isTrue);
  });

  test('replaceAll then snapshot gives back the same care', () async {
    final sample = sampleCare(DateTime(2026, 6, 10, 12));
    await repo.replaceAll(sample);
    final back = await repo.snapshot();
    expect(back.patients.length, sample.patients.length);
    expect(back.medications.length, sample.medications.length);
    expect({for (final d in back.doses) d.id: d.givenAt},
        {for (final d in sample.doses) d.id: d.givenAt});
  });

  test('replaceAll is all or nothing', () async {
    await repo.savePatient(sam);
    final broken = CareSnapshot(
      patients: const [Patient(id: 'x', displayName: 'X')],
      // A medication for a patient who isn't there fails the foreign key.
      medications: [med('orphan', const IntervalSchedule(60))],
      doses: const [],
    );
    await expectLater(repo.replaceAll(broken), throwsA(anything));
    expect([for (final p in await repo.patients()) p.id], ['sam']);
  });

  test('delete all data', () async {
    await repo.replaceAll(sampleCare(DateTime(2026, 6, 10, 12)));
    await repo.deleteAllData();
    final left = await repo.snapshot();
    expect([left.patients, left.medications, left.doses], everyElement(isEmpty));
  });
}
