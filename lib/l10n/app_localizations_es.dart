// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours y $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Dosis de las $time omitida';
  }

  @override
  String listAnd(String items, String last) {
    return '$items y $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Cada $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'A las $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'Según sea necesario, con al menos $duration entre dosis';
  }

  @override
  String get taperNoSteps => 'Reducción gradual sin pasos';

  @override
  String taperStepFrom(String date) {
    return 'Desde el $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return 'Del $from al $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: cada $duration';
  }

  @override
  String get taperFinished => 'Reducción gradual terminada';

  @override
  String taperShortEvery(String duration) {
    return 'Reducción: cada $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text desde el $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text hasta el $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, luego cada $duration';
  }

  @override
  String get statusNotGiven => 'Aún no se ha dado';

  @override
  String get statusCanGiveNow => 'Se puede dar ahora';

  @override
  String get statusDueNow => 'Toca ahora';

  @override
  String statusNextAt(String time) {
    return 'Próxima a las $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'Con $duration de retraso';
  }

  @override
  String statusMissed(String duration) {
    return 'Perdida: tocaba hace $duration';
  }

  @override
  String get statusFinished => 'Terminado';

  @override
  String get remindersOff => 'Desactivados';

  @override
  String get remindersOn => 'Activados';

  @override
  String remindersEarly(String duration) {
    return '$duration antes';
  }

  @override
  String get remindersAlarm => 'como alarma';

  @override
  String whenToday(String time) {
    return 'hoy a las $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'mañana a las $time';
  }

  @override
  String whenYesterday(String time) {
    return 'ayer a las $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return 'el $date a las $time';
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
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String courseFinishedLastDay(String date) {
    return 'Tratamiento terminado: el último día fue el $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tratamiento terminado: se dieron las $count dosis',
      one: 'Tratamiento terminado: se dio su única dosis',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Último día: $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total dosis, $given dadas hasta ahora',
      one: '1 dosis, $given dada hasta ahora',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'último día: $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quedan $count dosis',
      one: 'queda 1 dosis',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Primera dosis $when';
  }

  @override
  String get cardAsNeeded => 'Según sea necesario';

  @override
  String cardAvailableFrom(String when) {
    return 'Disponible $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Próxima dosis $when';
  }

  @override
  String cardIn(String duration) {
    return 'en $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Toca en $duration';
  }

  @override
  String cardAt(String when) {
    return '$when';
  }

  @override
  String cardSince(String when) {
    return 'desde $when';
  }

  @override
  String cardOverdue(String duration) {
    return 'Con $duration de retraso';
  }

  @override
  String cardWasDue(String when) {
    return 'tocaba $when';
  }

  @override
  String get cardMissed => 'Perdida';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'tocaba $when, hace $duration';
  }

  @override
  String get personYou => 'Tú';

  @override
  String get personYouAfterFor => 'ti';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication: toca a las $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication: toca ahora';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication: con retraso desde las $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication: ya se puede volver a dar';
  }

  @override
  String reminderManyFor(int count, String person) {
    return '$count medicamentos para $person';
  }

  @override
  String reminderFor(String person) {
    return 'Para $person';
  }

  @override
  String get channelAlarms => 'Alarmas de medicación';

  @override
  String get channelAlarmsDescription =>
      'Para los medicamentos que suenan como una alarma cuando toca una dosis.';

  @override
  String get channelReminders => 'Recordatorios de medicación';

  @override
  String get channelRemindersDescription =>
      'Avisos previos, dosis que tocan y dosis con retraso.';

  @override
  String get channelUpkeep => 'Mantener los recordatorios';

  @override
  String get channelUpkeepDescription =>
      'Un aviso cuando hay que abrir Nexpill para que no se acaben los recordatorios.';

  @override
  String get actionMarkGiven => 'Marcar como dada';

  @override
  String get actionSkip => 'Omitir';

  @override
  String actionSnooze(int minutes) {
    return 'Posponer $minutes min';
  }

  @override
  String get upkeepTitle => 'Abre Nexpill para seguir recibiendo recordatorios';

  @override
  String get upkeepBody =>
      'Los recordatorios se programan con una semana de antelación cada vez que se usa Nexpill. Ábrelo para programar los siguientes.';

  @override
  String get testReminderTitle => 'Recordatorio de prueba';

  @override
  String get testReminderBody =>
      'Los recordatorios funcionan. Así es como se verán.';

  @override
  String get csvGivenAt => 'Fecha y hora';

  @override
  String get csvGivenAtUtc => 'Fecha y hora (UTC)';

  @override
  String get csvPatient => 'Persona';

  @override
  String get csvMedication => 'Medicamento';

  @override
  String get csvDose => 'Dosis';

  @override
  String get csvGivenBy => 'Dada por';

  @override
  String get csvNotes => 'Notas';

  @override
  String get csvStatus => 'Estado';

  @override
  String get csvCorrects => 'Corrige la entrada';

  @override
  String get csvEntry => 'Entrada';

  @override
  String get csvReplaced => 'Sustituida por una corrección';

  @override
  String get csvSkipped => 'Omitida';

  @override
  String get csvCorrection => 'Corrección';

  @override
  String get csvGiven => 'Dada';

  @override
  String summaryTitleFor(String name) {
    return 'Resumen de medicación de $name';
  }

  @override
  String get summaryTitle => 'Resumen de medicación';

  @override
  String summaryAsOf(String dateTime) {
    return 'A fecha de $dateTime. Solo medicamentos activos.';
  }

  @override
  String get summaryNotAdvice =>
      'Hecho con Nexpill, que lleva el control de horarios. No es consejo médico.';

  @override
  String get summaryNoActive => 'No hay medicamentos activos.';

  @override
  String summaryPurpose(String value) {
    return 'Para: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dosis: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Horario: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Tratamiento: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Instrucciones: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Última dosis: $value';
  }

  @override
  String get summaryNotYet => 'Todavía no';

  @override
  String summaryStatus(String value) {
    return 'Estado: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Recordatorios: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Quedan: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (quedan pocas)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (no queda ninguna)';
  }

  @override
  String get backupNotNexpill =>
      'Este archivo no es una copia de seguridad de Nexpill.';

  @override
  String get backupTooNew =>
      'Esta copia de seguridad es de una versión más reciente de Nexpill. Actualiza la aplicación y vuelve a intentarlo.';

  @override
  String get backupTwoOfYou =>
      'En este archivo hay más de una persona marcada como tú.';

  @override
  String backupCorrectsMissing(String medication) {
    return 'Una dosis de $medication corrige otra que no está en su historial.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return 'Las correcciones de las dosis de $medication forman un círculo.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where necesita \"lastDay\" o \"doses\", pero no ambos.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where tiene una hora que no es HH:mm: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where tiene un tipo de horario desconocido: \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where no tiene la forma esperada.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where: falta \"$key\", o no es el tipo de valor correcto.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where tiene \"$key\" vacío.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where tiene un \"$key\" imposible: $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where tiene un \"$key\" que no es una fecha AAAA-MM-DD.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where tiene un \"$key\" que no es una fecha y hora con zona horaria.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'El identificador \"$id\" aparece más de una vez.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where no tiene \"$key\".';
  }

  @override
  String get backupWhereFile => 'El archivo';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key n.º $number';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get couldNotSave => 'No se pudo guardar el archivo.';

  @override
  String get hours => 'Horas';

  @override
  String get minutes => 'Minutos';

  @override
  String cardMoreFor(String medication) {
    return 'Más opciones de $medication';
  }

  @override
  String get edit => 'Editar';

  @override
  String get doseHistory => 'Historial de dosis';

  @override
  String skipTheDose(String time) {
    return 'Omitir la dosis de las $time';
  }

  @override
  String get stopTaking => 'Dejar de tomar';

  @override
  String lastGiven(String when) {
    return 'Última dosis $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Última dosis $when, dada por $name';
  }

  @override
  String get skip => 'Omitir';

  @override
  String get give => 'Dar';

  @override
  String supplyLeft(String amount) {
    return 'Quedan $amount';
  }

  @override
  String get supplyNoneLeft => 'No queda ninguna: hay que reponer';

  @override
  String supplyRunningLow(String left) {
    return '$left: quedan pocas';
  }

  @override
  String get earlyTitle => 'Es pronto';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return 'La próxima dosis de $medication toca $when, dentro de $duration. ¿Registrar una dosis ahora de todos modos?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return '$medication se puede volver a dar $when, dentro de $duration. ¿Registrar una dosis ahora de todos modos?';
  }

  @override
  String get notYet => 'Todavía no';

  @override
  String get logItNow => 'Registrar ahora';

  @override
  String get dayGiven => 'Día en que se dio';

  @override
  String get timeGiven => 'Hora en que se dio';

  @override
  String get timeInFuture => 'Esa hora todavía no ha llegado.';

  @override
  String correctEntry(String medication) {
    return 'Corregir esta entrada de $medication';
  }

  @override
  String giveMedication(String medication) {
    return 'Dar $medication';
  }

  @override
  String get originalStays =>
      'La original se queda en el historial, marcada como corregida.';

  @override
  String get now => 'Ahora';

  @override
  String get earlier => 'Antes';

  @override
  String givenWhen(String when) {
    return 'Dada $when';
  }

  @override
  String get change => 'Cambiar';

  @override
  String get dose => 'Dosis';

  @override
  String get givenBy => 'Dada por';

  @override
  String get optional => 'Opcional';

  @override
  String get notes => 'Notas';

  @override
  String get saveCorrection => 'Guardar corrección';

  @override
  String get logDose => 'Registrar dosis';

  @override
  String get doseHistorySaved => 'Historial de dosis guardado';

  @override
  String get correctTimeOrDetails => 'Corregir la hora o los detalles';

  @override
  String get keepsOriginal => 'Se conserva la original, marcada como corregida';

  @override
  String get deleteEntry => 'Borrar la entrada';

  @override
  String get deleteEntrySkippedHint => 'La dosis vuelve a tocar';

  @override
  String get deleteEntryHint => 'Solo para una dosis que nunca se dio';

  @override
  String get deleteEntryTitle => '¿Borrar esta entrada?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, omitida. Bórrala si la dosis no debía omitirse.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Usa esto solo si la dosis nunca se dio; para cambiar la hora, corrígela. También se borran sus correcciones.';
  }

  @override
  String get delete => 'Borrar';

  @override
  String get yourDoses => 'Tus dosis';

  @override
  String personsDoses(String name) {
    return 'Dosis de $name';
  }

  @override
  String get doses => 'Dosis';

  @override
  String get saveAsCsv => 'Guardar como hoja de cálculo (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Solo $medication';
  }

  @override
  String get nothingLogged => 'Todavía no hay nada registrado.';

  @override
  String historyBy(String name) {
    return 'por $name';
  }

  @override
  String get historyCorrection => 'corrección';

  @override
  String get historyCorrected => 'corregida';

  @override
  String get defaultDose => '1 comprimido';

  @override
  String get errorName => 'Ponle un nombre al medicamento.';

  @override
  String get errorDose => 'Indica qué es una dosis, como \"1 comprimido\".';

  @override
  String get errorHowOften => 'Elige cada cuánto.';

  @override
  String get errorShortestGap => 'Elige el tiempo mínimo entre dosis.';

  @override
  String get errorAddTime => 'Añade al menos una hora.';

  @override
  String get errorDosesStillToGive => 'Indica cuántas dosis quedan por dar.';

  @override
  String get errorCourseDoses => 'Indica cuántas dosis tiene el tratamiento.';

  @override
  String get errorStartingSupply => 'Indica cuánto hay al empezar.';

  @override
  String get errorPerDose => 'Indica cuánto usa una dosis.';

  @override
  String get errorLowAt => 'Indica cuándo avisar, o déjalo vacío.';

  @override
  String get errorNoSteps => 'Añade al menos un paso.';

  @override
  String get errorStepInterval => 'Cada paso necesita un intervalo.';

  @override
  String get errorStepEnds => 'Un paso tiene que terminar después de empezar.';

  @override
  String get errorOpenEnded => 'Solo el último paso puede quedar sin fin.';

  @override
  String get errorStepsOverlap => 'Hay dos pasos que se solapan.';

  @override
  String deleteMedicationTitle(String medication) {
    return '¿Borrar $medication?';
  }

  @override
  String get deleteMedicationMessage =>
      'Su historial de dosis también se borra. Para dejarlo pero conservar el historial, desactiva «Lo toma ahora».';

  @override
  String get newMedication => 'Nuevo medicamento';

  @override
  String editMedication(String medication) {
    return 'Editar $medication';
  }

  @override
  String get save => 'Guardar';

  @override
  String forPerson(String person) {
    return 'Para $person';
  }

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldNameHint => 'p. ej., amoxicilina';

  @override
  String get fieldStrength => 'Concentración';

  @override
  String get fieldStrengthHint => 'Opcional, p. ej., 500 mg';

  @override
  String get fieldPurpose => 'Para qué es';

  @override
  String get fieldPurposeHint => 'Opcional, p. ej., la tensión';

  @override
  String get fieldUsualDose => 'Dosis habitual';

  @override
  String get fieldUsualDoseHint => 'p. ej., 1 comprimido, 5 ml';

  @override
  String get fieldInstructions => 'Instrucciones';

  @override
  String get fieldInstructionsHint => 'Opcional, p. ej., con comida';

  @override
  String get sectionWhen => 'Cuándo';

  @override
  String get sectionHowLong => 'Cuánto tiempo';

  @override
  String get sectionReminders => 'Recordatorios';

  @override
  String get sectionSupply => 'Existencias';

  @override
  String get takingThisNow => 'Lo toma ahora';

  @override
  String get takingThisNowHint =>
      'Desactívalo cuando se deje. Conserva su historial pero deja de recordar.';

  @override
  String get deleteMedication => 'Borrar medicamento';

  @override
  String get addMedication => 'Añadir medicamento';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get kindInterval => 'Cada pocas horas';

  @override
  String get kindFixedTimes => 'A horas fijas';

  @override
  String get kindAsNeeded => 'Según sea necesario';

  @override
  String get kindTaper => 'Reducción gradual';

  @override
  String get every => 'Cada';

  @override
  String get intervalHint => 'Se cuenta desde la última dosis dada.';

  @override
  String get atLeastApart => 'Con al menos este tiempo entre dosis';

  @override
  String get asNeededHint =>
      'Nunca «toca»: Nexpill muestra cuándo se puede volver a dar.';

  @override
  String get addTime => 'Añadir hora';

  @override
  String get fixedTimesHint =>
      'Todos los días, según el reloj de este teléfono.';

  @override
  String get timeOfDose => 'Hora de la dosis';

  @override
  String get courseUntilStopped => 'Hasta que se deje';

  @override
  String get courseUntilDate => 'Hasta una fecha';

  @override
  String get courseNumberOfDoses => 'Un número de dosis';

  @override
  String get courseOngoingHint =>
      'Los recordatorios siguen hasta que desactives «Lo toma ahora».';

  @override
  String courseLastDayChip(String date) {
    return 'Último día: $date';
  }

  @override
  String get courseLastDayHint =>
      'Las dosis siguen durante ese día; los recordatorios se detienen a la medianoche, al terminar.';

  @override
  String get dosesStillToGive => 'Dosis que quedan por dar';

  @override
  String get numberOfDoses => 'Número de dosis';

  @override
  String get dosesHint => 'p. ej., 10';

  @override
  String get courseDosesHint =>
      'Los recordatorios se detienen cuando se da la última.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count dosis dadas hasta ahora. Los recordatorios se detienen cuando se da la última.',
      one: '1 dosis dada hasta ahora. Los recordatorios se detienen cuando se da la última.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Último día del tratamiento';

  @override
  String taperStepNumber(int number) {
    return 'Paso $number';
  }

  @override
  String get removeStep => 'Quitar paso';

  @override
  String stepFrom(String date) {
    return 'Desde el $date';
  }

  @override
  String get noEndDate => 'Sin fecha de fin';

  @override
  String stepUntil(String date) {
    return 'Hasta el $date';
  }

  @override
  String get clearEnd => 'Quitar el fin';

  @override
  String get addStep => 'Añadir un paso';

  @override
  String get taperHint =>
      'Cada paso va desde la medianoche de su primer día hasta la medianoche de su día de fin. El último paso puede quedar sin fin.';

  @override
  String get remindMe => 'Recordármelo';

  @override
  String get remindAsNeededHint => 'Cuando se pueda volver a dar.';

  @override
  String get remindHint =>
      'Cuando toque una dosis, y otra vez mientras siga con retraso.';

  @override
  String get headsUp => 'Aviso antes de que toque';

  @override
  String get none => 'Ninguno';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get repeatWhileOverdue => 'Repetir mientras haya retraso';

  @override
  String everyDuration(String duration) {
    return 'cada $duration';
  }

  @override
  String get ringLikeAlarm => 'Sonar como una alarma';

  @override
  String get ringLikeAlarmHint =>
      'El sonido de alarma, repitiéndose hasta que la marques como dada o la pospongas.';

  @override
  String get trackSupply => 'Llevar la cuenta de lo que queda';

  @override
  String get trackSupplyHint => 'Se descuenta con cada dosis registrada.';

  @override
  String get startingAmount => 'Cantidad inicial';

  @override
  String get unit => 'Unidad';

  @override
  String get unitHint => 'comprimidos';

  @override
  String get eachDoseUses => 'Cada dosis usa';

  @override
  String get warnAt => 'Avisar con';

  @override
  String get everyone => 'Todos';

  @override
  String get managePeople => 'Gestionar personas';

  @override
  String get settings => 'Ajustes';

  @override
  String get addSomeone => 'Añadir a alguien';

  @override
  String get noMedicationsYet => 'Todavía no hay medicamentos';

  @override
  String get nothingToGiveNow => 'Nada que dar ahora';

  @override
  String moreDueNow(int count) {
    return '+ $count más que tocan ahora';
  }

  @override
  String get remindersOffShort => 'Recordatorios desactivados';

  @override
  String get errorEnterName => 'Escribe un nombre.';

  @override
  String get errorNameTaken => 'Ya hay alguien con ese nombre.';

  @override
  String get whoAreYouCaringFor => '¿A quién cuidas?';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get nameHint => 'Basta con un nombre o un apodo';

  @override
  String get thisIsMe => 'Soy yo';

  @override
  String get forYourOwnMedications => 'Para tus propios medicamentos';

  @override
  String get add => 'Añadir';

  @override
  String get deleteYourMedicationsTitle => '¿Borrar tus medicamentos?';

  @override
  String deletePersonTitle(String name) {
    return '¿Borrar a $name?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'También se borran tus $count medicamentos y todo el historial de dosis, y no se pueden recuperar sin una copia de seguridad.',
      one: 'También se borran tu medicamento y todo el historial de dosis, y no se pueden recuperar sin una copia de seguridad.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'También se borran sus $count medicamentos y todo el historial de dosis, y no se pueden recuperar sin una copia de seguridad.',
      one: 'También se borran su medicamento y todo el historial de dosis, y no se pueden recuperar sin una copia de seguridad.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Personas';

  @override
  String tapToSeeThem(String count) {
    return '$count · toca para verlos';
  }

  @override
  String get addYourName => 'Añadir tu nombre';

  @override
  String get asSetForEach => 'Según lo indicado en cada medicamento';

  @override
  String allOffFor(String person) {
    return 'Todos desactivados para $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicamentos',
      one: '1 medicamento',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return '$medication registrado, $when';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication: omitida $count veces seguidas';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Recordatorios desactivados para $medication. Vuelve a activarlos en Editar.';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication dejado. Se conserva su historial.';
  }

  @override
  String get remindersAreOff => 'Los recordatorios están desactivados';

  @override
  String get allowNotificationsHint =>
      'Permite las notificaciones para que te lleguen.';

  @override
  String get allow => 'Permitir';

  @override
  String remindersAreOffFor(String person) {
    return 'Los recordatorios están desactivados para $person.';
  }

  @override
  String get addYourFirst =>
      'Añade el primero y Nexpill llevará la cuenta de cuándo se puede dar cada dosis.';

  @override
  String addPersonsFirst(String name) {
    return 'Añade el primero de $name y Nexpill llevará la cuenta de cuándo se puede dar cada dosis.';
  }

  @override
  String get allEndedForYou =>
      'Todos tus medicamentos han terminado o se han dejado. Están abajo, con su historial.';

  @override
  String allEndedForPerson(String name) {
    return 'Todos los medicamentos de $name han terminado o se han dejado. Están abajo, con su historial.';
  }

  @override
  String get addAMedication => 'Añadir un medicamento';

  @override
  String get addAnotherMedication => 'Añadir otro medicamento';

  @override
  String addMedicationFor(String name) {
    return 'Añadir un medicamento para $name';
  }

  @override
  String endedStopped(int count) {
    return 'Dejados ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Terminados ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Terminados y dejados ($count)';
  }

  @override
  String get resume => 'Reanudar';

  @override
  String get logoLabel => 'Logotipo de Nexpill';

  @override
  String get welcomeWhat =>
      'Lleva la cuenta de cuándo se dio cada dosis y cuándo puede darse la siguiente, y te avisa a tiempo.';

  @override
  String get welcomePrivate =>
      'Todo se queda en este teléfono. Sin cuenta y sin internet.';

  @override
  String get whoAreTheMedicationsFor => '¿Para quién son los medicamentos?';

  @override
  String get me => 'Para mí';

  @override
  String get someoneICareFor => 'Para alguien a quien cuido';

  @override
  String get addMoreLater => 'Puedes añadir a más personas después.';

  @override
  String noBrowser(String website) {
    return 'No hay ningún navegador para abrirlo. Visita $website.';
  }

  @override
  String get backupSaved => 'Copia de seguridad guardada';

  @override
  String get couldNotOpen => 'No se pudo abrir ese archivo.';

  @override
  String get cantRestore => 'No se puede restaurar este archivo';

  @override
  String get ok => 'Aceptar';

  @override
  String get restoreTitle => '¿Sustituirlo todo por esta copia de seguridad?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dosis registradas',
      one: '1 dosis registrada',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'Contiene $people, $medications y $doses. Todo lo que hay ahora en este teléfono se sustituirá por ella.';
  }

  @override
  String get replace => 'Sustituir';

  @override
  String get restored => 'Restaurado';

  @override
  String get summaryFor => 'Resumen de';

  @override
  String get summarySaved => 'Resumen guardado';

  @override
  String get yourNameOnSummary => 'Tu nombre en el resumen';

  @override
  String get continueAction => 'Continuar';

  @override
  String get deleteAllTitle => '¿Borrar todos los datos?';

  @override
  String get deleteAllMessage =>
      'Todas las personas, medicamentos y dosis de este teléfono, y todos los recordatorios. No se puede deshacer; si quizá lo quieras recuperar, guarda antes una copia de seguridad.';

  @override
  String get deleteEverything => 'Borrarlo todo';

  @override
  String get notificationsOff => 'Las notificaciones están desactivadas';

  @override
  String get notificationsOn => 'Las notificaciones están activadas';

  @override
  String get notificationsOffHint =>
      'Los recordatorios no se pueden mostrar hasta que se permitan.';

  @override
  String get notificationsOnHint =>
      'Los recordatorios aparecerán en este teléfono.';

  @override
  String get mayBeLate => 'Los recordatorios pueden llegar tarde';

  @override
  String get mayBeLateHint =>
      'Android ha desactivado las alarmas exactas de Nexpill. Vuelve a activar «Alarmas y recordatorios» en los ajustes del teléfono para la aplicación.';

  @override
  String get sendTest => 'Enviar un recordatorio de prueba';

  @override
  String get sendTestHint => 'Llega en unos segundos.';

  @override
  String get testOnItsWay => 'El recordatorio de prueba está en camino';

  @override
  String get peopleYouCareFor => 'Personas a las que cuidas';

  @override
  String onThisPhone(int count) {
    return '$count en este teléfono';
  }

  @override
  String get yourData => 'Tus datos';

  @override
  String get backUp => 'Hacer una copia en un archivo';

  @override
  String get backUpHint => 'Todo, guardado donde elijas.';

  @override
  String get restore => 'Restaurar una copia de seguridad';

  @override
  String get restoreHint => 'Sustituye lo que hay en este teléfono.';

  @override
  String get medicationSummary => 'Resumen de medicación';

  @override
  String get medicationSummaryHint =>
      'Texto sencillo, para el médico o para pasar el relevo.';

  @override
  String get deleteAllData => 'Borrar todos los datos';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutNexpill => 'Acerca de Nexpill';

  @override
  String get aboutNexpillHint => 'Dónde están tus datos y por qué es gratis';

  @override
  String get website => 'Sitio web';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get sendFeedbackHint =>
      'Un formulario en el sitio web, en tu navegador.';

  @override
  String get version => 'Versión';

  @override
  String get language => 'Idioma';

  @override
  String get sameAsPhone => 'Igual que el teléfono';

  @override
  String sameAsPhoneNow(String language) {
    return 'Igual que el teléfono: $language';
  }

  @override
  String get aboutStaysTitle => 'Se queda en tu teléfono';

  @override
  String get aboutStaysBody =>
      'Todo lo que registras se guarda en una base de datos en este dispositivo. No hay cuenta ni servidor. Solo va a otro sitio si tú lo mueves, como copia de seguridad o exportación.';

  @override
  String get aboutCannotSeeTitle => 'No podemos verlo';

  @override
  String get aboutCannotSeeBody =>
      'Nexpill está hecho sin permiso para usar internet. Android lo garantiza, y puedes comprobarlo en la lista de permisos de la aplicación.';

  @override
  String get aboutRemindersTitle =>
      'Los recordatorios vienen del propio teléfono';

  @override
  String get aboutRemindersBody =>
      'Cada recordatorio es una alarma que guarda este teléfono, así que llega a tiempo sin cobertura, en modo avión y después de reiniciar.';

  @override
  String get aboutPermissionsTitle => 'Para qué son los permisos';

  @override
  String get aboutPermissionsBody =>
      'Notificaciones, para los recordatorios. Alarmas exactas, para que lleguen en el minuto justo. Iniciarse tras reiniciar, para volver a programarlos. Vibración. Esa es la lista completa.';

  @override
  String get aboutFreeTitle => 'Gratis, para siempre';

  @override
  String get aboutFreeBody =>
      'Nexpill lo escribió un cuidador para cuidadores. Siempre será gratis y de código abierto: sin precio, sin versión premium y sin anuncios.';

  @override
  String get aboutCheckTitle => 'Puedes revisar nuestro trabajo';

  @override
  String get aboutCheckBody =>
      'Nexpill es de código abierto bajo la Licencia Pública General de GNU. Cualquiera puede leer exactamente lo que hace.';

  @override
  String get aboutHeadline => 'Tus registros se quedan contigo.';

  @override
  String get aboutIntro =>
      'Nexpill lleva la cuenta de cuándo se dio cada dosis y cuándo puede darse la siguiente, y te avisa a tiempo. No da consejos médicos.';

  @override
  String get aboutTradeOff =>
      'Algo que conviene saber: no hay copia en la nube, así que si pierdes o borras el teléfono, pierdes el historial. Guarda de vez en cuando una copia de seguridad desde Ajustes y tenla en otro sitio que no sea este teléfono.';

  @override
  String versionNumber(String version) {
    return 'Versión $version';
  }
}
