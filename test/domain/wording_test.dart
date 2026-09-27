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
    final (a, b) = cardText(computeMedicationStatus(m, doses, now), s, now);
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

  test('relative days', () {
    expect(plain(whenText(DateTime(2026, 6, 10, 9), now)), '9:00 AM');
    expect(plain(whenText(DateTime(2026, 6, 9, 21), now)), 'yesterday at 9:00 PM');
    expect(plain(whenText(DateTime(2026, 6, 13, 8), now)), 'Jun 13 at 8:00 AM');
    expect(dayHeading(dateOnly(now), now), 'Today');
    expect(shortDurationText(192), '3 hr 12 min');
  });
}
