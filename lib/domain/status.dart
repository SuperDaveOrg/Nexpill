import 'dart:math' as math;

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// The one-glance answer for a medication card.
enum MedicationStatusLabel {
  /// Nothing logged yet.
  neverTaken,

  /// Not yet time for the next dose.
  tooEarly,

  /// Due within the due-soon window.
  dueSoon,

  /// Due now, and not yet late.
  eligibleNow,

  /// Past due.
  overdue,

  /// An interval or taper dose so late that half an interval has passed since
  /// it was due — 1.5 intervals since the last dose.
  missed,

  /// An as-needed medication that may be given now.
  availablePrn;

  /// Where a medication in this state goes in a list: what needs doing
  /// first at the top.
  int get urgency => switch (this) {
        missed => 0,
        overdue => 1,
        eligibleNow => 2,
        dueSoon => 3,
        neverTaken => 4,
        tooEarly => 5,
        availablePrn => 6,
      };

  /// Whether the dose is late.
  bool get isLate => this == missed || this == overdue;
}

/// Orders statuses for a list: most urgent first, then soonest due.
int compareByUrgency(MedicationStatus a, MedicationStatus b) {
  final byUrgency = a.label.urgency.compareTo(b.label.urgency);
  if (byUrgency != 0) return byUrgency;
  return a.schedule.nextEligibleAt.compareTo(b.schedule.nextEligibleAt);
}

class MedicationStatus {
  const MedicationStatus({
    required this.label,
    required this.schedule,
    required this.minutesUntilEligible,
  });

  final MedicationStatusLabel label;

  /// The timing the label was drawn from.
  final ScheduleResult schedule;

  /// Minutes until the next dose may be given, rounded up; 0 once it may.
  final int minutesUntilEligible;
}

/// Summarises [medication]'s timing as of [now] into a status for display.
MedicationStatus computeMedicationStatus(
  Medication medication,
  Iterable<DoseEvent> doseEvents,
  DateTime now, {
  int dueSoonWindowMinutes = 20,
}) {
  final result = calculateSchedule(medication, doseEvents, now);
  final minutesUntilEligible =
      math.max(0, ceilMinutes(result.nextEligibleAt.difference(now)));
  final schedule = medication.schedule;
  final overdue = result.overdueByMinutes ?? 0;
  final interval = switch (schedule) {
    IntervalSchedule(:final intervalMinutes) => intervalMinutes,
    TaperSchedule(:final rules) => activeTaperRule(rules, now)?.intervalMinutes,
    _ => null,
  };

  final label = switch (schedule) {
    _ when result.lastGivenAt == null => MedicationStatusLabel.neverTaken,
    PrnSchedule() when result.eligibleNow => MedicationStatusLabel.availablePrn,
    _ when !result.eligibleNow => minutesUntilEligible <= dueSoonWindowMinutes
        ? MedicationStatusLabel.dueSoon
        : MedicationStatusLabel.tooEarly,
    _ when interval != null && overdue >= (interval * 0.5).ceil() =>
      MedicationStatusLabel.missed,
    _ when overdue > 0 => MedicationStatusLabel.overdue,
    _ => MedicationStatusLabel.eligibleNow,
  };

  return MedicationStatus(
    label: label,
    schedule: result,
    minutesUntilEligible: minutesUntilEligible,
  );
}
