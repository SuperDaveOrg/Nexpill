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

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String durationHours(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String durationMinutes(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} {minutes}'**
  String durationHoursMinutes(String hours, String minutes);

  /// No description provided for @skippedDose.
  ///
  /// In en, this message translates to:
  /// **'Skipped the {time} dose'**
  String skippedDose(String time);

  /// No description provided for @listAnd.
  ///
  /// In en, this message translates to:
  /// **'{items} and {last}'**
  String listAnd(String items, String last);

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @scheduleEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {duration}'**
  String scheduleEvery(String duration);

  /// No description provided for @scheduleAt.
  ///
  /// In en, this message translates to:
  /// **'At {times}'**
  String scheduleAt(String times);

  /// No description provided for @scheduleAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed, at least {duration} apart'**
  String scheduleAsNeeded(String duration);

  /// No description provided for @taperNoSteps.
  ///
  /// In en, this message translates to:
  /// **'Taper with no steps'**
  String get taperNoSteps;

  /// No description provided for @taperStepFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String taperStepFrom(String date);

  /// No description provided for @taperStepRange.
  ///
  /// In en, this message translates to:
  /// **'{from} to {until}'**
  String taperStepRange(String from, String until);

  /// No description provided for @taperStep.
  ///
  /// In en, this message translates to:
  /// **'{when}: every {duration}'**
  String taperStep(String when, String duration);

  /// No description provided for @taperFinished.
  ///
  /// In en, this message translates to:
  /// **'Taper finished'**
  String get taperFinished;

  /// No description provided for @scheduleOnce.
  ///
  /// In en, this message translates to:
  /// **'Once, {when}'**
  String scheduleOnce(String when);

  /// No description provided for @scheduleOnceToday.
  ///
  /// In en, this message translates to:
  /// **'Once, today at {time}'**
  String scheduleOnceToday(String time);

  /// No description provided for @singleDoseFinished.
  ///
  /// In en, this message translates to:
  /// **'Single dose logged'**
  String get singleDoseFinished;

  /// No description provided for @taperShortEvery.
  ///
  /// In en, this message translates to:
  /// **'Taper: every {duration}'**
  String taperShortEvery(String duration);

  /// No description provided for @taperShortFrom.
  ///
  /// In en, this message translates to:
  /// **'{text} from {date}'**
  String taperShortFrom(String text, String date);

  /// No description provided for @taperShortUntil.
  ///
  /// In en, this message translates to:
  /// **'{text} until {date}'**
  String taperShortUntil(String text, String date);

  /// No description provided for @taperShortThen.
  ///
  /// In en, this message translates to:
  /// **'{text}, then every {duration}'**
  String taperShortThen(String text, String duration);

  /// No description provided for @statusNotGiven.
  ///
  /// In en, this message translates to:
  /// **'Not given yet'**
  String get statusNotGiven;

  /// No description provided for @statusCanGiveNow.
  ///
  /// In en, this message translates to:
  /// **'Can be given now'**
  String get statusCanGiveNow;

  /// No description provided for @statusDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get statusDueNow;

  /// No description provided for @statusNextAt.
  ///
  /// In en, this message translates to:
  /// **'Next at {time}'**
  String statusNextAt(String time);

  /// No description provided for @statusOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {duration}'**
  String statusOverdueBy(String duration);

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed: was due {duration} ago'**
  String statusMissed(String duration);

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get remindersOn;

  /// No description provided for @remindersEarly.
  ///
  /// In en, this message translates to:
  /// **'{duration} early'**
  String remindersEarly(String duration);

  /// No description provided for @remindersAlarm.
  ///
  /// In en, this message translates to:
  /// **'as an alarm'**
  String get remindersAlarm;

  /// No description provided for @whenToday.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String whenToday(String time);

  /// No description provided for @whenTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow at {time}'**
  String whenTomorrow(String time);

  /// No description provided for @whenYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday at {time}'**
  String whenYesterday(String time);

  /// No description provided for @whenOnDay.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String whenOnDay(String date, String time);

  /// No description provided for @shortMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String shortMinutes(int count);

  /// No description provided for @shortHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hr'**
  String shortHours(int count);

  /// No description provided for @shortHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String shortHoursMinutes(int hours, int minutes);

  /// No description provided for @shortDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String shortDays(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @courseFinishedLastDay.
  ///
  /// In en, this message translates to:
  /// **'Course finished: last day was {date}'**
  String courseFinishedLastDay(String date);

  /// No description provided for @courseFinishedDoses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Course finished: its 1 dose given} other{Course finished: all {count} doses given}}'**
  String courseFinishedDoses(int count);

  /// No description provided for @courseLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day {date}'**
  String courseLastDay(String date);

  /// No description provided for @courseDosesSoFar.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{1 dose, {given} given so far} other{{total} doses, {given} given so far}}'**
  String courseDosesSoFar(int total, Object given);

  /// No description provided for @courseShortLastDay.
  ///
  /// In en, this message translates to:
  /// **'last day {date}'**
  String courseShortLastDay(String date);

  /// No description provided for @courseDosesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose left} other{{count} doses left}}'**
  String courseDosesLeft(int count);

  /// No description provided for @cardFirstDue.
  ///
  /// In en, this message translates to:
  /// **'First due {when}'**
  String cardFirstDue(String when);

  /// No description provided for @cardAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get cardAsNeeded;

  /// No description provided for @cardAvailableFrom.
  ///
  /// In en, this message translates to:
  /// **'Next dose from {when}'**
  String cardAvailableFrom(String when);

  /// No description provided for @cardNextDose.
  ///
  /// In en, this message translates to:
  /// **'Next dose {when}'**
  String cardNextDose(String when);

  /// No description provided for @cardIn.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String cardIn(String duration);

  /// No description provided for @cardDueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {duration}'**
  String cardDueIn(String duration);

  /// No description provided for @cardAt.
  ///
  /// In en, this message translates to:
  /// **'at {when}'**
  String cardAt(String when);

  /// No description provided for @cardSince.
  ///
  /// In en, this message translates to:
  /// **'since {when}'**
  String cardSince(String when);

  /// No description provided for @cardOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue {duration}'**
  String cardOverdue(String duration);

  /// No description provided for @cardWasDue.
  ///
  /// In en, this message translates to:
  /// **'was due {when}'**
  String cardWasDue(String when);

  /// No description provided for @cardMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get cardMissed;

  /// No description provided for @cardMissedWasDue.
  ///
  /// In en, this message translates to:
  /// **'was due {when}, {duration} ago'**
  String cardMissedWasDue(String when, String duration);

  /// No description provided for @personYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get personYou;

  /// No description provided for @personYouAfterFor.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get personYouAfterFor;

  /// No description provided for @reminderDueAt.
  ///
  /// In en, this message translates to:
  /// **'{medication} due at {time}'**
  String reminderDueAt(String medication, String time);

  /// No description provided for @reminderDueNow.
  ///
  /// In en, this message translates to:
  /// **'{medication} due now'**
  String reminderDueNow(String medication);

  /// No description provided for @reminderOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'{medication} overdue since {time}'**
  String reminderOverdueSince(String medication, String time);

  /// No description provided for @reminderAvailable.
  ///
  /// In en, this message translates to:
  /// **'{medication} can be given again'**
  String reminderAvailable(String medication);

  /// No description provided for @reminderManyFor.
  ///
  /// In en, this message translates to:
  /// **'{count} medications for {person}'**
  String reminderManyFor(int count, String person);

  /// No description provided for @reminderFor.
  ///
  /// In en, this message translates to:
  /// **'For {person}'**
  String reminderFor(String person);

  /// No description provided for @channelAlarms.
  ///
  /// In en, this message translates to:
  /// **'Medication alarms'**
  String get channelAlarms;

  /// No description provided for @channelAlarmsDescription.
  ///
  /// In en, this message translates to:
  /// **'For medications set to ring like an alarm when a dose is due.'**
  String get channelAlarmsDescription;

  /// No description provided for @channelReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get channelReminders;

  /// No description provided for @channelRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Heads-ups, doses due, and overdue doses.'**
  String get channelRemindersDescription;

  /// No description provided for @channelUpkeep.
  ///
  /// In en, this message translates to:
  /// **'Keeping reminders going'**
  String get channelUpkeep;

  /// No description provided for @channelUpkeepDescription.
  ///
  /// In en, this message translates to:
  /// **'A note when Nexpill needs opening so reminders don\'t run out.'**
  String get channelUpkeepDescription;

  /// No description provided for @actionMarkGiven.
  ///
  /// In en, this message translates to:
  /// **'Mark given'**
  String get actionMarkGiven;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min'**
  String actionSnooze(int minutes);

  /// No description provided for @upkeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Nexpill to keep reminders coming'**
  String get upkeepTitle;

  /// No description provided for @upkeepBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are set a week ahead each time Nexpill is used. Open it to set the next ones.'**
  String get upkeepBody;

  /// No description provided for @testReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testReminderTitle;

  /// No description provided for @testReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are working. This is how they\'ll look.'**
  String get testReminderBody;

  /// No description provided for @csvGivenAt.
  ///
  /// In en, this message translates to:
  /// **'Given at'**
  String get csvGivenAt;

  /// No description provided for @csvGivenAtUtc.
  ///
  /// In en, this message translates to:
  /// **'Given at (UTC)'**
  String get csvGivenAtUtc;

  /// No description provided for @csvPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get csvPatient;

  /// No description provided for @csvMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get csvMedication;

  /// No description provided for @csvDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get csvDose;

  /// No description provided for @csvGivenBy.
  ///
  /// In en, this message translates to:
  /// **'Given by'**
  String get csvGivenBy;

  /// No description provided for @csvNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get csvNotes;

  /// No description provided for @csvStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get csvStatus;

  /// No description provided for @csvCorrects.
  ///
  /// In en, this message translates to:
  /// **'Corrects entry'**
  String get csvCorrects;

  /// No description provided for @csvEntry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get csvEntry;

  /// No description provided for @csvReplaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced by a correction'**
  String get csvReplaced;

  /// No description provided for @csvSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get csvSkipped;

  /// No description provided for @csvCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get csvCorrection;

  /// No description provided for @csvGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get csvGiven;

  /// No description provided for @summaryTitleFor.
  ///
  /// In en, this message translates to:
  /// **'Medication summary for {name}'**
  String summaryTitleFor(String name);

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication summary'**
  String get summaryTitle;

  /// No description provided for @summaryAsOf.
  ///
  /// In en, this message translates to:
  /// **'As of {dateTime}. Active medications only.'**
  String summaryAsOf(String dateTime);

  /// No description provided for @summaryNotAdvice.
  ///
  /// In en, this message translates to:
  /// **'From Nexpill, a timing tracker. Not medical advice.'**
  String get summaryNotAdvice;

  /// No description provided for @summaryNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active medications.'**
  String get summaryNoActive;

  /// No description provided for @summaryPurpose.
  ///
  /// In en, this message translates to:
  /// **'For: {value}'**
  String summaryPurpose(String value);

  /// No description provided for @summaryDose.
  ///
  /// In en, this message translates to:
  /// **'Dose: {value}'**
  String summaryDose(String value);

  /// No description provided for @summarySchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule: {value}'**
  String summarySchedule(String value);

  /// No description provided for @summaryCourse.
  ///
  /// In en, this message translates to:
  /// **'Course: {value}'**
  String summaryCourse(String value);

  /// No description provided for @summaryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions: {value}'**
  String summaryInstructions(String value);

  /// No description provided for @summaryLastGiven.
  ///
  /// In en, this message translates to:
  /// **'Last given: {value}'**
  String summaryLastGiven(String value);

  /// No description provided for @summaryNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get summaryNotYet;

  /// No description provided for @summaryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String summaryStatus(String value);

  /// No description provided for @summaryReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders: {value}'**
  String summaryReminders(String value);

  /// No description provided for @summaryRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {value}'**
  String summaryRemaining(String value);

  /// No description provided for @summaryRunningLow.
  ///
  /// In en, this message translates to:
  /// **'{amount} (running low)'**
  String summaryRunningLow(String amount);

  /// No description provided for @summaryNoneLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} (none left)'**
  String summaryNoneLeft(String amount);

  /// No description provided for @backupNotNexpill.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Nexpill backup.'**
  String get backupNotNexpill;

  /// No description provided for @backupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer version of Nexpill. Update the app, then try again.'**
  String get backupTooNew;

  /// No description provided for @backupTwoOfYou.
  ///
  /// In en, this message translates to:
  /// **'More than one person in this file is marked as you.'**
  String get backupTwoOfYou;

  /// No description provided for @backupCorrectsMissing.
  ///
  /// In en, this message translates to:
  /// **'A dose of {medication} corrects one that isn\'t in its history.'**
  String backupCorrectsMissing(String medication);

  /// No description provided for @backupCorrectionsCircle.
  ///
  /// In en, this message translates to:
  /// **'Corrections to {medication}\'s doses go round in a circle.'**
  String backupCorrectionsCircle(String medication);

  /// No description provided for @backupCourseBoth.
  ///
  /// In en, this message translates to:
  /// **'{where} needs either \"lastDay\" or \"doses\", not both.'**
  String backupCourseBoth(String where);

  /// No description provided for @backupBadTime.
  ///
  /// In en, this message translates to:
  /// **'{where} has a time that isn\'t HH:mm: {time}.'**
  String backupBadTime(String where, String time);

  /// No description provided for @backupUnknownSchedule.
  ///
  /// In en, this message translates to:
  /// **'{where} has an unknown schedule type \"{type}\".'**
  String backupUnknownSchedule(String where, String type);

  /// No description provided for @backupWrongForm.
  ///
  /// In en, this message translates to:
  /// **'{where} isn\'t in the expected form.'**
  String backupWrongForm(String where);

  /// No description provided for @backupMissing.
  ///
  /// In en, this message translates to:
  /// **'{where} is missing \"{key}\" or it is the wrong kind of value.'**
  String backupMissing(String where, String key);

  /// No description provided for @backupEmpty.
  ///
  /// In en, this message translates to:
  /// **'{where} has an empty \"{key}\".'**
  String backupEmpty(String where, String key);

  /// No description provided for @backupImpossible.
  ///
  /// In en, this message translates to:
  /// **'{where} has an impossible \"{key}\": {value}.'**
  String backupImpossible(String where, String key, String value);

  /// No description provided for @backupBadDate.
  ///
  /// In en, this message translates to:
  /// **'{where} has a \"{key}\" that isn\'t a YYYY-MM-DD date.'**
  String backupBadDate(String where, String key);

  /// No description provided for @backupBadInstant.
  ///
  /// In en, this message translates to:
  /// **'{where} has a \"{key}\" that isn\'t a date and time with a time zone.'**
  String backupBadInstant(String where, String key);

  /// No description provided for @backupDuplicateId.
  ///
  /// In en, this message translates to:
  /// **'The id \"{id}\" appears more than once.'**
  String backupDuplicateId(String id);

  /// No description provided for @backupNone.
  ///
  /// In en, this message translates to:
  /// **'{where} has no \"{key}\".'**
  String backupNone(String where, String key);

  /// No description provided for @backupWhereFile.
  ///
  /// In en, this message translates to:
  /// **'The file'**
  String get backupWhereFile;

  /// No description provided for @backupWhereItem.
  ///
  /// In en, this message translates to:
  /// **'{where}, {key} {number}'**
  String backupWhereItem(String where, String key, int number);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file.'**
  String get couldNotSave;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @cardMoreFor.
  ///
  /// In en, this message translates to:
  /// **'More for {medication}'**
  String cardMoreFor(String medication);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @doseHistory.
  ///
  /// In en, this message translates to:
  /// **'Dose history'**
  String get doseHistory;

  /// No description provided for @skipTheDose.
  ///
  /// In en, this message translates to:
  /// **'Skip the {time} dose'**
  String skipTheDose(String time);

  /// No description provided for @stopTaking.
  ///
  /// In en, this message translates to:
  /// **'Stop taking'**
  String get stopTaking;

  /// No description provided for @lastGiven.
  ///
  /// In en, this message translates to:
  /// **'Last given {when}'**
  String lastGiven(String when);

  /// No description provided for @lastGivenBy.
  ///
  /// In en, this message translates to:
  /// **'Last given {when} by {name}'**
  String lastGivenBy(String when, String name);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @give.
  ///
  /// In en, this message translates to:
  /// **'Give'**
  String get give;

  /// No description provided for @supplyLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String supplyLeft(String amount);

  /// No description provided for @supplyNoneLeft.
  ///
  /// In en, this message translates to:
  /// **'None left: time to refill'**
  String get supplyNoneLeft;

  /// No description provided for @supplyRunningLow.
  ///
  /// In en, this message translates to:
  /// **'{left}: running low'**
  String supplyRunningLow(String left);

  /// No description provided for @earlyTitle.
  ///
  /// In en, this message translates to:
  /// **'This is early'**
  String get earlyTitle;

  /// No description provided for @earlyMessageDue.
  ///
  /// In en, this message translates to:
  /// **'{medication} is next due {when}, in {duration}. Log a dose now anyway?'**
  String earlyMessageDue(String medication, String when, String duration);

  /// No description provided for @earlyMessageAvailable.
  ///
  /// In en, this message translates to:
  /// **'{medication} can next be given {when}, in {duration}. Log a dose now anyway?'**
  String earlyMessageAvailable(String medication, String when, String duration);

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @logItNow.
  ///
  /// In en, this message translates to:
  /// **'Log it now'**
  String get logItNow;

  /// No description provided for @dayGiven.
  ///
  /// In en, this message translates to:
  /// **'Day it was given'**
  String get dayGiven;

  /// No description provided for @timeGiven.
  ///
  /// In en, this message translates to:
  /// **'Time it was given'**
  String get timeGiven;

  /// No description provided for @timeInFuture.
  ///
  /// In en, this message translates to:
  /// **'That time hasn\'t happened yet.'**
  String get timeInFuture;

  /// No description provided for @correctEntry.
  ///
  /// In en, this message translates to:
  /// **'Correct this {medication} entry'**
  String correctEntry(String medication);

  /// No description provided for @giveMedication.
  ///
  /// In en, this message translates to:
  /// **'Give {medication}'**
  String giveMedication(String medication);

  /// No description provided for @originalStays.
  ///
  /// In en, this message translates to:
  /// **'The original stays in history, marked as corrected.'**
  String get originalStays;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @givenWhen.
  ///
  /// In en, this message translates to:
  /// **'Given {when}'**
  String givenWhen(String when);

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @givenBy.
  ///
  /// In en, this message translates to:
  /// **'Given by'**
  String get givenBy;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @saveCorrection.
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get saveCorrection;

  /// No description provided for @logDose.
  ///
  /// In en, this message translates to:
  /// **'Log dose'**
  String get logDose;

  /// No description provided for @doseHistorySaved.
  ///
  /// In en, this message translates to:
  /// **'Dose history saved'**
  String get doseHistorySaved;

  /// No description provided for @correctTimeOrDetails.
  ///
  /// In en, this message translates to:
  /// **'Correct time or details'**
  String get correctTimeOrDetails;

  /// No description provided for @keepsOriginal.
  ///
  /// In en, this message translates to:
  /// **'Keeps the original, marked as corrected'**
  String get keepsOriginal;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntrySkippedHint.
  ///
  /// In en, this message translates to:
  /// **'The dose becomes due again'**
  String get deleteEntrySkippedHint;

  /// No description provided for @deleteEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Only for a dose that was never given'**
  String get deleteEntryHint;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteSkippedMessage.
  ///
  /// In en, this message translates to:
  /// **'{medication}, {dateTime}, skipped. Delete it if the dose wasn\'t meant to be skipped.'**
  String deleteSkippedMessage(String medication, String dateTime);

  /// No description provided for @deleteDoseMessage.
  ///
  /// In en, this message translates to:
  /// **'{medication}, {dateTime}. Use this only if the dose was never given; to fix its time, correct it instead. Any corrections of it go too.'**
  String deleteDoseMessage(String medication, String dateTime);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yourDoses.
  ///
  /// In en, this message translates to:
  /// **'Your doses'**
  String get yourDoses;

  /// No description provided for @personsDoses.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s doses'**
  String personsDoses(String name);

  /// No description provided for @doses.
  ///
  /// In en, this message translates to:
  /// **'Doses'**
  String get doses;

  /// No description provided for @saveAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Save as a spreadsheet (CSV)'**
  String get saveAsCsv;

  /// No description provided for @onlyMedication.
  ///
  /// In en, this message translates to:
  /// **'Only {medication}'**
  String onlyMedication(String medication);

  /// No description provided for @nothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get nothingLogged;

  /// No description provided for @historyBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String historyBy(String name);

  /// No description provided for @historyCorrection.
  ///
  /// In en, this message translates to:
  /// **'correction'**
  String get historyCorrection;

  /// No description provided for @historyCorrected.
  ///
  /// In en, this message translates to:
  /// **'corrected'**
  String get historyCorrected;

  /// No description provided for @defaultDose.
  ///
  /// In en, this message translates to:
  /// **'1 tablet'**
  String get defaultDose;

  /// No description provided for @errorName.
  ///
  /// In en, this message translates to:
  /// **'Give the medication a name.'**
  String get errorName;

  /// No description provided for @errorDose.
  ///
  /// In en, this message translates to:
  /// **'Say what one dose is, like \"1 tablet\".'**
  String get errorDose;

  /// No description provided for @errorHowOften.
  ///
  /// In en, this message translates to:
  /// **'Choose how often.'**
  String get errorHowOften;

  /// No description provided for @errorShortestGap.
  ///
  /// In en, this message translates to:
  /// **'Choose the shortest gap between doses.'**
  String get errorShortestGap;

  /// No description provided for @errorAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time.'**
  String get errorAddTime;

  /// No description provided for @errorDosesStillToGive.
  ///
  /// In en, this message translates to:
  /// **'Enter how many doses are still to give.'**
  String get errorDosesStillToGive;

  /// No description provided for @errorCourseDoses.
  ///
  /// In en, this message translates to:
  /// **'Enter how many doses the course has.'**
  String get errorCourseDoses;

  /// No description provided for @errorStartingSupply.
  ///
  /// In en, this message translates to:
  /// **'Enter how much there is to start with.'**
  String get errorStartingSupply;

  /// No description provided for @errorPerDose.
  ///
  /// In en, this message translates to:
  /// **'Enter how much one dose uses.'**
  String get errorPerDose;

  /// No description provided for @errorLowAt.
  ///
  /// In en, this message translates to:
  /// **'Enter when to warn, or leave it empty.'**
  String get errorLowAt;

  /// No description provided for @errorNoSteps.
  ///
  /// In en, this message translates to:
  /// **'Add at least one step.'**
  String get errorNoSteps;

  /// No description provided for @errorStepInterval.
  ///
  /// In en, this message translates to:
  /// **'Every step needs an interval.'**
  String get errorStepInterval;

  /// No description provided for @errorStepEnds.
  ///
  /// In en, this message translates to:
  /// **'A step has to end after it starts.'**
  String get errorStepEnds;

  /// No description provided for @errorOpenEnded.
  ///
  /// In en, this message translates to:
  /// **'Only the last step can be open-ended.'**
  String get errorOpenEnded;

  /// No description provided for @errorStepsOverlap.
  ///
  /// In en, this message translates to:
  /// **'Two steps overlap.'**
  String get errorStepsOverlap;

  /// No description provided for @deleteMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {medication}?'**
  String deleteMedicationTitle(String medication);

  /// No description provided for @deleteMedicationMessage.
  ///
  /// In en, this message translates to:
  /// **'Its dose history goes with it. To stop it but keep the history, turn off \"Taking this now\" instead.'**
  String get deleteMedicationMessage;

  /// No description provided for @newMedication.
  ///
  /// In en, this message translates to:
  /// **'New medication'**
  String get newMedication;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit {medication}'**
  String editMedication(String medication);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @forPerson.
  ///
  /// In en, this message translates to:
  /// **'For {person}'**
  String forPerson(String person);

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amoxicillin'**
  String get fieldNameHint;

  /// No description provided for @fieldStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get fieldStrength;

  /// No description provided for @fieldStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. 500 mg'**
  String get fieldStrengthHint;

  /// No description provided for @fieldPurpose.
  ///
  /// In en, this message translates to:
  /// **'What it\'s for'**
  String get fieldPurpose;

  /// No description provided for @fieldPurposeHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. blood pressure'**
  String get fieldPurposeHint;

  /// No description provided for @fieldUsualDose.
  ///
  /// In en, this message translates to:
  /// **'Usual dose'**
  String get fieldUsualDose;

  /// No description provided for @fieldUsualDoseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tablet, 5 ml'**
  String get fieldUsualDoseHint;

  /// No description provided for @fieldInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get fieldInstructions;

  /// No description provided for @fieldInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. with food'**
  String get fieldInstructionsHint;

  /// No description provided for @sectionWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get sectionWhen;

  /// No description provided for @sectionHowLong.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get sectionHowLong;

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get sectionReminders;

  /// No description provided for @sectionSupply.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get sectionSupply;

  /// No description provided for @takingThisNow.
  ///
  /// In en, this message translates to:
  /// **'Taking this now'**
  String get takingThisNow;

  /// No description provided for @takingThisNowHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off when it\'s stopped. It keeps its history but stops reminding.'**
  String get takingThisNowHint;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete medication'**
  String get deleteMedication;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get addMedication;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @kindInterval.
  ///
  /// In en, this message translates to:
  /// **'Every few hours'**
  String get kindInterval;

  /// No description provided for @kindFixedTimes.
  ///
  /// In en, this message translates to:
  /// **'At set times'**
  String get kindFixedTimes;

  /// No description provided for @kindAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get kindAsNeeded;

  /// No description provided for @kindTaper.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get kindTaper;

  /// No description provided for @kindOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get kindOnce;

  /// No description provided for @every.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get every;

  /// No description provided for @intervalHint.
  ///
  /// In en, this message translates to:
  /// **'Counted from the last dose given.'**
  String get intervalHint;

  /// No description provided for @atLeastApart.
  ///
  /// In en, this message translates to:
  /// **'At least this long apart'**
  String get atLeastApart;

  /// No description provided for @asNeededHint.
  ///
  /// In en, this message translates to:
  /// **'Never \"due\" — Nexpill shows when it can be given again.'**
  String get asNeededHint;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @fixedTimesHint.
  ///
  /// In en, this message translates to:
  /// **'Every day, on this phone\'s clock.'**
  String get fixedTimesHint;

  /// No description provided for @timeOfDose.
  ///
  /// In en, this message translates to:
  /// **'Time of dose'**
  String get timeOfDose;

  /// No description provided for @onceHint.
  ///
  /// In en, this message translates to:
  /// **'A single dose. Once it\'s given or skipped it\'s finished, and stays in history.'**
  String get onceHint;

  /// No description provided for @dayOfDose.
  ///
  /// In en, this message translates to:
  /// **'Day of the dose'**
  String get dayOfDose;

  /// No description provided for @courseUntilStopped.
  ///
  /// In en, this message translates to:
  /// **'Until stopped'**
  String get courseUntilStopped;

  /// No description provided for @courseUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Until a date'**
  String get courseUntilDate;

  /// No description provided for @courseNumberOfDoses.
  ///
  /// In en, this message translates to:
  /// **'A number of doses'**
  String get courseNumberOfDoses;

  /// No description provided for @courseOngoingHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders carry on until you turn off \"Taking this now\".'**
  String get courseOngoingHint;

  /// No description provided for @courseLastDayChip.
  ///
  /// In en, this message translates to:
  /// **'Last day: {date}'**
  String courseLastDayChip(String date);

  /// No description provided for @courseLastDayHint.
  ///
  /// In en, this message translates to:
  /// **'Doses carry on through that day; reminders stop at midnight at the end of it.'**
  String get courseLastDayHint;

  /// No description provided for @dosesStillToGive.
  ///
  /// In en, this message translates to:
  /// **'Doses still to give'**
  String get dosesStillToGive;

  /// No description provided for @numberOfDoses.
  ///
  /// In en, this message translates to:
  /// **'Number of doses'**
  String get numberOfDoses;

  /// No description provided for @dosesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10'**
  String get dosesHint;

  /// No description provided for @courseDosesHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders stop once the last one is given.'**
  String get courseDosesHint;

  /// No description provided for @courseDosesGivenHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose given so far. Reminders stop once the last one is given.} other{{count} doses given so far. Reminders stop once the last one is given.}}'**
  String courseDosesGivenHint(int count);

  /// No description provided for @lastDayOfCourse.
  ///
  /// In en, this message translates to:
  /// **'Last day of the course'**
  String get lastDayOfCourse;

  /// No description provided for @taperStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String taperStepNumber(int number);

  /// No description provided for @removeStep.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get removeStep;

  /// No description provided for @stepFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String stepFrom(String date);

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @stepUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String stepUntil(String date);

  /// No description provided for @clearEnd.
  ///
  /// In en, this message translates to:
  /// **'Clear end'**
  String get clearEnd;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add a step'**
  String get addStep;

  /// No description provided for @taperHint.
  ///
  /// In en, this message translates to:
  /// **'Each step runs from midnight on its first day until midnight on its end day. The last step can be open-ended.'**
  String get taperHint;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindAsNeededHint.
  ///
  /// In en, this message translates to:
  /// **'When it can be given again.'**
  String get remindAsNeededHint;

  /// No description provided for @remindHint.
  ///
  /// In en, this message translates to:
  /// **'When a dose is due, and again while it\'s overdue.'**
  String get remindHint;

  /// No description provided for @headsUp.
  ///
  /// In en, this message translates to:
  /// **'Heads-up before it\'s due'**
  String get headsUp;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @repeatWhileOverdue.
  ///
  /// In en, this message translates to:
  /// **'Repeat while overdue'**
  String get repeatWhileOverdue;

  /// No description provided for @everyDuration.
  ///
  /// In en, this message translates to:
  /// **'every {duration}'**
  String everyDuration(String duration);

  /// No description provided for @ringLikeAlarm.
  ///
  /// In en, this message translates to:
  /// **'Ring like an alarm'**
  String get ringLikeAlarm;

  /// No description provided for @ringLikeAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'The alarm sound, repeating until you mark it given or snooze it.'**
  String get ringLikeAlarmHint;

  /// No description provided for @trackSupply.
  ///
  /// In en, this message translates to:
  /// **'Track how much is left'**
  String get trackSupply;

  /// No description provided for @trackSupplyHint.
  ///
  /// In en, this message translates to:
  /// **'Counts down with each dose logged.'**
  String get trackSupplyHint;

  /// No description provided for @startingAmount.
  ///
  /// In en, this message translates to:
  /// **'Starting amount'**
  String get startingAmount;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get unitHint;

  /// No description provided for @eachDoseUses.
  ///
  /// In en, this message translates to:
  /// **'Each dose uses'**
  String get eachDoseUses;

  /// No description provided for @warnAt.
  ///
  /// In en, this message translates to:
  /// **'Warn at'**
  String get warnAt;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @managePeople.
  ///
  /// In en, this message translates to:
  /// **'Manage people'**
  String get managePeople;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addSomeone.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get addSomeone;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @nothingToGiveNow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to give now'**
  String get nothingToGiveNow;

  /// No description provided for @moreDueNow.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more due now'**
  String moreDueNow(int count);

  /// No description provided for @remindersOffShort.
  ///
  /// In en, this message translates to:
  /// **'Reminders off'**
  String get remindersOffShort;

  /// No description provided for @errorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get errorEnterName;

  /// No description provided for @errorNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone already has that name.'**
  String get errorNameTaken;

  /// No description provided for @whoAreYouCaringFor.
  ///
  /// In en, this message translates to:
  /// **'Who are you caring for?'**
  String get whoAreYouCaringFor;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'A first name or nickname is fine'**
  String get nameHint;

  /// No description provided for @thisIsMe.
  ///
  /// In en, this message translates to:
  /// **'This is me'**
  String get thisIsMe;

  /// No description provided for @forYourOwnMedications.
  ///
  /// In en, this message translates to:
  /// **'For your own medications'**
  String get forYourOwnMedications;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteYourMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your medications?'**
  String get deleteYourMedicationsTitle;

  /// No description provided for @deletePersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deletePersonTitle(String name);

  /// No description provided for @deleteYourMedicationsMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your medication and all dose history go too, and can\'t be brought back unless you have a backup file.} other{Your {count} medications and all dose history go too, and can\'t be brought back unless you have a backup file.}}'**
  String deleteYourMedicationsMessage(int count);

  /// No description provided for @deletePersonMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Their medication and all dose history go too, and can\'t be brought back unless you have a backup file.} other{Their {count} medications and all dose history go too, and can\'t be brought back unless you have a backup file.}}'**
  String deletePersonMessage(int count);

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @tapToSeeThem.
  ///
  /// In en, this message translates to:
  /// **'{count} · tap to see them'**
  String tapToSeeThem(String count);

  /// No description provided for @addYourName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get addYourName;

  /// No description provided for @asSetForEach.
  ///
  /// In en, this message translates to:
  /// **'As set for each medication'**
  String get asSetForEach;

  /// No description provided for @allOffFor.
  ///
  /// In en, this message translates to:
  /// **'All off for {person}'**
  String allOffFor(String person);

  /// No description provided for @medicationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medication} other{{count} medications}}'**
  String medicationCount(int count);

  /// No description provided for @doseLogged.
  ///
  /// In en, this message translates to:
  /// **'{medication} logged, {when}'**
  String doseLogged(String medication, String when);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @skippedInARow.
  ///
  /// In en, this message translates to:
  /// **'{medication}: skipped {count} times in a row'**
  String skippedInARow(String medication, int count);

  /// No description provided for @medicationSkipped.
  ///
  /// In en, this message translates to:
  /// **'{medication}: {skipped}'**
  String medicationSkipped(String medication, String skipped);

  /// No description provided for @remindersOffFor.
  ///
  /// In en, this message translates to:
  /// **'Reminders off for {medication}. Turn them on again in Edit.'**
  String remindersOffFor(String medication);

  /// No description provided for @medicationStopped.
  ///
  /// In en, this message translates to:
  /// **'{medication} stopped. Its history is kept.'**
  String medicationStopped(String medication);

  /// No description provided for @remindersAreOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get remindersAreOff;

  /// No description provided for @allowNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so they can reach you.'**
  String get allowNotificationsHint;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @remindersAreOffFor.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off for {person}.'**
  String remindersAreOffFor(String person);

  /// No description provided for @addYourFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first one, and Nexpill will keep track of when each dose can be given.'**
  String get addYourFirst;

  /// No description provided for @addPersonsFirst.
  ///
  /// In en, this message translates to:
  /// **'Add {name}\'s first one, and Nexpill will keep track of when each dose can be given.'**
  String addPersonsFirst(String name);

  /// No description provided for @allEndedForYou.
  ///
  /// In en, this message translates to:
  /// **'Everything for you has finished or been stopped. It\'s all below, with its history.'**
  String get allEndedForYou;

  /// No description provided for @allEndedForPerson.
  ///
  /// In en, this message translates to:
  /// **'Everything for {name} has finished or been stopped. It\'s all below, with its history.'**
  String allEndedForPerson(String name);

  /// No description provided for @addAMedication.
  ///
  /// In en, this message translates to:
  /// **'Add a medication'**
  String get addAMedication;

  /// No description provided for @addAnotherMedication.
  ///
  /// In en, this message translates to:
  /// **'Add another medication'**
  String get addAnotherMedication;

  /// No description provided for @addMedicationFor.
  ///
  /// In en, this message translates to:
  /// **'Add a medication for {name}'**
  String addMedicationFor(String name);

  /// No description provided for @endedStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped ({count})'**
  String endedStopped(int count);

  /// No description provided for @endedFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished ({count})'**
  String endedFinished(int count);

  /// No description provided for @endedBoth.
  ///
  /// In en, this message translates to:
  /// **'Finished and stopped ({count})'**
  String endedBoth(int count);

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @logoLabel.
  ///
  /// In en, this message translates to:
  /// **'Nexpill logo'**
  String get logoLabel;

  /// No description provided for @welcomeWhat.
  ///
  /// In en, this message translates to:
  /// **'Keeps track of when each dose was given and when the next one can be, and reminds you on time.'**
  String get welcomeWhat;

  /// No description provided for @welcomePrivate.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. No account, no internet.'**
  String get welcomePrivate;

  /// No description provided for @whoAreTheMedicationsFor.
  ///
  /// In en, this message translates to:
  /// **'Who are the medications for?'**
  String get whoAreTheMedicationsFor;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @someoneICareFor.
  ///
  /// In en, this message translates to:
  /// **'Someone I care for'**
  String get someoneICareFor;

  /// No description provided for @addMoreLater.
  ///
  /// In en, this message translates to:
  /// **'You can add more people later.'**
  String get addMoreLater;

  /// No description provided for @noBrowser.
  ///
  /// In en, this message translates to:
  /// **'No browser to open it with. Visit {website} instead.'**
  String noBrowser(String website);

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that file.'**
  String get couldNotOpen;

  /// No description provided for @cantRestore.
  ///
  /// In en, this message translates to:
  /// **'Can\'t restore this file'**
  String get cantRestore;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything with this backup?'**
  String get restoreTitle;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @dosesLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose logged} other{{count} doses logged}}'**
  String dosesLoggedCount(int count);

  /// No description provided for @restoreMessage.
  ///
  /// In en, this message translates to:
  /// **'It has {people}, {medications} and {doses}. Everything now on this phone will be replaced by it.'**
  String restoreMessage(String people, String medications, String doses);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// No description provided for @summaryFor.
  ///
  /// In en, this message translates to:
  /// **'Summary for'**
  String get summaryFor;

  /// No description provided for @summarySaved.
  ///
  /// In en, this message translates to:
  /// **'Summary saved'**
  String get summarySaved;

  /// No description provided for @yourNameOnSummary.
  ///
  /// In en, this message translates to:
  /// **'Your name on the summary'**
  String get yourNameOnSummary;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'Every person, medication and dose on this phone, and every reminder. This can\'t be undone; if you might want it back, save a backup first.'**
  String get deleteAllMessage;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsOff;

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get notificationsOn;

  /// No description provided for @notificationsOffHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders can\'t be shown until they\'re allowed.'**
  String get notificationsOffHint;

  /// No description provided for @notificationsOnHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders will show on this phone.'**
  String get notificationsOnHint;

  /// No description provided for @mayBeLate.
  ///
  /// In en, this message translates to:
  /// **'Reminders may be late'**
  String get mayBeLate;

  /// No description provided for @mayBeLateHint.
  ///
  /// In en, this message translates to:
  /// **'Android has turned off exact alarms for Nexpill. Turn \"Alarms & reminders\" back on in the phone\'s settings for the app.'**
  String get mayBeLateHint;

  /// No description provided for @sendTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test reminder'**
  String get sendTest;

  /// No description provided for @sendTestHint.
  ///
  /// In en, this message translates to:
  /// **'Arrives in a few seconds.'**
  String get sendTestHint;

  /// No description provided for @testOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'Test reminder on its way'**
  String get testOnItsWay;

  /// No description provided for @peopleYouCareFor.
  ///
  /// In en, this message translates to:
  /// **'People you care for'**
  String get peopleYouCareFor;

  /// No description provided for @onThisPhone.
  ///
  /// In en, this message translates to:
  /// **'{count} on this phone'**
  String onThisPhone(int count);

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @backUp.
  ///
  /// In en, this message translates to:
  /// **'Back up to a file'**
  String get backUp;

  /// No description provided for @backUpHint.
  ///
  /// In en, this message translates to:
  /// **'Everything, saved wherever you choose.'**
  String get backUpHint;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get restore;

  /// No description provided for @restoreHint.
  ///
  /// In en, this message translates to:
  /// **'Replaces what\'s on this phone.'**
  String get restoreHint;

  /// No description provided for @medicationSummary.
  ///
  /// In en, this message translates to:
  /// **'Medication summary'**
  String get medicationSummary;

  /// No description provided for @medicationSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Plain text, for a doctor or a handover.'**
  String get medicationSummaryHint;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutNexpill.
  ///
  /// In en, this message translates to:
  /// **'About Nexpill'**
  String get aboutNexpill;

  /// No description provided for @aboutNexpillHint.
  ///
  /// In en, this message translates to:
  /// **'Where your data lives, and why it\'s free'**
  String get aboutNexpillHint;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'A form on the website, in your browser.'**
  String get sendFeedbackHint;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sameAsPhone.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone'**
  String get sameAsPhone;

  /// No description provided for @sameAsPhoneNow.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone: {language}'**
  String sameAsPhoneNow(String language);

  /// No description provided for @aboutStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'It stays on your phone'**
  String get aboutStaysTitle;

  /// No description provided for @aboutStaysBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you log is written to a database on this device. There is no account and no server. It only goes anywhere else if you move it yourself, as a backup file or an export.'**
  String get aboutStaysBody;

  /// No description provided for @aboutCannotSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'We cannot see it'**
  String get aboutCannotSeeTitle;

  /// No description provided for @aboutCannotSeeBody.
  ///
  /// In en, this message translates to:
  /// **'Nexpill is built without permission to use the internet at all. Android enforces that, and you can check it in the app\'s permission list.'**
  String get aboutCannotSeeBody;

  /// No description provided for @aboutRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders come from the phone itself'**
  String get aboutRemindersTitle;

  /// No description provided for @aboutRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Each reminder is an alarm this phone holds, so it arrives on time with no signal, in airplane mode, and after a restart.'**
  String get aboutRemindersBody;

  /// No description provided for @aboutPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What the permissions are for'**
  String get aboutPermissionsTitle;

  /// No description provided for @aboutPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications, for reminders. Exact alarms, so they arrive on the minute. Starting after a restart, to set them again. Vibration. That is the whole list.'**
  String get aboutPermissionsBody;

  /// No description provided for @aboutFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free, for good'**
  String get aboutFreeTitle;

  /// No description provided for @aboutFreeBody.
  ///
  /// In en, this message translates to:
  /// **'Nexpill was written by a caregiver, for caregivers. It will always be free and open source: no price, no premium tier, no ads.'**
  String get aboutFreeBody;

  /// No description provided for @aboutCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'You can check our work'**
  String get aboutCheckTitle;

  /// No description provided for @aboutCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Nexpill is open source under the GNU General Public License. Anyone can read exactly what it does.'**
  String get aboutCheckBody;

  /// No description provided for @aboutHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your records stay with you.'**
  String get aboutHeadline;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'Nexpill keeps track of when each dose was given and when the next one can be, and reminds you on time. It doesn\'t give medical advice.'**
  String get aboutIntro;

  /// No description provided for @aboutTradeOff.
  ///
  /// In en, this message translates to:
  /// **'One trade-off worth knowing: there is no cloud copy, so a lost or wiped phone means lost history. Save a backup file from Settings now and then, and keep it somewhere other than this phone.'**
  String get aboutTradeOff;

  /// No description provided for @versionNumber.
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
