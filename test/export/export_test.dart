import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/data/sample_data.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/export/dose_history_csv.dart';
import 'package:nexpill/export/file_names.dart';
import 'package:nexpill/export/patient_summary.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

void main() {
  final now = DateTime(2026, 6, 10, 12);
  final sample = sampleCare(now);

  group('dose history CSV', () {
    test('has a header and one row per entry, newest first', () {
      final lines = doseHistoryCsv(sample).split('\r\n')..removeLast();
      expect(lines.first, startsWith('Given at,Given at (UTC),Patient,Medication'));
      expect(lines.length, sample.doses.length + 1);
      expect(lines[1], contains('Ibuprofen'), reason: 'given 2 hours ago');
    });

    test('marks corrections and what they replaced', () {
      final csv = doseHistoryCsv(sample);
      expect(csv, contains('Replaced by a correction'));
      expect(csv, contains(',Correction,sample-d2,sample-d3'));
    });

    test('marks skipped doses, with no dose given', () {
      final csv = doseHistoryCsv(sample);
      expect(csv, contains(',Vitamin D,,,,Skipped,,sample-d6'));
    });

    test('one patient only', () {
      final csv = doseHistoryCsv(sample, patientId: 'sample-alex');
      expect(csv, isNot(contains('Vitamin D')));
      expect(csv, contains('Ibuprofen'));
    });

    test('quotes fields with commas, quotes or line breaks', () {
      final care = CareSnapshot(
        patients: const [Patient(id: 'p', displayName: 'Lee, "Sam"')],
        medications: const [
          Medication(
              id: 'm',
              patientId: 'p',
              name: 'Drops',
              defaultDoseText: '1',
              schedule: IntervalSchedule(60),
              reminders: ReminderSettings(enabled: true)),
        ],
        doses: [
          DoseEvent(id: 'd', medicationId: 'm', givenAt: DateTime.utc(2026), notes: 'line\nbreak'),
        ],
      );
      final row = doseHistoryCsv(care).split('\r\n')[1];
      expect(row, contains('"Lee, ""Sam"""'));
      expect(row, contains('"line\nbreak"'));
    });
  });

  test('you, without a name: "You" in the CSV, no name on the summary', () {
    final care = CareSnapshot(
      patients: const [Patient(id: 'me', displayName: '', isSelf: true)],
      medications: const [
        Medication(
            id: 'm',
            patientId: 'me',
            name: 'Drops',
            defaultDoseText: '1',
            schedule: IntervalSchedule(60),
            reminders: ReminderSettings(enabled: true)),
      ],
      doses: [DoseEvent(id: 'd', medicationId: 'm', givenAt: DateTime.utc(2026))],
    );
    expect(doseHistoryCsv(care).split('\r\n')[1], contains(',You,Drops,'));
    expect(patientSummary(care, care.patients.single, now: now),
        startsWith('Medication summary\n'));
    expect(patientSummaryFileName(care.patients.single, DateTime(2026, 6, 10)),
        'nexpill-summary-2026-06-10.txt');
  });

  group('patient summary', () {
    final alex = sample.patient('sample-alex')!;
    final text = patientSummary(sample, alex, now: now);

    test('lists active medications with schedule and status', () {
      expect(text, startsWith('Medication summary for Alex Rivera\n'));
      expect(text, contains('Not medical advice'));
      expect(text, contains('1. Acetaminophen (500 mg)\n   For: Pain after surgery\n'));
      expect(text, contains('   Schedule: Every 4 hours'));
      expect(text.replaceAll('\u202f', ' '), contains('   Schedule: At 8:00 AM and 8:00 PM'));
      expect(text, contains('   Schedule: As needed, at least 6 hours apart'));
      expect(text, contains('   Remaining: 29 tablets'));
      expect(text, contains('   Reminders: On, 10 minutes early, as an alarm'));
    });

    test('a medication never given says so, without a status', () {
      expect(text, contains('Eye drops'));
      final drops = text.substring(text.indexOf('Eye drops'));
      expect(drops.split('\n\n').first, contains('Last given: Not yet'));
      expect(drops.split('\n\n').first, isNot(contains('Status:')));
      expect(drops.split('\n\n').first, isNot(contains('For:')));
    });
  });

  group('wording', () {
    test('durations', () {
      expect(durationText(1), '1 minute');
      expect(durationText(60), '1 hour');
      expect(durationText(285), '4 hours 45 minutes');
      expect(durationText(1440), '24 hours');
    });

    test('lists', () {
      expect(listText(['a']), 'a');
      expect(listText(['a', 'b', 'c']), 'a, b and c');
    });
  });

  test('file names', () {
    const alex = Patient(id: 'a', displayName: ' Dr. Alex  Rivera ');
    expect(patientSummaryFileName(alex, now), 'nexpill-dr-alex-rivera-summary-2026-06-10.txt');
    expect(doseHistoryFileName(alex, now), 'nexpill-dr-alex-rivera-doses-2026-06-10.csv');
    expect(doseHistoryFileName(const Patient(id: 'j', displayName: 'José'), now),
        'nexpill-jos-doses-2026-06-10.csv');
    expect(patientSummaryFileName(const Patient(id: 'z', displayName: '李'), now),
        'nexpill-summary-2026-06-10.txt', reason: 'no stray hyphens');
  });
}
