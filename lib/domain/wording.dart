import 'package:intl/intl.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/models/medication.dart';

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

/// "2:30 PM".
String clockText(DateTime at) => DateFormat.jm().format(at.toLocal());

/// "Jun 10, 2026, 2:30 PM".
String dateTimeText(DateTime at) =>
    DateFormat.yMMMd().add_jm().format(at.toLocal());

/// "Jun 10, 2026".
String dateText(DateTime day) => DateFormat.yMMMd().format(day);

/// "a, b and c".
String listText(List<String> items) => switch (items.length) {
      0 => '',
      1 => items.single,
      _ => '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}',
    };

/// The schedule in a phrase: "Every 8 hours", "At 08:00 and 20:00",
/// "As needed, at least 6 hours apart", or the taper's steps.
String scheduleText(MedicationSchedule schedule) => switch (schedule) {
      IntervalSchedule(:final intervalMinutes) =>
        'Every ${durationText(intervalMinutes)}',
      FixedTimesSchedule(:final times) =>
        'At ${listText([for (final t in [...times]..sort()) t.toString()])}',
      PrnSchedule(:final minimumIntervalMinutes) =>
        'As needed, at least ${durationText(minimumIntervalMinutes)} apart',
      TaperSchedule(:final rules) => rules.isEmpty
          ? 'Taper with no steps'
          : [
              for (final r in rules)
                '${r.endDate == null ? 'From ${dateText(r.startDate)}' : '${dateText(r.startDate)} to ${dateText(r.endDate!)}'}: '
                    'every ${durationText(r.intervalMinutes)}',
            ].join('; '),
    };

/// The schedule as it stands [now], short enough for a card: a taper shows
/// the step in force and what comes next, not every step.
String scheduleShortText(MedicationSchedule schedule, DateTime now) {
  if (schedule is! TaperSchedule || schedule.rules.isEmpty) {
    return scheduleText(schedule);
  }
  final rules = [...schedule.rules]..sort((a, b) => a.startDate.compareTo(b.startDate));
  final i = rules.indexWhere((r) =>
      !now.isBefore(dateOnly(r.startDate)) &&
      (r.endDate == null || now.isBefore(dateOnly(r.endDate!))));
  if (i < 0) {
    final upcoming = rules.where((r) => now.isBefore(dateOnly(r.startDate)));
    if (upcoming.isEmpty) return 'Taper finished';
    final first = upcoming.first;
    return 'Taper: every ${durationText(first.intervalMinutes)} '
        'from ${DateFormat.MMMd().format(first.startDate)}';
  }
  final r = rules[i];
  final until = r.endDate == null ? '' : ' until ${DateFormat.MMMd().format(r.endDate!)}';
  final next = i + 1 < rules.length
      ? ', then every ${durationText(rules[i + 1].intervalMinutes)}'
      : '';
  return 'Taper: every ${durationText(r.intervalMinutes)}$until$next';
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

/// What a medication card says, in two lines: the one thing to know
/// ("Due in 8 min", "Overdue 25 min"), and when that is.
(String headline, String detail) cardText(
    MedicationStatus status, MedicationSchedule schedule, DateTime now) {
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
  };
}
