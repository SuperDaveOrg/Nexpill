import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

const sam = Patient(id: 'sam', displayName: 'Sam');

Medication med(
  String id,
  MedicationSchedule schedule, {
  String patientId = 'sam',
  ReminderSettings? reminders,
  bool active = true,
}) =>
    Medication(
      id: id,
      patientId: patientId,
      name: id,
      defaultDoseText: '1 tablet',
      schedule: schedule,
      reminders: reminders ?? const ReminderSettings(enabled: true),
      active: active,
    );

DoseEvent given(String medicationId, DateTime at, {String id = 'd'}) =>
    DoseEvent(id: '$id-$medicationId', medicationId: medicationId, givenAt: at);

CareSnapshot care(List<Medication> meds, List<DoseEvent> doses,
        {List<Patient> patients = const [sam]}) =>
    CareSnapshot(patients: patients, medications: meds, doses: doses);

/// Each notification as "HH:mm kind:med+kind:med", local time, for reading.
List<String> summary(ReminderPlan plan) => [
      for (final n in plan.notifications)
        '${_hm(n.at)} ${[for (final i in n.items) '${i.kind.name}:${i.medication.id}'].join('+')}',
    ];

String _hm(DateTime t) {
  final l = t.toLocal();
  return '${l.day}/${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

void main() {
  // Local times, so fixed-time slots read naturally in any zone.
  final from = DateTime(2026, 6, 10, 9);
  const planner = ReminderPlanner(horizon: Duration(hours: 24));

  group('interval', () {
    test('heads-up, due, then overdue repeats up to the cap', () {
      final m = med('amox', const IntervalSchedule(8 * 60),
          reminders: const ReminderSettings(enabled: true, earlyMinutes: 10));
      final plan = planner.plan(
          care([m], [given('amox', DateTime(2026, 6, 10, 6))]),
          from: from);
      expect(summary(plan), [
        '10/13:50 dueSoon:amox',
        '10/14:00 dueNow:amox',
        '10/14:30 overdue:amox',
        '10/15:00 overdue:amox',
        '10/15:30 overdue:amox',
        '10/16:00 overdue:amox',
        '10/16:30 overdue:amox',
        '10/17:00 overdue:amox',
      ]);
      expect(plan.refreshNoticeAt, isNull);
    });

    test('already overdue: only the repeats still to come', () {
      final m = med('amox', const IntervalSchedule(120));
      final plan = planner.plan(
          care([m], [given('amox', DateTime(2026, 6, 10, 6, 15))]),
          from: from);
      // Due 08:15; the 08:45 repeat has passed but still counts to the six.
      expect(summary(plan), [
        '10/09:15 overdue:amox',
        '10/09:45 overdue:amox',
        '10/10:15 overdue:amox',
        '10/10:45 overdue:amox',
        '10/11:15 overdue:amox',
      ]);
    });

    test('never given: nothing to count from, so no reminders', () {
      final plan =
          planner.plan(care([med('amox', const IntervalSchedule(480))], []), from: from);
      expect(plan.notifications, isEmpty);
    });

    test('a replan between the due time and its minute keeps the reminder', () {
      // Due 09:00:48, so the alarm is set for 09:01:00. Replanning at
      // 09:00:50 — the app coming to the foreground, say — must not drop it
      // just because the due time itself has passed. (Found on the
      // emulator.)
      final m = med('acet', const IntervalSchedule(240));
      final plan = planner.plan(
          care([m], [given('acet', DateTime(2026, 6, 10, 5, 0, 48))]),
          from: DateTime(2026, 6, 10, 9, 0, 50));
      expect(summary(plan).first, '10/09:01 dueNow:acet');
    });

    test('a reminder is never earlier than the due time, to the minute', () {
      final m = med('amox', const IntervalSchedule(60));
      final plan = planner.plan(
          care([m], [given('amox', DateTime(2026, 6, 10, 8, 30, 20))]),
          from: from);
      expect(plan.notifications.first.at, DateTime(2026, 6, 10, 9, 31).toUtc());
    });
  });

  group('silence', () {
    final dose = given('amox', DateTime(2026, 6, 10, 6));

    test('inactive medication', () {
      expect(
          planner.plan(care([med('amox', const IntervalSchedule(480), active: false)], [dose]),
              from: from).notifications,
          isEmpty);
    });

    test('reminders off for the medication', () {
      final m = med('amox', const IntervalSchedule(480),
          reminders: const ReminderSettings(enabled: false));
      expect(planner.plan(care([m], [dose]), from: from).notifications, isEmpty);
    });

    test('notifications off for the patient', () {
      final quiet = sam.copyWith(notificationsEnabled: false);
      expect(
          planner.plan(care([med('amox', const IntervalSchedule(480))], [dose], patients: [quiet]),
              from: from).notifications,
          isEmpty);
    });
  });

  group('as needed', () {
    test('one "can be given again" per dose, never overdue or early', () {
      final m = med('ibu', const PrnSchedule(360),
          reminders: const ReminderSettings(enabled: true, earlyMinutes: 15));
      final plan = planner.plan(care([m], [given('ibu', DateTime(2026, 6, 10, 8))]),
          from: from);
      expect(summary(plan), ['10/14:00 available:ibu']);
    });

    test('defaults to no reminders', () {
      expect(ReminderSettings.defaultsFor(const PrnSchedule(60)).enabled, isFalse);
      expect(ReminderSettings.defaultsFor(const IntervalSchedule(60)).enabled, isTrue);
    });
  });

  group('fixed times', () {
    const times = FixedTimesSchedule([ClockTime(8, 0), ClockTime(20, 0)]);

    test('each slot is due in turn; given this morning, next is tonight', () {
      final m = med('eye', times,
          reminders: const ReminderSettings(
              enabled: true, earlyMinutes: 15, overdueRepeatMinutes: 60));
      final plan = planner.plan(care([m], [given('eye', DateTime(2026, 6, 10, 8, 2))]),
          from: from);
      expect(summary(plan), [
        '10/19:45 dueSoon:eye',
        '10/20:00 dueNow:eye',
        '10/21:00 overdue:eye',
        '10/22:00 overdue:eye',
        '10/23:00 overdue:eye',
        '11/00:00 overdue:eye',
        '11/01:00 overdue:eye',
        '11/02:00 overdue:eye',
        // Tomorrow morning's heads-up comes while tonight's is still
        // overdue, so the engine says "overdue" then: no heads-up. The
        // 08:00 slot itself is due.
        '11/08:00 dueNow:eye',
        '11/09:00 overdue:eye',
      ]);
    });

    test('overdue repeats stop when the next slot comes round', () {
      const often = FixedTimesSchedule([ClockTime(10, 0), ClockTime(11, 0)]);
      final m = med('drops', often);
      final plan = const ReminderPlanner(horizon: Duration(hours: 3)).plan(
          care([m], [given('drops', DateTime(2026, 6, 9, 22))]),
          from: from);
      expect(summary(plan), [
        '10/10:00 dueNow:drops',
        '10/10:30 overdue:drops',
        '10/11:00 dueNow:drops',
        '10/11:30 overdue:drops',
        '10/12:00 overdue:drops',
      ]);
    });

    test('recurring forever, so a notice is planned before reminders run out', () {
      final plan = planner.plan(care([med('eye', times)], []), from: from);
      expect(plan.refreshNoticeAt, from.add(const Duration(hours: 12)));
    });
  });

  group('taper', () {
    final taper = TaperSchedule([
      TaperRule(startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 11), intervalMinutes: 480),
      TaperRule(startDate: DateTime(2026, 6, 11), intervalMinutes: 720),
    ]);

    test('follows the step in force, switching at local midnight', () {
      final m = med('pred', taper,
          reminders: const ReminderSettings(
              enabled: true, overdueRepeatMinutes: 120));
      final plan = const ReminderPlanner(horizon: Duration(hours: 30))
          .plan(care([m], [given('pred', DateTime(2026, 6, 10, 20))]), from: from);
      // Due 04:00 on the 11th on the old 8-hour step — but by then the
      // 12-hour step has started, and a dose from before a step doesn't
      // count toward it: due 12 hours from its start.
      expect(summary(plan).take(2), ['11/12:00 dueNow:pred', '11/14:00 overdue:pred']);
    });

    test('never given: due on each beat of the step', () {
      final m = med('pred', taper,
          reminders: const ReminderSettings(enabled: true, overdueRepeatMinutes: 600));
      final plan = const ReminderPlanner(horizon: Duration(hours: 16))
          .plan(care([m], []), from: from);
      expect(summary(plan), ['10/16:00 dueNow:pred', '11/00:00 dueNow:pred']);
    });
  });

  group('notifications', () {
    test('one per patient per minute, listing everything due', () {
      final a = med('amox', const IntervalSchedule(480));
      final b = med('para', const IntervalSchedule(480));
      final alex = med('zinc', const IntervalSchedule(480), patientId: 'alex');
      final at = DateTime(2026, 6, 10, 6);
      final plan = planner.plan(
        care([a, b, alex], [given('amox', at), given('para', at), given('zinc', at)],
            patients: [sam, const Patient(id: 'alex', displayName: 'Alex')]),
        from: from,
      );
      final first = plan.notifications.where((n) => n.at == DateTime(2026, 6, 10, 14).toUtc());
      expect(first.length, 2);
      final sams = first.firstWhere((n) => n.patient.id == 'sam');
      expect(sams.title, '2 medications for Sam');
      expect(sams.body, 'amox due now\npara due now');
      expect(first.firstWhere((n) => n.patient.id == 'alex').title, 'zinc due now');
    });

    test('alarm mode rings when due or overdue, not for the heads-up', () {
      final m = med('amox', const IntervalSchedule(480),
          reminders: const ReminderSettings(enabled: true, earlyMinutes: 10, alarm: true));
      final plan = planner.plan(care([m], [given('amox', DateTime(2026, 6, 10, 6))]),
          from: from);
      expect([for (final n in plan.notifications.take(3)) n.rings], [false, true, true]);
    });

    test('alarm mode is ignored for as-needed medications', () {
      final m = med('ibu', const PrnSchedule(60),
          reminders: const ReminderSettings(enabled: true, alarm: true));
      final plan = planner.plan(care([m], [given('ibu', DateTime(2026, 6, 10, 8, 30))]),
          from: from);
      expect(plan.notifications.single.rings, isFalse);
    });

    test('capped, with a notice at the last one kept', () {
      const every = FixedTimesSchedule([ClockTime(9, 30), ClockTime(10, 30)]);
      final plan = const ReminderPlanner(maxNotifications: 3)
          .plan(care([med('eye', every)], []), from: from);
      expect(plan.notifications.length, 3);
      expect(plan.refreshNoticeAt, plan.notifications.last.at);
    });
  });

  test('snoozed notification describes things as they are now', () {
    final m = med('amox', const IntervalSchedule(120));
    final now = DateTime(2026, 6, 10, 9);
    final n = snoozedNotification(
      care([m], [given('amox', DateTime(2026, 6, 10, 6))]),
      ['amox'],
      now: now,
      at: now.add(const Duration(minutes: 5)),
    )!;
    expect(n.items.single.kind, ReminderKind.overdue);
    expect(n.title, startsWith('amox overdue since'));
  });

  test('ClockTime.on keeps wall-clock times across a DST change', () {
    // Whatever the zone, 08:00 on any day is 08:00 local.
    expect(const ClockTime(8, 0).on(DateTime(2026, 3, 29)).hour, 8);
  });
}
