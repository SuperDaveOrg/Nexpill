import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// Ported from the PWA's scheduling.test.ts. engine_golden_test.dart covers
/// the same ground exhaustively; these say what the rules are.

Medication med(
  MedicationSchedule schedule, {
  String id = 'med-1',
  ReminderSettings? reminders,
}) =>
    Medication(
      id: id,
      patientId: 'patient-1',
      name: 'Test med',
      defaultDoseText: '1 tablet',
      schedule: schedule,
      reminders: reminders ?? ReminderSettings.defaultsFor(schedule),
    );

DoseEvent dose(String at,
        {String id = 'dose-1', String medicationId = 'med-1', String? corrects}) =>
    DoseEvent(
      id: id,
      medicationId: medicationId,
      givenAt: DateTime.parse(at),
      supersedesId: corrects,
    );

DateTime utc(String s) => DateTime.parse(s);

void main() {
  final now = utc('2026-03-28T10:00:00.000Z');

  group('interval', () {
    test('with no doses is eligible straight away', () {
      final r = calculateSchedule(
        med(const IntervalSchedule(8 * 60),
            reminders: const ReminderSettings(enabled: true, earlyMinutes: 10)),
        [],
        now,
      );
      expect(r.lastGivenAt, isNull);
      expect(r.eligibleNow, isTrue);
      expect(r.nextEligibleAt, now);
      expect(r.tooEarlyByMinutes, isNull);
      expect(r.overdueByMinutes, isNull);
      expect(r.reminderAt, utc('2026-03-28T09:50:00.000Z'));
    });

    test('counts the too-early window from the latest dose', () {
      final r = calculateSchedule(
          med(const IntervalSchedule(6 * 60)), [dose('2026-03-28T07:00:00Z')], now);
      expect(r.lastGivenAt, utc('2026-03-28T07:00:00Z'));
      expect(r.eligibleNow, isFalse);
      expect(r.nextEligibleAt, utc('2026-03-28T13:00:00Z'));
      expect(r.tooEarlyByMinutes, 180);
      expect(r.overdueByMinutes, isNull);
    });

    test('is overdue after the expected time', () {
      final r = calculateSchedule(
          med(const IntervalSchedule(120)), [dose('2026-03-28T06:00:00Z')], now);
      expect(r.nextEligibleAt, utc('2026-03-28T08:00:00Z'));
      expect(r.eligibleNow, isTrue);
      expect(r.overdueByMinutes, 120);
      expect(r.tooEarlyByMinutes, isNull);
    });

    test('handles odd intervals like 4 hours 45 minutes', () {
      final r = calculateSchedule(med(const IntervalSchedule(4 * 60 + 45)),
          [dose('2026-03-28T05:20:00Z')], now);
      expect(r.nextEligibleAt, utc('2026-03-28T10:05:00Z'));
      expect(r.eligibleNow, isFalse);
      expect(r.tooEarlyByMinutes, 5);
    });

    test('is eligible, not yet overdue, at exactly the due instant', () {
      final r = calculateSchedule(
          med(const IntervalSchedule(120)), [dose('2026-03-28T08:00:00Z')], now);
      expect(r.nextEligibleAt, now);
      expect(r.eligibleNow, isTrue);
      expect(r.tooEarlyByMinutes, isNull);
      expect(r.overdueByMinutes, isNull);
    });

    test('ignores doses a correction replaced', () {
      final r = calculateSchedule(med(const IntervalSchedule(120)), [
        dose('2026-03-28T09:50:00Z', id: 'original'),
        dose('2026-03-28T09:20:00Z', id: 'fix', corrects: 'original'),
      ], now);
      expect(r.lastGivenAt, utc('2026-03-28T09:20:00Z'));
      expect(r.nextEligibleAt, utc('2026-03-28T11:20:00Z'));
      expect(r.tooEarlyByMinutes, 80);
    });

    test('ignores other medications\' doses', () {
      final r = calculateSchedule(med(const IntervalSchedule(120)),
          [dose('2026-03-28T09:00:00Z', medicationId: 'other')], now);
      expect(r.lastGivenAt, isNull);
    });
  });

  group('as needed (PRN)', () {
    test('is available once the lockout has passed, and never overdue', () {
      final r = calculateSchedule(
          med(const PrnSchedule(4 * 60)), [dose('2026-03-28T04:45:00Z')], now);
      expect(r.nextEligibleAt, utc('2026-03-28T08:45:00Z'));
      expect(r.eligibleNow, isTrue);
      expect(r.tooEarlyByMinutes, isNull);
      expect(r.overdueByMinutes, isNull);
    });

    test('with no doses is available now', () {
      final r = calculateSchedule(med(const PrnSchedule(120)), [], now);
      expect(r.eligibleNow, isTrue);
      expect(r.nextEligibleAt, now);
    });

    test('stays not-overdue long after the lockout', () {
      final r = calculateSchedule(
          med(const PrnSchedule(60)), [dose('2026-03-27T00:00:00Z')], now);
      expect(r.nextEligibleAt, utc('2026-03-27T01:00:00Z'));
      expect(r.overdueByMinutes, isNull);
    });
  });

  group('fixed times', () {
    const times = FixedTimesSchedule(
        [ClockTime(8, 0), ClockTime(12, 0), ClockTime(20, 0)]);

    DoseEvent givenAt(DateTime local) => DoseEvent(
        id: 'dose-1', medicationId: 'med-1', givenAt: local.toUtc());
    DateTime due(List<DoseEvent> doses, DateTime now) =>
        calculateSchedule(med(times), doses, now).nextEligibleAt;

    test('before the first slot, uses yesterday\'s last', () {
      final r = calculateSchedule(med(times), [], DateTime(2026, 3, 28, 5));
      expect(r.nextEligibleAt, DateTime(2026, 3, 27, 20));
    });

    test('between slots, uses the one just past', () {
      final r = calculateSchedule(med(times), [], DateTime(2026, 3, 28, 13, 15));
      expect(r.nextEligibleAt, DateTime(2026, 3, 28, 12));
    });

    test('after the last slot, uses today\'s last', () {
      final r = calculateSchedule(med(times), [], DateTime(2026, 3, 28, 23));
      expect(r.nextEligibleAt, DateTime(2026, 3, 28, 20));
    });

    test('a dose shortly after its slot moves on to the next slot', () {
      final r = calculateSchedule(med(times),
          [givenAt(DateTime(2026, 3, 28, 8, 5))], DateTime(2026, 3, 28, 8, 10));
      expect(r.nextEligibleAt, DateTime(2026, 3, 28, 12));
      expect(r.eligibleNow, isFalse);
      expect(r.overdueByMinutes, isNull);
    });

    test('a dose shortly before its slot counts for that slot', () {
      expect(due([givenAt(DateTime(2026, 3, 28, 7, 50))], DateTime(2026, 3, 28, 7, 55)),
          DateTime(2026, 3, 28, 12));
    });

    test('each dose counts for the nearest slot; halfway goes to the later', () {
      // Halfway between 08:00 and 12:00 is 10:00.
      expect(due([givenAt(DateTime(2026, 3, 28, 9, 59))], DateTime(2026, 3, 28, 10, 30)),
          DateTime(2026, 3, 28, 12));
      expect(due([givenAt(DateTime(2026, 3, 28, 10))], DateTime(2026, 3, 28, 10, 30)),
          DateTime(2026, 3, 28, 20));
    });

    test('last night\'s dose makes this morning\'s the next one', () {
      expect(due([givenAt(DateTime(2026, 3, 27, 20, 5))], DateTime(2026, 3, 28, 7)),
          DateTime(2026, 3, 28, 8));
    });

    test('a skipped slot is overdue until the next slot, then dropped', () {
      final noon = [givenAt(DateTime(2026, 3, 27, 12))];
      final evening = calculateSchedule(med(times), noon, DateTime(2026, 3, 28, 7));
      expect(evening.nextEligibleAt, DateTime(2026, 3, 27, 20));
      expect(evening.overdueByMinutes, 11 * 60);
      expect(due(noon, DateTime(2026, 3, 28, 9)), DateTime(2026, 3, 28, 8));
    });

    test('with one slot a day, the window is twelve hours either side', () {
      const nightly = FixedTimesSchedule([ClockTime(21, 30)]);
      final r = calculateSchedule(med(nightly),
          [givenAt(DateTime(2026, 3, 28, 10))], DateTime(2026, 3, 28, 11));
      expect(r.nextEligibleAt, DateTime(2026, 3, 29, 21, 30));
    });
  });

  group('taper', () {
    final taper = TaperSchedule([
      TaperRule(
          startDate: DateTime(2026, 3, 20),
          endDate: DateTime(2026, 3, 25),
          intervalMinutes: 8 * 60),
      TaperRule(startDate: DateTime(2026, 3, 25), intervalMinutes: 12 * 60),
    ]);

    test('uses the interval of the step in force', () {
      final r = calculateSchedule(med(taper), [dose('2026-03-28T06:30:00Z')], now);
      expect(r.nextEligibleAt, utc('2026-03-28T18:30:00Z'));
      expect(r.eligibleNow, isFalse);
      expect(r.tooEarlyByMinutes, 510);
    });

    test('switches step at local midnight', () {
      final boundary = DateTime(2026, 3, 25);
      final r = calculateSchedule(med(taper), [], boundary);
      expect(r.nextEligibleAt, boundary);
      expect(r.eligibleNow, isTrue);

      // A minute earlier the old 8-hour step still applies: its last beat
      // from 20 March was 16:00 on the 24th.
      final before = calculateSchedule(
          med(taper), [], boundary.subtract(const Duration(minutes: 1)));
      expect(before.nextEligibleAt, DateTime(2026, 3, 24, 16));
    });

    test('a dose from before the step began doesn\'t hold it back', () {
      final r = calculateSchedule(
          med(taper), [dose('2026-03-24T22:00:00')], DateTime(2026, 3, 26));
      expect(r.nextEligibleAt, DateTime(2026, 3, 25, 12));
    });
  });

  group('reminders', () {
    test('have a time only when enabled', () {
      final on = med(const IntervalSchedule(60),
          id: 'on',
          reminders: const ReminderSettings(enabled: true, earlyMinutes: 15));
      final off = med(const IntervalSchedule(60),
          id: 'off',
          reminders: const ReminderSettings(enabled: false, earlyMinutes: 15));
      final doses = [
        dose('2026-03-28T09:30:00Z', id: 'a', medicationId: 'on'),
        dose('2026-03-28T09:30:00Z', id: 'b', medicationId: 'off'),
      ];
      final r = calculateSchedule(on, doses, now);
      expect(r.nextEligibleAt, utc('2026-03-28T10:30:00Z'));
      expect(r.reminderAt, utc('2026-03-28T10:15:00Z'));
      expect(calculateSchedule(off, doses, now).reminderAt, isNull);
    });
  });
}
