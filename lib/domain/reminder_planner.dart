import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// Works out every reminder due over the coming days, so the phone can be
/// given them as alarms up front.
///
/// Pure, no I/O. The rule is simple: a reminder fires at a moment exactly
/// when the timing engine would say, at that moment, that a dose is coming
/// up, due, or overdue. So reminders can never disagree with what the app
/// shows. The plan assumes no more doses are given; every dose logged,
/// every edit, and every app start replans.
///
/// The rules, carried over from the PWA:
/// - Nothing for an inactive medication, one with reminders off, or a
///   patient whose notifications are off.
/// - An early heads-up, if set, before a dose is due; then "due now".
/// - Overdue reminders repeat every `overdueRepeatMinutes` — at most
///   [maxOverdueRepeats] times, and only until the next dose is due.
/// - As-needed medications get only "can be given again", once per dose.
/// - An interval or as-needed medication never given has no reminders:
///   there's nothing to count from.
/// - Everything due for one patient at the same minute is one notification.
class ReminderPlanner {
  const ReminderPlanner({
    this.horizon = const Duration(days: 7),
    this.maxNotifications = 400,
    this.maxOverdueRepeats = 6,
  });

  /// How far ahead to plan. Replanning happens whenever the app is used, so
  /// this only matters if it goes unopened; see [ReminderPlan.refreshNoticeAt].
  final Duration horizon;

  /// Android lets an app hold about 500 alarms; this leaves room to spare.
  final int maxNotifications;

  /// Overdue repeats stop after this many, so a dose that isn't coming
  /// doesn't ring all night.
  final int maxOverdueRepeats;

  ReminderPlan plan(CareSnapshot care, {required DateTime from}) {
    final until = from.add(horizon);
    // Planned a day past the horizon, only to learn whether anything lies
    // beyond it.
    final beyond = until.add(const Duration(days: 1));

    final groups = <(String, DateTime), List<ReminderItem>>{};
    for (final m in care.medications) {
      final patient = care.patient(m.patientId);
      if (patient == null ||
          !patient.notificationsEnabled ||
          !m.active ||
          !m.reminders.enabled) {
        continue;
      }
      for (final item in _medicationReminders(m, care.doses, from, beyond)) {
        final at = _ceilToMinute(item.firesAt);
        groups.putIfAbsent((m.patientId, at), () => []).add(item);
      }
    }

    final all = [
      for (final MapEntry(key: (patientId, at), value: items) in groups.entries)
        PlannedNotification(
          at: at,
          patient: care.patient(patientId)!,
          items: items..sort((a, b) => a.medication.name.compareTo(b.medication.name)),
        ),
    ]..sort((a, b) {
        final byTime = a.at.compareTo(b.at);
        return byTime != 0 ? byTime : a.patient.id.compareTo(b.patient.id);
      });

    final inHorizon = [for (final n in all) if (!n.at.isAfter(until)) n];
    final kept = inHorizon.take(maxNotifications).toList();
    final truncated = kept.length < all.length;

    return ReminderPlan(
      notifications: kept,
      // If reminders would carry on past what's scheduled, ask for the app
      // to be opened before they run out.
      refreshNoticeAt: !truncated
          ? null
          : kept.length < inHorizon.length
              ? kept.last.at
              : until.subtract(const Duration(hours: 12)),
    );
  }

  Iterable<ReminderItem> _medicationReminders(
    Medication m,
    List<DoseEvent> doses,
    DateTime from,
    DateTime until,
  ) sync* {
    final prn = m.schedule is PrnSchedule;
    final early = Duration(minutes: m.reminders.earlyMinutes);
    final repeat = Duration(minutes: m.reminders.overdueRepeatMinutes);

    // Between two change points the engine's answer holds still, so each
    // stretch is one question to it.
    final points = [from, ..._changePoints(m, doses, from, until), until];
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final last = i == points.length - 2;
      final s = calculateSchedule(m, doses, start);
      if (s.lastGivenAt == null &&
          (m.schedule is IntervalSchedule || prn)) {
        continue;
      }
      final due = s.nextEligibleAt;

      // Whether the reminder due at [x] belongs to this stretch and hasn't
      // fired yet. It fires at the next whole minute, so one due a few
      // seconds before [from] is still to come; the first stretch reaches
      // back to catch it.
      bool inStretch(DateTime x) =>
          _ceilToMinute(x).isAfter(from) &&
          (i == 0 || !x.isBefore(start)) &&
          (x.isBefore(end) || (last && x == end));

      if (!prn && early > Duration.zero) {
        final x = due.subtract(early);
        if (inStretch(x)) yield ReminderItem(m, ReminderKind.dueSoon, due, x);
      }
      if (inStretch(due)) {
        yield ReminderItem(
            m, prn ? ReminderKind.available : ReminderKind.dueNow, due, due);
      }
      if (!prn) {
        for (var k = 1; k <= maxOverdueRepeats; k++) {
          final x = due.add(repeat * k);
          if (!x.isBefore(end) && !(last && x == end)) break;
          if (inStretch(x)) {
            yield ReminderItem(m, ReminderKind.overdue, due, x);
          }
        }
      }
    }
  }

  /// Every moment in (from, until) at which the engine's answer for [m] can
  /// change without a new dose: fixed slots coming round, taper steps
  /// starting or ending, and — for a taper never given — each beat of its
  /// rhythm.
  static List<DateTime> _changePoints(
      Medication m, List<DoseEvent> doses, DateTime from, DateTime until) {
    final points = <DateTime>{};
    void add(DateTime t) {
      if (t.isAfter(from) && t.isBefore(until)) points.add(t);
    }

    switch (m.schedule) {
      case FixedTimesSchedule(:final times):
        final first = from.toLocal();
        final days = until.difference(from).inDays + 2;
        for (var d = -1; d <= days; d++) {
          final day = DateTime(first.year, first.month, first.day + d);
          for (final t in times) {
            add(t.on(day));
          }
        }
      case TaperSchedule(:final rules):
        final neverGiven = doses.every((d) => d.medicationId != m.id);
        for (final r in rules) {
          final start = dateOnly(r.startDate);
          add(start);
          if (r.endDate != null) add(dateOnly(r.endDate!));
          if (neverGiven) {
            final step = Duration(minutes: r.intervalMinutes);
            var beat = start;
            if (beat.isBefore(from)) {
              beat = beat.add(step * (from.difference(beat).inMicroseconds ~/
                  step.inMicroseconds));
            }
            final stepEnd = r.endDate == null ? until : dateOnly(r.endDate!);
            for (; beat.isBefore(until) && beat.isBefore(stepEnd); beat = beat.add(step)) {
              add(beat);
            }
          }
        }
      case IntervalSchedule() || PrnSchedule():
        break;
    }
    return points.toList()..sort();
  }
}

