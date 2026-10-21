// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Skipped the $time dose';
  }

  @override
  String listAnd(String items, String last) {
    return '$items and $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Every $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'At $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'As needed, at least $duration apart';
  }

  @override
  String get taperNoSteps => 'Taper with no steps';

  @override
  String taperStepFrom(String date) {
    return 'From $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return '$from to $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: every $duration';
  }

  @override
  String get taperFinished => 'Taper finished';

  @override
  String taperShortEvery(String duration) {
    return 'Taper: every $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text from $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text until $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, then every $duration';
  }

  @override
  String get statusNotGiven => 'Not given yet';

  @override
  String get statusCanGiveNow => 'Can be given now';

  @override
  String get statusDueNow => 'Due now';

  @override
  String statusNextAt(String time) {
    return 'Next at $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'Overdue by $duration';
  }

  @override
  String statusMissed(String duration) {
    return 'Missed: was due $duration ago';
  }

  @override
  String get statusFinished => 'Finished';

  @override
  String get remindersOff => 'Off';

  @override
  String get remindersOn => 'On';

  @override
  String remindersEarly(String duration) {
    return '$duration early';
  }

  @override
  String get remindersAlarm => 'as an alarm';

  @override
  String whenToday(String time) {
    return '$time';
  }

  @override
  String whenTomorrow(String time) {
    return 'tomorrow at $time';
  }

  @override
  String whenYesterday(String time) {
    return 'yesterday at $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return '$date at $time';
  }

  @override
  String shortMinutes(int count) {
    return '$count min';
  }

  @override
  String shortHours(int count) {
    return '$count hr';
  }

  @override
  String shortHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String shortDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String courseFinishedLastDay(String date) {
    return 'Course finished: last day was $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Course finished: all $count doses given',
      one: 'Course finished: its 1 dose given',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Last day $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total doses, $given given so far',
      one: '1 dose, $given given so far',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'last day $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses left',
      one: '1 dose left',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'First due $when';
  }

  @override
  String get cardAsNeeded => 'As needed';

  @override
  String cardAvailableFrom(String when) {
    return 'Next dose from $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Next dose $when';
  }

  @override
  String cardIn(String duration) {
    return 'in $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Due in $duration';
  }

  @override
  String cardAt(String when) {
    return 'at $when';
  }

  @override
  String cardSince(String when) {
    return 'since $when';
  }

  @override
  String cardOverdue(String duration) {
    return 'Overdue $duration';
  }

  @override
  String cardWasDue(String when) {
    return 'was due $when';
  }

  @override
  String get cardMissed => 'Missed';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'was due $when, $duration ago';
  }

  @override
  String get personYou => 'You';

  @override
  String get personYouAfterFor => 'you';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication due at $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication due now';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication overdue since $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication can be given again';
  }

  @override
  String reminderManyFor(int count, String person) {
    return '$count medications for $person';
  }

  @override
  String reminderFor(String person) {
    return 'For $person';
  }

  @override
  String get channelAlarms => 'Medication alarms';

  @override
  String get channelAlarmsDescription =>
      'For medications set to ring like an alarm when a dose is due.';

  @override
  String get channelReminders => 'Medication reminders';

  @override
  String get channelRemindersDescription =>
      'Heads-ups, doses due, and overdue doses.';

  @override
  String get channelUpkeep => 'Keeping reminders going';

  @override
  String get channelUpkeepDescription =>
      'A note when Nexpill needs opening so reminders don\'t run out.';

  @override
  String get actionMarkGiven => 'Mark given';

  @override
  String get actionSkip => 'Skip';

  @override
  String actionSnooze(int minutes) {
    return 'Snooze $minutes min';
  }

  @override
  String get upkeepTitle => 'Open Nexpill to keep reminders coming';

  @override
  String get upkeepBody =>
      'Reminders are set a week ahead each time Nexpill is used. Open it to set the next ones.';

  @override
  String get testReminderTitle => 'Test reminder';

  @override
  String get testReminderBody =>
      'Reminders are working. This is how they\'ll look.';

  @override
  String get csvGivenAt => 'Given at';

  @override
  String get csvGivenAtUtc => 'Given at (UTC)';

  @override
  String get csvPatient => 'Patient';

  @override
  String get csvMedication => 'Medication';

  @override
  String get csvDose => 'Dose';

  @override
  String get csvGivenBy => 'Given by';

  @override
  String get csvNotes => 'Notes';

  @override
  String get csvStatus => 'Status';

  @override
  String get csvCorrects => 'Corrects entry';

  @override
  String get csvEntry => 'Entry';

  @override
  String get csvReplaced => 'Replaced by a correction';

  @override
  String get csvSkipped => 'Skipped';

  @override
  String get csvCorrection => 'Correction';

  @override
  String get csvGiven => 'Given';

  @override
  String summaryTitleFor(String name) {
    return 'Medication summary for $name';
  }

  @override
  String get summaryTitle => 'Medication summary';

  @override
  String summaryAsOf(String dateTime) {
    return 'As of $dateTime. Active medications only.';
  }

  @override
  String get summaryNotAdvice =>
      'From Nexpill, a timing tracker. Not medical advice.';

  @override
  String get summaryNoActive => 'No active medications.';

  @override
  String summaryPurpose(String value) {
    return 'For: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dose: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Schedule: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Course: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Instructions: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Last given: $value';
  }

  @override
  String get summaryNotYet => 'Not yet';

  @override
  String summaryStatus(String value) {
    return 'Status: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Reminders: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Remaining: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (running low)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (none left)';
  }

  @override
  String get backupNotNexpill => 'This file isn\'t a Nexpill backup.';

  @override
  String get backupTooNew =>
      'This backup is from a newer version of Nexpill. Update the app, then try again.';

  @override
  String get backupTwoOfYou =>
      'More than one person in this file is marked as you.';

  @override
  String backupCorrectsMissing(String medication) {
    return 'A dose of $medication corrects one that isn\'t in its history.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return 'Corrections to $medication\'s doses go round in a circle.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where needs either \"lastDay\" or \"doses\", not both.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where has a time that isn\'t HH:mm: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where has an unknown schedule type \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where isn\'t in the expected form.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where is missing \"$key\" or it is the wrong kind of value.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where has an empty \"$key\".';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where has an impossible \"$key\": $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where has a \"$key\" that isn\'t a YYYY-MM-DD date.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where has a \"$key\" that isn\'t a date and time with a time zone.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'The id \"$id\" appears more than once.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where has no \"$key\".';
  }

  @override
  String get backupWhereFile => 'The file';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key $number';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get couldNotSave => 'Couldn\'t save the file.';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String cardMoreFor(String medication) {
    return 'More for $medication';
  }

  @override
  String get edit => 'Edit';

  @override
  String get doseHistory => 'Dose history';

  @override
  String skipTheDose(String time) {
    return 'Skip the $time dose';
  }

  @override
  String get stopTaking => 'Stop taking';

  @override
  String lastGiven(String when) {
    return 'Last given $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Last given $when by $name';
  }

  @override
  String get skip => 'Skip';

  @override
  String get give => 'Give';

  @override
  String supplyLeft(String amount) {
    return '$amount left';
  }

  @override
  String get supplyNoneLeft => 'None left: time to refill';

  @override
  String supplyRunningLow(String left) {
    return '$left: running low';
  }

  @override
  String get earlyTitle => 'This is early';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return '$medication is next due $when, in $duration. Log a dose now anyway?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return '$medication can next be given $when, in $duration. Log a dose now anyway?';
  }

  @override
  String get notYet => 'Not yet';

  @override
  String get logItNow => 'Log it now';

  @override
  String get dayGiven => 'Day it was given';

  @override
  String get timeGiven => 'Time it was given';

  @override
  String get timeInFuture => 'That time hasn\'t happened yet.';

  @override
  String correctEntry(String medication) {
    return 'Correct this $medication entry';
  }

  @override
  String giveMedication(String medication) {
    return 'Give $medication';
  }

  @override
  String get originalStays =>
      'The original stays in history, marked as corrected.';

  @override
  String get now => 'Now';

  @override
  String get earlier => 'Earlier';

  @override
  String givenWhen(String when) {
    return 'Given $when';
  }

  @override
  String get change => 'Change';

  @override
  String get dose => 'Dose';

  @override
  String get givenBy => 'Given by';

  @override
  String get optional => 'Optional';

  @override
  String get notes => 'Notes';

  @override
  String get saveCorrection => 'Save correction';

  @override
  String get logDose => 'Log dose';

  @override
  String get doseHistorySaved => 'Dose history saved';

  @override
  String get correctTimeOrDetails => 'Correct time or details';

  @override
  String get keepsOriginal => 'Keeps the original, marked as corrected';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get deleteEntrySkippedHint => 'The dose becomes due again';

  @override
  String get deleteEntryHint => 'Only for a dose that was never given';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, skipped. Delete it if the dose wasn\'t meant to be skipped.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Use this only if the dose was never given; to fix its time, correct it instead. Any corrections of it go too.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get yourDoses => 'Your doses';

  @override
  String personsDoses(String name) {
    return '$name\'s doses';
  }

  @override
  String get doses => 'Doses';

  @override
  String get saveAsCsv => 'Save as a spreadsheet (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Only $medication';
  }

  @override
  String get nothingLogged => 'Nothing logged yet.';

  @override
  String historyBy(String name) {
    return 'by $name';
  }

  @override
  String get historyCorrection => 'correction';

  @override
  String get historyCorrected => 'corrected';

  @override
  String get defaultDose => '1 tablet';

  @override
  String get errorName => 'Give the medication a name.';

  @override
  String get errorDose => 'Say what one dose is, like \"1 tablet\".';

  @override
  String get errorHowOften => 'Choose how often.';

  @override
  String get errorShortestGap => 'Choose the shortest gap between doses.';

  @override
  String get errorAddTime => 'Add at least one time.';

  @override
  String get errorDosesStillToGive => 'Enter how many doses are still to give.';

  @override
  String get errorCourseDoses => 'Enter how many doses the course has.';

  @override
  String get errorStartingSupply => 'Enter how much there is to start with.';

  @override
  String get errorPerDose => 'Enter how much one dose uses.';

  @override
  String get errorLowAt => 'Enter when to warn, or leave it empty.';

  @override
  String get errorNoSteps => 'Add at least one step.';

  @override
  String get errorStepInterval => 'Every step needs an interval.';

  @override
  String get errorStepEnds => 'A step has to end after it starts.';

  @override
  String get errorOpenEnded => 'Only the last step can be open-ended.';

  @override
  String get errorStepsOverlap => 'Two steps overlap.';

  @override
  String deleteMedicationTitle(String medication) {
    return 'Delete $medication?';
  }

  @override
  String get deleteMedicationMessage =>
      'Its dose history goes with it. To stop it but keep the history, turn off \"Taking this now\" instead.';

  @override
  String get newMedication => 'New medication';

  @override
  String editMedication(String medication) {
    return 'Edit $medication';
  }

  @override
  String get save => 'Save';

  @override
  String forPerson(String person) {
    return 'For $person';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameHint => 'e.g. Amoxicillin';

  @override
  String get fieldStrength => 'Strength';

  @override
  String get fieldStrengthHint => 'Optional, e.g. 500 mg';

  @override
  String get fieldPurpose => 'What it\'s for';

  @override
  String get fieldPurposeHint => 'Optional, e.g. blood pressure';

  @override
  String get fieldUsualDose => 'Usual dose';

  @override
  String get fieldUsualDoseHint => 'e.g. 1 tablet, 5 ml';

  @override
  String get fieldInstructions => 'Instructions';

  @override
  String get fieldInstructionsHint => 'Optional, e.g. with food';

  @override
  String get sectionWhen => 'When';

  @override
  String get sectionHowLong => 'How long';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get sectionSupply => 'Supply';

  @override
  String get takingThisNow => 'Taking this now';

  @override
  String get takingThisNowHint =>
      'Turn off when it\'s stopped. It keeps its history but stops reminding.';

  @override
  String get deleteMedication => 'Delete medication';

  @override
  String get addMedication => 'Add medication';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get kindInterval => 'Every few hours';

  @override
  String get kindFixedTimes => 'At set times';

  @override
  String get kindAsNeeded => 'As needed';

  @override
  String get kindTaper => 'Taper';

  @override
  String get every => 'Every';

  @override
  String get intervalHint => 'Counted from the last dose given.';

  @override
  String get atLeastApart => 'At least this long apart';

  @override
  String get asNeededHint =>
      'Never \"due\" — Nexpill shows when it can be given again.';

  @override
  String get addTime => 'Add time';

  @override
  String get fixedTimesHint => 'Every day, on this phone\'s clock.';

  @override
  String get timeOfDose => 'Time of dose';

  @override
  String get courseUntilStopped => 'Until stopped';

  @override
  String get courseUntilDate => 'Until a date';

  @override
  String get courseNumberOfDoses => 'A number of doses';

  @override
  String get courseOngoingHint =>
      'Reminders carry on until you turn off \"Taking this now\".';

  @override
  String courseLastDayChip(String date) {
    return 'Last day: $date';
  }

  @override
  String get courseLastDayHint =>
      'Doses carry on through that day; reminders stop at midnight at the end of it.';

  @override
  String get dosesStillToGive => 'Doses still to give';

  @override
  String get numberOfDoses => 'Number of doses';

  @override
  String get dosesHint => 'e.g. 10';

  @override
  String get courseDosesHint => 'Reminders stop once the last one is given.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count doses given so far. Reminders stop once the last one is given.',
      one: '1 dose given so far. Reminders stop once the last one is given.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Last day of the course';

  @override
  String taperStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get removeStep => 'Remove step';

  @override
  String stepFrom(String date) {
    return 'From $date';
  }

  @override
  String get noEndDate => 'No end date';

  @override
  String stepUntil(String date) {
    return 'Until $date';
  }

  @override
  String get clearEnd => 'Clear end';

  @override
  String get addStep => 'Add a step';

  @override
  String get taperHint =>
      'Each step runs from midnight on its first day until midnight on its end day. The last step can be open-ended.';

  @override
  String get remindMe => 'Remind me';

  @override
  String get remindAsNeededHint => 'When it can be given again.';

  @override
  String get remindHint => 'When a dose is due, and again while it\'s overdue.';

  @override
  String get headsUp => 'Heads-up before it\'s due';

  @override
  String get none => 'None';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get repeatWhileOverdue => 'Repeat while overdue';

  @override
  String everyDuration(String duration) {
    return 'every $duration';
  }

  @override
  String get ringLikeAlarm => 'Ring like an alarm';

  @override
  String get ringLikeAlarmHint =>
      'The alarm sound, repeating until you mark it given or snooze it.';

  @override
  String get trackSupply => 'Track how much is left';

  @override
  String get trackSupplyHint => 'Counts down with each dose logged.';

  @override
  String get startingAmount => 'Starting amount';

  @override
  String get unit => 'Unit';

  @override
  String get unitHint => 'tablets';

  @override
  String get eachDoseUses => 'Each dose uses';

  @override
  String get warnAt => 'Warn at';

  @override
  String get everyone => 'Everyone';

  @override
  String get managePeople => 'Manage people';

  @override
  String get settings => 'Settings';

  @override
  String get addSomeone => 'Add someone';

  @override
  String get noMedicationsYet => 'No medications yet';

  @override
  String get nothingToGiveNow => 'Nothing to give now';

  @override
  String moreDueNow(int count) {
    return '+ $count more due now';
  }

  @override
  String get remindersOffShort => 'Reminders off';

  @override
  String get errorEnterName => 'Enter a name.';

  @override
  String get errorNameTaken => 'Someone already has that name.';

  @override
  String get whoAreYouCaringFor => 'Who are you caring for?';

  @override
  String get rename => 'Rename';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHint => 'A first name or nickname is fine';

  @override
  String get thisIsMe => 'This is me';

  @override
  String get forYourOwnMedications => 'For your own medications';

  @override
  String get add => 'Add';

  @override
  String get deleteYourMedicationsTitle => 'Delete your medications?';

  @override
  String deletePersonTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your $count medications and all dose history go too, and can\'t be brought back unless you have a backup file.',
      one: 'Your medication and all dose history go too, and can\'t be brought back unless you have a backup file.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Their $count medications and all dose history go too, and can\'t be brought back unless you have a backup file.',
      one: 'Their medication and all dose history go too, and can\'t be brought back unless you have a backup file.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'People';

  @override
  String tapToSeeThem(String count) {
    return '$count · tap to see them';
  }

  @override
  String get addYourName => 'Add your name';

  @override
  String get asSetForEach => 'As set for each medication';

  @override
  String allOffFor(String person) {
    return 'All off for $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medications',
      one: '1 medication',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return '$medication logged, $when';
  }

  @override
  String get undo => 'Undo';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication: skipped $count times in a row';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Reminders off for $medication. Turn them on again in Edit.';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication stopped. Its history is kept.';
  }

  @override
  String get remindersAreOff => 'Reminders are off';

  @override
  String get allowNotificationsHint =>
      'Allow notifications so they can reach you.';

  @override
  String get allow => 'Allow';

  @override
  String remindersAreOffFor(String person) {
    return 'Reminders are off for $person.';
  }

  @override
  String get addYourFirst =>
      'Add your first one, and Nexpill will keep track of when each dose can be given.';

  @override
  String addPersonsFirst(String name) {
    return 'Add $name\'s first one, and Nexpill will keep track of when each dose can be given.';
  }

  @override
  String get allEndedForYou =>
      'Everything for you has finished or been stopped. It\'s all below, with its history.';

  @override
  String allEndedForPerson(String name) {
    return 'Everything for $name has finished or been stopped. It\'s all below, with its history.';
  }

  @override
  String get addAMedication => 'Add a medication';

  @override
  String get addAnotherMedication => 'Add another medication';

  @override
  String addMedicationFor(String name) {
    return 'Add a medication for $name';
  }

  @override
  String endedStopped(int count) {
    return 'Stopped ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Finished ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Finished and stopped ($count)';
  }

  @override
  String get resume => 'Resume';

  @override
  String get logoLabel => 'Nexpill logo';

  @override
  String get welcomeWhat =>
      'Keeps track of when each dose was given and when the next one can be, and reminds you on time.';

  @override
  String get welcomePrivate =>
      'Everything stays on this phone. No account, no internet.';

  @override
  String get whoAreTheMedicationsFor => 'Who are the medications for?';

  @override
  String get me => 'Me';

  @override
  String get someoneICareFor => 'Someone I care for';

  @override
  String get addMoreLater => 'You can add more people later.';

  @override
  String noBrowser(String website) {
    return 'No browser to open it with. Visit $website instead.';
  }

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get couldNotOpen => 'Couldn\'t open that file.';

  @override
  String get cantRestore => 'Can\'t restore this file';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Replace everything with this backup?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses logged',
      one: '1 dose logged',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'It has $people, $medications and $doses. Everything now on this phone will be replaced by it.';
  }

  @override
  String get replace => 'Replace';

  @override
  String get restored => 'Restored';

  @override
  String get summaryFor => 'Summary for';

  @override
  String get summarySaved => 'Summary saved';

  @override
  String get yourNameOnSummary => 'Your name on the summary';

  @override
  String get continueAction => 'Continue';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllMessage =>
      'Every person, medication and dose on this phone, and every reminder. This can\'t be undone; if you might want it back, save a backup first.';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get notificationsOff => 'Notifications are off';

  @override
  String get notificationsOn => 'Notifications are on';

  @override
  String get notificationsOffHint =>
      'Reminders can\'t be shown until they\'re allowed.';

  @override
  String get notificationsOnHint => 'Reminders will show on this phone.';

  @override
  String get mayBeLate => 'Reminders may be late';

  @override
  String get mayBeLateHint =>
      'Android has turned off exact alarms for Nexpill. Turn \"Alarms & reminders\" back on in the phone\'s settings for the app.';

  @override
  String get sendTest => 'Send a test reminder';

  @override
  String get sendTestHint => 'Arrives in a few seconds.';

  @override
  String get testOnItsWay => 'Test reminder on its way';

  @override
  String get peopleYouCareFor => 'People you care for';

  @override
  String onThisPhone(int count) {
    return '$count on this phone';
  }

  @override
  String get yourData => 'Your data';

  @override
  String get backUp => 'Back up to a file';

  @override
  String get backUpHint => 'Everything, saved wherever you choose.';

  @override
  String get restore => 'Restore from a backup';

  @override
  String get restoreHint => 'Replaces what\'s on this phone.';

  @override
  String get medicationSummary => 'Medication summary';

  @override
  String get medicationSummaryHint => 'Plain text, for a doctor or a handover.';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get about => 'About';

  @override
  String get aboutNexpill => 'About Nexpill';

  @override
  String get aboutNexpillHint => 'Where your data lives, and why it\'s free';

  @override
  String get website => 'Website';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get sendFeedbackHint => 'A form on the website, in your browser.';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get sameAsPhone => 'Same as the phone';

  @override
  String sameAsPhoneNow(String language) {
    return 'Same as the phone: $language';
  }

  @override
  String get aboutStaysTitle => 'It stays on your phone';

  @override
  String get aboutStaysBody =>
      'Everything you log is written to a database on this device. There is no account and no server. It only goes anywhere else if you move it yourself, as a backup file or an export.';

  @override
  String get aboutCannotSeeTitle => 'We cannot see it';

  @override
  String get aboutCannotSeeBody =>
      'Nexpill is built without permission to use the internet at all. Android enforces that, and you can check it in the app\'s permission list.';

  @override
  String get aboutRemindersTitle => 'Reminders come from the phone itself';

  @override
  String get aboutRemindersBody =>
      'Each reminder is an alarm this phone holds, so it arrives on time with no signal, in airplane mode, and after a restart.';

  @override
  String get aboutPermissionsTitle => 'What the permissions are for';

  @override
  String get aboutPermissionsBody =>
      'Notifications, for reminders. Exact alarms, so they arrive on the minute. Starting after a restart, to set them again. Vibration. That is the whole list.';

  @override
  String get aboutFreeTitle => 'Free, for good';

  @override
  String get aboutFreeBody =>
      'Nexpill was written by a caregiver, for caregivers. It will always be free and open source: no price, no premium tier, no ads.';

  @override
  String get aboutCheckTitle => 'You can check our work';

  @override
  String get aboutCheckBody =>
      'Nexpill is open source under the GNU General Public License. Anyone can read exactly what it does.';

  @override
  String get aboutHeadline => 'Your records stay with you.';

  @override
  String get aboutIntro =>
      'Nexpill keeps track of when each dose was given and when the next one can be, and reminds you on time. It doesn\'t give medical advice.';

  @override
  String get aboutTradeOff =>
      'One trade-off worth knowing: there is no cloud copy, so a lost or wiped phone means lost history. Save a backup file from Settings now and then, and keep it somewhere other than this phone.';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }
}
