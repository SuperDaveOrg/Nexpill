// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
      zero: '$count horas',
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
      zero: '$count minutos',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours e $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Dose das $time saltada';
  }

  @override
  String listAnd(String items, String last) {
    return '$items e $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'A cada $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'Às $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'Quando necessário, com pelo menos $duration de intervalo';
  }

  @override
  String get taperNoSteps => 'Redução gradual sem etapas';

  @override
  String taperStepFrom(String date) {
    return 'A partir de $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return 'De $from a $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: a cada $duration';
  }

  @override
  String get taperFinished => 'Redução gradual terminada';

  @override
  String scheduleOnce(String when) {
    return 'Uma vez, $when';
  }

  @override
  String scheduleOnceToday(String time) {
    return 'Uma vez, hoje às $time';
  }

  @override
  String get singleDoseFinished => 'Dose única registada';

  @override
  String taperShortEvery(String duration) {
    return 'Redução: a cada $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text a partir de $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text até $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, depois a cada $duration';
  }

  @override
  String get statusNotGiven => 'Ainda sem doses dadas';

  @override
  String get statusCanGiveNow => 'Pode ser dada agora';

  @override
  String get statusDueNow => 'Está na hora';

  @override
  String statusNextAt(String time) {
    return 'Próxima às $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'Em atraso há $duration';
  }

  @override
  String statusMissed(String duration) {
    return 'Falhada: estava prevista há $duration';
  }

  @override
  String get statusFinished => 'Terminado';

  @override
  String get remindersOff => 'Desativados';

  @override
  String get remindersOn => 'Ativados';

  @override
  String remindersEarly(String duration) {
    return '$duration antes';
  }

  @override
  String get remindersAlarm => 'como alarme';

  @override
  String whenToday(String time) {
    return 'hoje às $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'amanhã às $time';
  }

  @override
  String whenYesterday(String time) {
    return 'ontem às $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return 'dia $date às $time';
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
      other: '$count dias',
      one: '1 dia',
      zero: '$count dias',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String courseFinishedLastDay(String date) {
    return 'Tratamento terminado: o último dia foi $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tratamento terminado: as $count doses foram dadas',
      one: 'Tratamento terminado: a única dose foi dada',
      zero: 'Tratamento terminado: as $count doses foram dadas',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Último dia: $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total doses; dadas até agora: $given',
      one: '1 dose; dadas até agora: $given',
      zero: '$total doses; dadas até agora: $given',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'último dia: $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faltam $count doses',
      one: 'falta 1 dose',
      zero: 'faltam $count doses',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Primeira dose $when';
  }

  @override
  String get cardAsNeeded => 'Quando necessário';

  @override
  String cardAvailableFrom(String when) {
    return 'Próxima dose a partir de $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Próxima dose $when';
  }

  @override
  String cardIn(String duration) {
    return 'daqui a $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Dose daqui a $duration';
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
    return 'Em atraso há $duration';
  }

  @override
  String cardWasDue(String when) {
    return 'estava prevista para $when';
  }

  @override
  String get cardMissed => 'Falhada';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'estava prevista para $when, há $duration';
  }

  @override
  String get personYou => 'Eu';

  @override
  String get personYouAfterFor => 'si';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication: dose às $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication: está na hora';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication: em atraso desde as $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication: já pode ser dada outra dose';
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
  String get channelAlarms => 'Alarmes de medicação';

  @override
  String get channelAlarmsDescription =>
      'Para medicamentos configurados para tocar como um alarme quando está na hora de uma dose.';

  @override
  String get channelReminders => 'Lembretes de medicação';

  @override
  String get channelRemindersDescription =>
      'Avisos antecipados, doses na hora e doses em atraso.';

  @override
  String get channelUpkeep => 'Manter os lembretes ativos';

  @override
  String get channelUpkeepDescription =>
      'Um aviso quando é preciso abrir o Nexpill para que os lembretes não acabem.';

  @override
  String get actionMarkGiven => 'Marcar como dada';

  @override
  String get actionSkip => 'Saltar';

  @override
  String actionSnooze(int minutes) {
    return 'Adiar $minutes min';
  }

  @override
  String get upkeepTitle => 'Abra o Nexpill para continuar a receber lembretes';

  @override
  String get upkeepBody =>
      'Os lembretes são programados com uma semana de antecedência sempre que o Nexpill é usado. Abra-o para programar os seguintes.';

  @override
  String get testReminderTitle => 'Lembrete de teste';

  @override
  String get testReminderBody =>
      'Os lembretes estão a funcionar. É assim que vão aparecer.';

  @override
  String get csvGivenAt => 'Data e hora';

  @override
  String get csvGivenAtUtc => 'Data e hora (UTC)';

  @override
  String get csvPatient => 'Pessoa';

  @override
  String get csvMedication => 'Medicamento';

  @override
  String get csvDose => 'Dose';

  @override
  String get csvGivenBy => 'Dada por';

  @override
  String get csvNotes => 'Notas';

  @override
  String get csvStatus => 'Estado';

  @override
  String get csvCorrects => 'Corrige a entrada';

  @override
  String get csvEntry => 'Entrada';

  @override
  String get csvReplaced => 'Substituída por uma correção';

  @override
  String get csvSkipped => 'Saltada';

  @override
  String get csvRefill => 'Reposição';

  @override
  String get csvCorrection => 'Correção';

  @override
  String get csvGiven => 'Dada';

  @override
  String summaryTitleFor(String name) {
    return 'Resumo da medicação de $name';
  }

  @override
  String get summaryTitle => 'Resumo da medicação';

  @override
  String summaryAsOf(String dateTime) {
    return 'À data de $dateTime. Apenas medicamentos ativos.';
  }

  @override
  String get summaryNotAdvice =>
      'Feito com o Nexpill, que regista os horários das doses. Não é aconselhamento médico.';

  @override
  String get summaryNoActive => 'Sem medicamentos ativos.';

  @override
  String summaryPurpose(String value) {
    return 'Para: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Dose: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'Horário: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Tratamento: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Instruções: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Última dose: $value';
  }

  @override
  String get summaryNotYet => 'Ainda não';

  @override
  String summaryStatus(String value) {
    return 'Estado: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Lembretes: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Restante: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (a acabar)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (esgotado)';
  }

  @override
  String get backupNotNexpill =>
      'Este ficheiro não é uma cópia de segurança do Nexpill.';

  @override
  String get backupTooNew =>
      'Esta cópia de segurança é de uma versão mais recente do Nexpill. Atualize a aplicação e tente novamente.';

  @override
  String get backupTwoOfYou =>
      'Neste ficheiro há mais do que uma pessoa marcada com «Sou eu».';

  @override
  String backupCorrectsMissing(String medication) {
    return 'Uma dose de $medication corrige outra que não está no seu histórico.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return 'As correções das doses de $medication formam um círculo.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where precisa de \"lastDay\" ou de \"doses\", mas não de ambos.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where tem uma hora que não está no formato HH:mm: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where tem um tipo de horário desconhecido: \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where não tem a forma esperada.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where: falta \"$key\" ou o valor não é do tipo correto.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where tem \"$key\" vazio.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where tem um valor impossível em \"$key\": $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where tem um \"$key\" que não é uma data AAAA-MM-DD.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where tem um \"$key\" que não é uma data e hora com fuso horário.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'O identificador \"$id\" aparece mais do que uma vez.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where não tem \"$key\".';
  }

  @override
  String get backupWhereFile => 'O ficheiro';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key n.º $number';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get couldNotSave => 'Não foi possível guardar o ficheiro.';

  @override
  String get hours => 'Horas';

  @override
  String get minutes => 'Minutos';

  @override
  String cardMoreFor(String medication) {
    return 'Mais opções de $medication';
  }

  @override
  String get edit => 'Editar';

  @override
  String get doseHistory => 'Histórico de doses';

  @override
  String skipTheDose(String time) {
    return 'Saltar a dose das $time';
  }

  @override
  String get stopTaking => 'Deixar de tomar';

  @override
  String lastGiven(String when) {
    return 'Última dose $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Última dose $when, dada por $name';
  }

  @override
  String get skip => 'Saltar';

  @override
  String get give => 'Dar';

  @override
  String supplyLeft(String amount) {
    return '$amount em stock';
  }

  @override
  String get supplyNoneLeft => 'Esgotado: é preciso repor';

  @override
  String supplyRunningLow(String left) {
    return '$left: a acabar';
  }

  @override
  String get refill => 'Repor';

  @override
  String refillTitle(String medication) {
    return 'Repor $medication';
  }

  @override
  String get refillAmount => 'Quantidade a adicionar';

  @override
  String get refillAdd => 'Adicionar';

  @override
  String refilled(String medication, String left) {
    return '$medication: stock reposto. $left.';
  }

  @override
  String get earlyTitle => 'Ainda é cedo';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return 'A próxima dose de $medication está prevista para $when, daqui a $duration. Registar uma dose agora mesmo assim?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return 'A próxima dose de $medication pode ser dada a partir de $when, daqui a $duration. Registar uma dose agora mesmo assim?';
  }

  @override
  String get notYet => 'Ainda não';

  @override
  String get logItNow => 'Registar agora';

  @override
  String get dayGiven => 'Dia em que foi dada';

  @override
  String get timeGiven => 'Hora a que foi dada';

  @override
  String get timeInFuture => 'Essa hora ainda não chegou.';

  @override
  String correctEntry(String medication) {
    return 'Corrigir esta entrada de $medication';
  }

  @override
  String giveMedication(String medication) {
    return 'Dar $medication';
  }

  @override
  String get originalStays =>
      'A original fica no histórico, marcada como corrigida.';

  @override
  String get now => 'Agora';

  @override
  String get earlier => 'Antes';

  @override
  String givenWhen(String when) {
    return 'Dada $when';
  }

  @override
  String get change => 'Alterar';

  @override
  String get dose => 'Dose';

  @override
  String get givenBy => 'Dada por';

  @override
  String get optional => 'Opcional';

  @override
  String get notes => 'Notas';

  @override
  String get saveCorrection => 'Guardar correção';

  @override
  String get logDose => 'Registar dose';

  @override
  String get doseHistorySaved => 'Histórico de doses guardado';

  @override
  String get correctTimeOrDetails => 'Corrigir a hora ou os detalhes';

  @override
  String get keepsOriginal => 'Mantém a original, marcada como corrigida';

  @override
  String get deleteEntry => 'Eliminar entrada';

  @override
  String get deleteEntrySkippedHint => 'A dose volta a ficar por dar';

  @override
  String get deleteEntryHint => 'Apenas para uma dose que nunca foi dada';

  @override
  String get deleteEntryTitle => 'Eliminar esta entrada?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, saltada. Elimine-a se a dose não era para ser saltada.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Use isto apenas se a dose nunca foi dada; para corrigir a hora, use a correção. As correções desta entrada também são eliminadas.';
  }

  @override
  String deleteRefillMessage(
    String medication,
    String dateTime,
    String amount,
  ) {
    return '$medication, $dateTime: +$amount. Elimine-a se foi registada por engano; o stock desce na mesma quantidade. Se a quantidade estava errada, reponha de novo com a certa.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get yourDoses => 'As suas doses';

  @override
  String personsDoses(String name) {
    return 'Doses de $name';
  }

  @override
  String get doses => 'Doses';

  @override
  String get saveAsCsv => 'Guardar como folha de cálculo (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Só $medication';
  }

  @override
  String get nothingLogged => 'Ainda não há nada registado.';

  @override
  String historyBy(String name) {
    return 'por $name';
  }

  @override
  String get historyCorrection => 'correção';

  @override
  String historyRefill(String amount) {
    return 'Reposição: +$amount';
  }

  @override
  String get historyCorrected => 'corrigida';

  @override
  String get defaultDose => '1 comprimido';

  @override
  String get errorName => 'Dê um nome ao medicamento.';

  @override
  String get errorDose =>
      'Indique o que é uma dose, por exemplo «1 comprimido».';

  @override
  String get errorHowOften => 'Escolha com que frequência.';

  @override
  String get errorShortestGap => 'Escolha o intervalo mínimo entre doses.';

  @override
  String get errorAddTime => 'Adicione pelo menos uma hora.';

  @override
  String get errorDosesStillToGive => 'Indique quantas doses faltam dar.';

  @override
  String get errorCourseDoses => 'Indique quantas doses tem o tratamento.';

  @override
  String get errorAmountLeft => 'Indique quanto há em stock.';

  @override
  String get errorPerDose => 'Indique quanto gasta cada dose.';

  @override
  String get errorLowAt => 'Indique quando avisar, ou deixe em branco.';

  @override
  String get errorNoSteps => 'Adicione pelo menos uma etapa.';

  @override
  String get errorStepInterval => 'Cada etapa precisa de um intervalo.';

  @override
  String get errorStepEnds => 'Uma etapa tem de terminar depois de começar.';

  @override
  String get errorOpenEnded => 'Só a última etapa pode ficar sem fim.';

  @override
  String get errorStepsOverlap => 'Há duas etapas que se sobrepõem.';

  @override
  String deleteMedicationTitle(String medication) {
    return 'Eliminar $medication?';
  }

  @override
  String get deleteMedicationMessage =>
      'O histórico de doses também é eliminado. Para o interromper mas manter o histórico, desative antes «A tomar atualmente».';

  @override
  String get newMedication => 'Novo medicamento';

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
  String get fieldName => 'Nome';

  @override
  String get fieldNameHint => 'p. ex., amoxicilina';

  @override
  String get fieldStrength => 'Dosagem';

  @override
  String get fieldStrengthHint => 'Opcional, p. ex., 500 mg';

  @override
  String get fieldPurpose => 'Para que serve';

  @override
  String get fieldPurposeHint => 'Opcional, p. ex., tensão arterial';

  @override
  String get fieldUsualDose => 'Dose habitual';

  @override
  String get fieldUsualDoseHint => 'p. ex., 1 comprimido, 5 ml';

  @override
  String get fieldInstructions => 'Instruções';

  @override
  String get fieldInstructionsHint => 'Opcional, p. ex., à refeição';

  @override
  String get sectionWhen => 'Quando';

  @override
  String get sectionHowLong => 'Durante quanto tempo';

  @override
  String get sectionReminders => 'Lembretes';

  @override
  String get sectionSupply => 'Stock';

  @override
  String get takingThisNow => 'A tomar atualmente';

  @override
  String get takingThisNowHint =>
      'Desative quando for interrompido. Mantém o histórico, mas deixa de enviar lembretes.';

  @override
  String get deleteMedication => 'Eliminar medicamento';

  @override
  String get addMedication => 'Adicionar medicamento';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get kindInterval => 'De tantas em tantas horas';

  @override
  String get kindFixedTimes => 'A horas fixas';

  @override
  String get kindAsNeeded => 'Quando necessário';

  @override
  String get kindTaper => 'Redução gradual';

  @override
  String get kindOnce => 'Uma vez';

  @override
  String get every => 'A cada';

  @override
  String get intervalHint => 'Contado a partir da última dose dada.';

  @override
  String get atLeastApart => 'Intervalo mínimo entre doses';

  @override
  String get asNeededHint =>
      'Nunca fica «na hora»: o Nexpill mostra quando se pode dar outra dose.';

  @override
  String get addTime => 'Adicionar hora';

  @override
  String get fixedTimesHint => 'Todos os dias, pelo relógio deste telemóvel.';

  @override
  String get timeOfDose => 'Hora da dose';

  @override
  String get onceHint =>
      'Uma única dose. Assim que for dada ou saltada, fica terminada e continua no histórico.';

  @override
  String get dayOfDose => 'Dia da dose';

  @override
  String get courseUntilStopped => 'Até ser interrompido';

  @override
  String get courseUntilDate => 'Até uma data';

  @override
  String get courseNumberOfDoses => 'Um número de doses';

  @override
  String get courseOngoingHint =>
      'Os lembretes continuam até desativar «A tomar atualmente».';

  @override
  String courseLastDayChip(String date) {
    return 'Último dia: $date';
  }

  @override
  String get courseLastDayHint =>
      'As doses continuam durante esse dia; os lembretes param à meia-noite, quando o dia termina.';

  @override
  String get dosesStillToGive => 'Doses que faltam dar';

  @override
  String get numberOfDoses => 'Número de doses';

  @override
  String get dosesHint => 'p. ex., 10';

  @override
  String get courseDosesHint => 'Os lembretes param depois de dada a última.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count doses dadas até agora. Os lembretes param depois de dada a última.',
      one: '1 dose dada até agora. Os lembretes param depois de dada a última.',
      zero:
          '$count doses dadas até agora. Os lembretes param depois de dada a última.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Último dia do tratamento';

  @override
  String taperStepNumber(int number) {
    return 'Etapa $number';
  }

  @override
  String get removeStep => 'Remover etapa';

  @override
  String stepFrom(String date) {
    return 'A partir de $date';
  }

  @override
  String get noEndDate => 'Sem data de fim';

  @override
  String stepUntil(String date) {
    return 'Até $date';
  }

  @override
  String get clearEnd => 'Remover o fim';

  @override
  String get addStep => 'Adicionar uma etapa';

  @override
  String get taperHint =>
      'Cada etapa vai da meia-noite do primeiro dia até à meia-noite do dia de fim. A última etapa pode ficar sem fim.';

  @override
  String get remindMe => 'Lembrar-me';

  @override
  String get remindAsNeededHint => 'Quando se puder dar outra dose.';

  @override
  String get remindHint =>
      'Quando for a hora de uma dose, e outra vez enquanto estiver em atraso.';

  @override
  String get headsUp => 'Aviso antes da hora';

  @override
  String get none => 'Nenhum';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get repeatWhileOverdue => 'Repetir enquanto estiver em atraso';

  @override
  String everyDuration(String duration) {
    return 'a cada $duration';
  }

  @override
  String get ringLikeAlarm => 'Tocar como um alarme';

  @override
  String get ringLikeAlarmHint =>
      'O som de alarme, a repetir até a marcar como dada ou a adiar.';

  @override
  String get trackSupply => 'Contar quanto resta';

  @override
  String get trackSupplyHint => 'Desconta a cada dose registada.';

  @override
  String get amountLeft => 'Quantidade em stock';

  @override
  String get unit => 'Unidade';

  @override
  String get unitHint => 'comprimidos';

  @override
  String get eachDoseUses => 'Cada dose gasta';

  @override
  String get warnAt => 'Avisar quando restarem';

  @override
  String get everyone => 'Todos';

  @override
  String get managePeople => 'Gerir pessoas';

  @override
  String get settings => 'Definições';

  @override
  String get addSomeone => 'Adicionar alguém';

  @override
  String get noMedicationsYet => 'Ainda sem medicamentos';

  @override
  String get nothingToGiveNow => 'Nada para dar agora';

  @override
  String moreDueNow(int count) {
    return '+ mais $count na hora';
  }

  @override
  String get remindersOffShort => 'Lembretes desativados';

  @override
  String get errorEnterName => 'Introduza um nome.';

  @override
  String get errorNameTaken => 'Já há alguém com esse nome.';

  @override
  String get whoAreYouCaringFor => 'De quem cuida?';

  @override
  String get rename => 'Mudar o nome';

  @override
  String get yourName => 'O seu nome';

  @override
  String get nameHint => 'Basta um nome próprio ou uma alcunha';

  @override
  String get thisIsMe => 'Sou eu';

  @override
  String get forYourOwnMedications => 'Para os seus próprios medicamentos';

  @override
  String get add => 'Adicionar';

  @override
  String get deleteYourMedicationsTitle => 'Eliminar os seus medicamentos?';

  @override
  String deletePersonTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Os seus $count medicamentos e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
      one: 'O seu medicamento e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
      zero:
          'Os seus $count medicamentos e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Os $count medicamentos desta pessoa e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
      one: 'O medicamento desta pessoa e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
      zero:
          'Os $count medicamentos desta pessoa e todo o histórico de doses também são eliminados, e não podem ser recuperados sem um ficheiro de cópia de segurança.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Pessoas';

  @override
  String tapToSeeThem(String count) {
    return '$count · toque para ver';
  }

  @override
  String get addYourName => 'Adicionar o seu nome';

  @override
  String get asSetForEach => 'Conforme definido em cada medicamento';

  @override
  String allOffFor(String person) {
    return 'Todos desativados para $person';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicamentos',
      one: '1 medicamento',
      zero: '$count medicamentos',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return 'Dose de $medication registada, $when';
  }

  @override
  String get undo => 'Anular';

  @override
  String skippedInARow(String medication, int count) {
    return '$medication: $count doses saltadas seguidas';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return 'Lembretes desativados para $medication. Volte a ativá-los em Editar.';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication: toma interrompida. O histórico é mantido.';
  }

  @override
  String get remindersAreOff => 'Os lembretes estão desativados';

  @override
  String get allowNotificationsHint =>
      'Permita as notificações para que os lembretes cheguem até si.';

  @override
  String get allow => 'Permitir';

  @override
  String remindersAreOffFor(String person) {
    return 'Os lembretes estão desativados para $person.';
  }

  @override
  String get addYourFirst =>
      'Adicione o primeiro medicamento e o Nexpill vai registar quando pode ser dada cada dose.';

  @override
  String addPersonsFirst(String name) {
    return 'Adicione o primeiro medicamento de $name e o Nexpill vai registar quando pode ser dada cada dose.';
  }

  @override
  String get allEndedForYou =>
      'Todos os seus medicamentos terminaram ou foram interrompidos. Estão todos abaixo, com o histórico.';

  @override
  String allEndedForPerson(String name) {
    return 'Todos os medicamentos de $name terminaram ou foram interrompidos. Estão todos abaixo, com o histórico.';
  }

  @override
  String get addAMedication => 'Adicionar um medicamento';

  @override
  String get addAnotherMedication => 'Adicionar outro medicamento';

  @override
  String addMedicationFor(String name) {
    return 'Adicionar um medicamento para $name';
  }

  @override
  String endedStopped(int count) {
    return 'Interrompidos ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Terminados ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Terminados e interrompidos ($count)';
  }

  @override
  String get resume => 'Retomar';

  @override
  String get logoLabel => 'Logótipo do Nexpill';

  @override
  String get welcomeWhat =>
      'Regista quando foi dada cada dose e quando se pode dar a seguinte, e envia lembretes a tempo.';

  @override
  String get welcomePrivate =>
      'Tudo fica neste telemóvel. Sem conta, sem internet.';

  @override
  String get whoAreTheMedicationsFor => 'Para quem são os medicamentos?';

  @override
  String get me => 'Para mim';

  @override
  String get someoneICareFor => 'Para alguém de quem cuido';

  @override
  String get addMoreLater => 'Pode adicionar mais pessoas depois.';

  @override
  String noBrowser(String website) {
    return 'Não há nenhum navegador para o abrir. Visite $website.';
  }

  @override
  String get backupSaved => 'Cópia de segurança guardada';

  @override
  String get couldNotOpen => 'Não foi possível abrir esse ficheiro.';

  @override
  String get cantRestore => 'Não é possível restaurar este ficheiro';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Substituir tudo por esta cópia de segurança?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
      zero: '$count pessoas',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses registadas',
      one: '1 dose registada',
      zero: '$count doses registadas',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'Contém $people, $medications e $doses. Tudo o que está agora neste telemóvel será substituído pelo seu conteúdo.';
  }

  @override
  String get replace => 'Substituir';

  @override
  String get restored => 'Restaurado';

  @override
  String get summaryFor => 'Resumo de';

  @override
  String get summarySaved => 'Resumo guardado';

  @override
  String get yourNameOnSummary => 'O seu nome no resumo';

  @override
  String get continueAction => 'Continuar';

  @override
  String get deleteAllTitle => 'Eliminar todos os dados?';

  @override
  String get deleteAllMessage =>
      'Todas as pessoas, medicamentos e doses deste telemóvel, e todos os lembretes. Não é possível anular; se puder vir a precisar deles, guarde primeiro uma cópia de segurança.';

  @override
  String get deleteEverything => 'Eliminar tudo';

  @override
  String get notificationsOff => 'As notificações estão desativadas';

  @override
  String get notificationsOn => 'As notificações estão ativadas';

  @override
  String get notificationsOffHint =>
      'Os lembretes não podem ser mostrados enquanto as notificações não forem permitidas.';

  @override
  String get notificationsOnHint =>
      'Os lembretes vão aparecer neste telemóvel.';

  @override
  String get mayBeLate => 'Os lembretes podem chegar atrasados';

  @override
  String get mayBeLateHint =>
      'O Android desativou os alarmes exatos do Nexpill. Volte a ativar «Alarmes e lembretes» nas definições do telemóvel para esta aplicação.';

  @override
  String get sendTest => 'Enviar um lembrete de teste';

  @override
  String get sendTestHint => 'Chega dentro de poucos segundos.';

  @override
  String get testOnItsWay => 'Lembrete de teste a caminho';

  @override
  String get peopleYouCareFor => 'Pessoas de quem cuida';

  @override
  String onThisPhone(int count) {
    return '$count neste telemóvel';
  }

  @override
  String get yourData => 'Os seus dados';

  @override
  String get backUp => 'Fazer cópia de segurança num ficheiro';

  @override
  String get backUpHint => 'Tudo, guardado onde escolher.';

  @override
  String get restore => 'Restaurar uma cópia de segurança';

  @override
  String get restoreHint => 'Substitui o que está neste telemóvel.';

  @override
  String get medicationSummary => 'Resumo da medicação';

  @override
  String get medicationSummaryHint =>
      'Texto simples, para o médico ou para passar os cuidados a outra pessoa.';

  @override
  String get deleteAllData => 'Eliminar todos os dados';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutNexpill => 'Acerca do Nexpill';

  @override
  String get aboutNexpillHint => 'Onde ficam os seus dados e porque é gratuito';

  @override
  String get website => 'Site';

  @override
  String get sendFeedback => 'Enviar comentários';

  @override
  String get sendFeedbackHint => 'Um formulário no site, no seu navegador.';

  @override
  String get version => 'Versão';

  @override
  String get language => 'Idioma';

  @override
  String get sameAsPhone => 'Igual ao telemóvel';

  @override
  String sameAsPhoneNow(String language) {
    return 'Igual ao telemóvel: $language';
  }

  @override
  String get aboutStaysTitle => 'Fica no seu telemóvel';

  @override
  String get aboutStaysBody =>
      'Tudo o que regista é guardado numa base de dados neste dispositivo. Não há conta nem servidor. Só sai deste dispositivo se o mover por iniciativa própria, como ficheiro de cópia de segurança ou exportação.';

  @override
  String get aboutCannotSeeTitle => 'Não conseguimos vê-lo';

  @override
  String get aboutCannotSeeBody =>
      'O Nexpill é feito sem qualquer permissão para usar a internet. O Android garante-o, e pode confirmá-lo na lista de permissões da aplicação.';

  @override
  String get aboutRemindersTitle => 'Os lembretes vêm do próprio telemóvel';

  @override
  String get aboutRemindersBody =>
      'Cada lembrete é um alarme guardado neste telemóvel, por isso chega a horas sem rede, em modo de voo e depois de reiniciar.';

  @override
  String get aboutPermissionsTitle => 'Para que servem as permissões';

  @override
  String get aboutPermissionsBody =>
      'Notificações, para os lembretes. Alarmes exatos, para que cheguem ao minuto. Arranque após reiniciar, para os voltar a programar. Vibração. É a lista completa.';

  @override
  String get aboutFreeTitle => 'Gratuito, para sempre';

  @override
  String get aboutFreeBody =>
      'O Nexpill foi escrito por um cuidador, para cuidadores. Será sempre gratuito e de código aberto: sem preço, sem versão premium, sem anúncios.';

  @override
  String get aboutCheckTitle => 'Pode verificar o nosso trabalho';

  @override
  String get aboutCheckBody =>
      'O Nexpill é de código aberto, sob a Licença Pública Geral GNU. Qualquer pessoa pode ler exatamente o que faz.';

  @override
  String get aboutHeadline => 'Os seus registos ficam consigo.';

  @override
  String get aboutIntro =>
      'O Nexpill regista quando foi dada cada dose e quando se pode dar a seguinte, e envia lembretes a tempo. Não dá aconselhamento médico.';

  @override
  String get aboutTradeOff =>
      'Há um compromisso que convém conhecer: não há cópia na nuvem, por isso, se o telemóvel se perder ou for apagado, perde-se o histórico. Guarde de vez em quando um ficheiro de cópia de segurança a partir das Definições, e mantenha-o noutro sítio que não este telemóvel.';

  @override
  String versionNumber(String version) {
    return 'Versão $version';
  }
}
