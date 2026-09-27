import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

void main() {
  const eightHourly = Medication(
    id: 'med-1',
    patientId: 'patient-1',
    name: 'Amoxicillin',
    defaultDoseText: '500 mg',
    schedule: IntervalSchedule(480),
      reminders: ReminderSettings(enabled: true),
  );
  final doses = [
    DoseEvent(
        id: 'dose-1',
        medicationId: 'med-1',
        givenAt: DateTime.parse('2026-03-28T06:00:00Z')),
  ];

  MedicationStatusLabel labelAt(String now) =>
      computeMedicationStatus(eightHourly, doses, DateTime.parse(now)).label;

  test('never taken until a dose is logged', () {
    expect(
      computeMedicationStatus(eightHourly, [], DateTime.parse('2026-03-28T06:00:00Z')).label,
      MedicationStatusLabel.neverTaken,
    );
  });

  test('too early, then due soon within 20 minutes', () {
    expect(labelAt('2026-03-28T13:39:00Z'), MedicationStatusLabel.tooEarly);
    expect(labelAt('2026-03-28T13:40:00Z'), MedicationStatusLabel.dueSoon);
  });

  test('eligible at the due instant, then overdue', () {
    expect(labelAt('2026-03-28T14:00:00Z'), MedicationStatusLabel.eligibleNow);
    expect(labelAt('2026-03-28T14:10:00Z'), MedicationStatusLabel.overdue);
  });

  test('missed once 1.5 intervals have passed since the last dose', () {
    expect(labelAt('2026-03-28T17:59:00Z'), MedicationStatusLabel.overdue);
    expect(labelAt('2026-03-28T18:00:00Z'), MedicationStatusLabel.missed);
    expect(labelAt('2026-03-28T18:01:00Z'), MedicationStatusLabel.missed);
  });

  test('as-needed medication is available, never overdue or missed', () {
    const prn = Medication(
      id: 'med-1',
      patientId: 'patient-1',
      name: 'Pain relief',
      defaultDoseText: '1 tablet',
      schedule: PrnSchedule(240),
      reminders: ReminderSettings(enabled: true),
    );
    final status = computeMedicationStatus(
        prn, doses, DateTime.parse('2026-03-29T06:00:00Z'));
    expect(status.label, MedicationStatusLabel.availablePrn);
  });

  test('a taper is missed by the interval of the step in force', () {
    final taper = Medication(
      id: 'med-1',
      patientId: 'patient-1',
      name: 'Prednisone',
      defaultDoseText: '10 mg',
      schedule: TaperSchedule([
        TaperRule(startDate: DateTime(2026, 3, 1), intervalMinutes: 480),
      ]),
      reminders: const ReminderSettings(enabled: true),
    );
    // Due 14:00 UTC; half of 8 hours later it's missed.
    MedicationStatusLabel at(String now) =>
        computeMedicationStatus(taper, doses, DateTime.parse(now)).label;
    expect(at('2026-03-28T17:59:00Z'), MedicationStatusLabel.overdue);
    expect(at('2026-03-28T18:00:00Z'), MedicationStatusLabel.missed);
  });
}
