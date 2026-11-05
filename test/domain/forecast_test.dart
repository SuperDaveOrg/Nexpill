import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/forecast.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

const sam = Patient(id: 'sam', displayName: 'Sam');

Medication med(
  String id,
  MedicationSchedule schedule, {
  ReminderSettings reminders = const ReminderSettings(enabled: true),
  bool active = true,
  CourseEnd? course,
  bool inventory = false,
  double? doseAmount,
  String? doseUnit,
}) =>
    Medication(
      id: id,
      patientId: 'sam',
      name: id,
      defaultDoseText: '1 tablet',
      schedule: schedule,
      reminders: reminders,
      active: active,
      course: course,
      inventoryEnabled: inventory,
      doseAmount: doseAmount,
      doseUnit: doseUnit,
    );

DoseEvent given(String medicationId, DateTime at,
        {String id = 'd', bool skipped = false}) =>
    DoseEvent(
        id: '$id-$medicationId',
        medicationId: medicationId,
        givenAt: at,
        skipped: skipped);

void main() {
  // Local times, so fixed-time slots read naturally in any zone.
  final from = DateTime(2026, 6, 10, 9);
  final day = from.add(const Duration(hours: 24));

  DoseForecast forecast(List<Medication> meds, List<DoseEvent> doses,
          {DateTime? until}) =>
      forecastDoses(
        CareSnapshot(patients: const [sam], medications: meds, doses: doses),
        'sam',
        from: from,
        until: until ?? day,
      );

  /// Each dose as "day/HH:mm med", with a "!" if due now.
  List<String> read(DoseForecast f) => [
        for (final d in f.doses)
          '${d.at.day}/${d.at.hour.toString().padLeft(2, '0')}:'
              '${d.at.minute.toString().padLeft(2, '0')} '
              '${d.medication.id}${d.dueNow ? '!' : ''}',
      ];

  test('an interval sees every dose, not only the next', () {
    final m = med('a', const IntervalSchedule(8 * 60));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), [
      '10/16:00 a',
      '11/00:00 a',
      '11/08:00 a',
    ]);
  });

  test('a late interval dose counts on from now', () {
    final m = med('a', const IntervalSchedule(8 * 60));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 9, 22))])), [
      '10/06:00 a!',
      '10/17:00 a',
      '11/01:00 a',
    ]);
  });

  test('fixed times, by the clock, and the end is left out', () {
    final m = med('a',
        const FixedTimesSchedule([ClockTime(8, 0), ClockTime(12, 0), ClockTime(20, 0)]));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), [
      '10/12:00 a',
      '10/20:00 a',
      '11/08:00 a',
    ]);
    expect(
        read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))],
            until: DateTime(2026, 6, 11, 8))),
        ['10/12:00 a', '10/20:00 a']);
  });

  test('a late fixed dose does not drop the slot after it', () {
    final m = med('a', const FixedTimesSchedule([ClockTime(8, 0), ClockTime(12, 0)]));
    final late = DateTime(2026, 6, 10, 10, 30);
    final f = forecastDoses(
      CareSnapshot(
          patients: const [sam],
          medications: [m],
          doses: [given('a', DateTime(2026, 6, 9, 12))]),
      'sam',
      from: late,
      until: DateTime(2026, 6, 10, 18),
    );
    expect(read(f), ['10/08:00 a!', '10/12:00 a']);
  });

  test('a taper changes interval when its next step starts', () {
    final m = med(
        'a',
        TaperSchedule([
          TaperRule(
              startDate: DateTime(2026, 6, 1),
              endDate: DateTime(2026, 6, 11),
              intervalMinutes: 6 * 60),
          TaperRule(startDate: DateTime(2026, 6, 11), intervalMinutes: 12 * 60),
        ]));
    // 15:00, 21:00, then the new step counts 12 hours from its start, not
    // from the 03:00 the old step would have said.
    expect(
        read(forecast([m], [given('a', DateTime(2026, 6, 10, 9))],
            until: DateTime(2026, 6, 11, 18))),
        ['10/15:00 a', '10/21:00 a', '11/12:00 a']);
  });

  test('a taper that ends stops the forecast', () {
    final m = med(
        'a',
        TaperSchedule([
          TaperRule(
              startDate: DateTime(2026, 6, 1),
              endDate: DateTime(2026, 6, 11),
              intervalMinutes: 8 * 60),
        ]));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), [
      '10/16:00 a',
    ]);
  });

  test('a course of doses counts the supposed ones, and stops', () {
    final m = med('a', const IntervalSchedule(4 * 60),
        course: const EndsAfterDoses(3));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), [
      '10/12:00 a',
      '10/16:00 a',
    ]);
  });

  test('a course stops after its last day', () {
    final m = med('a', const IntervalSchedule(10 * 60),
        course: EndsAfterDay(DateTime(2026, 6, 10)));
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), [
      '10/18:00 a',
    ]);
  });

  test('a single dose appears once, and not after it is given', () {
    final m = med('a', OnceSchedule(DateTime(2026, 6, 10, 15)));
    expect(read(forecast([m], [])), ['10/15:00 a']);
    expect(read(forecast([m], [given('a', DateTime(2026, 6, 10, 8))])), isEmpty);
  });

  test('a dose skipped ahead of time is left out', () {
    final m = med('a', const IntervalSchedule(4 * 60));
    expect(
        read(forecast([
          m
        ], [
          given('a', DateTime(2026, 6, 10, 8)),
          given('a', DateTime(2026, 6, 10, 12), id: 's', skipped: true),
        ], until: DateTime(2026, 6, 10, 21))),
        ['10/16:00 a', '10/20:00 a']);
  });

  test('reminders being off changes nothing; stopped medications are out', () {
    final quiet = med('a', const IntervalSchedule(12 * 60),
        reminders: const ReminderSettings(enabled: false));
    final stopped = med('b', const IntervalSchedule(12 * 60), active: false);
    expect(
        read(forecast([
          quiet,
          stopped
        ], [
          given('a', DateTime(2026, 6, 10, 8)),
          given('b', DateTime(2026, 6, 10, 8)),
        ])),
        ['10/20:00 a', '11/08:00 a']);
  });

  test('as-needed and never-started intervals have no set time', () {
    final prn = med('p', const PrnSchedule(6 * 60));
    final unstarted = med('u', const IntervalSchedule(8 * 60));
    final f = forecast([unstarted, prn], [given('p', DateTime(2026, 6, 10, 8))]);
    expect(f.doses, isEmpty);
    expect([for (final m in f.withoutSetTime) m.id], ['p', 'u']);
  });

  test('other people, and real history, are left alone', () {
    const other = Medication(
      id: 'o',
      patientId: 'jo',
      name: 'o',
      defaultDoseText: '',
      schedule: IntervalSchedule(60),
      reminders: ReminderSettings(enabled: true),
    );
    final m = med('a', const IntervalSchedule(12 * 60));
    final doses = [given('a', DateTime(2026, 6, 10, 8))];
    expect(read(forecast([m, other], doses)), ['10/20:00 a', '11/08:00 a']);
    expect(doses, hasLength(1));
  });

  test('every 8 hours stays 8 hours across a clock change', () {
    final start = DateTime.utc(2026, 3, 8, 0);
    final m = med('a', const IntervalSchedule(8 * 60));
    final f = forecastDoses(
      CareSnapshot(
          patients: const [sam],
          medications: [m],
          doses: [given('a', start)]),
      'sam',
      from: start.add(const Duration(minutes: 1)),
      until: start.add(const Duration(hours: 25)),
    );
    expect([for (final d in f.doses) d.at.difference(start).inHours], [8, 16, 24]);
  });

  test('schedules with nothing to count by end rather than hang', () {
    final m = med('a', const FixedTimesSchedule([]));
    expect(forecast([m], [given('a', DateTime(2026, 6, 10, 8))]).doses,
        hasLength(1));
  });

  test('the total adds up the amount when the supply is counted', () {
    final counted = med('a', const IntervalSchedule(60),
        inventory: true, doseAmount: 2, doseUnit: 'tablets');
    final free = med('b', const IntervalSchedule(60));
    expect(forecastTotalText(counted, 3), '3 doses, 6 tablets');
    expect(forecastTotalText(free, 1), '1 dose of 1 tablet');
  });
}
