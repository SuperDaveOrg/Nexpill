// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures',
      one: '1 heure',
      zero: '$count heures',
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
      zero: '$count minutes',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours et $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Dose de $time sautée';
  }

  @override
  String listAnd(String items, String last) {
    return '$items et $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Toutes les $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'À $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'Si besoin, au moins $duration entre deux doses';
  }

  @override
  String get taperNoSteps => 'Diminution progressive sans étapes';

  @override
  String taperStepFrom(String date) {
    return 'À partir du $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return 'Du $from au $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when : toutes les $duration';
  }

  @override
  String get taperFinished => 'Diminution progressive terminée';

  @override
  String scheduleOnce(String when) {
    return 'Une fois, $when';
  }

  @override
  String scheduleOnceToday(String time) {
    return 'Une fois, aujourd\'hui à $time';
  }

  @override
  String get singleDoseFinished => 'Dose unique enregistrée';

  @override
  String taperShortEvery(String duration) {
    return 'Diminution : toutes les $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text à partir du $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text jusqu\'au $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, puis toutes les $duration';
  }

  @override
  String get statusNotGiven => 'Aucune dose donnée';

  @override
  String get statusCanGiveNow => 'Dose possible maintenant';

  @override
  String get statusDueNow => 'À donner maintenant';

  @override
  String statusNextAt(String time) {
    return 'Prochaine dose à $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'En retard de $duration';
  }

  @override
  String statusMissed(String duration) {
    return 'Manquée : était prévue il y a $duration';
  }

  @override
  String get statusFinished => 'Terminé';

  @override
  String get remindersOff => 'Désactivés';

  @override
  String get remindersOn => 'Activés';

  @override
  String remindersEarly(String duration) {
    return '$duration avant';
  }

  @override
  String get remindersAlarm => 'en mode alarme';

  @override
  String whenToday(String time) {
    return 'aujourd\'hui à $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'demain à $time';
  }

  @override
  String whenYesterday(String time) {
    return 'hier à $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return 'le $date à $time';
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
      other: '$count jours',
      one: '1 jour',
      zero: '$count jours',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String courseFinishedLastDay(String date) {
    return 'Traitement terminé : le dernier jour était le $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Traitement terminé : les $count doses ont été données',
      one: 'Traitement terminé : son unique dose a été donnée',
      zero: 'Traitement terminé : les $count doses ont été données',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Dernier jour : $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total doses, $given données jusqu\'ici',
      one: '1 dose, $given donnée jusqu\'ici',
      zero: '$total doses, $given données jusqu\'ici',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'dernier jour : $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses restantes',
      one: '1 dose restante',
      zero: '$count doses restantes',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Première dose $when';
  }

  @override
  String get cardAsNeeded => 'Si besoin';

  @override
  String cardAvailableFrom(String when) {
    return 'Prochaine dose possible $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Prochaine dose $when';
  }

  @override
  String cardIn(String duration) {
    return 'dans $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'À donner dans $duration';
  }

  @override
  String cardAt(String when) {
    return '$when';
  }

  @override
  String cardSince(String when) {
    return 'depuis $when';
  }

  @override
  String cardOverdue(String duration) {
    return 'En retard de $duration';
  }

  @override
  String cardWasDue(String when) {
    return 'était prévue $when';
  }

  @override
  String get cardMissed => 'Manquée';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'était prévue $when, il y a $duration';
  }

  @override
  String get personYou => 'Vous';

  @override
  String get personYouAfterFor => 'vous';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication : à donner à $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication : à donner maintenant';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication : en retard depuis $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication : nouvelle dose possible';
  }

  @override
  String reminderManyFor(int count, String person) {
    return '$count médicaments pour $person';
  }

  @override
  String reminderFor(String person) {
    return 'Pour $person';
  }

  @override
  String get channelAlarms => 'Alarmes de médicaments';

  @override
  String get channelAlarmsDescription =>
      'Pour les médicaments réglés pour sonner comme une alarme quand une dose est à donner.';

  @override
  String get channelReminders => 'Rappels de médicaments';

  @override
  String get channelRemindersDescription =>
      'Avis anticipés, doses à donner et doses en retard.';

  @override
  String get channelUpkeep => 'Maintien des rappels';

  @override
  String get channelUpkeepDescription =>
      'Un message quand il faut ouvrir Nexpill pour que les rappels ne s\'arrêtent pas.';

  @override
  String get actionMarkGiven => 'Marquer comme donnée';

  @override
  String get actionSkip => 'Sauter';

  @override
  String actionSnooze(int minutes) {
    return 'Reporter de $minutes min';
  }

  @override
  String get upkeepTitle =>
      'Ouvrez Nexpill pour continuer à recevoir les rappels';

  @override
  String get upkeepBody =>
      'Les rappels sont programmés une semaine à l\'avance à chaque utilisation de Nexpill. Ouvrez l\'application pour programmer les suivants.';

  @override
  String get testReminderTitle => 'Rappel de test';

  @override
  String get testReminderBody =>
      'Les rappels fonctionnent. Voici à quoi ils ressembleront.';

  @override
  String get csvGivenAt => 'Date et heure';

  @override
  String get csvGivenAtUtc => 'Date et heure (UTC)';

  @override
  String get csvPatient => 'Personne';

  @override
  String get csvMedication => 'Médicament';

  @override
  String get csvDose => 'Dose';

  @override
  String get csvGivenBy => 'Donnée par';

  @override
  String get csvNotes => 'Notes';

  @override
  String get csvStatus => 'Statut';

  @override
  String get csvCorrects => 'Corrige l\'entrée';

  @override
  String get csvEntry => 'Entrée';

  @override
  String get csvReplaced => 'Remplacée par une correction';

  @override
  String get csvSkipped => 'Sautée';

  @override
  String get csvRefill => 'Réapprovisionnement';

  @override
  String get csvCorrection => 'Correction';

  @override
  String get csvGiven => 'Donnée';

  @override
  String summaryTitleFor(String name) {
    return 'Résumé des médicaments pour $name';
  }

  @override
  String get summaryTitle => 'Résumé des médicaments';

  @override
  String summaryAsOf(String dateTime) {
    return 'Au $dateTime. Médicaments en cours uniquement.';
  }

  @override
  String get summaryNotAdvice =>
      'Établi avec Nexpill, un outil de suivi des horaires. Ce n\'est pas un avis médical.';

  @override
  String get summaryNoActive => 'Aucun médicament en cours.';

  @override
  String summaryPurpose(String value) {
    return 'Utilisé pour : $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dose : $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Horaire : $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Traitement : $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Instructions : $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Dernière dose : $value';
  }

  @override
  String get summaryNotYet => 'Pas encore';

  @override
  String summaryStatus(String value) {
    return 'Statut : $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Rappels : $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Reste : $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (stock bas)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (stock épuisé)';
  }

  @override
  String get backupNotNexpill =>
      'Ce fichier n\'est pas une sauvegarde Nexpill.';

  @override
  String get backupTooNew =>
      'Cette sauvegarde provient d\'une version plus récente de Nexpill. Mettez l\'application à jour, puis réessayez.';

  @override
  String get backupTwoOfYou =>
      'Dans ce fichier, plus d\'une personne est indiquée comme étant vous.';

  @override
  String backupCorrectsMissing(String medication) {
    return 'Pour $medication, une dose en corrige une autre qui ne figure pas dans l\'historique.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return 'Pour $medication, les corrections de doses tournent en boucle.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where doit avoir \"lastDay\" ou \"doses\", mais pas les deux.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where contient une heure qui n\'est pas au format HH:mm : $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where contient un type d\'horaire inconnu : \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where n\'a pas la forme attendue.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where : \"$key\" est absent ou n\'a pas le bon type de valeur.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where contient un \"$key\" vide.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where contient un \"$key\" impossible : $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where contient un \"$key\" qui n\'est pas une date AAAA-MM-JJ.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where contient un \"$key\" qui n\'est pas une date et heure avec fuseau horaire.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'L\'identifiant \"$id\" apparaît plus d\'une fois.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where n\'a pas de \"$key\".';
  }

  @override
  String get backupWhereFile => 'Le fichier';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key n° $number';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get couldNotSave => 'Impossible d\'enregistrer le fichier.';

  @override
  String get hours => 'Heures';

  @override
  String get minutes => 'Minutes';

  @override
  String cardMoreFor(String medication) {
    return 'Plus d\'options pour $medication';
  }

  @override
  String get edit => 'Modifier';

  @override
  String get doseHistory => 'Historique des doses';

  @override
  String skipTheDose(String time) {
    return 'Sauter la dose de $time';
  }

  @override
  String get stopTaking => 'Arrêter le traitement';

  @override
  String lastGiven(String when) {
    return 'Dernière dose $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Dernière dose $when, donnée par $name';
  }

  @override
  String get skip => 'Sauter';

  @override
  String get give => 'Donner';

  @override
  String supplyLeft(String amount) {
    return 'Il reste $amount';
  }

  @override
  String get supplyNoneLeft => 'Stock épuisé : à renouveler';

  @override
  String supplyRunningLow(String left) {
    return '$left (stock bas)';
  }

  @override
  String get refill => 'Réapprovisionner';

  @override
  String refillTitle(String medication) {
    return 'Réapprovisionner $medication';
  }

  @override
  String get refillAmount => 'Quantité à ajouter';

  @override
  String get refillAdd => 'Ajouter';

  @override
  String refilled(String medication, String left) {
    return 'Réapprovisionnement de $medication. $left.';
  }

  @override
  String get earlyTitle => 'C\'est trop tôt';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return 'Pour $medication, la prochaine dose est prévue $when, dans $duration. Enregistrer une dose maintenant quand même ?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return 'Pour $medication, la prochaine dose est possible $when, dans $duration. Enregistrer une dose maintenant quand même ?';
  }

  @override
  String get notYet => 'Pas encore';

  @override
  String get logItNow => 'Enregistrer maintenant';

  @override
  String get dayGiven => 'Jour où elle a été donnée';

  @override
  String get timeGiven => 'Heure à laquelle elle a été donnée';

  @override
  String get timeInFuture => 'Cette heure n\'est pas encore passée.';

  @override
  String correctEntry(String medication) {
    return 'Corriger cette entrée pour $medication';
  }

  @override
  String giveMedication(String medication) {
    return 'Donner $medication';
  }

  @override
  String get originalStays =>
      'L\'entrée d\'origine reste dans l\'historique, marquée comme corrigée.';

  @override
  String get now => 'Maintenant';

  @override
  String get earlier => 'Plus tôt';

  @override
  String givenWhen(String when) {
    return 'Donnée $when';
  }

  @override
  String get change => 'Modifier';

  @override
  String get dose => 'Dose';

  @override
  String get givenBy => 'Donnée par';

  @override
  String get optional => 'Facultatif';

  @override
  String get notes => 'Notes';

  @override
  String get saveCorrection => 'Enregistrer la correction';

  @override
  String get logDose => 'Enregistrer la dose';

  @override
  String get doseHistorySaved => 'Historique des doses enregistré';

  @override
  String get correctTimeOrDetails => 'Corriger l\'heure ou les détails';

  @override
  String get keepsOriginal =>
      'L\'entrée d\'origine est conservée, marquée comme corrigée';

  @override
  String get deleteEntry => 'Supprimer l\'entrée';

  @override
  String get deleteEntrySkippedHint => 'La dose redevient à donner';

  @override
  String get deleteEntryHint =>
      'Uniquement pour une dose qui n\'a jamais été donnée';

  @override
  String get deleteEntryTitle => 'Supprimer cette entrée ?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, sautée. Supprimez-la si cette dose n\'aurait pas dû être sautée.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. À utiliser uniquement si la dose n\'a jamais été donnée ; pour changer son heure, corrigez-la plutôt. Ses éventuelles corrections seront aussi supprimées.';
  }

  @override
  String deleteRefillMessage(
    String medication,
    String dateTime,
    String amount,
  ) {
    return '$medication, $dateTime : +$amount. Supprimez-le s\'il a été enregistré par erreur ; la quantité restante baisse d\'autant. Si la quantité était fausse, réapprovisionnez ensuite avec la bonne.';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get yourDoses => 'Vos doses';

  @override
  String personsDoses(String name) {
    return 'Doses pour $name';
  }

  @override
  String get doses => 'Doses';

  @override
  String get saveAsCsv => 'Enregistrer comme tableur (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Uniquement $medication';
  }

  @override
  String get nothingLogged => 'Rien n\'a encore été enregistré.';

  @override
  String historyBy(String name) {
    return 'par $name';
  }

  @override
  String get historyCorrection => 'correction';

  @override
  String historyRefill(String amount) {
    return 'Réapprovisionnement : +$amount';
  }

  @override
  String get historyCorrected => 'corrigée';

  @override
  String get defaultDose => '1 comprimé';

  @override
  String get errorName => 'Donnez un nom au médicament.';

  @override
  String get errorDose =>
      'Indiquez ce qu\'est une dose, par exemple « 1 comprimé ».';

  @override
  String get errorHowOften => 'Choisissez la fréquence.';

  @override
  String get errorShortestGap =>
      'Choisissez l\'écart minimum entre deux doses.';

  @override
  String get errorAddTime => 'Ajoutez au moins une heure.';

  @override
  String get errorDosesStillToGive =>
      'Indiquez combien de doses restent à donner.';

  @override
  String get errorCourseDoses =>
      'Indiquez combien de doses compte le traitement.';

  @override
  String get errorAmountLeft => 'Indiquez la quantité restante.';

  @override
  String get errorPerDose => 'Indiquez la quantité utilisée par dose.';

  @override
  String get errorLowAt => 'Indiquez quand prévenir, ou laissez vide.';

  @override
  String get errorNoSteps => 'Ajoutez au moins une étape.';

  @override
  String get errorStepInterval => 'Chaque étape doit avoir un intervalle.';

  @override
  String get errorStepEnds =>
      'Une étape doit se terminer après avoir commencé.';

  @override
  String get errorOpenEnded => 'Seule la dernière étape peut rester sans fin.';

  @override
  String get errorStepsOverlap => 'Deux étapes se chevauchent.';

  @override
  String deleteMedicationTitle(String medication) {
    return 'Supprimer $medication ?';
  }

  @override
  String get deleteMedicationMessage =>
      'Son historique de doses sera aussi supprimé. Pour l\'arrêter en gardant l\'historique, désactivez plutôt « Traitement en cours ».';

  @override
  String get newMedication => 'Nouveau médicament';

  @override
  String editMedication(String medication) {
    return 'Modifier $medication';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String forPerson(String person) {
    return 'Pour $person';
  }

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldNameHint => 'ex. : amoxicilline';

  @override
  String get fieldStrength => 'Dosage';

  @override
  String get fieldStrengthHint => 'Facultatif, ex. : 500 mg';

  @override
  String get fieldPurpose => 'Utilisé pour';

  @override
  String get fieldPurposeHint => 'Facultatif, ex. : tension artérielle';

  @override
  String get fieldUsualDose => 'Dose habituelle';

  @override
  String get fieldUsualDoseHint => 'ex. : 1 comprimé, 5 ml';

  @override
  String get fieldInstructions => 'Instructions';

  @override
  String get fieldInstructionsHint => 'Facultatif, ex. : pendant le repas';

  @override
  String get sectionWhen => 'Quand';

  @override
  String get sectionHowLong => 'Durée';

  @override
  String get sectionReminders => 'Rappels';

  @override
  String get sectionSupply => 'Stock';

  @override
  String get takingThisNow => 'Traitement en cours';

  @override
  String get takingThisNowHint =>
      'À désactiver quand le traitement est arrêté. L\'historique est conservé, mais les rappels s\'arrêtent.';

  @override
  String get deleteMedication => 'Supprimer le médicament';

  @override
  String get addMedication => 'Ajouter le médicament';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get kindInterval => 'Toutes les X heures';

  @override
  String get kindFixedTimes => 'À heures fixes';

  @override
  String get kindAsNeeded => 'Si besoin';

  @override
  String get kindTaper => 'Diminution progressive';

  @override
  String get kindOnce => 'Une fois';

  @override
  String get every => 'Toutes les';

  @override
  String get intervalHint => 'Compté à partir de la dernière dose donnée.';

  @override
  String get atLeastApart => 'Écart minimum entre deux doses';

  @override
  String get asNeededHint =>
      'Jamais « à donner » : Nexpill indique quand une nouvelle dose est possible.';

  @override
  String get addTime => 'Ajouter une heure';

  @override
  String get fixedTimesHint =>
      'Tous les jours, selon l\'horloge de ce téléphone.';

  @override
  String get timeOfDose => 'Heure de la dose';

  @override
  String get onceHint =>
      'Une seule dose. Dès qu\'elle est donnée ou sautée, elle est terminée et reste dans l\'historique.';

  @override
  String get dayOfDose => 'Jour de la dose';

  @override
  String get courseUntilStopped => 'Jusqu\'à l\'arrêt';

  @override
  String get courseUntilDate => 'Jusqu\'à une date';

  @override
  String get courseNumberOfDoses => 'Un nombre de doses';

  @override
  String get courseOngoingHint =>
      'Les rappels continuent jusqu\'à ce que vous désactiviez « Traitement en cours ».';

  @override
  String courseLastDayChip(String date) {
    return 'Dernier jour : $date';
  }

  @override
  String get courseLastDayHint =>
      'Les doses continuent toute cette journée ; les rappels s\'arrêtent à minuit, à la fin de celle-ci.';

  @override
  String get dosesStillToGive => 'Doses restant à donner';

  @override
  String get numberOfDoses => 'Nombre de doses';

  @override
  String get dosesHint => 'ex. : 10';

  @override
  String get courseDosesHint =>
      'Les rappels s\'arrêtent une fois la dernière dose donnée.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count doses données jusqu\'ici. Les rappels s\'arrêtent une fois la dernière dose donnée.',
      one: '1 dose donnée jusqu\'ici. Les rappels s\'arrêtent une fois la dernière dose donnée.',
      zero:
          '$count doses données jusqu\'ici. Les rappels s\'arrêtent une fois la dernière dose donnée.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Dernier jour du traitement';

  @override
  String taperStepNumber(int number) {
    return 'Étape $number';
  }

  @override
  String get removeStep => 'Retirer l\'étape';

  @override
  String stepFrom(String date) {
    return 'À partir du $date';
  }

  @override
  String get noEndDate => 'Pas de date de fin';

  @override
  String stepUntil(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String get clearEnd => 'Retirer la fin';

  @override
  String get addStep => 'Ajouter une étape';

  @override
  String get taperHint =>
      'Chaque étape va de minuit le premier jour jusqu\'à minuit le jour de fin. La dernière étape peut rester sans fin.';

  @override
  String get remindMe => 'Me le rappeler';

  @override
  String get remindAsNeededHint => 'Quand une nouvelle dose est possible.';

  @override
  String get remindHint =>
      'Quand une dose est à donner, puis de nouveau tant qu\'elle est en retard.';

  @override
  String get headsUp => 'Prévenir avant l\'heure prévue';

  @override
  String get none => 'Aucun';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get repeatWhileOverdue => 'Répéter tant qu\'elle est en retard';

  @override
  String everyDuration(String duration) {
    return 'toutes les $duration';
  }

  @override
  String get ringLikeAlarm => 'Sonner comme une alarme';

  @override
  String get ringLikeAlarmHint =>
      'Le son d\'alarme, répété jusqu\'à ce que vous marquiez la dose comme donnée ou reportiez le rappel.';

  @override
  String get trackSupply => 'Suivre la quantité restante';

  @override
  String get trackSupplyHint => 'Diminue à chaque dose enregistrée.';

  @override
  String get amountLeft => 'Quantité restante';

  @override
  String get unit => 'Unité';

  @override
  String get unitHint => 'comprimés';

  @override
  String get eachDoseUses => 'Quantité par dose';

  @override
  String get warnAt => 'Prévenir quand il reste';

  @override
  String get everyone => 'Tout le monde';

  @override
  String get managePeople => 'Gérer les personnes';

  @override
  String get settings => 'Paramètres';

  @override
  String get addSomeone => 'Ajouter une personne';

  @override
  String get noMedicationsYet => 'Aucun médicament pour l\'instant';

  @override
  String get nothingToGiveNow => 'Rien à donner maintenant';

  @override
  String moreDueNow(int count) {
    return '+ $count autres à donner maintenant';
  }

  @override
  String get remindersOffShort => 'Rappels désactivés';

  @override
  String get errorEnterName => 'Saisissez un nom.';

  @override
  String get errorNameTaken => 'Ce nom est déjà utilisé.';

  @override
  String get whoAreYouCaringFor => 'De qui vous occupez-vous ?';

  @override
  String get rename => 'Renommer';

  @override
  String get yourName => 'Votre nom';

  @override
  String get nameHint => 'Un prénom ou un surnom suffit';

  @override
  String get thisIsMe => 'C\'est moi';

  @override
  String get forYourOwnMedications => 'Pour vos propres médicaments';

  @override
  String get add => 'Ajouter';

  @override
  String get deleteYourMedicationsTitle => 'Supprimer vos médicaments ?';

  @override
  String deletePersonTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vos $count médicaments et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
      one: 'Votre médicament et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
      zero:
          'Vos $count médicaments et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ses $count médicaments et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
      one: 'Son médicament et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
      zero:
          'Ses $count médicaments et tout l\'historique des doses seront aussi supprimés, sans possibilité de les récupérer sauf avec un fichier de sauvegarde.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Personnes';

  @override
  String tapToSeeThem(String count) {
    return '$count · touchez pour les voir';
  }

  @override
  String get addYourName => 'Ajouter votre nom';

  @override
  String get asSetForEach => 'Selon le réglage de chaque médicament';

  @override
  String allOffFor(String person) {
    return 'Tous désactivés pour $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médicaments',
      one: '1 médicament',
      zero: '$count médicaments',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return 'Dose de $medication enregistrée, $when';
  }

  @override
  String get undo => 'Annuler';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication : dose sautée $count fois de suite';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication : $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Rappels désactivés pour $medication. Réactivez-les dans Modifier.';
  }

  @override
  String medicationStopped(String medication) {
    return 'Arrêt de $medication. Son historique est conservé.';
  }

  @override
  String get remindersAreOff => 'Les rappels sont désactivés';

  @override
  String get allowNotificationsHint =>
      'Autorisez les notifications pour qu\'ils vous parviennent.';

  @override
  String get allow => 'Autoriser';

  @override
  String remindersAreOffFor(String person) {
    return 'Les rappels sont désactivés pour $person.';
  }

  @override
  String get addYourFirst =>
      'Ajoutez votre premier médicament, et Nexpill suivra quand chaque dose peut être donnée.';

  @override
  String addPersonsFirst(String name) {
    return 'Ajoutez le premier médicament pour $name, et Nexpill suivra quand chaque dose peut être donnée.';
  }

  @override
  String get allEndedForYou =>
      'Tous vos médicaments sont terminés ou arrêtés. Ils figurent ci-dessous, avec leur historique.';

  @override
  String allEndedForPerson(String name) {
    return 'Tous les médicaments pour $name sont terminés ou arrêtés. Ils figurent ci-dessous, avec leur historique.';
  }

  @override
  String get addAMedication => 'Ajouter un médicament';

  @override
  String get addAnotherMedication => 'Ajouter un autre médicament';

  @override
  String addMedicationFor(String name) {
    return 'Ajouter un médicament pour $name';
  }

  @override
  String endedStopped(int count) {
    return 'Arrêtés ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Terminés ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Terminés et arrêtés ($count)';
  }

  @override
  String get resume => 'Reprendre';

  @override
  String get logoLabel => 'Logo de Nexpill';

  @override
  String get welcomeWhat =>
      'Suit quand chaque dose a été donnée et quand la suivante peut l\'être, et vous rappelle à l\'heure.';

  @override
  String get welcomePrivate =>
      'Tout reste sur ce téléphone. Pas de compte, pas d\'internet.';

  @override
  String get whoAreTheMedicationsFor => 'Pour qui sont les médicaments ?';

  @override
  String get me => 'Moi';

  @override
  String get someoneICareFor => 'Une personne dont je m\'occupe';

  @override
  String get addMoreLater =>
      'Vous pourrez ajouter d\'autres personnes plus tard.';

  @override
  String noBrowser(String website) {
    return 'Aucun navigateur pour l\'ouvrir. Rendez-vous sur $website.';
  }

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String get couldNotOpen => 'Impossible d\'ouvrir ce fichier.';

  @override
  String get cantRestore => 'Impossible de restaurer ce fichier';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Tout remplacer par cette sauvegarde ?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: '$count personnes',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses enregistrées',
      one: '1 dose enregistrée',
      zero: '$count doses enregistrées',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'Elle contient $people, $medications et $doses. Tout ce qui se trouve actuellement sur ce téléphone sera remplacé par son contenu.';
  }

  @override
  String get replace => 'Remplacer';

  @override
  String get restored => 'Restauration effectuée';

  @override
  String get summaryFor => 'Résumé pour';

  @override
  String get summarySaved => 'Résumé enregistré';

  @override
  String get yourNameOnSummary => 'Votre nom sur le résumé';

  @override
  String get continueAction => 'Continuer';

  @override
  String get deleteAllTitle => 'Supprimer toutes les données ?';

  @override
  String get deleteAllMessage =>
      'Toutes les personnes, tous les médicaments et toutes les doses de ce téléphone, ainsi que tous les rappels. Cette action est irréversible ; si vous risquez d\'en avoir besoin, enregistrez d\'abord une sauvegarde.';

  @override
  String get deleteEverything => 'Tout supprimer';

  @override
  String get notificationsOff => 'Les notifications sont désactivées';

  @override
  String get notificationsOn => 'Les notifications sont activées';

  @override
  String get notificationsOffHint =>
      'Les rappels ne peuvent pas s\'afficher tant qu\'elles ne sont pas autorisées.';

  @override
  String get notificationsOnHint =>
      'Les rappels s\'afficheront sur ce téléphone.';

  @override
  String get mayBeLate => 'Les rappels risquent d\'être en retard';

  @override
  String get mayBeLateHint =>
      'Android a désactivé les alarmes exactes pour Nexpill. Réactivez « Alarmes et rappels » pour l\'application dans les paramètres du téléphone.';

  @override
  String get sendTest => 'Envoyer un rappel de test';

  @override
  String get sendTestHint => 'Arrive dans quelques secondes.';

  @override
  String get testOnItsWay => 'Rappel de test en cours d\'envoi';

  @override
  String get peopleYouCareFor => 'Personnes dont vous vous occupez';

  @override
  String onThisPhone(int count) {
    return '$count sur ce téléphone';
  }

  @override
  String get yourData => 'Vos données';

  @override
  String get backUp => 'Sauvegarder dans un fichier';

  @override
  String get backUpHint => 'Tout, enregistré où vous le souhaitez.';

  @override
  String get restore => 'Restaurer une sauvegarde';

  @override
  String get restoreHint => 'Remplace ce qui se trouve sur ce téléphone.';

  @override
  String get medicationSummary => 'Résumé des médicaments';

  @override
  String get medicationSummaryHint =>
      'En texte simple, pour un médecin ou une transmission.';

  @override
  String get deleteAllData => 'Supprimer toutes les données';

  @override
  String get about => 'À propos';

  @override
  String get aboutNexpill => 'À propos de Nexpill';

  @override
  String get aboutNexpillHint =>
      'Où se trouvent vos données, et pourquoi c\'est gratuit';

  @override
  String get website => 'Site web';

  @override
  String get sendFeedback => 'Envoyer un commentaire';

  @override
  String get sendFeedbackHint =>
      'Un formulaire sur le site web, dans votre navigateur.';

  @override
  String get version => 'Version';

  @override
  String get language => 'Langue';

  @override
  String get sameAsPhone => 'Comme le téléphone';

  @override
  String sameAsPhoneNow(String language) {
    return 'Comme le téléphone : $language';
  }

  @override
  String get aboutStaysTitle => 'Tout reste sur votre téléphone';

  @override
  String get aboutStaysBody =>
      'Tout ce que vous enregistrez est écrit dans une base de données sur cet appareil. Il n\'y a ni compte ni serveur. Vos données ne vont ailleurs que si vous les déplacez vous-même, sous forme de fichier de sauvegarde ou d\'export.';

  @override
  String get aboutCannotSeeTitle => 'Nous ne pouvons pas les voir';

  @override
  String get aboutCannotSeeBody =>
      'Nexpill est conçu sans aucune autorisation d\'accès à internet. Android le garantit, et vous pouvez le vérifier dans la liste des autorisations de l\'application.';

  @override
  String get aboutRemindersTitle =>
      'Les rappels viennent du téléphone lui-même';

  @override
  String get aboutRemindersBody =>
      'Chaque rappel est une alarme gardée par ce téléphone : il arrive à l\'heure sans réseau, en mode avion et après un redémarrage.';

  @override
  String get aboutPermissionsTitle => 'À quoi servent les autorisations';

  @override
  String get aboutPermissionsBody =>
      'Notifications, pour les rappels. Alarmes exactes, pour qu\'ils arrivent à la minute près. Lancement au démarrage, pour les reprogrammer après un redémarrage. Vibreur. C\'est la liste complète.';

  @override
  String get aboutFreeTitle => 'Gratuit, pour toujours';

  @override
  String get aboutFreeBody =>
      'Nexpill a été écrit par un aidant, pour les aidants. Il sera toujours gratuit et open source : pas de prix, pas de version premium, pas de publicité.';

  @override
  String get aboutCheckTitle => 'Vous pouvez vérifier notre travail';

  @override
  String get aboutCheckBody =>
      'Nexpill est open source, sous licence publique générale GNU. Tout le monde peut lire exactement ce qu\'il fait.';

  @override
  String get aboutHeadline => 'Vos données restent avec vous.';

  @override
  String get aboutIntro =>
      'Nexpill suit quand chaque dose a été donnée et quand la suivante peut l\'être, et vous rappelle à l\'heure. Il ne donne pas d\'avis médical.';

  @override
  String get aboutTradeOff =>
      'Une contrepartie à connaître : il n\'y a pas de copie dans le cloud, donc un téléphone perdu ou réinitialisé, c\'est un historique perdu. Enregistrez de temps en temps un fichier de sauvegarde depuis les Paramètres, et gardez-le ailleurs que sur ce téléphone.';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }
}
