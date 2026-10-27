// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours und $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Dosis um $time ausgelassen';
  }

  @override
  String listAnd(String items, String last) {
    return '$items und $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Alle $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'Um $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'Bei Bedarf, mindestens $duration Abstand';
  }

  @override
  String get taperNoSteps => 'Ausschleichen ohne Stufen';

  @override
  String taperStepFrom(String date) {
    return 'Ab $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return '$from bis $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: alle $duration';
  }

  @override
  String get taperFinished => 'Ausschleichen beendet';

  @override
  String scheduleOnce(String when) {
    return 'Einmalig, $when';
  }

  @override
  String scheduleOnceToday(String time) {
    return 'Einmalig, heute um $time';
  }

  @override
  String get singleDoseFinished => 'Einzeldosis erfasst';

  @override
  String taperShortEvery(String duration) {
    return 'Ausschleichen: alle $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text ab $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text bis $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, dann alle $duration';
  }

  @override
  String get statusNotGiven => 'Noch nicht gegeben';

  @override
  String get statusCanGiveNow => 'Kann jetzt gegeben werden';

  @override
  String get statusDueNow => 'Jetzt fällig';

  @override
  String statusNextAt(String time) {
    return 'Nächste Dosis um $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'Seit $duration überfällig';
  }

  @override
  String statusMissed(String duration) {
    return 'Verpasst: war vor $duration fällig';
  }

  @override
  String get statusFinished => 'Beendet';

  @override
  String get remindersOff => 'Aus';

  @override
  String get remindersOn => 'An';

  @override
  String remindersEarly(String duration) {
    return '$duration vorher';
  }

  @override
  String get remindersAlarm => 'als Alarm';

  @override
  String whenToday(String time) {
    return 'heute um $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'morgen um $time';
  }

  @override
  String whenYesterday(String time) {
    return 'gestern um $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return 'am $date um $time';
  }

  @override
  String shortMinutes(int count) {
    return '$count Min.';
  }

  @override
  String shortHours(int count) {
    return '$count Std.';
  }

  @override
  String shortHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String shortDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tagen',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String courseFinishedLastDay(String date) {
    return 'Behandlung beendet: letzter Tag war der $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Behandlung beendet: alle $count Dosen gegeben',
      one: 'Behandlung beendet: die eine Dosis wurde gegeben',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Letzter Tag: $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total Dosen, bisher $given gegeben',
      one: '1 Dosis, bisher $given gegeben',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'letzter Tag: $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch $count Dosen',
      one: 'noch 1 Dosis',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Erste Dosis $when fällig';
  }

  @override
  String get cardAsNeeded => 'Bei Bedarf';

  @override
  String cardAvailableFrom(String when) {
    return 'Nächste Dosis $when möglich';
  }

  @override
  String cardNextDose(String when) {
    return 'Nächste Dosis $when';
  }

  @override
  String cardIn(String duration) {
    return 'in $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Fällig in $duration';
  }

  @override
  String cardAt(String when) {
    return '$when';
  }

  @override
  String cardSince(String when) {
    return '$when fällig geworden';
  }

  @override
  String cardOverdue(String duration) {
    return 'Seit $duration überfällig';
  }

  @override
  String cardWasDue(String when) {
    return 'war $when fällig';
  }

  @override
  String get cardMissed => 'Verpasst';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'war $when fällig, vor $duration';
  }

  @override
  String get personYou => 'Du';

  @override
  String get personYouAfterFor => 'dich';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication: fällig um $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication: jetzt fällig';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication: überfällig seit $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication: kann wieder gegeben werden';
  }

  @override
  String reminderManyFor(int count, String person) {
    return '$count Medikamente für $person';
  }

  @override
  String reminderFor(String person) {
    return 'Für $person';
  }

  @override
  String get channelAlarms => 'Medikamenten-Alarme';

  @override
  String get channelAlarmsDescription =>
      'Für Medikamente, die wie ein Wecker klingeln sollen, wenn eine Dosis fällig ist.';

  @override
  String get channelReminders => 'Medikamenten-Erinnerungen';

  @override
  String get channelRemindersDescription =>
      'Vorwarnungen, fällige und überfällige Dosen.';

  @override
  String get channelUpkeep => 'Erinnerungen am Laufen halten';

  @override
  String get channelUpkeepDescription =>
      'Ein Hinweis, wenn Nexpill geöffnet werden muss, damit die Erinnerungen nicht ausgehen.';

  @override
  String get actionMarkGiven => 'Als gegeben markieren';

  @override
  String get actionSkip => 'Auslassen';

  @override
  String actionSnooze(int minutes) {
    return '$minutes Min. später';
  }

  @override
  String get upkeepTitle => 'Nexpill öffnen, damit weiter Erinnerungen kommen';

  @override
  String get upkeepBody =>
      'Erinnerungen werden bei jeder Nutzung von Nexpill eine Woche im Voraus gestellt. Öffne die App, um die nächsten zu stellen.';

  @override
  String get testReminderTitle => 'Test-Erinnerung';

  @override
  String get testReminderBody =>
      'Erinnerungen funktionieren. So werden sie aussehen.';

  @override
  String get csvGivenAt => 'Gegeben am';

  @override
  String get csvGivenAtUtc => 'Gegeben am (UTC)';

  @override
  String get csvPatient => 'Person';

  @override
  String get csvMedication => 'Medikament';

  @override
  String get csvDose => 'Dosis';

  @override
  String get csvGivenBy => 'Gegeben von';

  @override
  String get csvNotes => 'Notizen';

  @override
  String get csvStatus => 'Status';

  @override
  String get csvCorrects => 'Korrigiert Eintrag';

  @override
  String get csvEntry => 'Eintrag';

  @override
  String get csvReplaced => 'Durch eine Korrektur ersetzt';

  @override
  String get csvSkipped => 'Ausgelassen';

  @override
  String get csvCorrection => 'Korrektur';

  @override
  String get csvGiven => 'Gegeben';

  @override
  String summaryTitleFor(String name) {
    return 'Medikamentenübersicht für $name';
  }

  @override
  String get summaryTitle => 'Medikamentenübersicht';

  @override
  String summaryAsOf(String dateTime) {
    return 'Stand: $dateTime. Nur aktuelle Medikamente.';
  }

  @override
  String get summaryNotAdvice =>
      'Erstellt mit Nexpill, einer App zum Festhalten von Einnahmezeiten. Keine medizinische Beratung.';

  @override
  String get summaryNoActive => 'Keine aktuellen Medikamente.';

  @override
  String summaryPurpose(String value) {
    return 'Wofür: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dosis: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Zeitplan: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Dauer: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Hinweise: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Zuletzt gegeben: $value';
  }

  @override
  String get summaryNotYet => 'Noch nicht';

  @override
  String summaryStatus(String value) {
    return 'Status: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Erinnerungen: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Vorrat: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (wird knapp)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (aufgebraucht)';
  }

  @override
  String get backupNotNexpill => 'Diese Datei ist keine Nexpill-Sicherung.';

  @override
  String get backupTooNew =>
      'Diese Sicherung stammt aus einer neueren Version von Nexpill. Aktualisiere die App und versuche es dann noch einmal.';

  @override
  String get backupTwoOfYou =>
      'In dieser Datei ist mehr als eine Person als „ich selbst“ markiert.';

  @override
  String backupCorrectsMissing(String medication) {
    return '$medication: Eine Dosis korrigiert eine andere, die nicht im Verlauf steht.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return '$medication: Die Korrekturen der Dosen verweisen im Kreis aufeinander.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where: braucht entweder \"lastDay\" oder \"doses\", nicht beides.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where: enthält eine Uhrzeit, die nicht im Format HH:mm ist: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where: unbekannter Zeitplantyp \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where: nicht in der erwarteten Form.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where: \"$key\" fehlt oder hat den falschen Werttyp.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where: \"$key\" ist leer.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where: unmöglicher Wert für \"$key\": $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where: \"$key\" ist kein Datum im Format JJJJ-MM-TT.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where: \"$key\" ist kein Datum mit Uhrzeit und Zeitzone.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'Die ID \"$id\" kommt mehr als einmal vor.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where: \"$key\" fehlt.';
  }

  @override
  String get backupWhereFile => 'Die Datei';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key Nr. $number';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get couldNotSave => 'Die Datei konnte nicht gespeichert werden.';

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String cardMoreFor(String medication) {
    return 'Mehr zu $medication';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get doseHistory => 'Dosisverlauf';

  @override
  String skipTheDose(String time) {
    return 'Dosis um $time auslassen';
  }

  @override
  String get stopTaking => 'Absetzen';

  @override
  String lastGiven(String when) {
    return 'Zuletzt $when gegeben';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Zuletzt $when von $name gegeben';
  }

  @override
  String get skip => 'Auslassen';

  @override
  String get give => 'Geben';

  @override
  String supplyLeft(String amount) {
    return 'Noch $amount';
  }

  @override
  String get supplyNoneLeft => 'Aufgebraucht: Zeit zum Nachbesorgen';

  @override
  String supplyRunningLow(String left) {
    return '$left: wird knapp';
  }

  @override
  String get refill => 'Nachfüllen';

  @override
  String refillTitle(String medication) {
    return '$medication nachfüllen';
  }

  @override
  String get refillAmount => 'Menge zum Hinzufügen';

  @override
  String get refillAdd => 'Hinzufügen';

  @override
  String refilled(String medication, String left) {
    return '$medication nachgefüllt. $left.';
  }

  @override
  String get earlyTitle => 'Das ist zu früh';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return '$medication ist als Nächstes $when fällig, in $duration. Trotzdem jetzt eine Dosis eintragen?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return '$medication kann als Nächstes $when gegeben werden, in $duration. Trotzdem jetzt eine Dosis eintragen?';
  }

  @override
  String get notYet => 'Noch nicht';

  @override
  String get logItNow => 'Jetzt eintragen';

  @override
  String get dayGiven => 'Tag der Gabe';

  @override
  String get timeGiven => 'Uhrzeit der Gabe';

  @override
  String get timeInFuture => 'Diese Uhrzeit liegt in der Zukunft.';

  @override
  String correctEntry(String medication) {
    return 'Diesen Eintrag zu $medication korrigieren';
  }

  @override
  String giveMedication(String medication) {
    return '$medication geben';
  }

  @override
  String get originalStays =>
      'Das Original bleibt im Verlauf, als korrigiert markiert.';

  @override
  String get now => 'Jetzt';

  @override
  String get earlier => 'Früher';

  @override
  String givenWhen(String when) {
    return 'Gegeben $when';
  }

  @override
  String get change => 'Ändern';

  @override
  String get dose => 'Dosis';

  @override
  String get givenBy => 'Gegeben von';

  @override
  String get optional => 'Optional';

  @override
  String get notes => 'Notizen';

  @override
  String get saveCorrection => 'Korrektur speichern';

  @override
  String get logDose => 'Dosis eintragen';

  @override
  String get doseHistorySaved => 'Dosisverlauf gespeichert';

  @override
  String get correctTimeOrDetails => 'Uhrzeit oder Angaben korrigieren';

  @override
  String get keepsOriginal => 'Das Original bleibt, als korrigiert markiert';

  @override
  String get deleteEntry => 'Eintrag löschen';

  @override
  String get deleteEntrySkippedHint => 'Die Dosis wird wieder fällig';

  @override
  String get deleteEntryHint => 'Nur für eine Dosis, die nie gegeben wurde';

  @override
  String get deleteEntryTitle => 'Diesen Eintrag löschen?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, ausgelassen. Lösche den Eintrag, wenn die Dosis nicht ausgelassen werden sollte.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Nur verwenden, wenn die Dosis nie gegeben wurde; um ihre Uhrzeit zu ändern, korrigiere sie stattdessen. Alle Korrekturen dazu werden ebenfalls gelöscht.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get yourDoses => 'Deine Dosen';

  @override
  String personsDoses(String name) {
    return 'Dosen von $name';
  }

  @override
  String get doses => 'Dosen';

  @override
  String get saveAsCsv => 'Als Tabelle speichern (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Nur $medication';
  }

  @override
  String get nothingLogged => 'Noch nichts eingetragen.';

  @override
  String historyBy(String name) {
    return 'von $name';
  }

  @override
  String get historyCorrection => 'Korrektur';

  @override
  String get historyCorrected => 'korrigiert';

  @override
  String get defaultDose => '1 Tablette';

  @override
  String get errorName => 'Gib dem Medikament einen Namen.';

  @override
  String get errorDose => 'Gib an, was eine Dosis ist, z. B. „1 Tablette“.';

  @override
  String get errorHowOften => 'Wähle, wie oft.';

  @override
  String get errorShortestGap =>
      'Wähle den kürzesten Abstand zwischen zwei Dosen.';

  @override
  String get errorAddTime => 'Füge mindestens eine Uhrzeit hinzu.';

  @override
  String get errorDosesStillToGive =>
      'Gib ein, wie viele Dosen noch zu geben sind.';

  @override
  String get errorCourseDoses =>
      'Gib ein, wie viele Dosen die Behandlung umfasst.';

  @override
  String get errorAmountLeft => 'Gib ein, wie viel noch vorhanden ist.';

  @override
  String get errorPerDose => 'Gib ein, wie viel eine Dosis verbraucht.';

  @override
  String get errorLowAt =>
      'Gib ein, ab wann gewarnt werden soll, oder lass das Feld leer.';

  @override
  String get errorNoSteps => 'Füge mindestens eine Stufe hinzu.';

  @override
  String get errorStepInterval => 'Jede Stufe braucht einen Abstand.';

  @override
  String get errorStepEnds => 'Eine Stufe muss nach ihrem Beginn enden.';

  @override
  String get errorOpenEnded => 'Nur die letzte Stufe kann ohne Ende sein.';

  @override
  String get errorStepsOverlap => 'Zwei Stufen überschneiden sich.';

  @override
  String deleteMedicationTitle(String medication) {
    return '$medication löschen?';
  }

  @override
  String get deleteMedicationMessage =>
      'Der Dosisverlauf wird mit gelöscht. Um es abzusetzen und den Verlauf zu behalten, schalte stattdessen „Wird derzeit genommen“ aus.';

  @override
  String get newMedication => 'Neues Medikament';

  @override
  String editMedication(String medication) {
    return '$medication bearbeiten';
  }

  @override
  String get save => 'Speichern';

  @override
  String forPerson(String person) {
    return 'Für $person';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameHint => 'z. B. Amoxicillin';

  @override
  String get fieldStrength => 'Stärke';

  @override
  String get fieldStrengthHint => 'Optional, z. B. 500 mg';

  @override
  String get fieldPurpose => 'Wofür';

  @override
  String get fieldPurposeHint => 'Optional, z. B. Blutdruck';

  @override
  String get fieldUsualDose => 'Übliche Dosis';

  @override
  String get fieldUsualDoseHint => 'z. B. 1 Tablette, 5 ml';

  @override
  String get fieldInstructions => 'Hinweise';

  @override
  String get fieldInstructionsHint => 'Optional, z. B. zum Essen';

  @override
  String get sectionWhen => 'Wann';

  @override
  String get sectionHowLong => 'Wie lange';

  @override
  String get sectionReminders => 'Erinnerungen';

  @override
  String get sectionSupply => 'Vorrat';

  @override
  String get takingThisNow => 'Wird derzeit genommen';

  @override
  String get takingThisNowHint =>
      'Ausschalten, wenn es abgesetzt ist. Der Verlauf bleibt erhalten, aber die Erinnerungen hören auf.';

  @override
  String get deleteMedication => 'Medikament löschen';

  @override
  String get addMedication => 'Medikament hinzufügen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get kindInterval => 'Alle paar Stunden';

  @override
  String get kindFixedTimes => 'Feste Uhrzeiten';

  @override
  String get kindAsNeeded => 'Bei Bedarf';

  @override
  String get kindTaper => 'Ausschleichen';

  @override
  String get kindOnce => 'Einmalig';

  @override
  String get every => 'Alle';

  @override
  String get intervalHint => 'Gezählt ab der zuletzt gegebenen Dosis.';

  @override
  String get atLeastApart => 'Mindestabstand';

  @override
  String get asNeededHint =>
      'Nie „fällig“ – Nexpill zeigt, wann es wieder gegeben werden kann.';

  @override
  String get addTime => 'Uhrzeit hinzufügen';

  @override
  String get fixedTimesHint => 'Jeden Tag, nach der Uhr dieses Telefons.';

  @override
  String get timeOfDose => 'Uhrzeit der Dosis';

  @override
  String get onceHint =>
      'Eine einzelne Dosis. Sobald sie gegeben oder ausgelassen wurde, ist sie beendet und bleibt im Verlauf.';

  @override
  String get dayOfDose => 'Tag der Dosis';

  @override
  String get courseUntilStopped => 'Bis zum Absetzen';

  @override
  String get courseUntilDate => 'Bis zu einem Datum';

  @override
  String get courseNumberOfDoses => 'Eine Anzahl Dosen';

  @override
  String get courseOngoingHint =>
      'Die Erinnerungen laufen weiter, bis du „Wird derzeit genommen“ ausschaltest.';

  @override
  String courseLastDayChip(String date) {
    return 'Letzter Tag: $date';
  }

  @override
  String get courseLastDayHint =>
      'An diesem Tag gehen die Dosen noch ganz weiter; die Erinnerungen enden um Mitternacht an seinem Ende.';

  @override
  String get dosesStillToGive => 'Noch zu gebende Dosen';

  @override
  String get numberOfDoses => 'Anzahl der Dosen';

  @override
  String get dosesHint => 'z. B. 10';

  @override
  String get courseDosesHint =>
      'Die Erinnerungen enden, sobald die letzte gegeben ist.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Bisher $count Dosen gegeben. Die Erinnerungen enden, sobald die letzte gegeben ist.',
      one: 'Bisher 1 Dosis gegeben. Die Erinnerungen enden, sobald die letzte gegeben ist.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Letzter Tag der Behandlung';

  @override
  String taperStepNumber(int number) {
    return 'Stufe $number';
  }

  @override
  String get removeStep => 'Stufe entfernen';

  @override
  String stepFrom(String date) {
    return 'Ab $date';
  }

  @override
  String get noEndDate => 'Kein Enddatum';

  @override
  String stepUntil(String date) {
    return 'Bis $date';
  }

  @override
  String get clearEnd => 'Ende entfernen';

  @override
  String get addStep => 'Stufe hinzufügen';

  @override
  String get taperHint =>
      'Jede Stufe läuft von Mitternacht zu Beginn ihres ersten Tages bis Mitternacht zu Beginn ihres Endtages. Die letzte Stufe kann ohne Ende sein.';

  @override
  String get remindMe => 'Erinnern';

  @override
  String get remindAsNeededHint => 'Wenn es wieder gegeben werden kann.';

  @override
  String get remindHint =>
      'Wenn eine Dosis fällig ist, und erneut, solange sie überfällig ist.';

  @override
  String get headsUp => 'Vorwarnung vor der Fälligkeit';

  @override
  String get none => 'Keine';

  @override
  String minutesShort(int count) {
    return '$count Min.';
  }

  @override
  String get repeatWhileOverdue => 'Wiederholen, solange überfällig';

  @override
  String everyDuration(String duration) {
    return 'alle $duration';
  }

  @override
  String get ringLikeAlarm => 'Wie ein Wecker klingeln';

  @override
  String get ringLikeAlarmHint =>
      'Der Weckton, wiederholt, bis du die Dosis als gegeben markierst oder auf später verschiebst.';

  @override
  String get trackSupply => 'Vorrat verfolgen';

  @override
  String get trackSupplyHint => 'Zählt mit jeder eingetragenen Dosis herunter.';

  @override
  String get amountLeft => 'Noch vorhanden';

  @override
  String get unit => 'Einheit';

  @override
  String get unitHint => 'Tabletten';

  @override
  String get eachDoseUses => 'Verbrauch pro Dosis';

  @override
  String get warnAt => 'Warnen bei';

  @override
  String get everyone => 'Alle';

  @override
  String get managePeople => 'Personen verwalten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get addSomeone => 'Person hinzufügen';

  @override
  String get noMedicationsYet => 'Noch keine Medikamente';

  @override
  String get nothingToGiveNow => 'Gerade nichts zu geben';

  @override
  String moreDueNow(int count) {
    return '+ $count weitere jetzt fällig';
  }

  @override
  String get remindersOffShort => 'Erinnerungen aus';

  @override
  String get errorEnterName => 'Gib einen Namen ein.';

  @override
  String get errorNameTaken => 'Diesen Namen hat schon jemand.';

  @override
  String get whoAreYouCaringFor => 'Um wen kümmerst du dich?';

  @override
  String get rename => 'Umbenennen';

  @override
  String get yourName => 'Dein Name';

  @override
  String get nameHint => 'Ein Vorname oder Spitzname reicht';

  @override
  String get thisIsMe => 'Das bin ich';

  @override
  String get forYourOwnMedications => 'Für deine eigenen Medikamente';

  @override
  String get add => 'Hinzufügen';

  @override
  String get deleteYourMedicationsTitle => 'Deine Medikamente löschen?';

  @override
  String deletePersonTitle(String name) {
    return '$name löschen?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deine $count Medikamente und der gesamte Dosisverlauf werden ebenfalls gelöscht und lassen sich nur mit einer Sicherungsdatei zurückholen.',
      one: 'Dein Medikament und der gesamte Dosisverlauf werden ebenfalls gelöscht und lassen sich nur mit einer Sicherungsdatei zurückholen.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Die $count Medikamente dieser Person und der gesamte Dosisverlauf werden ebenfalls gelöscht und lassen sich nur mit einer Sicherungsdatei zurückholen.',
      one: 'Das Medikament dieser Person und der gesamte Dosisverlauf werden ebenfalls gelöscht und lassen sich nur mit einer Sicherungsdatei zurückholen.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Personen';

  @override
  String tapToSeeThem(String count) {
    return '$count · zum Anzeigen tippen';
  }

  @override
  String get addYourName => 'Deinen Namen hinzufügen';

  @override
  String get asSetForEach => 'Wie bei jedem Medikament eingestellt';

  @override
  String allOffFor(String person) {
    return 'Alle aus für $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Medikamente',
      one: '1 Medikament',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return '$medication eingetragen, $when';
  }

  @override
  String get undo => 'Rückgängig';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication: $count-mal in Folge ausgelassen';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Erinnerungen für $medication aus. Unter „Bearbeiten“ wieder einschalten.';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication abgesetzt. Der Verlauf bleibt erhalten.';
  }

  @override
  String get remindersAreOff => 'Erinnerungen sind aus';

  @override
  String get allowNotificationsHint =>
      'Erlaube Benachrichtigungen, damit sie dich erreichen.';

  @override
  String get allow => 'Erlauben';

  @override
  String remindersAreOffFor(String person) {
    return 'Erinnerungen sind für $person aus.';
  }

  @override
  String get addYourFirst =>
      'Füge dein erstes Medikament hinzu, und Nexpill behält im Blick, wann jede Dosis gegeben werden kann.';

  @override
  String addPersonsFirst(String name) {
    return 'Füge das erste Medikament für $name hinzu, und Nexpill behält im Blick, wann jede Dosis gegeben werden kann.';
  }

  @override
  String get allEndedForYou =>
      'Alles für dich ist beendet oder abgesetzt. Du findest alles unten, mit Verlauf.';

  @override
  String allEndedForPerson(String name) {
    return 'Alles für $name ist beendet oder abgesetzt. Du findest alles unten, mit Verlauf.';
  }

  @override
  String get addAMedication => 'Medikament hinzufügen';

  @override
  String get addAnotherMedication => 'Weiteres Medikament hinzufügen';

  @override
  String addMedicationFor(String name) {
    return 'Medikament für $name hinzufügen';
  }

  @override
  String endedStopped(int count) {
    return 'Abgesetzt ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Beendet ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Beendet und abgesetzt ($count)';
  }

  @override
  String get resume => 'Fortsetzen';

  @override
  String get logoLabel => 'Nexpill-Logo';

  @override
  String get welcomeWhat =>
      'Behält im Blick, wann jede Dosis gegeben wurde und wann die nächste gegeben werden kann, und erinnert dich pünktlich.';

  @override
  String get welcomePrivate =>
      'Alles bleibt auf diesem Telefon. Kein Konto, kein Internet.';

  @override
  String get whoAreTheMedicationsFor => 'Für wen sind die Medikamente?';

  @override
  String get me => 'Ich';

  @override
  String get someoneICareFor => 'Jemand, um den ich mich kümmere';

  @override
  String get addMoreLater => 'Du kannst später weitere Personen hinzufügen.';

  @override
  String noBrowser(String website) {
    return 'Kein Browser zum Öffnen vorhanden. Besuche stattdessen $website.';
  }

  @override
  String get backupSaved => 'Sicherung gespeichert';

  @override
  String get couldNotOpen => 'Die Datei konnte nicht geöffnet werden.';

  @override
  String get cantRestore => 'Diese Datei kann nicht wiederhergestellt werden';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Alles durch diese Sicherung ersetzen?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eingetragene Dosen',
      one: '1 eingetragene Dosis',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'Sie enthält $people, $medications und $doses. Alles, was jetzt auf diesem Telefon ist, wird dadurch ersetzt.';
  }

  @override
  String get replace => 'Ersetzen';

  @override
  String get restored => 'Wiederhergestellt';

  @override
  String get summaryFor => 'Übersicht für';

  @override
  String get summarySaved => 'Übersicht gespeichert';

  @override
  String get yourNameOnSummary => 'Dein Name auf der Übersicht';

  @override
  String get continueAction => 'Weiter';

  @override
  String get deleteAllTitle => 'Alle Daten löschen?';

  @override
  String get deleteAllMessage =>
      'Alle Personen, Medikamente und Dosen auf diesem Telefon und alle Erinnerungen. Das lässt sich nicht rückgängig machen; wenn du die Daten vielleicht noch brauchst, speichere zuerst eine Sicherung.';

  @override
  String get deleteEverything => 'Alles löschen';

  @override
  String get notificationsOff => 'Benachrichtigungen sind aus';

  @override
  String get notificationsOn => 'Benachrichtigungen sind an';

  @override
  String get notificationsOffHint =>
      'Erinnerungen können erst angezeigt werden, wenn Benachrichtigungen erlaubt sind.';

  @override
  String get notificationsOnHint =>
      'Erinnerungen werden auf diesem Telefon angezeigt.';

  @override
  String get mayBeLate => 'Erinnerungen kommen eventuell zu spät';

  @override
  String get mayBeLateHint =>
      'Android hat exakte Wecker für Nexpill deaktiviert. Aktiviere „Wecker und Erinnerungen“ für die App in den Einstellungen des Telefons wieder.';

  @override
  String get sendTest => 'Test-Erinnerung senden';

  @override
  String get sendTestHint => 'Kommt in wenigen Sekunden.';

  @override
  String get testOnItsWay => 'Test-Erinnerung ist unterwegs';

  @override
  String get peopleYouCareFor => 'Personen, um die du dich kümmerst';

  @override
  String onThisPhone(int count) {
    return '$count auf diesem Telefon';
  }

  @override
  String get yourData => 'Deine Daten';

  @override
  String get backUp => 'In einer Datei sichern';

  @override
  String get backUpHint => 'Alles, gespeichert, wo du möchtest.';

  @override
  String get restore => 'Aus einer Sicherung wiederherstellen';

  @override
  String get restoreHint => 'Ersetzt, was auf diesem Telefon ist.';

  @override
  String get medicationSummary => 'Medikamentenübersicht';

  @override
  String get medicationSummaryHint =>
      'Als reiner Text, für die Arztpraxis oder eine Übergabe.';

  @override
  String get deleteAllData => 'Alle Daten löschen';

  @override
  String get about => 'Info';

  @override
  String get aboutNexpill => 'Über Nexpill';

  @override
  String get aboutNexpillHint =>
      'Wo deine Daten liegen und warum es kostenlos ist';

  @override
  String get website => 'Website';

  @override
  String get sendFeedback => 'Feedback senden';

  @override
  String get sendFeedbackHint =>
      'Ein Formular auf der Website, in deinem Browser.';

  @override
  String get version => 'Version';

  @override
  String get language => 'Sprache';

  @override
  String get sameAsPhone => 'Wie auf dem Telefon';

  @override
  String sameAsPhoneNow(String language) {
    return 'Wie auf dem Telefon: $language';
  }

  @override
  String get aboutStaysTitle => 'Alles bleibt auf deinem Telefon';

  @override
  String get aboutStaysBody =>
      'Alles, was du einträgst, wird in einer Datenbank auf diesem Gerät gespeichert. Es gibt kein Konto und keinen Server. Woandershin gelangt es nur, wenn du es selbst dorthin bringst, als Sicherungsdatei oder Export.';

  @override
  String get aboutCannotSeeTitle => 'Wir können es nicht sehen';

  @override
  String get aboutCannotSeeBody =>
      'Nexpill wird ganz ohne die Berechtigung gebaut, das Internet zu nutzen. Android setzt das durch, und du kannst es in der Berechtigungsliste der App prüfen.';

  @override
  String get aboutRemindersTitle => 'Erinnerungen kommen vom Telefon selbst';

  @override
  String get aboutRemindersBody =>
      'Jede Erinnerung ist ein Wecker, den dieses Telefon gespeichert hat. Sie kommt also pünktlich, auch ohne Netz, im Flugmodus und nach einem Neustart.';

  @override
  String get aboutPermissionsTitle => 'Wofür die Berechtigungen da sind';

  @override
  String get aboutPermissionsBody =>
      'Benachrichtigungen, für die Erinnerungen. Exakte Wecker, damit sie auf die Minute kommen. Start nach einem Neustart, um sie neu zu stellen. Vibration. Das ist die ganze Liste.';

  @override
  String get aboutFreeTitle => 'Kostenlos, für immer';

  @override
  String get aboutFreeBody =>
      'Nexpill wurde von einem pflegenden Angehörigen für pflegende Angehörige geschrieben. Es bleibt immer kostenlos und quelloffen: kein Preis, keine Premiumversion, keine Werbung.';

  @override
  String get aboutCheckTitle => 'Du kannst unsere Arbeit prüfen';

  @override
  String get aboutCheckBody =>
      'Nexpill ist Open Source unter der GNU General Public License. Alle können genau nachlesen, was es tut.';

  @override
  String get aboutHeadline => 'Deine Daten bleiben bei dir.';

  @override
  String get aboutIntro =>
      'Nexpill behält im Blick, wann jede Dosis gegeben wurde und wann die nächste gegeben werden kann, und erinnert dich pünktlich. Es gibt keine medizinischen Ratschläge.';

  @override
  String get aboutTradeOff =>
      'Ein Kompromiss, den du kennen solltest: Es gibt keine Kopie in der Cloud. Geht das Telefon verloren oder wird es zurückgesetzt, ist der Verlauf weg. Speichere ab und zu in den Einstellungen eine Sicherungsdatei und bewahre sie woanders als auf diesem Telefon auf.';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }
}
