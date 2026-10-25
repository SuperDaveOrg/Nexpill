import 'dart:math' as math;
import 'dart:ui' show Locale;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/dose_history.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// How timing is put into words, shared by the screens, the exports and the
/// reminders, so the same thing is always said the same way.

/// The app's words, in the language on screen. Like [use24HourClock], the
/// app sets it with [useLanguage] and the reminder isolate from the copy
/// kept in Preferences. English until then, as in tests.
AppLocalizations strings = lookupAppLocalizations(const Locale('en'));

/// Switches [strings], and the way dates are written, to [locale], which
/// must be one of [AppLocalizations.supportedLocales].
Future<void> useLanguage(Locale locale) async {
  strings = lookupAppLocalizations(locale);
  Intl.defaultLocale = strings.localeName;
  await initializeDateFormatting(strings.localeName);
}

/// "8 hours", "4 hours 45 minutes", "30 minutes", "1 minute".
String durationText(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return strings.durationMinutes(m);
  if (m == 0) return strings.durationHours(h);
  return strings.durationHoursMinutes(
      strings.durationHours(h), strings.durationMinutes(m));
}

/// Whether times read "14:30" rather than "2:30 PM". Follows the phone's
/// 24-hour setting: the app sets it from MediaQuery, and the reminder
/// isolate from the copy kept in Preferences.
bool use24HourClock = false;

/// The clock as the phone has it set. A language whose usual clock is
/// 24-hour still gets 12 hours on a phone set that way.
DateFormat _clock() {
  if (use24HourClock) return DateFormat.Hm();
  final usual = DateFormat.jm();
  return usual.pattern!.contains('a') ? usual : DateFormat('h:mm a');
}

/// "2:30 PM", or "14:30" with [use24HourClock].
String clockText(DateTime at) => _clock().format(at.toLocal());

/// A time on the clock, "8:00 AM" or "08:00", as [clockText] would show it
/// on any day.
String clockTimeText(ClockTime t) => clockText(t.on(DateTime(2000)));

/// "Skipped the 8:00 AM dose", for a skip logged at the time it was due.
String skippedText(DateTime dueAt) => strings.skippedDose(clockText(dueAt));

/// "Jun 10, 2026, 2:30 PM", or "Jun 10, 2026, 14:30" with [use24HourClock].
String dateTimeText(DateTime at) =>
    DateFormat.yMMMd().addPattern(_clock().pattern).format(at.toLocal());

/// "Jun 10, 2026".
String dateText(DateTime day) => DateFormat.yMMMd().format(day);

/// "a, b and c".
String listText(List<String> items) => switch (items.length) {
      0 => '',
      1 => items.single,
      _ => strings.listAnd(
          items.sublist(0, items.length - 1).join(strings.listSeparator),
          items.last),
    };

/// The schedule in a phrase: "Every 8 hours", "At 08:00 and 20:00",
/// "As needed, at least 6 hours apart", "Once, Jun 10, 2026 2:30 PM", or
/// the taper's steps.
String scheduleText(MedicationSchedule schedule) => switch (schedule) {
      IntervalSchedule(:final intervalMinutes) =>
        strings.scheduleEvery(durationText(intervalMinutes)),
      FixedTimesSchedule(:final times) => strings.scheduleAt(
          listText([for (final t in [...times]..sort()) clockTimeText(t)])),
      PrnSchedule(:final minimumIntervalMinutes) =>
        strings.scheduleAsNeeded(durationText(minimumIntervalMinutes)),
      TaperSchedule(:final rules) => rules.isEmpty
          ? strings.taperNoSteps
          : [
              for (final r in rules)
                strings.taperStep(
                    r.endDate == null
                        ? strings.taperStepFrom(dateText(r.startDate))
                        : strings.taperStepRange(
                            dateText(r.startDate), dateText(r.endDate!)),
                    durationText(r.intervalMinutes)),
            ].join('; '),
      OnceSchedule(:final at) => strings.scheduleOnce(dateTimeText(at)),
    };

/// The schedule as it stands [now], short enough for a card: a taper shows
/// the step the timing engine has in force and what comes next, not every
/// step, and a single dose when it is, "Once, tomorrow at 3:00 PM".
String scheduleShortText(MedicationSchedule schedule, DateTime now) {
  if (schedule case OnceSchedule(:final at)) {
    return dateOnly(at.toLocal()) == dateOnly(now)
        ? strings.scheduleOnceToday(clockText(at))
        : strings.scheduleOnce(whenText(at, now));
  }
  if (schedule is! TaperSchedule || schedule.rules.isEmpty) {
    return scheduleText(schedule);
  }
  if (taperFinished(schedule.rules, now)) return strings.taperFinished;
  final r = activeTaperRule(schedule.rules, now)!;
  var text = strings.taperShortEvery(durationText(r.intervalMinutes));
  if (now.isBefore(dateOnly(r.startDate))) {
    return strings.taperShortFrom(text, DateFormat.MMMd().format(r.startDate));
  }
  final rules = orderedTaperRules(schedule.rules);
  final i = rules.indexOf(r);
  if (r.endDate != null) {
    text = strings.taperShortUntil(text, DateFormat.MMMd().format(r.endDate!));
  }
  if (i + 1 < rules.length) {
    text = strings.taperShortThen(text, durationText(rules[i + 1].intervalMinutes));
  }
  return text;
}

