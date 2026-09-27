import 'package:flutter_test/flutter_test.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/ui/medication_draft.dart';

void main() {
  final today = DateTime(2026, 6, 10);
  MedicationDraft named() => MedicationDraft.blank('p', today)..name = 'Amoxicillin';

  test('a blank draft needs a name', () {
    expect(MedicationDraft.blank('p', today).validate().keys, ['name']);
    expect(named().validate(), isEmpty);
  });

  test('builds an interval medication with the new-medication defaults', () {
    final m = named().build(() => 'id-1');
    expect(m.id, 'id-1');
    expect((m.schedule as IntervalSchedule).intervalMinutes, 240);
    expect(m.reminders.enabled, isTrue);
    expect(m.reminders.earlyMinutes, 0);
    expect(m.inventoryEnabled, isFalse);
  });

  test('switching to as needed turns reminders off, unless they were touched', () {
    final d = named()..setKind(ScheduleKind.prn);
    expect(d.remindersOn, isFalse);
    d
      ..remindersOn = true
      ..remindersTouched = true
      ..setKind(ScheduleKind.interval)
      ..setKind(ScheduleKind.prn);
    expect(d.remindersOn, isTrue);
  });

  test('as-needed and taper never ring as alarms or give a heads-up', () {
    final d = named()
      ..alarm = true
      ..earlyMinutes = 15
      ..setKind(ScheduleKind.prn);
    final m = d.build(() => 'x');
    expect(m.reminders.alarm, isFalse);
    expect(m.reminders.earlyMinutes, 0);
  });

  test('fixed times need at least one time, and are stored sorted without repeats', () {
    final d = named()
      ..setKind(ScheduleKind.fixedTimes)
      ..times = [];
    expect(d.validate().keys, ['schedule']);
    d.times = [const ClockTime(20, 0), const ClockTime(8, 0), const ClockTime(20, 0)];
    final s = d.build(() => 'x').schedule as FixedTimesSchedule;
    expect(s.times, [const ClockTime(8, 0), const ClockTime(20, 0)]);
  });

  group('taper steps', () {
    MedicationDraft taper(List<TaperStepDraft> steps) => named()
      ..setKind(ScheduleKind.taper)
      ..taperSteps
          .replaceRange(0, 1, steps);

    test('in order, ending where the next begins', () {
      final d = taper([
        TaperStepDraft(start: DateTime(2026, 6, 5), minutes: 720),
        TaperStepDraft(start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 5), minutes: 480),
      ]);
      expect(d.validate(), isEmpty);
      final rules = (d.build(() => 'x').schedule as TaperSchedule).rules;
      expect([for (final r in rules) isoDate(r.startDate)], ['2026-06-01', '2026-06-05']);
    });

    test('only the last can be open-ended', () {
      final d = taper([
        TaperStepDraft(start: DateTime(2026, 6, 1)),
        TaperStepDraft(start: DateTime(2026, 6, 5)),
      ]);
      expect(d.validate()['schedule'], contains('last step'));
    });

    test('may not overlap', () {
      final d = taper([
        TaperStepDraft(start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 7)),
        TaperStepDraft(start: DateTime(2026, 6, 5)),
      ]);
      expect(d.validate()['schedule'], contains('overlap'));
    });

    test('must end after they start', () {
      final d = taper([TaperStepDraft(start: DateTime(2026, 6, 5), end: DateTime(2026, 6, 5))]);
      expect(d.validate()['schedule'], contains('end after'));
    });
  });

  test('supply needs a starting amount and a positive amount per dose', () {
    final d = named()..trackSupply = true;
    expect(d.validate().keys, ['supply']);
    d
      ..startingQuantity = '30'
      ..perDose = '0';
    expect(d.validate().keys, ['supply']);
    d
      ..perDose = '0,5'
      ..lowAt = '5';
    expect(d.validate(), isEmpty);
    final m = d.build(() => 'x');
    expect(m.doseAmount, 0.5);
    expect(m.lowSupplyThreshold, 5);
  });

  test('editing keeps everything, and round-trips', () {
    final original = named()
      ..setKind(ScheduleKind.fixedTimes)
      ..times = [const ClockTime(9, 30)]
      ..trackSupply = true
      ..startingQuantity = '2.5';
    final m = original.build(() => 'id');
    final again = MedicationDraft.of(m).build(() => 'other');
    expect(again.id, 'id');
    expect((again.schedule as FixedTimesSchedule).times, [const ClockTime(9, 30)]);
    expect(again.initialQuantity, 2.5);
  });
}
