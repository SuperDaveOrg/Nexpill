import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/notification_service.dart';

void main() {
  Medication med(String id, MedicationSchedule schedule) => Medication(
        id: id,
        patientId: 'sam',
        name: id,
        defaultDoseText: '1 tablet',
        schedule: schedule,
        reminders: const ReminderSettings(enabled: true),
      );
  final drops = med('drops', const FixedTimesSchedule([ClockTime(8, 0), ClockTime(20, 0)]));
  final amox = med('amox', const IntervalSchedule(480));
  final ibu = med('ibu', const PrnSchedule(360));
  final lastNight = DateTime(2026, 6, 9, 20);
  CareSnapshot care(List<DoseEvent> doses) => CareSnapshot(
      patients: const [Patient(id: 'sam', displayName: 'Sam')],
      medications: [drops, amox, ibu],
      doses: [
        for (final m in [drops, amox, ibu])
          DoseEvent(id: 'g-${m.id}', medicationId: m.id, givenAt: lastNight),
        ...doses,
      ]);
  final tag = ReminderTag(DateTime(2026, 6, 10, 8), const ['drops', 'amox', 'ibu']);
  final now = DateTime(2026, 6, 10, 8, 30);

  group('Skip on a reminder', () {
    test('skips the dose each scheduled medication is due, not as-needed ones', () {
      final skips = tag.dosesToSkip(care([]), now);
      expect(skips.keys, unorderedEquals(['drops', 'amox']));
      expect(skips['drops'], DateTime(2026, 6, 10, 8));
      expect(skips['amox']!.isAtSameMomentAs(DateTime(2026, 6, 10, 4)), isTrue);
    });

    test('leaves alone a dose given since', () {
      final given = DoseEvent(id: 'x', medicationId: 'drops', givenAt: DateTime(2026, 6, 10, 8, 10));
      expect(tag.dosesToSkip(care([given]), now).keys, ['amox']);
    });

    test('once skipped, the reminder is no longer due', () {
      final skip = DoseEvent(
          id: 's', medicationId: 'drops', givenAt: DateTime(2026, 6, 10, 8), skipped: true);
      expect(ReminderTag(tag.at, const ['drops']).stillDue(care([skip])), isFalse);
      expect(ReminderTag(tag.at, const ['drops']).stillDue(care([])), isTrue);
    });
  });
}
