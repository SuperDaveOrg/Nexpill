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

  test('doses: log, correct, and read back newest first', () async {
    await repo.savePatient(sam);
    await repo.saveMedication(med('a', const IntervalSchedule(60)));
    final first = await repo.logDose('a', givenAt: DateTime.utc(2026, 6, 10, 8), givenBy: 'Jo');
    await repo.logDose('a', givenAt: DateTime.utc(2026, 6, 10, 9));
    final fix = await repo.correctDose(first, givenAt: DateTime.utc(2026, 6, 10, 7, 45));

    expect(fix.supersedesId, first.id);
    expect(fix.givenBy, 'Jo', reason: 'details carry over');
    final doses = await repo.doses(medicationId: 'a');
    expect([for (final d in doses) d.givenAt.hour], [9, 8, 7]);
    expect(doses.first.givenAt.isUtc, isTrue);
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
    expect(left.doses, isEmpty);
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
