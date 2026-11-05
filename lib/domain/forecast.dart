import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// One dose a forecast expects.
class ForecastDose {
  const ForecastDose(this.medication, this.at, {required this.dueNow});

  final Medication medication;

  /// When it's due. Before the forecast's start for a dose already late.
  final DateTime at;

  /// Due, or late, as the forecast starts.
  final bool dueNow;
}

class DoseForecast {
  const DoseForecast({required this.doses, required this.withoutSetTime});

  /// Soonest first; at the same moment, by medication name.
  final List<ForecastDose> doses;

  /// Medications still in use that can't be given a time: as-needed ones,
  /// and interval ones never given, which have nothing to count from.
  final List<Medication> withoutSetTime;
}

/// What [patientId] has to take from [from] up to, not including, [until]:
/// what to load a pill dispenser with.
///
/// Pure, no I/O. It asks [calculateSchedule] what's due, supposes that dose
/// is given, and asks again, so it holds no timing rules of its own. Those
/// supposed doses are never stored. Unlike [ReminderPlanner], which supposes
/// no more doses are given, it needs them to see past the next dose; and it
/// counts medications with reminders off, whose doses are still taken.
///
/// A dose already late is supposed given now, the soonest it can be. An
/// interval then counts from now. A fixed-time medication carries on from
/// the slot that was due, so a late dose doesn't drop the next slot.
DoseForecast forecastDoses(
  CareSnapshot care,
  String patientId, {
  required DateTime from,
  required DateTime until,
}) {
  final doses = <ForecastDose>[];
  final withoutSetTime = <Medication>[];
  for (final m in care.medicationsFor(patientId)) {
    if (!m.active || calculateSchedule(m, care.doses, from).finished) continue;
    final noStart = m.schedule is IntervalSchedule &&
        latestEntry(m.id, care.doses) == null;
    if (m.schedule is PrnSchedule || noStart) {
      withoutSetTime.add(m);
    } else {
      doses.addAll(_projected(m, care.doses, from, until));
    }
  }
  doses.sort((a, b) {
    final byTime = a.at.compareTo(b.at);
    return byTime != 0
        ? byTime
        : a.medication.name.compareTo(b.medication.name);
  });
  withoutSetTime.sort((a, b) => a.name.compareTo(b.name));
  return DoseForecast(doses: doses, withoutSetTime: withoutSetTime);
}

Iterable<ForecastDose> _projected(
  Medication m,
  List<DoseEvent> doses,
  DateTime from,
  DateTime until,
) sync* {
  final history = [for (final d in doses) if (d.medicationId == m.id) d];
  var clock = from;
  DateTime? previous;
  while (clock.isBefore(until)) {
    final s = calculateSchedule(m, history, clock);
    if (s.finished) return;
    final due = s.nextEligibleAt;

    // Not due yet. A taper step or the end of a course on the way can change
    // that answer, so ask again there, or at the due time if that's sooner.
    if (due.isAfter(clock)) {
      final change = ReminderPlanner.changePoints(m, history, clock, until).firstOrNull;
      clock = change != null && change.isBefore(due) ? change : due;
      continue;
    }

    // A schedule with nothing to count by says "now" for ever.
    if (previous != null && !due.isAfter(previous)) return;
    previous = due;

    yield ForecastDose(m, due, dueNow: !due.isAfter(from));
    history.add(DoseEvent(
      id: 'forecast-${history.length}',
      medicationId: m.id,
      givenAt: m.schedule is FixedTimesSchedule ? due : clock,
    ));
  }
}
