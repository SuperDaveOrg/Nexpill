import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// intl puts a narrow no-break space before AM/PM, as CLDR now does. It
/// looks right on screen; tests compare with a plain space.
String plain(String s) => s.replaceAll('\u202f', ' ');

void main() {
  final now = DateTime(2026, 6, 10, 14, 0);

  Medication med(MedicationSchedule s) => Medication(
      id: 'm',
      patientId: 'p',
      name: 'M',
      defaultDoseText: '1',
      schedule: s,
      reminders: const ReminderSettings(enabled: true));
  DoseEvent at(DateTime t) => DoseEvent(id: 'd', medicationId: 'm', givenAt: t);

  (String, String) card(MedicationSchedule s, List<DoseEvent> doses) {
    final m = med(s);
    final (a, b) = cardText(computeMedicationStatus(m, doses, now), m, now);
    return (plain(a), plain(b));
  }

  group('card text', () {
    test('due soon counts down', () {
      expect(card(const IntervalSchedule(240), [at(DateTime(2026, 6, 10, 10, 8))]),
          ('Due in 8 min', 'at 2:08 PM'));
    });

    test('overdue says by how long', () {
      expect(card(const IntervalSchedule(240), [at(DateTime(2026, 6, 10, 9, 35))]).$1,
          'Overdue 25 min');
    });

    test('missed says when it was due', () {
      expect(card(const IntervalSchedule(120), [at(DateTime(2026, 6, 10, 9))]),
          ('Missed', 'was due 11:00 AM, 3 hr ago'));
    });

    test('next dose tomorrow says so', () {
      expect(card(const IntervalSchedule(720), [at(DateTime(2026, 6, 10, 13))]).$1,
          'Next dose tomorrow at 1:00 AM');
    });

    test('never given', () {
      expect(card(const IntervalSchedule(240), []), ('Not given yet', 'Can be given now'));
      expect(card(const FixedTimesSchedule([ClockTime(8, 0)]), []),
          ('Not given yet', 'Can be given now'));
    });

    test('as needed', () {
      expect(card(const PrnSchedule(240), [at(DateTime(2026, 6, 10, 8))]).$1,
          'Can be given now');
      expect(card(const PrnSchedule(240), [at(DateTime(2026, 6, 10, 12))]).$1,
          'Next dose from 4:00 PM');
    });
  });

  group('taper, short', () {
    final taper = TaperSchedule([
      TaperRule(startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 12), intervalMinutes: 480),
      TaperRule(startDate: DateTime(2026, 6, 12), intervalMinutes: 720),
    ]);

    test('the step in force and what follows', () {
      expect(scheduleShortText(taper, now),
          'Taper: every 8 hours until Jun 12, then every 12 hours');
    });

    test('before it starts, and after it ends', () {
      expect(scheduleShortText(taper, DateTime(2026, 5, 30)),
          'Taper: every 8 hours from Jun 1');
      final ended = TaperSchedule([
        TaperRule(startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 3), intervalMinutes: 480),
      ]);
      expect(scheduleShortText(ended, now), 'Taper finished');
    });
  });

  group('a course', () {
    Medication course(CourseEnd c) => Medication(
        id: 'm',
        patientId: 'p',
        name: 'M',
        defaultDoseText: '1',
        schedule: const IntervalSchedule(480),
        reminders: const ReminderSettings(enabled: true),
        course: c);
    final doses = [at(DateTime(2026, 6, 10, 6))];

    test('says how long is left', () {
      expect(courseShortText(course(EndsAfterDay(DateTime(2026, 6, 14))), doses),
          'last day Jun 14');
      expect(courseShortText(course(const EndsAfterDoses(4)), doses), '3 doses left');
      expect(courseShortText(course(const EndsAfterDoses(2)), doses), '1 dose left');
      expect(courseText(course(const EndsAfterDoses(4)), doses),
          '4 doses, 1 given so far');
      expect(courseShortText(med(const IntervalSchedule(480)), doses), isNull);
    });

    test('and why it finished', () {
      expect(finishedText(course(EndsAfterDay(DateTime(2026, 6, 14)))),
          'Course finished: last day was Jun 14, 2026');
      expect(finishedText(course(const EndsAfterDoses(5))),
          'Course finished: all 5 doses given');
      final m = course(const EndsAfterDoses(1));
      expect(cardText(computeMedicationStatus(m, doses, now), m, now),
          ('Finished', 'Course finished: its 1 dose given'));
    });
  });

  group('a single dose', () {
    test('says when it is', () {
      expect(plain(scheduleText(OnceSchedule(DateTime(2026, 6, 11, 15)))),
          'Once, Jun 11, 2026 3:00 PM');
      expect(plain(scheduleShortText(OnceSchedule(DateTime(2026, 6, 10, 17)), now)),
          'Once, today at 5:00 PM');
      expect(plain(scheduleShortText(OnceSchedule(DateTime(2026, 6, 11, 15)), now)),
          'Once, tomorrow at 3:00 PM');
    });

    test('is due like any other dose, and then finished', () {
      final s = OnceSchedule(DateTime(2026, 6, 10, 13));
      expect(card(s, []), ('Overdue 1 hr', 'was due 1:00 PM'));
      expect(card(s, [at(DateTime(2026, 6, 10, 13, 30))]),
          ('Finished', 'Single dose logged'));
    });
  });

  test('relative days', () {
    expect(plain(whenText(DateTime(2026, 6, 10, 9), now)), '9:00 AM');
    expect(plain(whenText(DateTime(2026, 6, 9, 21), now)), 'yesterday at 9:00 PM');
    expect(plain(whenText(DateTime(2026, 6, 13, 8), now)), 'Jun 13 at 8:00 AM');
    expect(dayHeading(dateOnly(now), now), 'Today');
    expect(shortDurationText(192), '3 hr 12 min');
  });

  test('follows the 24-hour setting', () {
    addTearDown(() => use24HourClock = false);
    use24HourClock = true;
    expect(clockText(DateTime(2026, 6, 10, 19, 15)), '19:15');
    expect(whenText(DateTime(2026, 6, 9, 21), now), 'yesterday at 21:00');
    expect(dateTimeText(DateTime(2026, 6, 10, 7, 5)), 'Jun 10, 2026 07:05');
    expect(scheduleText(const FixedTimesSchedule([ClockTime(20, 0), ClockTime(8, 0)])),
        'At 08:00 and 20:00');
  });

  test('set times read like every other time', () {
    expect(plain(scheduleText(const FixedTimesSchedule([ClockTime(20, 0), ClockTime(8, 30)]))),
        'At 8:30 AM and 8:00 PM');
  });
}
