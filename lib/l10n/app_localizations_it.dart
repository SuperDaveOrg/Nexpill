// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours e $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Dose delle $time saltata';
  }

  @override
  String listAnd(String items, String last) {
    return '$items e $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Ogni $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'Alle $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'Al bisogno, almeno $duration tra una dose e l\'altra';
  }

  @override
  String get taperNoSteps => 'Riduzione graduale senza fasi';

  @override
  String taperStepFrom(String date) {
    return 'Dal giorno $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return '$from – $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: ogni $duration';
  }

  @override
  String get taperFinished => 'Riduzione graduale terminata';

  @override
  String taperShortEvery(String duration) {
    return 'Riduzione: ogni $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text dal giorno $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text fino al giorno $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, poi ogni $duration';
  }

  @override
  String get statusNotGiven => 'Non ancora data';

  @override
  String get statusCanGiveNow => 'Si può dare ora';

  @override
  String get statusDueNow => 'Da dare ora';

  @override
  String statusNextAt(String time) {
    return 'Prossima alle $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'In ritardo di $duration';
  }

  @override
  String statusMissed(String duration) {
    return 'Mancata: era prevista $duration fa';
  }

  @override
  String get statusFinished => 'Terminato';

  @override
  String get remindersOff => 'Disattivati';

  @override
  String get remindersOn => 'Attivi';

  @override
  String remindersEarly(String duration) {
    return '$duration prima';
  }

  @override
  String get remindersAlarm => 'come sveglia';

  @override
  String whenToday(String time) {
    return 'oggi alle $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'domani alle $time';
  }

  @override
  String whenYesterday(String time) {
    return 'ieri alle $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return 'il $date alle $time';
  }

  @override
  String shortMinutes(int count) {
    return '$count min';
  }

  @override
  String shortHours(int count) {
    return '$count h';
  }

  @override
  String shortHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String shortDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String courseFinishedLastDay(String date) {
    return 'Ciclo terminato: ultimo giorno $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ciclo terminato: date tutte le $count dosi',
      one: 'Ciclo terminato: la sua unica dose è stata data',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Ultimo giorno: $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$given di $total dosi date finora',
      one: '$given di 1 dose data finora',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'ultimo giorno: $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'restano $count dosi',
      one: 'resta 1 dose',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Prima dose prevista $when';
  }

  @override
  String get cardAsNeeded => 'Al bisogno';

  @override
  String cardAvailableFrom(String when) {
    return 'Si potrà dare di nuovo $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Prossima dose $when';
  }

  @override
  String cardIn(String duration) {
    return 'tra $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Da dare tra $duration';
  }

  @override
  String cardAt(String when) {
    return '$when';
  }

  @override
  String cardSince(String when) {
    return 'prevista $when';
  }

  @override
  String cardOverdue(String duration) {
    return 'In ritardo di $duration';
  }

  @override
  String cardWasDue(String when) {
    return 'era prevista $when';
  }

  @override
  String get cardMissed => 'Mancata';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'era prevista $when, $duration fa';
  }

  @override
  String get personYou => 'Tu';

  @override
  String get personYouAfterFor => 'te';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication: da dare alle $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication: da dare ora';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication: in ritardo dalle $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication: si può dare di nuovo';
  }

  @override
  String reminderManyFor(int count, String person) {
    return '$count farmaci per $person';
  }

  @override
  String reminderFor(String person) {
    return 'Per $person';
  }

  @override
  String get channelAlarms => 'Sveglie dei farmaci';

  @override
  String get channelAlarmsDescription =>
      'Per i farmaci impostati per suonare come una sveglia quando una dose è da dare.';

  @override
  String get channelReminders => 'Promemoria dei farmaci';

  @override
  String get channelRemindersDescription =>
      'Preavvisi, dosi da dare e dosi in ritardo.';

  @override
  String get channelUpkeep => 'Mantenere attivi i promemoria';

  @override
  String get channelUpkeepDescription =>
      'Un avviso quando bisogna aprire Nexpill perché i promemoria non si esauriscano.';

  @override
  String get actionMarkGiven => 'Segna come data';

  @override
  String get actionSkip => 'Salta';

  @override
  String actionSnooze(int minutes) {
    return 'Posticipa $minutes min';
  }

  @override
  String get upkeepTitle =>
      'Apri Nexpill per continuare a ricevere i promemoria';

  @override
  String get upkeepBody =>
      'I promemoria vengono impostati con una settimana di anticipo ogni volta che usi Nexpill. Aprilo per impostare i prossimi.';

  @override
  String get testReminderTitle => 'Promemoria di prova';

  @override
  String get testReminderBody =>
      'I promemoria funzionano. Ecco come appariranno.';

  @override
  String get csvGivenAt => 'Data e ora';

  @override
  String get csvGivenAtUtc => 'Data e ora (UTC)';

  @override
  String get csvPatient => 'Persona';

  @override
  String get csvMedication => 'Farmaco';

  @override
  String get csvDose => 'Dose';

  @override
  String get csvGivenBy => 'Chi l\'ha data';

  @override
  String get csvNotes => 'Note';

  @override
  String get csvStatus => 'Stato';

  @override
  String get csvCorrects => 'Corregge la voce';

  @override
  String get csvEntry => 'Voce';

  @override
  String get csvReplaced => 'Sostituita da una correzione';

  @override
  String get csvSkipped => 'Saltata';

  @override
  String get csvCorrection => 'Correzione';

  @override
  String get csvGiven => 'Dose data';

  @override
  String summaryTitleFor(String name) {
    return 'Riepilogo dei farmaci di $name';
  }

  @override
  String get summaryTitle => 'Riepilogo dei farmaci';

  @override
  String summaryAsOf(String dateTime) {
    return 'Situazione: $dateTime. Solo i farmaci in uso.';
  }

  @override
  String get summaryNotAdvice =>
      'Generato da Nexpill, un\'app che tiene traccia degli orari. Non è un consiglio medico.';

  @override
  String get summaryNoActive => 'Nessun farmaco in uso.';

  @override
  String summaryPurpose(String value) {
    return 'A cosa serve: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dose abituale: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Orari: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Ciclo: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Istruzioni: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Ultima dose: $value';
  }

  @override
  String get summaryNotYet => 'Non ancora';

  @override
  String summaryStatus(String value) {
    return 'Stato: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Promemoria: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Rimanenza: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (in esaurimento)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (scorta esaurita)';
  }

  @override
  String get backupNotNexpill => 'Questo file non è un backup di Nexpill.';

  @override
  String get backupTooNew =>
      'Questo backup è di una versione più recente di Nexpill. Aggiorna l\'app e riprova.';

  @override
  String get backupTwoOfYou =>
      'In questo file più di una persona è indicata come te.';

  @override
  String backupCorrectsMissing(String medication) {
    return 'Una dose di $medication corregge una dose che non è nel suo storico.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return 'Le correzioni delle dosi di $medication si richiamano a vicenda in un circolo.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where richiede \"lastDay\" oppure \"doses\", non entrambi.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where contiene un orario che non è nel formato HH:mm: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where contiene un tipo di schema sconosciuto: \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where non ha la forma prevista.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where: manca \"$key\", oppure il valore non è del tipo giusto.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where contiene \"$key\" vuoto.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where contiene un valore impossibile per \"$key\": $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where contiene un \"$key\" che non è una data AAAA-MM-GG.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where contiene un \"$key\" che non è una data e ora con fuso orario.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'L\'id \"$id\" compare più di una volta.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where non contiene \"$key\".';
  }

  @override
  String get backupWhereFile => 'Il file';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key n. $number';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get couldNotSave => 'Impossibile salvare il file.';

  @override
  String get hours => 'Ore';

  @override
  String get minutes => 'Minuti';

  @override
  String cardMoreFor(String medication) {
    return 'Altre opzioni per $medication';
  }

  @override
  String get edit => 'Modifica';

  @override
  String get doseHistory => 'Storico delle dosi';

  @override
  String skipTheDose(String time) {
    return 'Salta la dose delle $time';
  }

  @override
  String get stopTaking => 'Sospendi';

  @override
  String lastGiven(String when) {
    return 'Ultima dose $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Ultima dose $when, data da $name';
  }

  @override
  String get skip => 'Salta';

  @override
  String get give => 'Dai la dose';

  @override
  String supplyLeft(String amount) {
    return 'Restano $amount';
  }

  @override
  String get supplyNoneLeft => 'Scorta esaurita: è ora di rifornirsi';

  @override
  String supplyRunningLow(String left) {
    return '$left: in esaurimento';
  }

  @override
  String get earlyTitle => 'È presto';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return 'La prossima dose di $medication è prevista $when, tra $duration. Registrare comunque una dose adesso?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return '$medication si potrà dare di nuovo $when, tra $duration. Registrare comunque una dose adesso?';
  }

  @override
  String get notYet => 'Non ancora';

  @override
  String get logItNow => 'Registra adesso';

  @override
  String get dayGiven => 'Giorno in cui è stata data';

  @override
  String get timeGiven => 'Ora in cui è stata data';

  @override
  String get timeInFuture => 'Quell\'ora non è ancora arrivata.';

  @override
  String correctEntry(String medication) {
    return 'Correggi questa voce di $medication';
  }

  @override
  String giveMedication(String medication) {
    return 'Dai $medication';
  }

  @override
  String get originalStays =>
      'La voce originale resta nello storico, segnata come corretta.';

  @override
  String get now => 'Adesso';

  @override
  String get earlier => 'Prima';

  @override
  String givenWhen(String when) {
    return 'Dose data $when';
  }

  @override
  String get change => 'Cambia';

  @override
  String get dose => 'Dose';

  @override
  String get givenBy => 'Chi l\'ha data';

  @override
  String get optional => 'Facoltativo';

  @override
  String get notes => 'Note';

  @override
  String get saveCorrection => 'Salva la correzione';

  @override
  String get logDose => 'Registra la dose';

  @override
  String get doseHistorySaved => 'Storico delle dosi salvato';

  @override
  String get correctTimeOrDetails => 'Correggi l\'orario o i dettagli';

  @override
  String get keepsOriginal => 'La voce originale resta, segnata come corretta';

  @override
  String get deleteEntry => 'Elimina la voce';

  @override
  String get deleteEntrySkippedHint => 'La dose torna da dare';

  @override
  String get deleteEntryHint => 'Solo per una dose mai data';

  @override
  String get deleteEntryTitle => 'Eliminare questa voce?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, saltata. Eliminala se la dose non andava saltata.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Usa questa opzione solo se la dose non è mai stata data; per sistemarne l\'orario, correggila. Vengono eliminate anche le sue eventuali correzioni.';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get yourDoses => 'Le tue dosi';

  @override
  String personsDoses(String name) {
    return 'Dosi di $name';
  }

  @override
  String get doses => 'Dosi';

  @override
  String get saveAsCsv => 'Salva come foglio di calcolo (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Solo $medication';
  }

  @override
  String get nothingLogged => 'Ancora nulla di registrato.';

  @override
  String historyBy(String name) {
    return 'da $name';
  }

  @override
  String get historyCorrection => 'correzione';

  @override
  String get historyCorrected => 'corretta';

  @override
  String get defaultDose => '1 compressa';

  @override
  String get errorName => 'Dai un nome al farmaco.';

  @override
  String get errorDose =>
      'Indica a cosa corrisponde una dose, ad esempio «1 compressa».';

  @override
  String get errorHowOften => 'Scegli ogni quanto.';

  @override
  String get errorShortestGap =>
      'Scegli l\'intervallo minimo tra una dose e l\'altra.';

  @override
  String get errorAddTime => 'Aggiungi almeno un orario.';

  @override
  String get errorDosesStillToGive => 'Indica quante dosi restano da dare.';

  @override
  String get errorCourseDoses => 'Indica quante dosi prevede il ciclo.';

  @override
  String get errorStartingSupply => 'Indica la quantità iniziale.';

  @override
  String get errorPerDose => 'Indica quanto ne usa una dose.';

  @override
  String get errorLowAt => 'Indica quando avvisarti, o lascia vuoto.';

  @override
  String get errorNoSteps => 'Aggiungi almeno una fase.';

  @override
  String get errorStepInterval => 'Ogni fase ha bisogno di un intervallo.';

  @override
  String get errorStepEnds => 'Una fase deve finire dopo il suo inizio.';

  @override
  String get errorOpenEnded => 'Solo l\'ultima fase può restare senza fine.';

  @override
  String get errorStepsOverlap => 'Due fasi si sovrappongono.';

  @override
  String deleteMedicationTitle(String medication) {
    return 'Eliminare $medication?';
  }

  @override
  String get deleteMedicationMessage =>
      'Viene eliminato anche il suo storico delle dosi. Per sospenderlo ma conservare lo storico, disattiva invece «In uso».';

  @override
  String get newMedication => 'Nuovo farmaco';

  @override
  String editMedication(String medication) {
    return 'Modifica $medication';
  }

  @override
  String get save => 'Salva';

  @override
  String forPerson(String person) {
    return 'Per $person';
  }

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldNameHint => 'es. amoxicillina';

  @override
  String get fieldStrength => 'Dosaggio';

  @override
  String get fieldStrengthHint => 'Facoltativo, es. 500 mg';

  @override
  String get fieldPurpose => 'A cosa serve';

  @override
  String get fieldPurposeHint => 'Facoltativo, es. pressione';

  @override
  String get fieldUsualDose => 'Dose abituale';

  @override
  String get fieldUsualDoseHint => 'es. 1 compressa, 5 ml';

  @override
  String get fieldInstructions => 'Istruzioni';

  @override
  String get fieldInstructionsHint => 'Facoltativo, es. a stomaco pieno';

  @override
  String get sectionWhen => 'Quando';

  @override
  String get sectionHowLong => 'Per quanto tempo';

  @override
  String get sectionReminders => 'Promemoria';

  @override
  String get sectionSupply => 'Scorta';

  @override
  String get takingThisNow => 'In uso';

  @override
  String get takingThisNowHint =>
      'Disattivalo quando viene sospeso. Lo storico resta, ma i promemoria si fermano.';

  @override
  String get deleteMedication => 'Elimina il farmaco';

  @override
  String get addMedication => 'Aggiungi il farmaco';

  @override
  String get saveChanges => 'Salva le modifiche';

  @override
  String get kindInterval => 'Ogni tot ore';

  @override
  String get kindFixedTimes => 'A orari fissi';

  @override
  String get kindAsNeeded => 'Al bisogno';

  @override
  String get kindTaper => 'Riduzione graduale';

  @override
  String get every => 'Ogni';

  @override
  String get intervalHint => 'Calcolato dall\'ultima dose data.';

  @override
  String get atLeastApart => 'Almeno questo tempo tra una dose e l\'altra';

  @override
  String get asNeededHint =>
      'Mai «da dare»: Nexpill mostra quando si può dare di nuovo.';

  @override
  String get addTime => 'Aggiungi orario';

  @override
  String get fixedTimesHint =>
      'Ogni giorno, secondo l\'orologio di questo telefono.';

  @override
  String get timeOfDose => 'Orario della dose';

  @override
  String get courseUntilStopped => 'Finché non viene sospeso';

  @override
  String get courseUntilDate => 'Fino a una data';

  @override
  String get courseNumberOfDoses => 'Un numero di dosi';

  @override
  String get courseOngoingHint =>
      'I promemoria continuano finché non disattivi «In uso».';

  @override
  String courseLastDayChip(String date) {
    return 'Ultimo giorno: $date';
  }

  @override
  String get courseLastDayHint =>
      'Le dosi continuano per tutto quel giorno; i promemoria si fermano alla mezzanotte, quando il giorno finisce.';

  @override
  String get dosesStillToGive => 'Dosi ancora da dare';

  @override
  String get numberOfDoses => 'Numero di dosi';

  @override
  String get dosesHint => 'es. 10';

  @override
  String get courseDosesHint =>
      'I promemoria si fermano quando viene data l\'ultima.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count dosi date finora. I promemoria si fermano quando viene data l\'ultima.',
      one: '1 dose data finora. I promemoria si fermano quando viene data l\'ultima.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Ultimo giorno del ciclo';

  @override
  String taperStepNumber(int number) {
    return 'Fase $number';
  }

  @override
  String get removeStep => 'Rimuovi la fase';

  @override
  String stepFrom(String date) {
    return 'Dal giorno $date';
  }

  @override
  String get noEndDate => 'Nessuna data di fine';

  @override
  String stepUntil(String date) {
    return 'Fino al giorno $date';
  }

  @override
  String get clearEnd => 'Togli la fine';

  @override
  String get addStep => 'Aggiungi una fase';

  @override
  String get taperHint =>
      'Ogni fase va dalla mezzanotte del suo primo giorno alla mezzanotte del suo giorno di fine. L\'ultima fase può restare senza fine.';

  @override
  String get remindMe => 'Ricordamelo';

  @override
  String get remindAsNeededHint => 'Quando si può dare di nuovo.';

  @override
  String get remindHint =>
      'Quando una dose è da dare, e di nuovo finché è in ritardo.';

  @override
  String get headsUp => 'Preavviso prima dell\'orario';

  @override
  String get none => 'Nessuno';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get repeatWhileOverdue => 'Ripeti finché è in ritardo';

  @override
  String everyDuration(String duration) {
    return 'ogni $duration';
  }

  @override
  String get ringLikeAlarm => 'Suona come una sveglia';

  @override
  String get ringLikeAlarmHint =>
      'Il suono della sveglia, ripetuto finché non la segni come data o la posticipi.';

  @override
  String get trackSupply => 'Tieni il conto di quanto ne resta';

  @override
  String get trackSupplyHint => 'Si riduce a ogni dose registrata.';

  @override
  String get startingAmount => 'Quantità iniziale';

  @override
  String get unit => 'Unità';

  @override
  String get unitHint => 'compresse';

  @override
  String get eachDoseUses => 'Ogni dose usa';

  @override
  String get warnAt => 'Avvisa quando ne restano';

  @override
  String get everyone => 'Tutti';

  @override
  String get managePeople => 'Gestisci le persone';

  @override
  String get settings => 'Impostazioni';

  @override
  String get addSomeone => 'Aggiungi qualcuno';

  @override
  String get noMedicationsYet => 'Ancora nessun farmaco';

  @override
  String get nothingToGiveNow => 'Niente da dare ora';

  @override
  String moreDueNow(int count) {
    return '+ altri $count da dare ora';
  }

  @override
  String get remindersOffShort => 'Promemoria disattivati';

  @override
  String get errorEnterName => 'Inserisci un nome.';

  @override
  String get errorNameTaken => 'C\'è già qualcuno con questo nome.';

  @override
  String get whoAreYouCaringFor => 'Di chi ti prendi cura?';

  @override
  String get rename => 'Rinomina';

  @override
  String get yourName => 'Il tuo nome';

  @override
  String get nameHint => 'Basta un nome o un soprannome';

  @override
  String get thisIsMe => 'Sono io';

  @override
  String get forYourOwnMedications => 'Per i tuoi farmaci';

  @override
  String get add => 'Aggiungi';

  @override
  String get deleteYourMedicationsTitle => 'Eliminare i tuoi farmaci?';

  @override
  String deletePersonTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vengono eliminati anche i tuoi $count farmaci e tutto lo storico delle dosi, e non si potranno recuperare senza un file di backup.',
      one: 'Vengono eliminati anche il tuo farmaco e tutto lo storico delle dosi, e non si potranno recuperare senza un file di backup.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vengono eliminati anche i suoi $count farmaci e tutto lo storico delle dosi, e non si potranno recuperare senza un file di backup.',
      one: 'Vengono eliminati anche il suo farmaco e tutto lo storico delle dosi, e non si potranno recuperare senza un file di backup.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Persone';

  @override
  String tapToSeeThem(String count) {
    return '$count · tocca per vedere';
  }

  @override
  String get addYourName => 'Aggiungi il tuo nome';

  @override
  String get asSetForEach => 'Come impostato per ogni farmaco';

  @override
  String allOffFor(String person) {
    return 'Tutti disattivati per $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count farmaci',
      one: '1 farmaco',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return '$medication: dose registrata, $when';
  }

  @override
  String get undo => 'Annulla';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication: dose saltata $count volte di fila';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Promemoria disattivati per $medication. Puoi riattivarli in Modifica.';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication: sospeso. Lo storico viene conservato.';
  }

  @override
  String get remindersAreOff => 'I promemoria sono disattivati';

  @override
  String get allowNotificationsHint =>
      'Consenti le notifiche perché i promemoria ti possano raggiungere.';

  @override
  String get allow => 'Consenti';

  @override
  String remindersAreOffFor(String person) {
    return 'I promemoria sono disattivati per $person.';
  }

  @override
  String get addYourFirst =>
      'Aggiungi il primo e Nexpill terrà traccia di quando si può dare ogni dose.';

  @override
  String addPersonsFirst(String name) {
    return 'Aggiungi il primo farmaco di $name e Nexpill terrà traccia di quando si può dare ogni dose.';
  }

  @override
  String get allEndedForYou =>
      'Tutti i tuoi farmaci sono terminati o sospesi. Li trovi qui sotto, con il loro storico.';

  @override
  String allEndedForPerson(String name) {
    return 'Tutti i farmaci di $name sono terminati o sospesi. Li trovi qui sotto, con il loro storico.';
  }

  @override
  String get addAMedication => 'Aggiungi un farmaco';

  @override
  String get addAnotherMedication => 'Aggiungi un altro farmaco';

  @override
  String addMedicationFor(String name) {
    return 'Aggiungi un farmaco per $name';
  }

  @override
  String endedStopped(int count) {
    return 'Sospesi ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Terminati ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Terminati e sospesi ($count)';
  }

  @override
  String get resume => 'Riprendi';

  @override
  String get logoLabel => 'Logo di Nexpill';

  @override
  String get welcomeWhat =>
      'Tiene traccia di quando è stata data ogni dose e di quando si può dare la prossima, e ti avvisa in orario.';

  @override
  String get welcomePrivate =>
      'Tutto resta su questo telefono. Nessun account, nessuna connessione a internet.';

  @override
  String get whoAreTheMedicationsFor => 'Per chi sono i farmaci?';

  @override
  String get me => 'Per me';

  @override
  String get someoneICareFor => 'Per qualcuno di cui mi prendo cura';

  @override
  String get addMoreLater => 'Potrai aggiungere altre persone in seguito.';

  @override
  String noBrowser(String website) {
    return 'Nessun browser per aprirlo. Visita $website.';
  }

  @override
  String get backupSaved => 'Backup salvato';

  @override
  String get couldNotOpen => 'Impossibile aprire il file.';

  @override
  String get cantRestore => 'Impossibile ripristinare questo file';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Sostituire tutto con questo backup?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dosi registrate',
      one: '1 dose registrata',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'Contiene $people, $medications e $doses. Tutto ciò che c\'è ora su questo telefono verrà sostituito.';
  }

  @override
  String get replace => 'Sostituisci';

  @override
  String get restored => 'Ripristinato';

  @override
  String get summaryFor => 'Riepilogo per';

  @override
  String get summarySaved => 'Riepilogo salvato';

  @override
  String get yourNameOnSummary => 'Il tuo nome sul riepilogo';

  @override
  String get continueAction => 'Continua';

  @override
  String get deleteAllTitle => 'Eliminare tutti i dati?';

  @override
  String get deleteAllMessage =>
      'Tutte le persone, i farmaci e le dosi su questo telefono, e tutti i promemoria. Non si può annullare; se potresti volerli recuperare, salva prima un backup.';

  @override
  String get deleteEverything => 'Elimina tutto';

  @override
  String get notificationsOff => 'Le notifiche sono disattivate';

  @override
  String get notificationsOn => 'Le notifiche sono attive';

  @override
  String get notificationsOffHint =>
      'I promemoria non possono essere mostrati finché le notifiche non sono consentite.';

  @override
  String get notificationsOnHint =>
      'I promemoria appariranno su questo telefono.';

  @override
  String get mayBeLate => 'I promemoria potrebbero arrivare in ritardo';

  @override
  String get mayBeLateHint =>
      'Android ha disattivato le sveglie esatte per Nexpill. Riattiva «Sveglie e promemoria» nelle impostazioni del telefono per l\'app.';

  @override
  String get sendTest => 'Invia un promemoria di prova';

  @override
  String get sendTestHint => 'Arriva entro pochi secondi.';

  @override
  String get testOnItsWay => 'Promemoria di prova in arrivo';

  @override
  String get peopleYouCareFor => 'Persone di cui ti prendi cura';

  @override
  String onThisPhone(int count) {
    return '$count su questo telefono';
  }

  @override
  String get yourData => 'I tuoi dati';

  @override
  String get backUp => 'Esegui il backup su un file';

  @override
  String get backUpHint => 'Tutto, salvato dove scegli tu.';

  @override
  String get restore => 'Ripristina da un backup';

  @override
  String get restoreHint => 'Sostituisce quello che c\'è su questo telefono.';

  @override
  String get medicationSummary => 'Riepilogo dei farmaci';

  @override
  String get medicationSummaryHint =>
      'Testo semplice, per il medico o per un passaggio di consegne.';

  @override
  String get deleteAllData => 'Elimina tutti i dati';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutNexpill => 'Informazioni su Nexpill';

  @override
  String get aboutNexpillHint =>
      'Dove si trovano i tuoi dati e perché è gratis';

  @override
  String get website => 'Sito web';

  @override
  String get sendFeedback => 'Invia un commento';

  @override
  String get sendFeedbackHint => 'Un modulo sul sito web, nel tuo browser.';

  @override
  String get version => 'Versione';

  @override
  String get language => 'Lingua';

  @override
  String get sameAsPhone => 'Come il telefono';

  @override
  String sameAsPhoneNow(String language) {
    return 'Come il telefono: $language';
  }

  @override
  String get aboutStaysTitle => 'Resta sul tuo telefono';

  @override
  String get aboutStaysBody =>
      'Tutto ciò che registri viene scritto in un database su questo dispositivo. Non c\'è nessun account e nessun server. Va altrove solo se lo sposti tu, come file di backup o esportazione.';

  @override
  String get aboutCannotSeeTitle => 'Noi non possiamo vederlo';

  @override
  String get aboutCannotSeeBody =>
      'Nexpill è realizzata senza alcun permesso di usare internet. Lo garantisce Android, e puoi verificarlo nell\'elenco dei permessi dell\'app.';

  @override
  String get aboutRemindersTitle => 'I promemoria arrivano dal telefono stesso';

  @override
  String get aboutRemindersBody =>
      'Ogni promemoria è una sveglia conservata da questo telefono, quindi arriva in orario anche senza segnale, in modalità aereo e dopo un riavvio.';

  @override
  String get aboutPermissionsTitle => 'A cosa servono i permessi';

  @override
  String get aboutPermissionsBody =>
      'Notifiche, per i promemoria. Sveglie esatte, perché arrivino al minuto. Avvio dopo il riavvio, per reimpostarli. Vibrazione. L\'elenco è tutto qui.';

  @override
  String get aboutFreeTitle => 'Gratis, per sempre';

  @override
  String get aboutFreeBody =>
      'Nexpill è stata scritta da chi assiste qualcuno, per chi assiste qualcuno. Sarà sempre gratuita e open source: nessun prezzo, nessuna versione premium, nessuna pubblicità.';

  @override
  String get aboutCheckTitle => 'Puoi verificare il nostro lavoro';

  @override
  String get aboutCheckBody =>
      'Nexpill è open source, con licenza GNU General Public License. Chiunque può leggere esattamente cosa fa.';

  @override
  String get aboutHeadline => 'I tuoi dati restano con te.';

  @override
  String get aboutIntro =>
      'Nexpill tiene traccia di quando è stata data ogni dose e di quando si può dare la prossima, e ti avvisa in orario. Non dà consigli medici.';

  @override
  String get aboutTradeOff =>
      'Un compromesso da sapere: non c\'è una copia nel cloud, quindi se perdi o resetti il telefono perdi lo storico. Salva ogni tanto un file di backup dalle Impostazioni e conservalo da qualche parte che non sia questo telefono.';

  @override
  String versionNumber(String version) {
    return 'Versione $version';
  }
}
