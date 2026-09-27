import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/medication.dart';

enum ScheduleKind { interval, fixedTimes, prn, taper }

/// One taper step as it's being edited.
class TaperStepDraft {
  TaperStepDraft({required this.start, this.end, this.minutes = 8 * 60});

  DateTime start;
  DateTime? end;
  int minutes;
}

/// The medication form's state: everything editable, kept for every
/// schedule type at once so switching type and back loses nothing. Plain
/// Dart, so its rules are tested without widgets.
class MedicationDraft {
  MedicationDraft.blank(this.patientId, DateTime today)
      : id = null,
        taperSteps = [TaperStepDraft(start: dateOnly(today))];

  MedicationDraft.of(Medication m)
      : id = m.id,
        patientId = m.patientId,
        name = m.name,
        strength = m.strengthText ?? '',
        dose = m.defaultDoseText,
        instructions = m.instructions ?? '',
        active = m.active,
        remindersOn = m.reminders.enabled,
        earlyMinutes = m.reminders.earlyMinutes,
        overdueRepeatMinutes = m.reminders.overdueRepeatMinutes,
        alarm = m.reminders.alarm,
        trackSupply = m.inventoryEnabled,
        startingQuantity = _num(m.initialQuantity),
        perDose = _num(m.doseAmount) ?? '1',
        unit = m.doseUnit ?? '',
        lowAt = _num(m.lowSupplyThreshold),
        remindersTouched = true,
        taperSteps = [] {
    switch (m.schedule) {
      case IntervalSchedule(:final intervalMinutes):
        kind = ScheduleKind.interval;
        everyMinutes = intervalMinutes;
      case FixedTimesSchedule(:final times):
        kind = ScheduleKind.fixedTimes;
        this.times = [...times]..sort();
      case PrnSchedule(:final minimumIntervalMinutes):
        kind = ScheduleKind.prn;
        prnMinutes = minimumIntervalMinutes;
      case TaperSchedule(:final rules):
        kind = ScheduleKind.taper;
        taperSteps.addAll([
          for (final r in rules)
            TaperStepDraft(start: r.startDate, end: r.endDate, minutes: r.intervalMinutes),
        ]);
    }
  }

  final String? id;
  String patientId;

  String name = '';
  String strength = '';
  String dose = '1 tablet';
  String instructions = '';
  bool active = true;

  ScheduleKind kind = ScheduleKind.interval;
  int everyMinutes = 4 * 60;
  List<ClockTime> times = [const ClockTime(8, 0)];
  int prnMinutes = 4 * 60;
  final List<TaperStepDraft> taperSteps;

  bool remindersOn = true;
  int earlyMinutes = 0;
  int overdueRepeatMinutes = ReminderSettings.defaultOverdueRepeatMinutes;
  bool alarm = false;

  /// Until the reminder switch is touched, it follows the schedule type's
  /// default: off for as-needed, on otherwise.
  bool remindersTouched = false;

  bool trackSupply = false;
  String? startingQuantity;
  String perDose = '1';
  String unit = '';
  String? lowAt;

  bool get isNew => id == null;

  /// Alarm mode rings for scheduled doses only.
  bool get alarmAvailable =>
      kind == ScheduleKind.interval || kind == ScheduleKind.fixedTimes;

  void setKind(ScheduleKind k) {
    kind = k;
    if (!remindersTouched) remindersOn = k != ScheduleKind.prn;
  }

  /// What's wrong, field by field; empty when it can be saved.
  Map<String, String> validate() {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'Give the medication a name.';
    if (dose.trim().isEmpty) errors['dose'] = 'Say what one dose is, like "1 tablet".';
    switch (kind) {
      case ScheduleKind.interval when everyMinutes < 1:
        errors['schedule'] = 'Choose how often.';
      case ScheduleKind.prn when prnMinutes < 1:
        errors['schedule'] = 'Choose the shortest gap between doses.';
      case ScheduleKind.fixedTimes when times.isEmpty:
        errors['schedule'] = 'Add at least one time.';
      case ScheduleKind.taper:
        final e = _taperError();
        if (e != null) errors['schedule'] = e;
      default:
        break;
    }
    if (trackSupply) {
      final start = _parse(startingQuantity);
      final each = _parse(perDose);
      if (start == null || start < 0) {
        errors['supply'] = 'Enter how much there is to start with.';
      } else if (each == null || each <= 0) {
        errors['supply'] = 'Enter how much one dose uses.';
      } else if (lowAt != null && lowAt!.trim().isNotEmpty && (_parse(lowAt) ?? -1) < 0) {
        errors['supply'] = 'Enter when to warn, or leave it empty.';
      }
    }
    return errors;
  }

  String? _taperError() {
    if (taperSteps.isEmpty) return 'Add at least one step.';
    final steps = [...taperSteps]..sort((a, b) => a.start.compareTo(b.start));
    for (final (i, s) in steps.indexed) {
      if (s.minutes < 1) return 'Every step needs an interval.';
      if (s.end != null && !s.end!.isAfter(s.start)) {
        return 'A step has to end after it starts.';
      }
      if (i < steps.length - 1) {
        if (s.end == null) return 'Only the last step can be open-ended.';
        if (s.end!.isAfter(steps[i + 1].start)) return 'Two steps overlap.';
      }
    }
    return null;
  }

  /// The medication to save, with [newId] used when it's new. Call only
  /// once [validate] is empty.
  Medication build(String Function() newId) {
    String? opt(String s) => s.trim().isEmpty ? null : s.trim();
    final steps = [...taperSteps]..sort((a, b) => a.start.compareTo(b.start));
    return Medication(
      id: id ?? newId(),
      patientId: patientId,
      name: name.trim(),
      strengthText: opt(strength),
      instructions: opt(instructions),
      active: active,
      defaultDoseText: dose.trim(),
      schedule: switch (kind) {
        ScheduleKind.interval => IntervalSchedule(everyMinutes),
        ScheduleKind.fixedTimes => FixedTimesSchedule(times.toSet().toList()..sort()),
        ScheduleKind.prn => PrnSchedule(prnMinutes),
        ScheduleKind.taper => TaperSchedule([
            for (final s in steps)
              TaperRule(
                  startDate: dateOnly(s.start),
                  endDate: s.end == null ? null : dateOnly(s.end!),
                  intervalMinutes: s.minutes),
          ]),
      },
      reminders: ReminderSettings(
        enabled: remindersOn,
        earlyMinutes: kind == ScheduleKind.prn ? 0 : earlyMinutes,
        overdueRepeatMinutes: overdueRepeatMinutes,
        alarm: alarmAvailable && alarm,
      ),
      inventoryEnabled: trackSupply,
      initialQuantity: trackSupply ? _parse(startingQuantity) : null,
      doseAmount: trackSupply ? _parse(perDose) : null,
      doseUnit: trackSupply ? opt(unit) : null,
      lowSupplyThreshold: trackSupply ? _parse(lowAt) : null,
    );
  }

  static double? _parse(String? s) =>
      s == null ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  static String? _num(double? q) => q == null
      ? null
      : q == q.roundToDouble()
          ? q.toInt().toString()
          : q.toString();
}
