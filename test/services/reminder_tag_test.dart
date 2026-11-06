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

  group('Snooze on a reminder', () {
    final until = DateTime.utc(2026, 6, 10, 12, 30);

    test('the tag carries its length and end through the notification', () {
      final back = ReminderTag.tryParse(
          ReminderTag(tag.at, const ['drops'], snoozeMinutes: 30, until: until)
              .encode())!;
      expect(back.snoozeMinutes, 30);
      expect(back.until, until);
    });

    test('a tag from before this setting snoozes for the 5 minutes it says', () {
      final back = ReminderTag.tryParse('{"at":0,"m":["drops"]}')!;
      expect(back.snoozeMinutes, 5);
      expect(back.until, isNull);
    });

    test('ends are per medication, and the later of two wins', () {
      final later = until.add(const Duration(minutes: 10));
      final ends = snoozeEnds([
        ReminderTag(tag.at, const ['drops', 'amox'], until: until),
        ReminderTag(tag.at, const ['amox'], until: later),
      ], care([]));
      expect(ends, {'drops': until, 'amox': later});
    });

    test('a dose given since is no longer held back', () {
      final given = DoseEvent(
          id: 'x', medicationId: 'drops', givenAt: DateTime(2026, 6, 10, 8, 10));
      final ends = snoozeEnds(
          [ReminderTag(tag.at, const ['drops', 'amox'], until: until)],
          care([given]));
      expect(ends.keys, ['amox']);
    });

    test('a pending snooze from before this setting holds nothing back', () {
      expect(snoozeEnds([ReminderTag(tag.at, const ['drops'])], care([])), isEmpty);
    });
  });

  group('alarmTime', () {
    final now = DateTime.utc(2026, 6, 10, 8, 59, 3);

    test('leaves a time still to come alone', () {
      final at = DateTime.utc(2026, 6, 10, 9);
      expect(alarmTime(at, now), at);
    });

    test('rings straight away if the time went by during a replan', () {
      final soon = now.add(const Duration(seconds: 1));
      expect(alarmTime(DateTime.utc(2026, 6, 10, 8, 59), now), soon);
      expect(alarmTime(now, now), soon);
    });
  });
}
