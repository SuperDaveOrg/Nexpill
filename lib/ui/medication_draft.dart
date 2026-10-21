import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/medication.dart';

enum ScheduleKind { interval, fixedTimes, prn, taper }

/// How long a medication runs: until stopped, through a last day, or for a
/// number of doses.
enum CourseKind { ongoing, lastDay, doses }

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
        givenSoFar = 0,
        courseLastDay = _aWeekFrom(today),
        taperSteps = [TaperStepDraft(start: dateOnly(today))];

  /// [givenSoFar] is how many of [m]'s doses count, so a course can be set
  /// as the doses still to give.
  MedicationDraft.of(Medication m, {this.givenSoFar = 0})
      : id = m.id,
        patientId = m.patientId,
        name = m.name,
        strength = m.strengthText ?? '',
        purpose = m.purpose ?? '',
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
        courseLastDay = switch (m.course) {
          EndsAfterDay(:final lastDay) => lastDay,
          _ => _aWeekFrom(DateTime.now()),
        },
        taperSteps = [] {
    switch (m.course) {
      case EndsAfterDay():
        courseKind = CourseKind.lastDay;
      case EndsAfterDoses(:final doses):
        courseKind = CourseKind.doses;
        dosesLeft = '${doses - givenSoFar < 0 ? 0 : doses - givenSoFar}';
      case null:
        break;
    }
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
  String purpose = '';
  String dose = strings.defaultDose;
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

  CourseKind courseKind = CourseKind.ongoing;
  DateTime courseLastDay;

  /// For a course of doses: how many are still to give.
  String dosesLeft = '';

  /// Doses of this medication already given that count.
  final int givenSoFar;

  bool get isNew => id == null;

  /// A taper's steps say when it ends, so it has no separate course.
  bool get courseAvailable => kind != ScheduleKind.taper;

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
    if (name.trim().isEmpty) errors['name'] = strings.errorName;
    if (dose.trim().isEmpty) errors['dose'] = strings.errorDose;
    switch (kind) {
      case ScheduleKind.interval when everyMinutes < 1:
        errors['schedule'] = strings.errorHowOften;
      case ScheduleKind.prn when prnMinutes < 1:
        errors['schedule'] = strings.errorShortestGap;
      case ScheduleKind.fixedTimes when times.isEmpty:
        errors['schedule'] = strings.errorAddTime;
      case ScheduleKind.taper:
        final e = _taperError();
        if (e != null) errors['schedule'] = e;
      default:
        break;
    }
    if (courseAvailable && courseKind == CourseKind.doses) {
      final left = int.tryParse(dosesLeft.trim());
      // Once doses have been given, 0 left means the course is complete.
      if (left == null || left < (givenSoFar > 0 ? 0 : 1)) {
        errors['course'] = givenSoFar > 0
            ? strings.errorDosesStillToGive
            : strings.errorCourseDoses;
      }
    }
    if (trackSupply) {
      final start = _parse(startingQuantity);
      final each = _parse(perDose);
      if (start == null || start < 0) {
        errors['supply'] = strings.errorStartingSupply;
      } else if (each == null || each <= 0) {
        errors['supply'] = strings.errorPerDose;
      } else if (lowAt != null && lowAt!.trim().isNotEmpty && (_parse(lowAt) ?? -1) < 0) {
        errors['supply'] = strings.errorLowAt;
      }
    }
    return errors;
  }

  String? _taperError() {
    if (taperSteps.isEmpty) return strings.errorNoSteps;
    final steps = [...taperSteps]..sort((a, b) => a.start.compareTo(b.start));
    for (final (i, s) in steps.indexed) {
      if (s.minutes < 1) return strings.errorStepInterval;
      if (s.end != null && !s.end!.isAfter(s.start)) {
        return strings.errorStepEnds;
      }
      if (i < steps.length - 1) {
        if (s.end == null) return strings.errorOpenEnded;
        if (s.end!.isAfter(steps[i + 1].start)) return strings.errorStepsOverlap;
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
      purpose: opt(purpose),
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
      course: !courseAvailable
          ? null
          : switch (courseKind) {
              CourseKind.ongoing => null,
              CourseKind.lastDay => EndsAfterDay(dateOnly(courseLastDay)),
              CourseKind.doses =>
                EndsAfterDoses(givenSoFar + int.parse(dosesLeft.trim())),
            },
    );
  }

  /// The last day of a week's course starting on [today]: a calendar day,
  /// so a daylight-saving change can't shift it.
  static DateTime _aWeekFrom(DateTime today) =>
      DateTime(today.year, today.month, today.day + 6);

  static double? _parse(String? s) =>
      s == null ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  static String? _num(double? q) => q == null ? null : quantityText(q);
}
