import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// Fictional people and medications for trying the app and for screenshots.
/// Never real data.
///
/// Built relative to [now], so every status and kind of reminder shows up
/// straight away: one dose due within minutes, one overdue, a fixed-time
/// medication, a taper mid-way, an as-needed one, and a correction.
CareSnapshot sampleCare(DateTime now) {
  const alex = Patient(id: 'sample-alex', displayName: 'Alex Rivera');
  const jordan = Patient(id: 'sample-jordan', displayName: 'Jordan Lee');
  final today = dateOnly(now);

  Medication med(
    String id,
    String patientId,
    String name,
    String dose,
    MedicationSchedule schedule, {
    String? strength,
    String? instructions,
    ReminderSettings? reminders,
    double? stock,
  }) =>
      Medication(
        id: id,
        patientId: patientId,
        name: name,
        strengthText: strength,
        instructions: instructions,
        defaultDoseText: dose,
        schedule: schedule,
        reminders: reminders ?? ReminderSettings.defaultsFor(schedule),
        inventoryEnabled: stock != null,
        initialQuantity: stock,
        doseAmount: stock == null ? null : 1,
        doseUnit: stock == null ? null : 'tablets',
        lowSupplyThreshold: stock == null ? null : 6,
      );

  DoseEvent dose(String id, String medicationId, Duration ago,
          {String? supersedes, String? givenBy}) =>
      DoseEvent(
        id: id,
        medicationId: medicationId,
        givenAt: now.subtract(ago).toUtc(),
        supersedesId: supersedes,
        givenBy: givenBy,
      );

  return CareSnapshot(
    patients: const [alex, jordan],
    medications: [
      med('sample-acet', alex.id, 'Acetaminophen', '1 tablet',
          const IntervalSchedule(4 * 60),
          strength: '500 mg',
          instructions: 'Keep ahead of the pain: every 4 hours, day and night.',
          reminders: const ReminderSettings(enabled: true, earlyMinutes: 10, alarm: true),
          stock: 30),
      med('sample-amox', alex.id, 'Amoxicillin', '1 capsule',
          const IntervalSchedule(8 * 60),
          strength: '500 mg', instructions: 'With water, with or without food.'),
      med('sample-drops', alex.id, 'Eye drops', '1 drop each eye',
          const FixedTimesSchedule([ClockTime(8, 0), ClockTime(20, 0)])),
      med('sample-pred', alex.id, 'Prednisone', '10 mg',
          TaperSchedule([
            TaperRule(
                startDate: today.subtract(const Duration(days: 3)),
                endDate: today.add(const Duration(days: 2)),
                intervalMinutes: 8 * 60),
            TaperRule(
                startDate: today.add(const Duration(days: 2)),
                intervalMinutes: 12 * 60),
          ]),
          instructions: 'Follow the taper exactly as prescribed.'),
      med('sample-ibu', alex.id, 'Ibuprofen', '200 mg',
          const PrnSchedule(6 * 60),
          instructions: 'As needed for pain, at least 6 hours apart.'),
      med('sample-vitd', jordan.id, 'Vitamin D', '1 capsule',
          const FixedTimesSchedule([ClockTime(9, 0)])),
    ],
    doses: [
      // Due in about eight minutes.
      dose('sample-d1', 'sample-acet', const Duration(hours: 3, minutes: 52),
          givenBy: 'Sam'),
      // Logged at the wrong time, then corrected.
      dose('sample-d2', 'sample-amox', const Duration(hours: 8, minutes: 5)),
      dose('sample-d3', 'sample-amox', const Duration(hours: 8, minutes: 40),
          supersedes: 'sample-d2'),
      dose('sample-d4', 'sample-pred', const Duration(hours: 5)),
      dose('sample-d5', 'sample-ibu', const Duration(hours: 2)),
    ],
  );
}
