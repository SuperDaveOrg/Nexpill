import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// Ported from the PWA's scheduling.test.ts. engine_golden_test.dart covers
/// the same ground exhaustively; these say what the rules are.

Medication med(
  MedicationSchedule schedule, {
  String id = 'med-1',
  ReminderSettings? reminders,
  CourseEnd? course,
}) =>
    Medication(
      id: id,
      patientId: 'patient-1',
      name: 'Test med',
      defaultDoseText: '1 tablet',
      schedule: schedule,
      reminders: reminders ?? ReminderSettings.defaultsFor(schedule),
      course: course,
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

    group('skipping', () {
      DoseEvent skipped(DateTime local) => DoseEvent(
          id: 'skip-1', medicationId: 'med-1', givenAt: local.toUtc(), skipped: true);
      final lastNight = givenAt(DateTime(2026, 3, 27, 20));
      final morning = skipped(DateTime(2026, 3, 28, 8));

      test('moves on to the next slot, without counting as given', () {
        final r = calculateSchedule(
            med(times), [lastNight, morning], DateTime(2026, 3, 28, 9, 30));
        expect(r.nextEligibleAt, DateTime(2026, 3, 28, 12));
        expect(r.eligibleNow, isFalse);
        expect(r.lastGivenAt, lastNight.givenAt);
      });

      test('the next dose is due as usual', () {
        final r = calculateSchedule(
            med(times), [lastNight, morning], DateTime(2026, 3, 28, 12, 30));
        expect(r.nextEligibleAt, DateTime(2026, 3, 28, 12));
        expect(r.overdueByMinutes, 30);
      });

      test('with nothing given yet, it isn\'t shown as never taken', () {
        final s = computeMedicationStatus(med(times), [morning], DateTime(2026, 3, 28, 9));
        expect(s.label, MedicationStatusLabel.tooEarly);
        expect(s.schedule.lastGivenAt, isNull);
      });

      test('uses no supply and doesn\'t count towards a course', () {
        final m = Medication(
            id: 'med-1', patientId: 'patient-1', name: 'Test med',
            defaultDoseText: '1 tablet', schedule: times,
            reminders: const ReminderSettings(enabled: true),
            inventoryEnabled: true, initialQuantity: 10, doseAmount: 1,
            course: const EndsAfterDoses(1));
        expect(computeInventoryStatus(m, [morning]).remaining, 10);
        expect(calculateSchedule(m, [morning], DateTime(2026, 3, 28, 13)).finished, isFalse);
      });

      test('an interval keeps its rhythm, as if given on time', () {
        // Every 4 hours: given 20:00, so 00:00 is skipped and 04:00 is next.
        final midnight = skipped(DateTime(2026, 3, 28, 0));
        final r = calculateSchedule(med(const IntervalSchedule(240)),
            [lastNight, midnight], DateTime(2026, 3, 28, 1));
        expect(r.nextEligibleAt.isAtSameMomentAs(DateTime(2026, 3, 28, 4)), isTrue);
        expect(r.lastGivenAt, lastNight.givenAt);
      });

      test('the next dose can be skipped before it\'s due', () {
        final evening = skipped(DateTime(2026, 3, 28, 20));
        final r = calculateSchedule(med(times),
            [givenAt(DateTime(2026, 3, 28, 12)), evening], DateTime(2026, 3, 28, 13));
        expect(r.nextEligibleAt, DateTime(2026, 3, 29, 8));
      });

      test('a dose given after all, even before a skip logged ahead, counts', () {
        // Given 04:43, 12:43 skipped, 20:43 skipped ahead, then given at 20:30.
        DateTime t(int h, int m) => DateTime(2026, 3, 28, h, m);
        final every8 = med(const IntervalSchedule(480));
        final entries = [
          givenAt(t(4, 43)),
          DoseEvent(id: 's1', medicationId: 'med-1', givenAt: t(12, 43).toUtc(), skipped: true),
          DoseEvent(id: 's2', medicationId: 'med-1', givenAt: t(20, 43).toUtc(), skipped: true),
        ];
        expect(calculateSchedule(every8, entries, t(13, 0)).nextEligibleAt
            .isAtSameMomentAs(DateTime(2026, 3, 29, 4, 43)), isTrue);
        final gave = DoseEvent(id: 'g', medicationId: 'med-1', givenAt: t(20, 30).toUtc());
        final r = calculateSchedule(every8, [...entries, gave], t(20, 31));
        expect(r.nextEligibleAt.isAtSameMomentAs(DateTime(2026, 3, 29, 4, 30)), isTrue);
        expect(r.lastGivenAt, gave.givenAt);
      });

      test('at set times, a dose given for a skipped time counts for it', () {
        final r = calculateSchedule(med(times),
            [lastNight, morning, givenAt(DateTime(2026, 3, 28, 8, 20))],
            DateTime(2026, 3, 28, 9));
        expect(r.nextEligibleAt, DateTime(2026, 3, 28, 12));
        expect(r.lastGivenAt, DateTime(2026, 3, 28, 8, 20).toUtc());
      });

      test('counts skips in a row, back to the last dose given', () {
        DoseEvent entry(String id, int day, {bool skip = true}) => DoseEvent(
            id: id, medicationId: 'med-1',
            givenAt: DateTime(2026, 3, day, 8).toUtc(), skipped: skip);
        expect(skipsInARow('med-1', []), 0);
        final history = [
          entry('a', 20, skip: false), entry('b', 21), entry('c', 22, skip: false),
          entry('d', 23), entry('e', 24), entry('f', 25),
        ];
        expect(skipsInARow('med-1', history), 3);
        expect(skipsInARow('med-1', [...history, entry('g', 26, skip: false)]), 0);
        expect(skipsInARow('other', history), 0);
      });

      test('is ignored as needed, where nothing is due', () {
        final r = calculateSchedule(med(const PrnSchedule(240)),
            [lastNight, morning], DateTime(2026, 3, 28, 9));
        expect(r.nextEligibleAt.isAtSameMomentAs(DateTime(2026, 3, 28, 0)), isTrue);
      });
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

    test('finishes at local midnight on the last step\'s end date', () {
      final ending = TaperSchedule([
        TaperRule(
            startDate: DateTime(2026, 3, 20),
            endDate: DateTime(2026, 3, 25),
            intervalMinutes: 8 * 60),
      ]);
      final end = DateTime(2026, 3, 25);
      final doses = [dose('2026-03-24T12:00:00')];

      final before = calculateSchedule(
          med(ending), doses, end.subtract(const Duration(minutes: 1)));
      expect(before.finished, isFalse);
      expect(before.overdueByMinutes, isNotNull);

      final after = calculateSchedule(
          med(ending), doses, end.add(const Duration(days: 3)));
      expect(after.finished, isTrue);
      expect(after.nextEligibleAt, end);
      expect(after.lastGivenAt, DateTime(2026, 3, 24, 12));
      expect(after.overdueByMinutes, isNull);
      expect(after.reminderAt, isNull);
    });

    test('with an open-ended last step never finishes', () {
      final r = calculateSchedule(med(taper), [], DateTime(2027, 1, 1));
      expect(r.finished, isFalse);
    });
  });

  group('a course with an end', () {
    test('runs through its last day, then is finished', () {
      final m = med(const IntervalSchedule(8 * 60),
          course: EndsAfterDay(DateTime(2026, 3, 28)));
      final doses = [dose('2026-03-28T20:00:00')];
      final lastMinute = calculateSchedule(m, doses, DateTime(2026, 3, 28, 23, 59));
      expect(lastMinute.finished, isFalse);
      expect(lastMinute.nextEligibleAt, DateTime(2026, 3, 29, 4));

      final after = calculateSchedule(m, doses, DateTime(2026, 3, 29));
      expect(after.finished, isTrue);
      expect(after.nextEligibleAt, DateTime(2026, 3, 29));
      expect(after.overdueByMinutes, isNull);
      expect(after.reminderAt, isNull);
    });

    test('of doses is finished by the last one, and a correction isn\'t another', () {
      final m = med(const IntervalSchedule(8 * 60), course: const EndsAfterDoses(2));
      final first = dose('2026-03-27T22:00:00Z', id: 'a');
      final fixed = dose('2026-03-27T21:30:00Z', id: 'b', corrects: 'a');
      expect(calculateSchedule(m, [first, fixed], now).finished, isFalse);

      final second = dose('2026-03-28T06:00:00Z', id: 'c');
      final r = calculateSchedule(m, [first, fixed, second], now);
      expect(r.finished, isTrue);
      expect(r.nextEligibleAt, utc('2026-03-28T06:00:00Z'));
      expect(r.lastGivenAt, utc('2026-03-28T06:00:00Z'));

      expect(
          calculateSchedule(m, [first, fixed, second], utc('2026-03-28T05:59:00Z'))
              .finished,
          isFalse,
          reason: 'as of before the last dose');
    });

    test('ends a taper early if it comes first', () {
      final m = med(
          TaperSchedule([TaperRule(startDate: DateTime(2026, 3, 1), intervalMinutes: 480)]),
          course: EndsAfterDay(DateTime(2026, 3, 27)));
      expect(finishesAt(m, []), DateTime(2026, 3, 28));
      expect(calculateSchedule(m, [], now).finished, isTrue);
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