/// One line saying where a medication stands, e.g. "Due at 2:30 PM" or
/// "Overdue by 1 hour 5 minutes".
String statusText(MedicationStatus status) {
  final s = status.schedule;
  return switch (status.label) {
    MedicationStatusLabel.neverTaken => strings.statusNotGiven,
    MedicationStatusLabel.availablePrn => strings.statusCanGiveNow,
    MedicationStatusLabel.eligibleNow => strings.statusDueNow,
    MedicationStatusLabel.dueSoon ||
    MedicationStatusLabel.tooEarly =>
      strings.statusNextAt(clockText(s.nextEligibleAt)),
    MedicationStatusLabel.overdue =>
      strings.statusOverdueBy(durationText(s.overdueByMinutes ?? 0)),
    MedicationStatusLabel.missed =>
      strings.statusMissed(durationText(s.overdueByMinutes ?? 0)),
    MedicationStatusLabel.finished => strings.statusFinished,
  };
}

/// How reminders are set, e.g. "On, 10 minutes early" or "Off".
String remindersText(ReminderSettings r) {
  if (!r.enabled) return strings.remindersOff;
  return [
    strings.remindersOn,
    if (r.earlyMinutes > 0) strings.remindersEarly(durationText(r.earlyMinutes)),
    if (r.alarm) strings.remindersAlarm,
  ].join(strings.listSeparator);
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
    0 => strings.whenToday(clock),
    1 => strings.whenTomorrow(clock),
    -1 => strings.whenYesterday(clock),
    _ => strings.whenOnDay(DateFormat.MMMd().format(day), clock),
  };
}

/// A short span for countdowns: "8 min", "3 hr 12 min", "2 days".
String shortDurationText(int minutes) {
  if (minutes < 60) return strings.shortMinutes(minutes);
  if (minutes < 48 * 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? strings.shortHours(h) : strings.shortHoursMinutes(h, m);
  }
  return strings.shortDays(minutes ~/ (24 * 60));
}

/// A calendar day heading: "Today", "Yesterday", or "Mon, Sep 28".
String dayHeading(DateTime day, DateTime now) {
  final d = DateTime.utc(day.year, day.month, day.day);
  final t = DateTime.utc(now.year, now.month, now.day);
  return switch (t.difference(d).inDays) {
    0 => strings.today,
    1 => strings.yesterday,
    _ => DateFormat.MMMEd().format(day),
  };
}

/// Why a finished medication has nothing more due: "Taper finished",
/// "Course finished: last day was Jun 14, 2026", "Course finished: all 5
/// doses given", "Single dose logged".
String finishedText(Medication m) => switch (m.course) {
      _ when m.schedule is OnceSchedule => strings.singleDoseFinished,
      EndsAfterDay(:final lastDay) =>
        strings.courseFinishedLastDay(dateText(lastDay)),
      EndsAfterDoses(:final doses) => strings.courseFinishedDoses(doses),
      null => strings.taperFinished,
    };

/// How long [m]'s course runs, for a summary: "Last day Jun 14, 2026" or
/// "5 doses, 2 given so far". Null for a medication that carries on.
String? courseText(Medication m, Iterable<DoseEvent> doses) => switch (m.course) {
      EndsAfterDay(:final lastDay) => strings.courseLastDay(dateText(lastDay)),
      EndsAfterDoses(doses: final total) =>
        strings.courseDosesSoFar(total, effectiveDoses(m.id, doses).length),
      null => null,
    };

/// The same, short enough for a card: "last day Jun 14" or "3 doses left".
String? courseShortText(Medication m, Iterable<DoseEvent> doses) =>
    switch (m.course) {
      EndsAfterDay(:final lastDay) =>
        strings.courseShortLastDay(DateFormat.MMMd().format(lastDay)),
      EndsAfterDoses(doses: final total) => strings.courseDosesLeft(
          math.max(0, total - effectiveDoses(m.id, doses).length)),
      null => null,
    };

/// What a medication card says, in two lines: the one thing to know
/// ("Due in 8 min", "Overdue 25 min"), and when that is.
(String headline, String detail) cardText(
    MedicationStatus status, Medication medication, DateTime now) {
  final schedule = medication.schedule;
  final s = status.schedule;
  final next = whenText(s.nextEligibleAt, now);
  final late = shortDurationText(s.overdueByMinutes ?? 0);
  final until = shortDurationText(status.minutesUntilEligible);
  return switch (status.label) {
    MedicationStatusLabel.neverTaken => s.eligibleNow
        ? (strings.statusNotGiven, strings.statusCanGiveNow)
        : (strings.statusNotGiven, strings.cardFirstDue(next)),
    MedicationStatusLabel.availablePrn =>
      (strings.statusCanGiveNow, strings.cardAsNeeded),
    MedicationStatusLabel.tooEarly => schedule is PrnSchedule
        ? (strings.cardAvailableFrom(next), strings.cardIn(until))
        : (strings.cardNextDose(next), strings.cardIn(until)),
    MedicationStatusLabel.dueSoon =>
      (strings.cardDueIn(until), strings.cardAt(next)),
    MedicationStatusLabel.eligibleNow =>
      (strings.statusDueNow, strings.cardSince(next)),
    MedicationStatusLabel.overdue =>
      (strings.cardOverdue(late), strings.cardWasDue(next)),
    MedicationStatusLabel.missed =>
      (strings.cardMissed, strings.cardMissedWasDue(next, late)),
    MedicationStatusLabel.finished =>
      (strings.statusFinished, finishedText(medication)),
  };
}

/// A person on their own, as a heading or in a list: their name, or "You"
/// for the phone's owner when they haven't given one.
String personName(Patient p) => p.hasName ? p.displayName : strings.personYou;

/// A person after "for": "for Sam", "for you". The phone's owner is "you"
/// even with a name set; it's them reading. Other sentences about the owner
/// have their own wording, since languages build them differently.
String personInSentence(Patient p) =>
    p.isSelf ? strings.personYouAfterFor : p.displayName;
