import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// How timing is put into words, shared by the screens, the exports and the
/// reminders, so the same thing is always said the same way.

/// "8 hours", "4 hours 45 minutes", "30 minutes", "1 minute".
String durationText(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  String unit(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
  if (h == 0) return unit(m, 'minute');
  if (m == 0) return unit(h, 'hour');
  return '${unit(h, 'hour')} ${unit(m, 'minute')}';
}

/// Whether times read "14:30" rather than "2:30 PM". Follows the phone's
/// 24-hour setting: the app sets it from MediaQuery, and the reminder
/// isolate from the copy kept in Preferences.
bool use24HourClock = false;

/// "2:30 PM", or "14:30" with [use24HourClock].
String clockText(DateTime at) =>
    (use24HourClock ? DateFormat.Hm() : DateFormat.jm()).format(at.toLocal());

/// A time on the clock, "8:00 AM" or "08:00", as [clockText] would show it
/// on any day.
String clockTimeText(ClockTime t) => clockText(t.on(DateTime(2000)));

/// "Skipped the 8:00 AM dose", for a skip logged at the time it was due.
String skippedText(DateTime dueAt) => 'Skipped the ${clockText(dueAt)} dose';

/// "Jun 10, 2026, 2:30 PM", or "Jun 10, 2026, 14:30" with [use24HourClock].
String dateTimeText(DateTime at) {
  final date = DateFormat.yMMMd();
  return (use24HourClock ? date.add_Hm() : date.add_jm()).format(at.toLocal());
}

/// "Jun 10, 2026".
String dateText(DateTime day) => DateFormat.yMMMd().format(day);

/// "a, b and c".
String listText(List<String> items) => switch (items.length) {
      0 => '',
      1 => items.single,
      _ => '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}',
    };

/// The schedule in a phrase: "Every 8 hours", "At 08:00 and 20:00",
/// "As needed, at least 6 hours apart", "Once, Jun 10, 2026 2:30 PM", or
/// the taper's steps.
String scheduleText(MedicationSchedule schedule) => switch (schedule) {
      IntervalSchedule(:final intervalMinutes) =>
        'Every ${durationText(intervalMinutes)}',
      FixedTimesSchedule(:final times) =>
        'At ${listText([for (final t in [...times]..sort()) clockTimeText(t)])}',
      PrnSchedule(:final minimumIntervalMinutes) =>
        'As needed, at least ${durationText(minimumIntervalMinutes)} apart',
      TaperSchedule(:final rules) => rules.isEmpty
          ? 'Taper with no steps'
          : [
              for (final r in rules)
                '${r.endDate == null ? 'From ${dateText(r.startDate)}' : '${dateText(r.startDate)} to ${dateText(r.endDate!)}'}: '
                    'every ${durationText(r.intervalMinutes)}',
            ].join('; '),
      OnceSchedule(:final at) => 'Once, ${dateTimeText(at)}',
    };

/// The schedule as it stands [now], short enough for a card: a taper shows
/// the step the timing engine has in force and what comes next, not every
/// step, and a single dose when it is, "Once, tomorrow at 3:00 PM".
String scheduleShortText(MedicationSchedule schedule, DateTime now) {
  if (schedule case OnceSchedule(:final at)) {
    final when = whenText(at, now);
    return 'Once, ${dateOnly(at.toLocal()) == dateOnly(now) ? 'today at $when' : when}';
  }
  if (schedule is! TaperSchedule || schedule.rules.isEmpty) {
    return scheduleText(schedule);
  }
  if (taperFinished(schedule.rules, now)) return 'Taper finished';
  final r = activeTaperRule(schedule.rules, now)!;
  final every = 'Taper: every ${durationText(r.intervalMinutes)}';
  if (now.isBefore(dateOnly(r.startDate))) {
    return '$every from ${DateFormat.MMMd().format(r.startDate)}';
  }
  final rules = orderedTaperRules(schedule.rules);
  final i = rules.indexOf(r);
  final until = r.endDate == null ? '' : ' until ${DateFormat.MMMd().format(r.endDate!)}';
  final next = i + 1 < rules.length
      ? ', then every ${durationText(rules[i + 1].intervalMinutes)}'
      : '';
  return '$every$until$next';
}

/// One line saying where a medication stands, e.g. "Due at 2:30 PM" or
/// "Overdue by 1 hour 5 minutes".
String statusText(MedicationStatus status) {
  final s = status.schedule;
  return switch (status.label) {
    MedicationStatusLabel.neverTaken => 'Not given yet',
    MedicationStatusLabel.availablePrn => 'Can be given now',
    MedicationStatusLabel.eligibleNow => 'Due now',
    MedicationStatusLabel.dueSoon ||
    MedicationStatusLabel.tooEarly =>
      'Next at ${clockText(s.nextEligibleAt)}',
    MedicationStatusLabel.overdue =>
      'Overdue by ${durationText(s.overdueByMinutes ?? 0)}',
    MedicationStatusLabel.missed =>
      'Missed: was due ${durationText(s.overdueByMinutes ?? 0)} ago',
    MedicationStatusLabel.finished => 'Finished',
  };
}

/// How reminders are set, e.g. "On, 10 minutes early" or "Off".
String remindersText(ReminderSettings r) {
  if (!r.enabled) return 'Off';
  return [
    'On',
    if (r.earlyMinutes > 0) '${durationText(r.earlyMinutes)} early',
    if (r.alarm) 'as an alarm',
  ].join(', ');
}

/// A quantity without a pointless ".0": "21", "2.5".
String quantityText(double q) =>
    q == q.roundToDouble() ? q.toInt().toString() : q.toString();

/// A time relative to [now]'s day: "4:28 PM", "tomorrow at 8:00 AM",
/// "yesterday at 8:00 PM", or "Sep 30 at 8:00 AM".
String whenText(DateTime at, DateTime now) {
  final day = DateTime(at.toLocal().year, at.toLocal().month, at.toLocal().day);
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime.utc(day.year, day.month, day.day)
      .difference(DateTime.utc(today.year, today.month, today.day))
      .inDays;
  final clock = clockText(at);
  return switch (days) {
    0 => clock,
    1 => 'tomorrow at $clock',
    -1 => 'yesterday at $clock',
    _ => '${DateFormat.MMMd().format(day)} at $clock',
  };
}

/// A short span for countdowns: "8 min", "3 hr 12 min", "2 days".
String shortDurationText(int minutes) {
  if (minutes < 60) return '$minutes min';
  if (minutes < 48 * 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }
  return '${minutes ~/ (24 * 60)} days';
}

/// A calendar day heading: "Today", "Yesterday", or "Mon, Sep 28".
String dayHeading(DateTime day, DateTime now) {
  final d = DateTime.utc(day.year, day.month, day.day);
  final t = DateTime.utc(now.year, now.month, now.day);
  return switch (t.difference(d).inDays) {
    0 => 'Today',
    1 => 'Yesterday',
    _ => DateFormat.MMMEd().format(day),
  };
}

/// Why a finished medication has nothing more due: "Taper finished",
/// "Course finished: last day was Jun 14, 2026", "Course finished: all 5
/// doses given", "Single dose logged".
String finishedText(Medication m) => switch (m.course) {
      _ when m.schedule is OnceSchedule => 'Single dose logged',
      EndsAfterDay(:final lastDay) =>
        'Course finished: last day was ${dateText(lastDay)}',
      EndsAfterDoses(:final doses) =>
        'Course finished: ${doses == 1 ? 'its 1 dose' : 'all $doses doses'} given',
      null => 'Taper finished',
    };

/// How long [m]'s course runs, for a summary: "Last day Jun 14, 2026" or
/// "5 doses, 2 given so far". Null for a medication that carries on.
String? courseText(Medication m, Iterable<DoseEvent> doses) => switch (m.course) {
      EndsAfterDay(:final lastDay) => 'Last day ${dateText(lastDay)}',
      EndsAfterDoses(doses: final total) =>
        '${_doses(total)}, ${effectiveDoses(m.id, doses).length} given so far',
      null => null,
    };

/// The same, short enough for a card: "last day Jun 14" or "3 doses left".
String? courseShortText(Medication m, Iterable<DoseEvent> doses) =>
    switch (m.course) {
      EndsAfterDay(:final lastDay) => 'last day ${DateFormat.MMMd().format(lastDay)}',
      EndsAfterDoses(doses: final total) =>
        '${_doses(math.max(0, total - effectiveDoses(m.id, doses).length))} left',
      null => null,
    };

String _doses(int n) => n == 1 ? '1 dose' : '$n doses';

/// What a medication card says, in two lines: the one thing to know
/// ("Due in 8 min", "Overdue 25 min"), and when that is.
(String headline, String detail) cardText(
    MedicationStatus status, Medication medication, DateTime now) {
  final schedule = medication.schedule;
  final s = status.schedule;
  final next = whenText(s.nextEligibleAt, now);
  final late = s.overdueByMinutes ?? 0;
  return switch (status.label) {
    MedicationStatusLabel.neverTaken => s.eligibleNow
        ? ('Not given yet', 'Can be given now')
        : ('Not given yet', 'First due $next'),
    MedicationStatusLabel.availablePrn => ('Can be given now', 'As needed'),
    MedicationStatusLabel.tooEarly => schedule is PrnSchedule
        ? ('Next dose from $next', 'in ${shortDurationText(status.minutesUntilEligible)}')
        : ('Next dose $next', 'in ${shortDurationText(status.minutesUntilEligible)}'),
    MedicationStatusLabel.dueSoon => (
        'Due in ${shortDurationText(status.minutesUntilEligible)}',
        'at $next',
      ),
    MedicationStatusLabel.eligibleNow => ('Due now', 'since $next'),
    MedicationStatusLabel.overdue => (
        'Overdue ${shortDurationText(late)}',
        'was due $next',
      ),
    MedicationStatusLabel.missed => (
        'Missed',
        'was due $next, ${shortDurationText(late)} ago',
      ),
    MedicationStatusLabel.finished => ('Finished', finishedText(medication)),
  };
}

/// A person on their own, as a heading or in a list: their name, or "You"
/// for the phone's owner when they haven't given one.
String personName(Patient p) => p.hasName ? p.displayName : 'You';

/// A person inside a sentence: "for Sam", "for you". The phone's owner is
/// "you" even with a name set; it's them reading.
String personInSentence(Patient p) => p.isSelf ? 'you' : p.displayName;
