import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// When a medication is next due, measured against a moment in time.
///
/// Pure, no I/O. Everything the app says about timing — the status on a card,
/// the reminders, the printed summary — comes from here, so the UI never
/// works out timing rules on its own.
class ScheduleResult {
  const ScheduleResult({
    required this.lastGivenAt,
    required this.nextEligibleAt,
    required this.eligibleNow,
    required this.tooEarlyByMinutes,
    required this.overdueByMinutes,
    required this.reminderAt,
    this.finished = false,
  });

  /// The most recent dose that still counts, or null if none.
  final DateTime? lastGivenAt;

  /// When the next dose may be given. For a fixed-time schedule, the most
  /// recent slot that has come round.
  final DateTime nextEligibleAt;

  /// True from [nextEligibleAt] onwards, including that exact instant.
  final bool eligibleNow;

  /// Minutes left until [nextEligibleAt], rounded up; null once eligible.
  final int? tooEarlyByMinutes;

  /// Minutes since [nextEligibleAt], rounded down; null before then, at that
  /// exact instant, and always for as-needed medications, which are never
  /// overdue.
  final int? overdueByMinutes;

  /// When the first reminder for [nextEligibleAt] is due — the early heads-up,
  /// or the due time itself without one — or null when reminders are off.
  final DateTime? reminderAt;

  /// A course that has ended, or a taper whose last step has: nothing more
  /// is due, so nothing is overdue and there's no reminder. [nextEligibleAt]
  /// is when it finished. See [finishesAt].
  final bool finished;
}

/// Works out [medication]'s timing as of [now] from its dose history.
///
/// [doseEvents] may hold any medication's doses; only this one's count.
ScheduleResult calculateSchedule(
  Medication medication,
  Iterable<DoseEvent> doseEvents,
  DateTime now,
) {
  final latest = latestDose(medication.id, doseEvents);
  final end = finishesAt(medication, doseEvents);
  if (end != null && !now.isBefore(end)) {
    return ScheduleResult(
      lastGivenAt: latest?.givenAt,
      nextEligibleAt: end,
      eligibleNow: true,
      tooEarlyByMinutes: null,
      overdueByMinutes: null,
      reminderAt: null,
      finished: true,
    );
  }
  final due = _dueAfterSkips(medication, doseEvents, latest, now);
  final sinceDue = now.difference(due);
  final eligibleNow = !sinceDue.isNegative;

  return ScheduleResult(
    lastGivenAt: latest?.givenAt,
    nextEligibleAt: due,
    eligibleNow: eligibleNow,
    tooEarlyByMinutes: eligibleNow ? null : ceilMinutes(-sinceDue),
    overdueByMinutes: medication.schedule is PrnSchedule || sinceDue <= Duration.zero
        ? null
        : floorMinutes(sinceDue),
    reminderAt: _reminderAt(due, medication.reminders),
  );
}

/// When [medication] finishes by itself: at the end of its course's last
/// day, at the dose that completes its course, or when a taper's last step
/// ends — whichever comes first. Null if none of those applies, or the
/// doses that would complete the course haven't all been given.
///
/// [doseEvents] may hold any medication's doses; only this one's count.
DateTime? finishesAt(Medication medication, Iterable<DoseEvent> doseEvents) {
  final ends = [
    if (medication.schedule case TaperSchedule(:final rules)) ?taperEndsAt(rules),
    if (medication.course case final course?) ?_courseEndsAt(course, medication.id, doseEvents),
  ];
  return ends.isEmpty ? null : ends.reduce((a, b) => a.isBefore(b) ? a : b);
}