DateTime _ceilToMinute(DateTime t) {
  final ms = t.millisecondsSinceEpoch;
  const minute = Duration.millisecondsPerMinute;
  final rounded = (ms + minute - 1) ~/ minute * minute;
  return DateTime.fromMillisecondsSinceEpoch(rounded, isUtc: true);
}

class ReminderPlan {
  const ReminderPlan({required this.notifications, this.refreshNoticeAt});

  final List<PlannedNotification> notifications;

  /// When to post a note asking for Nexpill to be opened, because reminders
  /// run out soon after; null if everything to come is scheduled.
  final DateTime? refreshNoticeAt;
}

enum ReminderKind {
  /// The early heads-up.
  dueSoon,
  dueNow,
  overdue,

  /// An as-needed medication may be given again.
  available,
}

/// One medication's part in a notification.
class ReminderItem {
  const ReminderItem(this.medication, this.kind, this.dueAt, this.firesAt);

  final Medication medication;
  final ReminderKind kind;

  /// When the dose this is about is (or was) due.
  final DateTime dueAt;
  final DateTime firesAt;

  /// Alarm mode rings for doses due or overdue on interval and fixed-time
  /// schedules, as in the PWA.
  bool get rings =>
      medication.reminders.alarm &&
      (kind == ReminderKind.dueNow || kind == ReminderKind.overdue) &&
      (medication.schedule is IntervalSchedule ||
          medication.schedule is FixedTimesSchedule);

  String get phrase => switch (kind) {
        ReminderKind.dueSoon => 'due at ${clockText(dueAt)}',
        ReminderKind.dueNow => 'due now',
        ReminderKind.overdue => 'overdue since ${clockText(dueAt)}',
        ReminderKind.available => 'can be given again',
      };
}

/// One notification: everything due for one patient at one minute.
class PlannedNotification {
  const PlannedNotification({
    required this.at,
    required this.patient,
    required this.items,
  });

  final DateTime at;
  final Patient patient;
  final List<ReminderItem> items;

  bool get rings => items.any((i) => i.rings);

  List<String> get medicationIds => [for (final i in items) i.medication.id];

  String get title => items.length == 1
      ? '${items.single.medication.name} ${items.single.phrase}'
      : '${items.length} medications for ${patient.displayName}';

  String get body => items.length == 1
      ? 'For ${patient.displayName} · ${items.single.medication.defaultDoseText}'
      : [for (final i in items) '${i.medication.name} ${i.phrase}'].join('\n');
}

/// The notification to show again for [medicationIds] after a snooze,
/// described as things stand at [now].
PlannedNotification? snoozedNotification(
  CareSnapshot care,
  List<String> medicationIds, {
  required DateTime now,
  required DateTime at,
}) {
  final items = <ReminderItem>[];
  Patient? patient;
  for (final id in medicationIds) {
    final m = care.medication(id);
    if (m == null || !m.active) continue;
    patient ??= care.patient(m.patientId);
    final s = calculateSchedule(m, care.doses, now);
    final kind = m.schedule is PrnSchedule
        ? ReminderKind.available
        : !s.eligibleNow
            ? ReminderKind.dueSoon
            : (s.overdueByMinutes ?? 0) > 0
                ? ReminderKind.overdue
                : ReminderKind.dueNow;
    items.add(ReminderItem(m, kind, s.nextEligibleAt, at));
  }
  if (patient == null || items.isEmpty) return null;
  return PlannedNotification(at: at, patient: patient, items: items);
}
