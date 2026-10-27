import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// A whole number of hours, inside bigger phrases: 'Every 8 hours' on the card and in the summary, '10 minutes early' in the reminder summary. Also the first half of durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String durationHours(int count);

  /// A whole number of minutes, inside bigger phrases: 'Every 30 minutes', 'On, 10 minutes early'. Also the second half of durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String durationMinutes(int count);

  /// A duration with both parts: {hours} is durationHours and {minutes} is durationMinutes, e.g. '4 hours 45 minutes'.
  ///
  /// In en, this message translates to:
  /// **'{hours} {minutes}'**
  String durationHoursMinutes(String hours, String minutes);

  /// Confirmation shown after a dose was skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped the {time} dose'**
  String skippedDose(String time);

  /// Joins the last item of a list to the rest, 'a, b and c': {items} is the earlier items already joined with listSeparator, {last} the final one. Used for 'At 08:00 and 20:00'.
  ///
  /// In en, this message translates to:
  /// **'{items} and {last}'**
  String listAnd(String items, String last);

  /// The separator between list items before the last one ('a, b and c'), and between the parts of the reminder summary ('On, 10 minutes early, as an alarm'). Keep the trailing space if your language uses one.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// Schedule of an interval medication, on the card, in the summary and under a stopped medication: a dose every {duration}, e.g. 'Every 8 hours'. {duration} is a duration… message.
  ///
  /// In en, this message translates to:
  /// **'Every {duration}'**
  String scheduleEvery(String duration);

  /// Schedule of a set-times medication: {times} is a list of clock times, e.g. 'At 08:00 and 20:00'.
  ///
  /// In en, this message translates to:
  /// **'At {times}'**
  String scheduleAt(String times);

  /// Schedule of an as-needed medication: {duration} is the minimum gap between doses. Allowed when the gap has passed, never required.
  ///
  /// In en, this message translates to:
  /// **'As needed, at least {duration} apart'**
  String scheduleAsNeeded(String duration);

  /// Schedule line for a taper whose list of steps is empty. The editor refuses to save one, so this is rarely seen.
  ///
  /// In en, this message translates to:
  /// **'Taper with no steps'**
  String get taperNoSteps;

  /// In a taper summary: a step that starts on {date} and has no end date.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String taperStepFrom(String date);

  /// In a taper summary: a step that runs from {from} to {until}, both dates. The open-ended form is taperStepFrom.
  ///
  /// In en, this message translates to:
  /// **'{from} to {until}'**
  String taperStepRange(String from, String until);

  /// One step in a taper summary: {when} is taperStepFrom or taperStepRange, {duration} the gap between doses during it, e.g. 'Jun 1, 2026 to Jun 7, 2026: every 8 hours'. Steps are joined with semicolons.
  ///
  /// In en, this message translates to:
  /// **'{when}: every {duration}'**
  String taperStep(String when, String duration);

  /// Card detail under 'Finished', the card's schedule line, and the summary status: the taper's last step has ended, so nothing more is due.
  ///
  /// In en, this message translates to:
  /// **'Taper finished'**
  String get taperFinished;

  /// Schedule of a single dose: {when} is its date and time ('Once, Jun 10, 2026, 2:30 PM') or, on the card, one of the when… messages ('Once, tomorrow at 3:00 PM').
  ///
  /// In en, this message translates to:
  /// **'Once, {when}'**
  String scheduleOnce(String when);

  /// Card schedule line for a single dose due today: {time} is a clock time.
  ///
  /// In en, this message translates to:
  /// **'Once, today at {time}'**
  String scheduleOnceToday(String time);

  /// Card detail under 'Finished' and summary status for a single dose that has been given or skipped: nothing more to give.
  ///
  /// In en, this message translates to:
  /// **'Single dose logged'**
  String get singleDoseFinished;

  /// Card schedule line for a taper: the gap between doses in the step currently in force, e.g. 'Taper: every 8 hours'. The other taperShort… messages wrap this text.
  ///
  /// In en, this message translates to:
  /// **'Taper: every {duration}'**
  String taperShortEvery(String duration);

  /// Card schedule line for a taper whose first step hasn't started: {text} is taperShortEvery, {date} the step's first day (month and day), e.g. 'Taper: every 8 hours from Jun 1'.
  ///
  /// In en, this message translates to:
  /// **'{text} from {date}'**
  String taperShortFrom(String text, String date);

  /// Card schedule line for a taper: {text} is taperShortEvery, {date} the current step's last day (month and day), e.g. 'Taper: every 8 hours until Jun 7'.
  ///
  /// In en, this message translates to:
  /// **'{text} until {date}'**
  String taperShortUntil(String text, String date);

  /// Card schedule line for a taper with a step still to come: {text} is the current step (taperShortEvery or taperShortUntil), {duration} the gap in the next step, e.g. 'Taper: every 8 hours until Jun 7, then every 12 hours'.
  ///
  /// In en, this message translates to:
  /// **'{text}, then every {duration}'**
  String taperShortThen(String text, String duration);

  /// Card status: no dose of this medication has been logged yet.
  ///
  /// In en, this message translates to:
  /// **'Not given yet'**
  String get statusNotGiven;

  /// Card status for an as-needed medication: the minimum gap has passed, so a dose is allowed now. Allowed, never required.
  ///
  /// In en, this message translates to:
  /// **'Can be given now'**
  String get statusCanGiveNow;

  /// Card status, also used in reminders: the dose should be given now.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statusDueNow;

  /// Card status: the next dose is at {time}; giving it before then would be too early.
  ///
  /// In en, this message translates to:
  /// **'Next at {time}'**
  String statusNextAt(String time);

  /// Card status: the dose was due {duration} ago and hasn't been given.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {duration}'**
  String statusOverdueBy(String duration);

  /// Card status: so late that the next dose is nearly due. Keep it distinct from overdue.
  ///
  /// In en, this message translates to:
  /// **'Missed: was due {duration} ago'**
  String statusMissed(String duration);

  /// Card status: the course or single dose is complete; nothing more to give.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// Reminder summary in the editor: reminders are off for this medication.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// Reminder summary in the editor: reminders are on for this medication.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get remindersOn;

  /// Reminder summary in the editor: reminders fire {duration} before the dose is due.
  ///
  /// In en, this message translates to:
  /// **'{duration} early'**
  String remindersEarly(String duration);

  /// Reminder summary in the editor, listed after 'On': the reminder rings as an alarm.
  ///
  /// In en, this message translates to:
  /// **'as an alarm'**
  String get remindersAlarm;

  /// A time today, inside bigger sentences: 'since {when}', 'was due {when}', 'Next dose {when}'. Spanish says 'hoy a las 4:28' so each of those reads well; check yours do.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String whenToday(String time);

  /// Inside bigger sentences: 'since {when}', 'was due {when}', 'Next dose {when}'.
  ///
  /// In en, this message translates to:
  /// **'tomorrow at {time}'**
  String whenTomorrow(String time);

  /// Inside bigger sentences: 'since {when}', 'was due {when}'.
  ///
  /// In en, this message translates to:
  /// **'yesterday at {time}'**
  String whenYesterday(String time);

  /// Inside bigger sentences: 'since {when}', 'was due {when}', 'Next dose {when}'.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String whenOnDay(String date, String time);

  /// Short duration on a card or in a reminder, e.g. '45 min'.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String shortMinutes(int count);

  /// Short duration on a card, a whole number of hours, e.g. '3 hr'; used in 'in 3 hr', 'Overdue 3 hr'. Pairs with shortMinutes and shortHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} hr'**
  String shortHours(int count);

  /// Short duration on a card, hours and minutes, e.g. '3 hr 12 min'; used in 'in 3 hr 12 min', 'Overdue 3 hr 12 min'. {hours} and {minutes} are numbers.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String shortHoursMinutes(int hours, int minutes);

  /// Short duration on a card for two days or more, e.g. 'Next dose … in 2 days'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String shortDays(int count);

  /// Heading of today's entries in the dose history.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Heading of yesterday's entries in the dose history.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Card detail under 'Finished' and summary status: the course ended because its last day, {date}, has passed.
  ///
  /// In en, this message translates to:
  /// **'Course finished: last day was {date}'**
  String courseFinishedLastDay(String date);

  /// Card detail under 'Finished' and summary status: the course ended because all its {count} doses have been given.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Course finished: its 1 dose given} other{Course finished: all {count} doses given}}'**
  String courseFinishedDoses(int count);

  /// Course line in the exported medication summary: the course runs through {date}, its last day.
  ///
  /// In en, this message translates to:
  /// **'Last day {date}'**
  String courseLastDay(String date);

  /// Course line in the exported medication summary: the course is {total} doses long and {given} of them have been given. Only {total} chooses the plural form; {given} is a number.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{1 dose, {given} given so far} other{{total} doses, {given} given so far}}'**
  String courseDosesSoFar(int total, Object given);

  /// On the medication card after the schedule, e.g. '1 tablet · Every 8 hours · last day Jun 14': the course runs through {date} (month and day).
  ///
  /// In en, this message translates to:
  /// **'last day {date}'**
  String courseShortLastDay(String date);

  /// On the medication card after the schedule, e.g. '1 tablet · Every 8 hours · 3 doses left': how many doses of the course are still to give.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose left} other{{count} doses left}}'**
  String courseDosesLeft(int count);

  /// Card detail line under 'Not given yet': when the first dose is due. {when} is one of the when… messages.
  ///
  /// In en, this message translates to:
  /// **'First due {when}'**
  String cardFirstDue(String when);

  /// Card detail line under 'Can be given now', for an as-needed medication.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get cardAsNeeded;

  /// Card headline for an as-needed medication still inside its minimum gap: a dose is allowed again from {when}.
  ///
  /// In en, this message translates to:
  /// **'Next dose from {when}'**
  String cardAvailableFrom(String when);

  /// Card headline: the next dose is due {when}; giving it now would be too early.
  ///
  /// In en, this message translates to:
  /// **'Next dose {when}'**
  String cardNextDose(String when);

  /// Card detail line under 'Next dose…': how long until then.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String cardIn(String duration);

  /// Card headline: not yet; the dose becomes due in {duration}.
  ///
  /// In en, this message translates to:
  /// **'Due in {duration}'**
  String cardDueIn(String duration);

  /// Card detail line under 'Due in…': the time it becomes due.
  ///
  /// In en, this message translates to:
  /// **'at {when}'**
  String cardAt(String when);

  /// Card detail line under 'Due now': since when.
  ///
  /// In en, this message translates to:
  /// **'since {when}'**
  String cardSince(String when);

  /// Card headline: the dose was due {duration} ago and hasn't been given.
  ///
  /// In en, this message translates to:
  /// **'Overdue {duration}'**
  String cardOverdue(String duration);

  /// Card detail line under 'Overdue…'.
  ///
  /// In en, this message translates to:
  /// **'was due {when}'**
  String cardWasDue(String when);

  /// Card headline: so late that the next dose is nearly due. Keep it distinct from overdue.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get cardMissed;

  /// Card detail line under 'Missed'.
  ///
  /// In en, this message translates to:
  /// **'was due {when}, {duration} ago'**
  String cardMissedWasDue(String when, String duration);

  /// The phone's owner where a name would stand alone, when they haven't given one: the home screen title, the People list, the Patient column of the exported history. Capitalised.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get personYou;

  /// The phone's owner after 'for' in a sentence: 'For you' in reminders, 'Reminders are off for you', 'All off for you'. Lower-case; it fills {person} in those messages, so make sure it reads well in each.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get personYouAfterFor;

  /// Reminder notification title, read half-asleep: keep it short. {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'{medication} due at {time}'**
  String reminderDueAt(String medication, String time);

  /// Reminder notification title: the dose should be given now.
  ///
  /// In en, this message translates to:
  /// **'{medication} due now'**
  String reminderDueNow(String medication);

  /// Reminder notification title: the dose was due at {time} and hasn't been given.
  ///
  /// In en, this message translates to:
  /// **'{medication} overdue since {time}'**
  String reminderOverdueSince(String medication, String time);

  /// Reminder notification title for an as-needed medication: a dose is allowed again. Allowed, never required.
  ///
  /// In en, this message translates to:
  /// **'{medication} can be given again'**
  String reminderAvailable(String medication);

  /// Reminder notification title when several medications for one person fall due at the same minute: {count} is 2 or more, {person} a name typed by the user or personYouAfterFor. The body then lists each medication.
  ///
  /// In en, this message translates to:
  /// **'{count} medications for {person}'**
  String reminderManyFor(int count, String person);

  /// Reminder notification body: who the medication is for. {person} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'For {person}'**
  String reminderFor(String person);

  /// Name of the Android notification channel for reminders set to ring like an alarm; shown in the phone's notification settings for Nexpill.
  ///
  /// In en, this message translates to:
  /// **'Medication alarms'**
  String get channelAlarms;

  /// Description of the alarms channel in the phone's notification settings.
  ///
  /// In en, this message translates to:
  /// **'For medications set to ring like an alarm when a dose is due.'**
  String get channelAlarmsDescription;

  /// Name of the Android notification channel for ordinary reminders; shown in the phone's notification settings for Nexpill.
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get channelReminders;

  /// Description of the reminders channel in the phone's notification settings: heads-ups before a dose, doses due now, and overdue repeats.
  ///
  /// In en, this message translates to:
  /// **'Heads-ups, doses due, and overdue doses.'**
  String get channelRemindersDescription;

  /// Name of the Android notification channel for the one notice that asks to open Nexpill so reminders can be set further ahead.
  ///
  /// In en, this message translates to:
  /// **'Keeping reminders going'**
  String get channelUpkeep;

  /// Description of the upkeep channel in the phone's notification settings.
  ///
  /// In en, this message translates to:
  /// **'A note when Nexpill needs opening so reminders don\'t run out.'**
  String get channelUpkeepDescription;

  /// Button on a reminder notification: logs the dose as given now, without opening the app.
  ///
  /// In en, this message translates to:
  /// **'Mark given'**
  String get actionMarkGiven;

  /// Button on a reminder notification: deliberately not giving this dose; the schedule carries on.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// Button on a reminder notification: shows it again in {minutes} minutes (currently 5).
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min'**
  String actionSnooze(int minutes);

  /// Title of the notice shown when the reminders planned a week ahead are about to run out because Nexpill hasn't been opened.
  ///
  /// In en, this message translates to:
  /// **'Open Nexpill to keep reminders coming'**
  String get upkeepTitle;

  /// Body of the notice that reminders are about to run out.
  ///
  /// In en, this message translates to:
  /// **'Reminders are set a week ahead each time Nexpill is used. Open it to set the next ones.'**
  String get upkeepBody;

  /// Title of the test notification sent from Settings → Send a test reminder.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testReminderTitle;

  /// Body of the test notification.
  ///
  /// In en, this message translates to:
  /// **'Reminders are working. This is how they\'ll look.'**
  String get testReminderBody;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Given at'**
  String get csvGivenAt;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Given at (UTC)'**
  String get csvGivenAtUtc;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get csvPatient;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get csvMedication;

  /// Column heading in the exported dose-history spreadsheet: the amount given.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get csvDose;

  /// Column heading in the exported dose-history spreadsheet: who gave it.
  ///
  /// In en, this message translates to:
  /// **'Given by'**
  String get csvGivenBy;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get csvNotes;

  /// Column heading in the exported dose-history spreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get csvStatus;

  /// Column heading in the exported spreadsheet: the number of the entry this row corrects.
  ///
  /// In en, this message translates to:
  /// **'Corrects entry'**
  String get csvCorrects;

  /// Column heading in the exported spreadsheet: the entry's number.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get csvEntry;

  /// Status cell in the exported spreadsheet: this entry was replaced by a correction and no longer counts.
  ///
  /// In en, this message translates to:
  /// **'Replaced by a correction'**
  String get csvReplaced;

  /// Status cell in the exported spreadsheet: the dose was deliberately skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get csvSkipped;

  /// Status column of the dose-history spreadsheet, for a refill: supply added rather than a dose. Its Dose column says how much, e.g. '+100 tablets'.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get csvRefill;

  /// Status cell in the exported spreadsheet: this entry corrects an earlier one.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get csvCorrection;

  /// Status cell in the exported spreadsheet: the dose was given.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get csvGiven;

  /// First line of the exported plain-text medication summary: {name} is the person's name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Medication summary for {name}'**
  String summaryTitleFor(String name);

  /// First line of the exported medication summary when the phone's owner has no name set. Same words as the Settings item medicationSummary.
  ///
  /// In en, this message translates to:
  /// **'Medication summary'**
  String get summaryTitle;

  /// Second line of the exported medication summary: {dateTime} is when it was written.
  ///
  /// In en, this message translates to:
  /// **'As of {dateTime}. Active medications only.'**
  String summaryAsOf(String dateTime);

  /// Third line of the exported medication summary, read by a doctor or another caregiver.
  ///
  /// In en, this message translates to:
  /// **'From Nexpill, a timing tracker. Not medical advice.'**
  String get summaryNotAdvice;

  /// Exported medication summary: the person has no active medications.
  ///
  /// In en, this message translates to:
  /// **'No active medications.'**
  String get summaryNoActive;

  /// Line under a medication in the exported summary: {value} is what it's for, as typed by the user.
  ///
  /// In en, this message translates to:
  /// **'For: {value}'**
  String summaryPurpose(String value);

  /// Line under a medication in the exported summary: {value} is the usual dose as typed by the user, e.g. '1 tablet'.
  ///
  /// In en, this message translates to:
  /// **'Dose: {value}'**
  String summaryDose(String value);

  /// Line under a medication in the exported summary: {value} is one of the schedule… messages, e.g. 'Every 8 hours'.
  ///
  /// In en, this message translates to:
  /// **'Schedule: {value}'**
  String summarySchedule(String value);

  /// Line under a medication in the exported summary: {value} is courseLastDay or courseDosesSoFar.
  ///
  /// In en, this message translates to:
  /// **'Course: {value}'**
  String summaryCourse(String value);

  /// Line under a medication in the exported summary: {value} is the instructions as typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Instructions: {value}'**
  String summaryInstructions(String value);

  /// Line under a medication in the exported summary: {value} is a date and time, or summaryNotYet.
  ///
  /// In en, this message translates to:
  /// **'Last given: {value}'**
  String summaryLastGiven(String value);

  /// Fills summaryLastGiven when no dose has been given yet: 'Last given: Not yet'.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get summaryNotYet;

  /// Line under a medication in the exported summary: {value} is one of the status… messages ('Due now', 'Overdue by 1 hour') or a finished text.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String summaryStatus(String value);

  /// Line under a medication in the exported summary: {value} is the reminder summary, 'Off' or 'On, 10 minutes early, as an alarm'.
  ///
  /// In en, this message translates to:
  /// **'Reminders: {value}'**
  String summaryReminders(String value);

  /// Line under a medication in the exported summary: {value} is the supply left with its unit, e.g. '12 tablets', or summaryRunningLow / summaryNoneLeft.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {value}'**
  String summaryRemaining(String value);

  /// Supply in the exported summary at or below the warning level: {amount} is a quantity with its unit, e.g. '3 tablets'.
  ///
  /// In en, this message translates to:
  /// **'{amount} (running low)'**
  String summaryRunningLow(String amount);

  /// Supply in the exported summary when it has run out: {amount} is a quantity with its unit, e.g. '0 tablets'.
  ///
  /// In en, this message translates to:
  /// **'{amount} (none left)'**
  String summaryNoneLeft(String amount);

  /// Shown in the 'Can't restore this file' dialog: the chosen file isn't JSON or has no nexpillBackup field. Nothing is restored.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Nexpill backup.'**
  String get backupNotNexpill;

  /// Shown in the 'Can't restore this file' dialog: the file's format version is newer than this app knows.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer version of Nexpill. Update the app, then try again.'**
  String get backupTooNew;

  /// Shown in the 'Can't restore this file' dialog: two people in the file are both marked as the phone's owner ('self').
  ///
  /// In en, this message translates to:
  /// **'More than one person in this file is marked as you.'**
  String get backupTwoOfYou;

  /// Shown in the 'Can't restore this file' dialog: a correction points at a dose that isn't in the file. {medication} is a medication name from the file.
  ///
  /// In en, this message translates to:
  /// **'A dose of {medication} corrects one that isn\'t in its history.'**
  String backupCorrectsMissing(String medication);

  /// Shown in the 'Can't restore this file' dialog: corrections point at each other in a loop. {medication} is a medication name from the file.
  ///
  /// In en, this message translates to:
  /// **'Corrections to {medication}\'s doses go round in a circle.'**
  String backupCorrectionsCircle(String medication);

  /// Shown in the 'Can't restore this file' dialog. {where} says where in the file (backupWhereFile, backupWhereItem, or a name in quotes). 'lastDay' and 'doses' are field names in the file; keep them in English.
  ///
  /// In en, this message translates to:
  /// **'{where} needs either \"lastDay\" or \"doses\", not both.'**
  String backupCourseBoth(String where);

  /// Shown in the 'Can't restore this file' dialog: a set time isn't in HH:mm form. {where} says where in the file; {time} is the bad value. Keep 'HH:mm'.
  ///
  /// In en, this message translates to:
  /// **'{where} has a time that isn\'t HH:mm: {time}.'**
  String backupBadTime(String where, String time);

  /// Shown in the 'Can't restore this file' dialog. {where} says where in the file; {type} is the unknown value found.
  ///
  /// In en, this message translates to:
  /// **'{where} has an unknown schedule type \"{type}\".'**
  String backupUnknownSchedule(String where, String type);

  /// Shown in the 'Can't restore this file' dialog: {where} (where in the file) isn't a JSON object.
  ///
  /// In en, this message translates to:
  /// **'{where} isn\'t in the expected form.'**
  String backupWrongForm(String where);

  /// Shown in the 'Can't restore this file' dialog: {where} says where in the file; {key} is a field name from the file, kept in English.
  ///
  /// In en, this message translates to:
  /// **'{where} is missing \"{key}\" or it is the wrong kind of value.'**
  String backupMissing(String where, String key);

  /// Shown in the 'Can't restore this file' dialog: a required text field, {key}, is blank. {where} says where in the file.
  ///
  /// In en, this message translates to:
  /// **'{where} has an empty \"{key}\".'**
  String backupEmpty(String where, String key);

  /// Shown in the 'Can't restore this file' dialog: a number is out of range, e.g. a negative interval. {where} says where in the file, {key} is the field name, {value} the number found.
  ///
  /// In en, this message translates to:
  /// **'{where} has an impossible \"{key}\": {value}.'**
  String backupImpossible(String where, String key, String value);

  /// Shown in the 'Can't restore this file' dialog: a date isn't in YYYY-MM-DD form. {where} says where in the file, {key} is the field name. Keep 'YYYY-MM-DD'.
  ///
  /// In en, this message translates to:
  /// **'{where} has a \"{key}\" that isn\'t a YYYY-MM-DD date.'**
  String backupBadDate(String where, String key);

  /// Shown in the 'Can't restore this file' dialog: a timestamp lacks a time zone. {where} says where in the file, {key} is the field name.
  ///
  /// In en, this message translates to:
  /// **'{where} has a \"{key}\" that isn\'t a date and time with a time zone.'**
  String backupBadInstant(String where, String key);

  /// Shown in the 'Can't restore this file' dialog: {id} is a record id that appears twice in the file.
  ///
  /// In en, this message translates to:
  /// **'The id \"{id}\" appears more than once.'**
  String backupDuplicateId(String id);

  /// Shown in the 'Can't restore this file' dialog: a list in the file is empty. {where} says where; {key} is the list's field name ('times', 'steps'), kept in English.
  ///
  /// In en, this message translates to:
  /// **'{where} has no \"{key}\".'**
  String backupNone(String where, String key);

  /// Fills {where} in the backup… messages when the problem is at the top level of the file: 'The file is missing "patients"…'. Capitalised, as it starts the sentence.
  ///
  /// In en, this message translates to:
  /// **'The file'**
  String get backupWhereFile;

  /// Fills {where} in the backup… messages for a list entry that has no name: entry {number} (counting from 1) of the list {key} inside {where}, e.g. 'The file, patients 2' or '"Sam", medications 1, doses 3'. {key} is a field name from the file, kept in English.
  ///
  /// In en, this message translates to:
  /// **'{where}, {key} {number}'**
  String backupWhereItem(String where, String key, int number);

  /// Button that closes a dialog without doing anything; used in every confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message shown when saving a backup, dose history or summary file fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file.'**
  String get couldNotSave;

  /// Label of the hours box in the editor's duration field (Every…, At least this long apart, a taper step's interval).
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// Label of the minutes box in the editor's duration field, next to Hours.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// Accessibility label of the three-dot menu on a medication card. {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'More for {medication}'**
  String cardMoreFor(String medication);

  /// Item in the card's menu: opens the medication editor. Also named in remindersOffFor.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Item in the card's menu (that medication's history) and the history button on the home screen (the person's whole history).
  ///
  /// In en, this message translates to:
  /// **'Dose history'**
  String get doseHistory;

  /// Title of the question asked before a dose is skipped.
  ///
  /// In en, this message translates to:
  /// **'Skip the {time} dose'**
  String skipTheDose(String time);

  /// Item in the card's menu: the medication is no longer being taken. Its history is kept and it moves to the 'Stopped' list at the bottom, where it can be resumed.
  ///
  /// In en, this message translates to:
  /// **'Stop taking'**
  String get stopTaking;

  /// Line on the medication card: when the last dose was given. {when} is one of the when… messages.
  ///
  /// In en, this message translates to:
  /// **'Last given {when}'**
  String lastGiven(String when);

  /// Line on the medication card: the last dose was given {when} (one of the when… messages) by {name}, as typed when logging it.
  ///
  /// In en, this message translates to:
  /// **'Last given {when} by {name}'**
  String lastGivenBy(String when, String name);

  /// Button on the medication card: deliberately not giving this dose; the schedule carries on.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// The main button on a medication card: opens the sheet to log a dose. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Give'**
  String get give;

  /// Supply line on the medication card: {amount} is a quantity with its unit, e.g. '12 tablets'.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String supplyLeft(String amount);

  /// Supply line on the medication card when the tracked supply has run out.
  ///
  /// In en, this message translates to:
  /// **'None left: time to refill'**
  String get supplyNoneLeft;

  /// Supply line on the medication card at or below the warning level: {left} is supplyLeft, e.g. '3 tablets left: running low'.
  ///
  /// In en, this message translates to:
  /// **'{left}: running low'**
  String supplyRunningLow(String left);

  /// Card menu item, shown when supply is tracked: add a new pack from the pharmacy to what's left.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// Title of the dialog that adds to a medication's supply.
  ///
  /// In en, this message translates to:
  /// **'Refill {medication}'**
  String refillTitle(String medication);

  /// Field label in the refill dialog: how much the new pack adds, e.g. 100 (tablets).
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get refillAmount;

  /// Confirming button of the refill dialog.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get refillAdd;

  /// Message after a refill: {left} is supplyLeft with the new total, e.g. 'Ibuprofen refilled. 112 tablets left.'
  ///
  /// In en, this message translates to:
  /// **'{medication} refilled. {left}.'**
  String refilled(String medication, String left);

  /// Title of the dialog shown when Give is tapped before the dose is due.
  ///
  /// In en, this message translates to:
  /// **'This is early'**
  String get earlyTitle;

  /// Body of the early-dose dialog for a scheduled medication: the dose isn't due yet. {medication} is a name typed by the user, {when} one of the when… messages, {duration} how long until then.
  ///
  /// In en, this message translates to:
  /// **'{medication} is next due {when}, in {duration}. Log a dose now anyway?'**
  String earlyMessageDue(String medication, String when, String duration);

  /// Body of the early-dose dialog for an as-needed medication: a dose is allowed again {when} (one of the when… messages), in {duration}. {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'{medication} can next be given {when}, in {duration}. Log a dose now anyway?'**
  String earlyMessageAvailable(String medication, String when, String duration);

  /// Button in the early-dose dialog: don't log a dose.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// Button in the early-dose dialog: log the dose now regardless.
  ///
  /// In en, this message translates to:
  /// **'Log it now'**
  String get logItNow;

  /// Title of the date picker when logging a dose that was given earlier.
  ///
  /// In en, this message translates to:
  /// **'Day it was given'**
  String get dayGiven;

  /// Title of the time picker when logging a dose that was given earlier.
  ///
  /// In en, this message translates to:
  /// **'Time it was given'**
  String get timeGiven;

  /// Error in the give-dose sheet when the chosen time is later than now.
  ///
  /// In en, this message translates to:
  /// **'That time hasn\'t happened yet.'**
  String get timeInFuture;

  /// Title of the screen for correcting a mistaken {medication} entry. The original stays in history, struck through.
  ///
  /// In en, this message translates to:
  /// **'Correct this {medication} entry'**
  String correctEntry(String medication);

  /// Title of the sheet for logging a dose: {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Give {medication}'**
  String giveMedication(String medication);

  /// Note under the title of the correction sheet: the entry being corrected stays in history.
  ///
  /// In en, this message translates to:
  /// **'The original stays in history, marked as corrected.'**
  String get originalStays;

  /// Segment in the give-dose sheet: the dose is given at this moment.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Segment in the give-dose sheet: the dose was given at an earlier time, which is then picked.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// In the give-dose sheet after picking an earlier time: {when} is one of the when… messages.
  ///
  /// In en, this message translates to:
  /// **'Given {when}'**
  String givenWhen(String when);

  /// Button beside the picked time in the give-dose sheet: pick a different one.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Field label when logging a dose: the amount given, as the user types it.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// Field label when logging a dose: who gave it.
  ///
  /// In en, this message translates to:
  /// **'Given by'**
  String get givenBy;

  /// Hint shown inside an empty optional text field: Given by, Notes, the owner's name, Warn at.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Field label when logging a dose: free-text notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Button that saves a correction of a logged dose.
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get saveCorrection;

  /// Button that saves a new dose.
  ///
  /// In en, this message translates to:
  /// **'Log dose'**
  String get logDose;

  /// Confirmation after the dose history was saved as a CSV file.
  ///
  /// In en, this message translates to:
  /// **'Dose history saved'**
  String get doseHistorySaved;

  /// Menu item on a history entry: opens the correction screen.
  ///
  /// In en, this message translates to:
  /// **'Correct time or details'**
  String get correctTimeOrDetails;

  /// Subtitle under 'Correct time or details' in a history entry's menu.
  ///
  /// In en, this message translates to:
  /// **'Keeps the original, marked as corrected'**
  String get keepsOriginal;

  /// Menu item on a history entry: removes it from history altogether. Only for an entry that should never have been logged.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntry;

  /// Subtitle under 'Delete entry' for a skipped dose: without the skip, the dose is due again.
  ///
  /// In en, this message translates to:
  /// **'The dose becomes due again'**
  String get deleteEntrySkippedHint;

  /// Subtitle under 'Delete entry' for a given dose.
  ///
  /// In en, this message translates to:
  /// **'Only for a dose that was never given'**
  String get deleteEntryHint;

  /// Title of the confirmation before a history entry is deleted.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// Body of the delete confirmation for a skipped dose. {medication} is a name typed by the user, {dateTime} when the dose was due.
  ///
  /// In en, this message translates to:
  /// **'{medication}, {dateTime}, skipped. Delete it if the dose wasn\'t meant to be skipped.'**
  String deleteSkippedMessage(String medication, String dateTime);

  /// Body of the delete confirmation for a given dose. {medication} is a name typed by the user, {dateTime} when it was given.
  ///
  /// In en, this message translates to:
  /// **'{medication}, {dateTime}. Use this only if the dose was never given; to fix its time, correct it instead. Any corrections of it go too.'**
  String deleteDoseMessage(String medication, String dateTime);

  /// Body of the delete confirmation for a refill in dose history. {medication} is a name typed by the user, {dateTime} when it was logged, {amount} the quantity added with its unit.
  ///
  /// In en, this message translates to:
  /// **'{medication}, {dateTime}: +{amount}. Delete it if it was logged by mistake; what\'s left goes down by that much. If the amount was wrong, refill again with the right one.'**
  String deleteRefillMessage(String medication, String dateTime, String amount);

  /// Confirming button of the delete dialogs (history entry, medication, person) and the Delete item in a person's menu on the People screen.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title of the dose history screen for the phone's owner.
  ///
  /// In en, this message translates to:
  /// **'Your doses'**
  String get yourDoses;

  /// Title of the dose history screen for someone else: {name} is their name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s doses'**
  String personsDoses(String name);

  /// Fallback title of the dose history screen when it is filtered to a medication that has since been deleted.
  ///
  /// In en, this message translates to:
  /// **'Doses'**
  String get doses;

  /// Accessibility label of the download button on the dose history screen.
  ///
  /// In en, this message translates to:
  /// **'Save as a spreadsheet (CSV)'**
  String get saveAsCsv;

  /// Filter chip at the top of the dose history when it shows one medication: {medication} is a name typed by the user. Removing the chip shows everything.
  ///
  /// In en, this message translates to:
  /// **'Only {medication}'**
  String onlyMedication(String medication);

  /// Dose history screen with no entries yet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get nothingLogged;

  /// In a history entry's detail line, after the dose amount: who gave it, e.g. '1 tablet · by Sam'. {name} is as typed when logging.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String historyBy(String name);

  /// Tag in a history entry's detail line: this entry is a correction of an earlier one.
  ///
  /// In en, this message translates to:
  /// **'correction'**
  String get historyCorrection;

  /// Line under a refill in dose history: {amount} is the quantity added with its unit, e.g. 'Refill: +100 tablets'.
  ///
  /// In en, this message translates to:
  /// **'Refill: +{amount}'**
  String historyRefill(String amount);

  /// Tag in a history entry's detail line: this entry was replaced by a correction and is shown struck through.
  ///
  /// In en, this message translates to:
  /// **'corrected'**
  String get historyCorrected;

  /// The usual dose prefilled when adding a medication; the user can change it.
  ///
  /// In en, this message translates to:
  /// **'1 tablet'**
  String get defaultDose;

  /// Validation error under the Name field of the medication editor.
  ///
  /// In en, this message translates to:
  /// **'Give the medication a name.'**
  String get errorName;

  /// Validation error under the Usual dose field of the medication editor.
  ///
  /// In en, this message translates to:
  /// **'Say what one dose is, like \"1 tablet\".'**
  String get errorDose;

  /// Validation error in the editor's When section: the interval is zero.
  ///
  /// In en, this message translates to:
  /// **'Choose how often.'**
  String get errorHowOften;

  /// Validation error in the editor's When section: the as-needed minimum gap is zero.
  ///
  /// In en, this message translates to:
  /// **'Choose the shortest gap between doses.'**
  String get errorShortestGap;

  /// Validation error in the editor's When section: a set-times schedule has no times.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time.'**
  String get errorAddTime;

  /// Validation error under the 'Doses still to give' field of a course some of whose doses have been given.
  ///
  /// In en, this message translates to:
  /// **'Enter how many doses are still to give.'**
  String get errorDosesStillToGive;

  /// Validation error under the 'Number of doses' field of a new course.
  ///
  /// In en, this message translates to:
  /// **'Enter how many doses the course has.'**
  String get errorCourseDoses;

  /// Validation error in the editor's Supply section: Amount left is missing or negative.
  ///
  /// In en, this message translates to:
  /// **'Enter how much is left.'**
  String get errorAmountLeft;

  /// Validation error in the editor's Supply section: Each dose uses is missing or zero.
  ///
  /// In en, this message translates to:
  /// **'Enter how much one dose uses.'**
  String get errorPerDose;

  /// Validation error in the editor's Supply section: Warn at isn't a number.
  ///
  /// In en, this message translates to:
  /// **'Enter when to warn, or leave it empty.'**
  String get errorLowAt;

  /// Validation error in the editor's When section: the taper has no steps.
  ///
  /// In en, this message translates to:
  /// **'Add at least one step.'**
  String get errorNoSteps;

  /// Validation error in the taper editor: a step's interval is zero.
  ///
  /// In en, this message translates to:
  /// **'Every step needs an interval.'**
  String get errorStepInterval;

  /// Validation error in the taper editor: a step's end date is on or before its start.
  ///
  /// In en, this message translates to:
  /// **'A step has to end after it starts.'**
  String get errorStepEnds;

  /// Validation error in the taper editor: a step other than the last has no end date.
  ///
  /// In en, this message translates to:
  /// **'Only the last step can be open-ended.'**
  String get errorOpenEnded;

  /// Validation error in the taper editor: one step ends after the next begins.
  ///
  /// In en, this message translates to:
  /// **'Two steps overlap.'**
  String get errorStepsOverlap;

  /// Title of the confirmation before a medication is deleted. {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Delete {medication}?'**
  String deleteMedicationTitle(String medication);

  /// Body of the delete-medication confirmation. 'Taking this now' is the editor switch takingThisNow; use the same words.
  ///
  /// In en, this message translates to:
  /// **'Its dose history goes with it. To stop it but keep the history, turn off \"Taking this now\" instead.'**
  String get deleteMedicationMessage;

  /// Title of the medication editor when adding.
  ///
  /// In en, this message translates to:
  /// **'New medication'**
  String get newMedication;

  /// Title of the medication editor when editing: {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Edit {medication}'**
  String editMedication(String medication);

  /// Button in the editor's top bar, and the confirming button of the person dialog when renaming.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Heading of the medication editor: whose medication this is. {person} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'For {person}'**
  String forPerson(String person);

  /// Label of the medication's name field in the editor, and of the name field in the add-person dialog.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Hint inside the empty Name field of the medication editor; the example is a medication name.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amoxicillin'**
  String get fieldNameHint;

  /// Field label in the medication editor: the strength printed on the pack, e.g. '500 mg'. Shown after the name on the card.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get fieldStrength;

  /// Hint inside the empty Strength field.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. 500 mg'**
  String get fieldStrengthHint;

  /// Field label in the medication editor: what the medication is for. Shown on the card and in reminders.
  ///
  /// In en, this message translates to:
  /// **'What it\'s for'**
  String get fieldPurpose;

  /// Hint inside the empty 'What it's for' field.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. blood pressure'**
  String get fieldPurposeHint;

  /// Field label in the medication editor: the amount usually given, prefilled when logging a dose.
  ///
  /// In en, this message translates to:
  /// **'Usual dose'**
  String get fieldUsualDose;

  /// Hint inside the empty Usual dose field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tablet, 5 ml'**
  String get fieldUsualDoseHint;

  /// Field label in the medication editor: free-text instructions, shown on the card.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get fieldInstructions;

  /// Hint inside the empty Instructions field.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. with food'**
  String get fieldInstructionsHint;

  /// Heading of the editor section that sets the schedule.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get sectionWhen;

  /// Heading of the editor section that sets how long the course runs.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get sectionHowLong;

  /// Heading of the editor's reminder section, of the Reminders section in Settings, and title of the per-person reminder switch on the People screen.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get sectionReminders;

  /// Heading of the editor section that tracks how much is left.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get sectionSupply;

  /// Switch in the editor of an existing medication: on while it's being taken; turning it off stops it but keeps its history. Named in deleteMedicationMessage and courseOngoingHint.
  ///
  /// In en, this message translates to:
  /// **'Taking this now'**
  String get takingThisNow;

  /// Subtitle of the 'Taking this now' switch.
  ///
  /// In en, this message translates to:
  /// **'Turn off when it\'s stopped. It keeps its history but stops reminding.'**
  String get takingThisNowHint;

  /// Item at the bottom of the medication editor: deletes the medication and its history after confirming.
  ///
  /// In en, this message translates to:
  /// **'Delete medication'**
  String get deleteMedication;

  /// Label of the add button on the home screen, and of the editor's save button when adding.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get addMedication;

  /// Save button at the bottom of the medication editor when editing.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Schedule-kind chip in the editor: a dose every so many hours, counted from the last dose given.
  ///
  /// In en, this message translates to:
  /// **'Every few hours'**
  String get kindInterval;

  /// Schedule-kind chip in the editor: at set clock times every day.
  ///
  /// In en, this message translates to:
  /// **'At set times'**
  String get kindFixedTimes;

  /// Kind of schedule, chosen when editing a medication: given only when needed, with a minimum gap between doses.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get kindAsNeeded;

  /// Schedule-kind chip in the editor: a taper, steps with dates and a different interval each.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get kindTaper;

  /// Schedule-kind chip in the editor: a single dose at one date and time.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get kindOnce;

  /// Heading over the duration field for an interval schedule: 'Every', then hours and minutes boxes.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// Hint under the interval duration field.
  ///
  /// In en, this message translates to:
  /// **'Counted from the last dose given.'**
  String get intervalHint;

  /// Heading over the duration field for an as-needed schedule: the minimum gap between doses.
  ///
  /// In en, this message translates to:
  /// **'At least this long apart'**
  String get atLeastApart;

  /// Hint under the as-needed gap. 'due' is the status word: an as-needed dose is allowed, never required, so the app never calls it due.
  ///
  /// In en, this message translates to:
  /// **'Never \"due\" — Nexpill shows when it can be given again.'**
  String get asNeededHint;

  /// Chip in the set-times schedule that opens the time picker to add a time.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// Hint under the set times.
  ///
  /// In en, this message translates to:
  /// **'Every day, on this phone\'s clock.'**
  String get fixedTimesHint;

  /// Title of the time picker for a set time, or for a single dose.
  ///
  /// In en, this message translates to:
  /// **'Time of dose'**
  String get timeOfDose;

  /// Hint under the single dose's date and time.
  ///
  /// In en, this message translates to:
  /// **'A single dose. Once it\'s given or skipped it\'s finished, and stays in history.'**
  String get onceHint;

  /// Title of the date picker for a single dose.
  ///
  /// In en, this message translates to:
  /// **'Day of the dose'**
  String get dayOfDose;

  /// How-long chip in the editor: the medication carries on until stopped.
  ///
  /// In en, this message translates to:
  /// **'Until stopped'**
  String get courseUntilStopped;

  /// How-long chip in the editor: the medication runs through a last day.
  ///
  /// In en, this message translates to:
  /// **'Until a date'**
  String get courseUntilDate;

  /// How-long chip in the editor: the medication runs for a set number of doses.
  ///
  /// In en, this message translates to:
  /// **'A number of doses'**
  String get courseNumberOfDoses;

  /// Hint under 'Until stopped'. 'Taking this now' is the editor switch takingThisNow; use the same words.
  ///
  /// In en, this message translates to:
  /// **'Reminders carry on until you turn off \"Taking this now\".'**
  String get courseOngoingHint;

  /// Chip showing the course's last day, {date}; tapping it picks a date.
  ///
  /// In en, this message translates to:
  /// **'Last day: {date}'**
  String courseLastDayChip(String date);

  /// Hint under the last-day chip.
  ///
  /// In en, this message translates to:
  /// **'Doses carry on through that day; reminders stop at midnight at the end of it.'**
  String get courseLastDayHint;

  /// Label of the number field for a course of doses when some have already been given.
  ///
  /// In en, this message translates to:
  /// **'Doses still to give'**
  String get dosesStillToGive;

  /// Label of the number field for a new course of doses.
  ///
  /// In en, this message translates to:
  /// **'Number of doses'**
  String get numberOfDoses;

  /// Hint inside the empty number-of-doses field.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10'**
  String get dosesHint;

  /// Hint under the number of doses of a new course.
  ///
  /// In en, this message translates to:
  /// **'Reminders stop once the last one is given.'**
  String get courseDosesHint;

  /// Hint under 'Doses still to give' when {count} doses of the course have already been given.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose given so far. Reminders stop once the last one is given.} other{{count} doses given so far. Reminders stop once the last one is given.}}'**
  String courseDosesGivenHint(int count);

  /// Title of the date picker for the course's last day.
  ///
  /// In en, this message translates to:
  /// **'Last day of the course'**
  String get lastDayOfCourse;

  /// Heading of each step in the taper editor: {number} counts from 1.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String taperStepNumber(int number);

  /// Accessibility label of the X button on a taper step.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get removeStep;

  /// Taper editor: button showing a step's first day; tapping it picks the date.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String stepFrom(String date);

  /// Chip on a taper step that has no end date; tapping it picks one.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// Taper editor: button showing a step's last day; tapping it picks the date.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String stepUntil(String date);

  /// Chip on a taper step: removes its end date, making it open-ended.
  ///
  /// In en, this message translates to:
  /// **'Clear end'**
  String get clearEnd;

  /// Button in the taper editor that adds a step.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get addStep;

  /// Hint under the taper steps.
  ///
  /// In en, this message translates to:
  /// **'Each step runs from midnight on its first day until midnight on its end day. The last step can be open-ended.'**
  String get taperHint;

  /// Switch in the editor's Reminders section: reminders on or off for this medication.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// Subtitle of the Remind me switch for an as-needed medication: it reminds when a dose is allowed again.
  ///
  /// In en, this message translates to:
  /// **'When it can be given again.'**
  String get remindAsNeededHint;

  /// Subtitle of the Remind me switch for a scheduled medication.
  ///
  /// In en, this message translates to:
  /// **'When a dose is due, and again while it\'s overdue.'**
  String get remindHint;

  /// Reminder setting: a reminder some minutes before the dose is due. Choices: None, 10 min, 15 min.
  ///
  /// In en, this message translates to:
  /// **'Heads-up before it\'s due'**
  String get headsUp;

  /// Choice in the heads-up setting: no early reminder.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Choice in the editor's reminder-timing dropdown, e.g. '10 min'.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// Reminder setting: how often the reminder repeats while the dose is overdue; the dropdown lists everyDuration choices.
  ///
  /// In en, this message translates to:
  /// **'Repeat while overdue'**
  String get repeatWhileOverdue;

  /// Choice in the repeat-while-overdue dropdown: {duration} is a short duration, e.g. 'every 30 min', 'every 1 hr'.
  ///
  /// In en, this message translates to:
  /// **'every {duration}'**
  String everyDuration(String duration);

  /// Switch in the editor's Reminders section: the reminder rings as an alarm rather than a normal notification.
  ///
  /// In en, this message translates to:
  /// **'Ring like an alarm'**
  String get ringLikeAlarm;

  /// Subtitle of the Ring like an alarm switch.
  ///
  /// In en, this message translates to:
  /// **'The alarm sound, repeating until you mark it given or snooze it.'**
  String get ringLikeAlarmHint;

  /// Switch in the editor's Supply section: count down how much is left with each dose.
  ///
  /// In en, this message translates to:
  /// **'Track how much is left'**
  String get trackSupply;

  /// Subtitle of the Track how much is left switch.
  ///
  /// In en, this message translates to:
  /// **'Counts down with each dose logged.'**
  String get trackSupplyHint;

  /// Field label in the Supply section: how much there is now. It counts down with each dose, and Refill adds to it.
  ///
  /// In en, this message translates to:
  /// **'Amount left'**
  String get amountLeft;

  /// Field label in the Supply section: what the supply is counted in, e.g. tablets, ml.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Hint inside the empty Unit field.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get unitHint;

  /// Field label in the Supply section: how much of the supply one dose uses.
  ///
  /// In en, this message translates to:
  /// **'Each dose uses'**
  String get eachDoseUses;

  /// Field label in the Supply section: the amount left at which the card and summary say 'running low'. Optional.
  ///
  /// In en, this message translates to:
  /// **'Warn at'**
  String get warnAt;

  /// Title of the home screen when caring for more than one person: each of them with what's next.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// Accessibility label of the people button on the Everyone screen, and an item in the person switcher: opens the People screen.
  ///
  /// In en, this message translates to:
  /// **'Manage people'**
  String get managePeople;

  /// Title of the Settings screen and accessibility label of the settings button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button that adds a person: on the Everyone screen, the People screen and in the person switcher.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get addSomeone;

  /// Heading on a person's empty home screen, and under their name on the Everyone screen: nothing added for them yet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// Heading on a person's home screen, and under their name on the Everyone screen, when every medication has finished or been stopped.
  ///
  /// In en, this message translates to:
  /// **'Nothing to give now'**
  String get nothingToGiveNow;

  /// On the Everyone screen under the person's first medication: {count} more of their medications are also due or overdue now.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more due now'**
  String moreDueNow(int count);

  /// Under a person on the Everyone screen whose reminders are all off, and the button in the skip message that turns a medication's reminders off.
  ///
  /// In en, this message translates to:
  /// **'Reminders off'**
  String get remindersOffShort;

  /// Error in the add-person dialog when the name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get errorEnterName;

  /// Error in the add-person dialog when another person already has that name.
  ///
  /// In en, this message translates to:
  /// **'Someone already has that name.'**
  String get errorNameTaken;

  /// Title of the dialog that adds a person.
  ///
  /// In en, this message translates to:
  /// **'Who are you caring for?'**
  String get whoAreYouCaringFor;

  /// Title of the person dialog when renaming, and the item in a person's menu on the People screen.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Title of the person dialog when the phone's owner adds their name; also the label of the name field while 'This is me' is ticked, and in the summary-name dialog.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// Hint inside the empty name field when adding someone else.
  ///
  /// In en, this message translates to:
  /// **'A first name or nickname is fine'**
  String get nameHint;

  /// Checkbox in the add-person dialog: this person is the phone's owner.
  ///
  /// In en, this message translates to:
  /// **'This is me'**
  String get thisIsMe;

  /// Subtitle under the 'This is me' checkbox.
  ///
  /// In en, this message translates to:
  /// **'For your own medications'**
  String get forYourOwnMedications;

  /// Confirming button of the add-person dialog.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Title of the confirmation before the phone's owner is removed on the People screen.
  ///
  /// In en, this message translates to:
  /// **'Delete your medications?'**
  String get deleteYourMedicationsTitle;

  /// Title of the confirmation before someone else is removed on the People screen: {name} is their name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePersonTitle(String name);

  /// Body of the confirmation before the phone's owner is removed: {count} is how many medications they have.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your medication and all dose history go too, and can\'t be brought back unless you have a backup file.} other{Your {count} medications and all dose history go too, and can\'t be brought back unless you have a backup file.}}'**
  String deleteYourMedicationsMessage(int count);

  /// Body of the confirmation before someone else is removed: {count} is how many medications they have.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Their medication and all dose history go too, and can\'t be brought back unless you have a backup file.} other{Their {count} medications and all dose history go too, and can\'t be brought back unless you have a backup file.}}'**
  String deletePersonMessage(int count);

  /// Title of the People screen and heading of the People section in Settings.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// Subtitle under a person on the People screen: {count} is medicationCount, e.g. '2 medications · tap to see them'.
  ///
  /// In en, this message translates to:
  /// **'{count} · tap to see them'**
  String tapToSeeThem(String count);

  /// Item in the phone's owner's menu on the People screen when they have no name yet.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addYourName;

  /// Subtitle of a person's Reminders switch on the People screen when on: each medication's own setting applies.
  ///
  /// In en, this message translates to:
  /// **'As set for each medication'**
  String get asSetForEach;

  /// Subtitle of a person's Reminders switch on the People screen when off: {person} is their name typed by the user, or personYouAfterFor.
  ///
  /// In en, this message translates to:
  /// **'All off for {person}'**
  String allOffFor(String person);

  /// How many active medications a person has: under their name on the People screen, and in the restore confirmation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medication} other{{count} medications}}'**
  String medicationCount(int count);

  /// Confirmation shown after a dose is logged.
  ///
  /// In en, this message translates to:
  /// **'{medication} logged, {when}'**
  String doseLogged(String medication, String when);

  /// Button on the message after a dose is logged or skipped, a medication is stopped or its reminders turned off: reverses it.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Message after the third skip in a row, offering to turn the reminders off: {medication} is a name typed by the user, {count} is 3 or more.
  ///
  /// In en, this message translates to:
  /// **'{medication}: skipped {count} times in a row'**
  String skippedInARow(String medication, int count);

  /// Message after a dose is skipped: {medication} is a name typed by the user, {skipped} is skippedDose.
  ///
  /// In en, this message translates to:
  /// **'{medication}: {skipped}'**
  String medicationSkipped(String medication, String skipped);

  /// Message after reminders were turned off from the skip message. 'Edit' is the card menu item edit; use the same word.
  ///
  /// In en, this message translates to:
  /// **'Reminders off for {medication}. Turn them on again in Edit.'**
  String remindersOffFor(String medication);

  /// Message after Stop taking: {medication} is a name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'{medication} stopped. Its history is kept.'**
  String medicationStopped(String medication);

  /// Title of the banner on the home screen when Android's notification permission is missing.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get remindersAreOff;

  /// Subtitle of the reminders-off banner on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so they can reach you.'**
  String get allowNotificationsHint;

  /// Button on the reminders-off banner and in Settings: asks Android for notification permission.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Note at the top of a person's home screen when their Reminders switch is off: {person} is their name typed by the user, or personYouAfterFor.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off for {person}.'**
  String remindersAreOffFor(String person);

  /// Text under 'No medications yet' on the phone's owner's own screen.
  ///
  /// In en, this message translates to:
  /// **'Add your first one, and Nexpill will keep track of when each dose can be given.'**
  String get addYourFirst;

  /// Text under 'No medications yet' on someone else's screen: {name} is their name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Add {name}\'s first one, and Nexpill will keep track of when each dose can be given.'**
  String addPersonsFirst(String name);

  /// Text under 'Nothing to give now' on the phone's owner's screen.
  ///
  /// In en, this message translates to:
  /// **'Everything for you has finished or been stopped. It\'s all below, with its history.'**
  String get allEndedForYou;

  /// Text under 'Nothing to give now' on someone else's screen: {name} is their name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Everything for {name} has finished or been stopped. It\'s all below, with its history.'**
  String allEndedForPerson(String name);

  /// Button under the empty-screen text on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Add a medication'**
  String get addAMedication;

  /// Button below the medication cards on the phone's owner's screen.
  ///
  /// In en, this message translates to:
  /// **'Add another medication'**
  String get addAnotherMedication;

  /// Button below the medication cards on someone else's screen: {name} is their name typed by the user.
  ///
  /// In en, this message translates to:
  /// **'Add a medication for {name}'**
  String addMedicationFor(String name);

  /// Heading of the collapsed list at the bottom of the home screen: {count} medications have been stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped ({count})'**
  String endedStopped(int count);

  /// Heading of the collapsed list at the bottom of the home screen: {count} courses have finished.
  ///
  /// In en, this message translates to:
  /// **'Finished ({count})'**
  String endedFinished(int count);

  /// Heading of the collapsed list at the bottom of the home screen: {count} medications, some finished and some stopped.
  ///
  /// In en, this message translates to:
  /// **'Finished and stopped ({count})'**
  String endedBoth(int count);

  /// Button on a stopped medication in that list: start taking it again.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Accessibility label of the logo on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Nexpill logo'**
  String get logoLabel;

  /// Welcome screen on first run: what Nexpill does.
  ///
  /// In en, this message translates to:
  /// **'Keeps track of when each dose was given and when the next one can be, and reminds you on time.'**
  String get welcomeWhat;

  /// Welcome screen: the privacy reassurance under what Nexpill does.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. No account, no internet.'**
  String get welcomePrivate;

  /// Question on the welcome screen, above the two buttons.
  ///
  /// In en, this message translates to:
  /// **'Who are the medications for?'**
  String get whoAreTheMedicationsFor;

  /// Welcome screen button: the medications are the phone's owner's.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// Welcome screen button: adds someone else.
  ///
  /// In en, this message translates to:
  /// **'Someone I care for'**
  String get someoneICareFor;

  /// Note under the welcome screen buttons.
  ///
  /// In en, this message translates to:
  /// **'You can add more people later.'**
  String get addMoreLater;

  /// Message when the Website or Send feedback link can't be opened: {website} is the site's address.
  ///
  /// In en, this message translates to:
  /// **'No browser to open it with. Visit {website} instead.'**
  String noBrowser(String website);

  /// Confirmation after the backup file was saved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// Message when the chosen backup file can't be read at all.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that file.'**
  String get couldNotOpen;

  /// Title of the dialog saying why a backup file was refused; its body is one of the backup… messages.
  ///
  /// In en, this message translates to:
  /// **'Can\'t restore this file'**
  String get cantRestore;

  /// Button closing the 'Can't restore this file' dialog.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Title of the confirmation before a backup replaces everything on the phone.
  ///
  /// In en, this message translates to:
  /// **'Replace everything with this backup?'**
  String get restoreTitle;

  /// Fills {people} in restoreMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// Fills {doses} in restoreMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose logged} other{{count} doses logged}}'**
  String dosesLoggedCount(int count);

  /// Body of the restore confirmation: {people} is peopleCount, {medications} is medicationCount, {doses} is dosesLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'It has {people}, {medications} and {doses}. Everything now on this phone will be replaced by it.'**
  String restoreMessage(String people, String medications, String doses);

  /// Confirming button of the restore confirmation.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// Message after a backup was restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// Title of the dialog choosing whose medication summary to save, when there is more than one person.
  ///
  /// In en, this message translates to:
  /// **'Summary for'**
  String get summaryFor;

  /// Confirmation after the medication summary file was saved.
  ///
  /// In en, this message translates to:
  /// **'Summary saved'**
  String get summarySaved;

  /// Title of the dialog asking the phone's owner, who has no name set, for a name to put on the summary.
  ///
  /// In en, this message translates to:
  /// **'Your name on the summary'**
  String get yourNameOnSummary;

  /// Confirming button of the summary-name dialog; an empty name is fine.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Title of the confirmation in Settings before all data is deleted.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllTitle;

  /// Body of the delete-all confirmation.
  ///
  /// In en, this message translates to:
  /// **'Every person, medication and dose on this phone, and every reminder. This can\'t be undone; if you might want it back, save a backup first.'**
  String get deleteAllMessage;

  /// Confirming button of the delete-all confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// Settings → Reminders: Android's notification permission is missing.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsOff;

  /// Settings → Reminders: notifications are allowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get notificationsOn;

  /// Subtitle under 'Notifications are off' in Settings.
  ///
  /// In en, this message translates to:
  /// **'Reminders can\'t be shown until they\'re allowed.'**
  String get notificationsOffHint;

  /// Subtitle under 'Notifications are on' in Settings.
  ///
  /// In en, this message translates to:
  /// **'Reminders will show on this phone.'**
  String get notificationsOnHint;

  /// Warning in Settings → Reminders when Android has taken away exact alarms.
  ///
  /// In en, this message translates to:
  /// **'Reminders may be late'**
  String get mayBeLate;

  /// Subtitle of that warning. 'Alarms & reminders' is the Android setting's name; use the phone's own wording in your language.
  ///
  /// In en, this message translates to:
  /// **'Android has turned off exact alarms for Nexpill. Turn \"Alarms & reminders\" back on in the phone\'s settings for the app.'**
  String get mayBeLateHint;

  /// Settings → Reminders item: sends a test notification.
  ///
  /// In en, this message translates to:
  /// **'Send a test reminder'**
  String get sendTest;

  /// Subtitle of Send a test reminder.
  ///
  /// In en, this message translates to:
  /// **'Arrives in a few seconds.'**
  String get sendTestHint;

  /// Message after tapping Send a test reminder.
  ///
  /// In en, this message translates to:
  /// **'Test reminder on its way'**
  String get testOnItsWay;

  /// Settings → People item: opens the People screen.
  ///
  /// In en, this message translates to:
  /// **'People you care for'**
  String get peopleYouCareFor;

  /// Subtitle of People you care for: {count} is how many people.
  ///
  /// In en, this message translates to:
  /// **'{count} on this phone'**
  String onThisPhone(int count);

  /// Heading of the Settings section with back up, restore, summary and delete all.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// Settings item: saves a backup file wherever the user chooses.
  ///
  /// In en, this message translates to:
  /// **'Back up to a file'**
  String get backUp;

  /// Subtitle of Back up to a file.
  ///
  /// In en, this message translates to:
  /// **'Everything, saved wherever you choose.'**
  String get backUpHint;

  /// Settings item: restores a backup file, replacing everything on the phone.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get restore;

  /// Subtitle of Restore from a backup.
  ///
  /// In en, this message translates to:
  /// **'Replaces what\'s on this phone.'**
  String get restoreHint;

  /// Settings item: saves the plain-text medication summary. Same words as summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication summary'**
  String get medicationSummary;

  /// Subtitle of Medication summary.
  ///
  /// In en, this message translates to:
  /// **'Plain text, for a doctor or a handover.'**
  String get medicationSummaryHint;

  /// Settings item: deletes everything after confirming.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// Heading of the About section in Settings.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Settings item that opens the About screen, and that screen's title.
  ///
  /// In en, this message translates to:
  /// **'About Nexpill'**
  String get aboutNexpill;

  /// Subtitle of About Nexpill in Settings.
  ///
  /// In en, this message translates to:
  /// **'Where your data lives, and why it\'s free'**
  String get aboutNexpillHint;

  /// Settings item: opens the Nexpill website in the browser.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Settings item: opens the feedback form on the website in the browser.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// Subtitle of Send feedback.
  ///
  /// In en, this message translates to:
  /// **'A form on the website, in your browser.'**
  String get sendFeedbackHint;

  /// Settings item label; the version number is its subtitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Heading of the Language section in Settings, its item, and the title of the language dialog.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Choice in the language dialog: follow the phone's language.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone'**
  String get sameAsPhone;

  /// Subtitle of the Language item when following the phone: {language} is the language in use, by its own name.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone: {language}'**
  String sameAsPhoneNow(String language);

  /// Heading of the first point on the About screen: the data stays on the phone.
  ///
  /// In en, this message translates to:
  /// **'It stays on your phone'**
  String get aboutStaysTitle;

  /// Body of the About screen's first point.
  ///
  /// In en, this message translates to:
  /// **'Everything you log is written to a database on this device. There is no account and no server. It only goes anywhere else if you move it yourself, as a backup file or an export.'**
  String get aboutStaysBody;

  /// Heading of the About screen's second point: Nexpill has no internet permission.
  ///
  /// In en, this message translates to:
  /// **'We cannot see it'**
  String get aboutCannotSeeTitle;

  /// Body of the About screen's second point.
  ///
  /// In en, this message translates to:
  /// **'Nexpill is built without permission to use the internet at all. Android enforces that, and you can check it in the app\'s permission list.'**
  String get aboutCannotSeeBody;

  /// Heading of the About screen's third point: reminders are local alarms.
  ///
  /// In en, this message translates to:
  /// **'Reminders come from the phone itself'**
  String get aboutRemindersTitle;

  /// Body of the About screen's third point.
  ///
  /// In en, this message translates to:
  /// **'Each reminder is an alarm this phone holds, so it arrives on time with no signal, in airplane mode, and after a restart.'**
  String get aboutRemindersBody;

  /// Heading of the About screen's fourth point: what each permission is for.
  ///
  /// In en, this message translates to:
  /// **'What the permissions are for'**
  String get aboutPermissionsTitle;

  /// Body of the About screen's fourth point; name the permissions as Android does in your language.
  ///
  /// In en, this message translates to:
  /// **'Notifications, for reminders. Exact alarms, so they arrive on the minute. Starting after a restart, to set them again. Vibration. That is the whole list.'**
  String get aboutPermissionsBody;

  /// Heading of the About screen's fifth point: free and open source for good.
  ///
  /// In en, this message translates to:
  /// **'Free, for good'**
  String get aboutFreeTitle;

  /// Body of the About screen's fifth point.
  ///
  /// In en, this message translates to:
  /// **'Nexpill was written by a caregiver, for caregivers. It will always be free and open source: no price, no premium tier, no ads.'**
  String get aboutFreeBody;

  /// Heading of the About screen's sixth point: the source is open.
  ///
  /// In en, this message translates to:
  /// **'You can check our work'**
  String get aboutCheckTitle;

  /// Body of the About screen's sixth point. 'GNU General Public License' is the licence's name.
  ///
  /// In en, this message translates to:
  /// **'Nexpill is open source under the GNU General Public License. Anyone can read exactly what it does.'**
  String get aboutCheckBody;

  /// Headline at the top of the About screen.
  ///
  /// In en, this message translates to:
  /// **'Your records stay with you.'**
  String get aboutHeadline;

  /// Introduction under the About screen's headline.
  ///
  /// In en, this message translates to:
  /// **'Nexpill keeps track of when each dose was given and when the next one can be, and reminds you on time. It doesn\'t give medical advice.'**
  String get aboutIntro;

  /// Small print at the bottom of the About screen: no cloud copy, so save backups.
  ///
  /// In en, this message translates to:
  /// **'One trade-off worth knowing: there is no cloud copy, so a lost or wiped phone means lost history. Save a backup file from Settings now and then, and keep it somewhere other than this phone.'**
  String get aboutTradeOff;

  /// Last line of the About screen: {version} is the app version, e.g. '1.2.0'.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionNumber(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