DateTime? _courseEndsAt(
    CourseEnd course, String medicationId, Iterable<DoseEvent> doseEvents) {
  switch (course) {
    case EndsAfterDay(:final lastDay):
      return DateTime(lastDay.year, lastDay.month, lastDay.day + 1);
    case EndsAfterDoses(:final doses):
      final given = effectiveDoses(medicationId, doseEvents)
        ..sort((a, b) {
          final byTime = a.givenAt.compareTo(b.givenAt);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
      return doses >= 1 && given.length >= doses ? given[doses - 1].givenAt : null;
  }
}

/// When [medication] is next due, counting a skipped dose as if it had been
/// given on time — but only a skip of a dose the last one given hasn't
/// already covered. So a dose given after all, even before the time of a
/// skip logged ahead, is what the next one counts from. As-needed doses are
/// never due, so there's nothing to skip.
DateTime _dueAfterSkips(Medication medication, Iterable<DoseEvent> doseEvents,
    DoseEvent? latest, DateTime now) {
  final schedule = medication.schedule;
  final fromGiven = _nextEligibleAt(schedule, latest, now);
  if (schedule is PrnSchedule) return fromGiven;
  final skip = latestSkip(medication.id, doseEvents);
  if (skip == null) return fromGiven;
  if (latest != null && skip.givenAt.isBefore(fromGiven)) return fromGiven;
  return _nextEligibleAt(schedule, skip, now);
}

DateTime _nextEligibleAt(
    MedicationSchedule schedule, DoseEvent? latest, DateTime now) {
  return switch (schedule) {
    // With nothing given yet, a dose can be given straight away.
    IntervalSchedule(:final intervalMinutes) =>
      latest?.givenAt.add(Duration(minutes: intervalMinutes)) ?? now,
    PrnSchedule(:final minimumIntervalMinutes) =>
      latest?.givenAt.add(Duration(minutes: minimumIntervalMinutes)) ?? now,
    FixedTimesSchedule(:final times) => _fixedDue(times, latest, now),
    TaperSchedule(:final rules) => _taperDue(rules, latest, now),
  };
}

/// The slot the medication is due at.
///
/// Each dose counts for the slot nearest to when it was given, so with slots
/// at 08:00, 12:00 and 20:00 a dose at 07:50 or 08:20 is the 08:00 dose.
/// The medication is then due at the slot after that one — unless a later
/// slot has already come round without a dose, in which case it's due (and
/// overdue) from that slot. A missed slot is never made up: once the next
/// dose is given, the one before is simply gone.
///
/// Only the latest dose matters, as for intervals. With nothing given yet,
/// the most recent slot is due.
DateTime _fixedDue(List<ClockTime> times, DoseEvent? latest, DateTime now) {
  if (times.isEmpty) return now;
  final current = _latestSlot(times, now);
  if (latest == null) return current;

  final given = latest.givenAt;
  final slots = _slotsAround(times, given);
  // The last slot at or before the dose, or the one after if that's nearer.
  // Exactly halfway counts for the later slot.
  var i = slots.lastIndexWhere((slot) => !slot.isAfter(given));
  if (slots[i + 1].difference(given) <= given.difference(slots[i])) i++;
  final next = slots[i + 1];

  return next.isAfter(current) ? next : current;
}

/// The most recent slot at or before [now], looking back into yesterday
/// before the first slot of the day.
DateTime _latestSlot(List<ClockTime> times, DateTime now) {
  final local = now.toLocal();
  final slots = _slotsAround(times, local);
  return slots.lastWhere((slot) => !slot.isAfter(local));
}

/// Every slot from the day before [at] to two days after, in order: always
/// at least one slot before [at] and two after it.
List<DateTime> _slotsAround(List<ClockTime> times, DateTime at) {
  final day = at.toLocal();
  final daily = times.toSet().toList()..sort();
  return [
    for (var d = -1; d <= 2; d++)
      for (final time in daily)
        time.on(DateTime(day.year, day.month, day.day + d)),
  ];
}

DateTime _taperDue(List<TaperRule> rules, DoseEvent? latest, DateTime now) {
  final rule = activeTaperRule(rules, now);
  if (rule == null) return now;
  final start = _ruleBoundary(rule.startDate);
  final interval = Duration(minutes: rule.intervalMinutes);

  // Nothing given yet: due on the step's own rhythm, counted from its start.
  if (latest == null) return _latestBeat(start, interval, now);

  // A dose from before this step started doesn't hold the new step back.
  final from = latest.givenAt.isAfter(start) ? latest.givenAt : start;
  return from.add(interval);
}

/// A taper's steps in the order they run: by start date, and of two steps
/// starting the same day, the one listed first.
List<TaperRule> orderedTaperRules(List<TaperRule> rules) {
  final sorted = rules.indexed.toList()
    ..sort((a, b) {
      final byStart = a.$2.startDate.compareTo(b.$2.startDate);
      return byStart != 0 ? byStart : a.$1 - b.$1;
    });
  return [for (final (_, rule) in sorted) rule];
}

/// When the taper's last step ends, after which no more doses are due; null
/// if a step is open-ended, or there are no steps.
DateTime? taperEndsAt(List<TaperRule> rules) {
  if (rules.isEmpty || rules.any((r) => r.endDate == null)) return null;
  return _ruleBoundary(
      rules.map((r) => r.endDate!).reduce((a, b) => a.isAfter(b) ? a : b));
}

/// Whether the taper's last step has ended by [now].
bool taperFinished(List<TaperRule> rules, DateTime now) {
  final end = taperEndsAt(rules);
  return end != null && !now.isBefore(end);
}

/// The step in force at [now]; before the first step, the first; after the
/// last has ended or in a gap between steps, the one that starts last. (Once
/// the last step has ended the taper is [taperFinished] and nothing is due.)
TaperRule? activeTaperRule(List<TaperRule> rules, DateTime now) {
  if (rules.isEmpty) return null;
  final ordered = orderedTaperRules(rules);

  for (final rule in ordered) {
    final end = rule.endDate;
    if (!now.isBefore(_ruleBoundary(rule.startDate)) &&
        (end == null || now.isBefore(_ruleBoundary(end)))) {
      return rule;
    }
  }
  if (now.isBefore(_ruleBoundary(ordered.first.startDate))) {
    return ordered.first;
  }
  return ordered.last;
}

/// The instant a taper step's calendar day begins: local midnight, so a step
/// "from 5 June" starts when 5 June does on the phone's clock.
DateTime _ruleBoundary(DateTime day) => dateOnly(day);

/// The last multiple of [interval] after [anchor] that is at or before [now];
/// [anchor] itself if [now] hasn't reached it.
DateTime _latestBeat(DateTime anchor, Duration interval, DateTime now) {
  if (!now.isAfter(anchor)) return anchor;
  final beats = now.difference(anchor).inMicroseconds ~/ interval.inMicroseconds;
  return anchor.add(interval * beats);
}

DateTime? _reminderAt(DateTime due, ReminderSettings settings) {
  if (!settings.enabled) return null;
  return due.subtract(Duration(minutes: settings.earlyMinutes));
}
