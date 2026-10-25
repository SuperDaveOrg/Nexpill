// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минуту',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(String hours, String minutes) {
    return '$hours $minutes';
  }

  @override
  String skippedDose(String time) {
    return 'Доза в $time пропущена';
  }

  @override
  String listAnd(String items, String last) {
    return '$items и $last';
  }

  @override
  String get listSeparator => ', ';

  @override
  String scheduleEvery(String duration) {
    return 'Раз в $duration';
  }

  @override
  String scheduleAt(String times) {
    return 'В $times';
  }

  @override
  String scheduleAsNeeded(String duration) {
    return 'По необходимости, не чаще раза в $duration';
  }

  @override
  String get taperNoSteps => 'Постепенное снижение без этапов';

  @override
  String taperStepFrom(String date) {
    return 'С $date';
  }

  @override
  String taperStepRange(String from, String until) {
    return 'С $from до $until';
  }

  @override
  String taperStep(String when, String duration) {
    return '$when: раз в $duration';
  }

  @override
  String get taperFinished => 'Постепенное снижение завершено';

  @override
  String scheduleOnce(String when) {
    return 'Однократно, $when';
  }

  @override
  String scheduleOnceToday(String time) {
    return 'Однократно, сегодня в $time';
  }

  @override
  String get singleDoseFinished => 'Разовая доза отмечена';

  @override
  String taperShortEvery(String duration) {
    return 'Снижение: раз в $duration';
  }

  @override
  String taperShortFrom(String text, String date) {
    return '$text с $date';
  }

  @override
  String taperShortUntil(String text, String date) {
    return '$text до $date';
  }

  @override
  String taperShortThen(String text, String duration) {
    return '$text, затем раз в $duration';
  }

  @override
  String get statusNotGiven => 'Ещё не давали';

  @override
  String get statusCanGiveNow => 'Можно дать сейчас';

  @override
  String get statusDueNow => 'Пора дать';

  @override
  String statusNextAt(String time) {
    return 'Следующая в $time';
  }

  @override
  String statusOverdueBy(String duration) {
    return 'Просрочено на $duration';
  }

  @override
  String statusMissed(String duration) {
    return 'Упущено: надо было дать $duration назад';
  }

  @override
  String get statusFinished => 'Завершено';

  @override
  String get remindersOff => 'Выключены';

  @override
  String get remindersOn => 'Включены';

  @override
  String remindersEarly(String duration) {
    return 'за $duration';
  }

  @override
  String get remindersAlarm => 'как будильник';

  @override
  String whenToday(String time) {
    return 'сегодня в $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'завтра в $time';
  }

  @override
  String whenYesterday(String time) {
    return 'вчера в $time';
  }

  @override
  String whenOnDay(String date, String time) {
    return '$date в $time';
  }

  @override
  String shortMinutes(int count) {
    return '$count мин';
  }

  @override
  String shortHours(int count) {
    return '$count ч';
  }

  @override
  String shortHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String shortDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String courseFinishedLastDay(String date) {
    return 'Курс завершён: последний день — $date';
  }

  @override
  String courseFinishedDoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Курс завершён: все дозы даны ($count)',
      many: 'Курс завершён: все дозы даны ($count)',
      few: 'Курс завершён: все дозы даны ($count)',
      one: 'Курс завершён: все дозы даны ($count)',
    );
    return '$_temp0';
  }

  @override
  String courseLastDay(String date) {
    return 'Последний день: $date';
  }

  @override
  String courseDosesSoFar(int total, Object given) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total дозы, пока дано: $given',
      many: '$total доз, пока дано: $given',
      few: '$total дозы, пока дано: $given',
      one: '$total доза, пока дано: $given',
    );
    return '$_temp0';
  }

  @override
  String courseShortLastDay(String date) {
    return 'последний день: $date';
  }

  @override
  String courseDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осталось $count дозы',
      many: 'осталось $count доз',
      few: 'осталось $count дозы',
      one: 'осталась $count доза',
    );
    return '$_temp0';
  }

  @override
  String cardFirstDue(String when) {
    return 'Первая доза $when';
  }

  @override
  String get cardAsNeeded => 'По необходимости';

  @override
  String cardAvailableFrom(String when) {
    return 'Снова можно дать $when';
  }

  @override
  String cardNextDose(String when) {
    return 'Следующая доза $when';
  }

  @override
  String cardIn(String duration) {
    return 'через $duration';
  }

  @override
  String cardDueIn(String duration) {
    return 'Дать через $duration';
  }

  @override
  String cardAt(String when) {
    return '$when';
  }

  @override
  String cardSince(String when) {
    return 'по графику $when';
  }

  @override
  String cardOverdue(String duration) {
    return 'Просрочено на $duration';
  }

  @override
  String cardWasDue(String when) {
    return 'надо было дать $when';
  }

  @override
  String get cardMissed => 'Упущено';

  @override
  String cardMissedWasDue(String when, String duration) {
    return 'надо было дать $when, $duration назад';
  }

  @override
  String get personYou => 'Вы';

  @override
  String get personYouAfterFor => 'вам';

  @override
  String reminderDueAt(String medication, String time) {
    return '$medication: дать в $time';
  }

  @override
  String reminderDueNow(String medication) {
    return '$medication: пора дать';
  }

  @override
  String reminderOverdueSince(String medication, String time) {
    return '$medication: просрочено с $time';
  }

  @override
  String reminderAvailable(String medication) {
    return '$medication: можно дать снова';
  }

  @override
  String reminderManyFor(int count, String person) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Кому: $person — $count лекарства',
      many: 'Кому: $person — $count лекарств',
      few: 'Кому: $person — $count лекарства',
      one: 'Кому: $person — $count лекарство',
    );
    return '$_temp0';
  }

  @override
  String reminderFor(String person) {
    return 'Кому: $person';
  }

  @override
  String get channelAlarms => 'Будильники для лекарств';

  @override
  String get channelAlarmsDescription =>
      'Для лекарств, у которых, когда пора дать дозу, звонит будильник.';

  @override
  String get channelReminders => 'Напоминания о лекарствах';

  @override
  String get channelRemindersDescription =>
      'Предупреждения заранее, дозы, которые пора дать, и просроченные дозы.';

  @override
  String get channelUpkeep => 'Поддержка напоминаний';

  @override
  String get channelUpkeepDescription =>
      'Сообщение, когда нужно открыть Nexpill, чтобы напоминания не закончились.';

  @override
  String get actionMarkGiven => 'Дано';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String actionSnooze(int minutes) {
    return 'Отложить на $minutes мин';
  }

  @override
  String get upkeepTitle => 'Откройте Nexpill, чтобы напоминания продолжались';

  @override
  String get upkeepBody =>
      'Напоминания назначаются на неделю вперёд каждый раз, когда используется Nexpill. Откройте приложение, чтобы назначить следующие.';

  @override
  String get testReminderTitle => 'Тестовое напоминание';

  @override
  String get testReminderBody =>
      'Напоминания работают. Вот так они будут выглядеть.';

  @override
  String get csvGivenAt => 'Когда дано';

  @override
  String get csvGivenAtUtc => 'Когда дано (UTC)';

  @override
  String get csvPatient => 'Человек';

  @override
  String get csvMedication => 'Лекарство';

  @override
  String get csvDose => 'Доза';

  @override
  String get csvGivenBy => 'Кто дал';

  @override
  String get csvNotes => 'Заметки';

  @override
  String get csvStatus => 'Статус';

  @override
  String get csvCorrects => 'Исправляет запись';

  @override
  String get csvEntry => 'Запись';

  @override
  String get csvReplaced => 'Заменено исправлением';

  @override
  String get csvSkipped => 'Пропущено';

  @override
  String get csvCorrection => 'Исправление';

  @override
  String get csvGiven => 'Дано';

  @override
  String summaryTitleFor(String name) {
    return 'Сводка по лекарствам: $name';
  }

  @override
  String get summaryTitle => 'Сводка по лекарствам';

  @override
  String summaryAsOf(String dateTime) {
    return 'По состоянию на $dateTime. Только текущие лекарства.';
  }

  @override
  String get summaryNotAdvice =>
      'Из Nexpill — приложения для учёта времени приёма. Не является медицинской рекомендацией.';

  @override
  String get summaryNoActive => 'Текущих лекарств нет.';

  @override
  String summaryPurpose(String value) {
    return 'Для чего: $value';
  }

  @override
  String summaryDose(String value) {
    return 'Доза: $value';
  }

  @override
  String summarySchedule(String value) {
    return 'График: $value';
  }

  @override
  String summaryCourse(String value) {
    return 'Курс: $value';
  }

  @override
  String summaryInstructions(String value) {
    return 'Указания: $value';
  }

  @override
  String summaryLastGiven(String value) {
    return 'Последняя доза: $value';
  }

  @override
  String get summaryNotYet => 'Ещё не давали';

  @override
  String summaryStatus(String value) {
    return 'Статус: $value';
  }

  @override
  String summaryReminders(String value) {
    return 'Напоминания: $value';
  }

  @override
  String summaryRemaining(String value) {
    return 'Осталось: $value';
  }

  @override
  String summaryRunningLow(String amount) {
    return '$amount (заканчивается)';
  }

  @override
  String summaryNoneLeft(String amount) {
    return '$amount (закончилось)';
  }

  @override
  String get backupNotNexpill =>
      'Этот файл не является резервной копией Nexpill.';

  @override
  String get backupTooNew =>
      'Эта резервная копия создана более новой версией Nexpill. Обновите приложение и попробуйте снова.';

  @override
  String get backupTwoOfYou =>
      'В этом файле больше одного человека отмечены как «вы».';

  @override
  String backupCorrectsMissing(String medication) {
    return '$medication: доза исправляет запись, которой нет в истории.';
  }

  @override
  String backupCorrectionsCircle(String medication) {
    return '$medication: исправления доз ссылаются друг на друга по кругу.';
  }

  @override
  String backupCourseBoth(String where) {
    return '$where: нужно либо \"lastDay\", либо \"doses\", но не оба сразу.';
  }

  @override
  String backupBadTime(String where, String time) {
    return '$where: время не в формате HH:mm: $time.';
  }

  @override
  String backupUnknownSchedule(String where, String type) {
    return '$where: неизвестный тип графика \"$type\".';
  }

  @override
  String backupWrongForm(String where) {
    return '$where: данные не в ожидаемом виде.';
  }

  @override
  String backupMissing(String where, String key) {
    return '$where: нет \"$key\" или у него неверный тип значения.';
  }

  @override
  String backupEmpty(String where, String key) {
    return '$where: \"$key\" пустое.';
  }

  @override
  String backupImpossible(String where, String key, String value) {
    return '$where: невозможное значение \"$key\": $value.';
  }

  @override
  String backupBadDate(String where, String key) {
    return '$where: \"$key\" — не дата в формате ГГГГ-ММ-ДД.';
  }

  @override
  String backupBadInstant(String where, String key) {
    return '$where: \"$key\" — не дата и время с часовым поясом.';
  }

  @override
  String backupDuplicateId(String id) {
    return 'Идентификатор \"$id\" встречается больше одного раза.';
  }

  @override
  String backupNone(String where, String key) {
    return '$where: нет \"$key\".';
  }

  @override
  String get backupWhereFile => 'Файл';

  @override
  String backupWhereItem(String where, String key, int number) {
    return '$where, $key № $number';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get couldNotSave => 'Не удалось сохранить файл.';

  @override
  String get hours => 'Часы';

  @override
  String get minutes => 'Минуты';

  @override
  String cardMoreFor(String medication) {
    return 'Другие действия: $medication';
  }

  @override
  String get edit => 'Изменить';

  @override
  String get doseHistory => 'История доз';

  @override
  String skipTheDose(String time) {
    return 'Пропустить дозу в $time';
  }

  @override
  String get stopTaking => 'Прекратить приём';

  @override
  String lastGiven(String when) {
    return 'Последняя доза $when';
  }

  @override
  String lastGivenBy(String when, String name) {
    return 'Последняя доза $when, дал(а) $name';
  }

  @override
  String get skip => 'Пропустить';

  @override
  String get give => 'Дать';

  @override
  String supplyLeft(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String get supplyNoneLeft => 'Ничего не осталось: пора пополнить';

  @override
  String supplyRunningLow(String left) {
    return '$left — заканчивается';
  }

  @override
  String get earlyTitle => 'Ещё рано';

  @override
  String earlyMessageDue(String medication, String when, String duration) {
    return '$medication: следующая доза $when, через $duration. Всё равно записать дозу сейчас?';
  }

  @override
  String earlyMessageAvailable(
    String medication,
    String when,
    String duration,
  ) {
    return '$medication: снова можно дать $when, через $duration. Всё равно записать дозу сейчас?';
  }

  @override
  String get notYet => 'Пока нет';

  @override
  String get logItNow => 'Записать сейчас';

  @override
  String get dayGiven => 'День, когда дано';

  @override
  String get timeGiven => 'Время, когда дано';

  @override
  String get timeInFuture => 'Это время ещё не наступило.';

  @override
  String correctEntry(String medication) {
    return 'Исправить запись: $medication';
  }

  @override
  String giveMedication(String medication) {
    return 'Дать: $medication';
  }

  @override
  String get originalStays =>
      'Исходная запись останется в истории с пометкой «исправлено».';

  @override
  String get now => 'Сейчас';

  @override
  String get earlier => 'Раньше';

  @override
  String givenWhen(String when) {
    return 'Дано $when';
  }

  @override
  String get change => 'Изменить';

  @override
  String get dose => 'Доза';

  @override
  String get givenBy => 'Кто дал';

  @override
  String get optional => 'Необязательно';

  @override
  String get notes => 'Заметки';

  @override
  String get saveCorrection => 'Сохранить исправление';

  @override
  String get logDose => 'Записать дозу';

  @override
  String get doseHistorySaved => 'История доз сохранена';

  @override
  String get correctTimeOrDetails => 'Исправить время или подробности';

  @override
  String get keepsOriginal =>
      'Исходная запись сохранится с пометкой «исправлено»';

  @override
  String get deleteEntry => 'Удалить запись';

  @override
  String get deleteEntrySkippedHint => 'Дозу снова нужно будет дать';

  @override
  String get deleteEntryHint =>
      'Только для дозы, которую на самом деле не давали';

  @override
  String get deleteEntryTitle => 'Удалить эту запись?';

  @override
  String deleteSkippedMessage(String medication, String dateTime) {
    return '$medication, $dateTime, пропущено. Удалите запись, если эту дозу не нужно было пропускать.';
  }

  @override
  String deleteDoseMessage(String medication, String dateTime) {
    return '$medication, $dateTime. Удаляйте, только если дозу на самом деле не давали; чтобы изменить время, исправьте запись. Её исправления тоже удалятся.';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get yourDoses => 'Ваши дозы';

  @override
  String personsDoses(String name) {
    return 'Дозы: $name';
  }

  @override
  String get doses => 'Дозы';

  @override
  String get saveAsCsv => 'Сохранить как таблицу (CSV)';

  @override
  String onlyMedication(String medication) {
    return 'Только $medication';
  }

  @override
  String get nothingLogged => 'Пока ничего не записано.';

  @override
  String historyBy(String name) {
    return 'дал(а) $name';
  }

  @override
  String get historyCorrection => 'исправление';

  @override
  String get historyCorrected => 'исправлено';

  @override
  String get defaultDose => '1 таблетка';

  @override
  String get errorName => 'Укажите название лекарства.';

  @override
  String get errorDose =>
      'Укажите, что такое одна доза, например «1 таблетка».';

  @override
  String get errorHowOften => 'Выберите, как часто.';

  @override
  String get errorShortestGap =>
      'Выберите минимальный промежуток между дозами.';

  @override
  String get errorAddTime => 'Добавьте хотя бы одно время.';

  @override
  String get errorDosesStillToGive => 'Укажите, сколько доз ещё осталось дать.';

  @override
  String get errorCourseDoses => 'Укажите, сколько доз в курсе.';

  @override
  String get errorStartingSupply => 'Укажите, сколько есть в начале.';

  @override
  String get errorPerDose => 'Укажите, сколько уходит на одну дозу.';

  @override
  String get errorLowAt =>
      'Укажите, когда предупреждать, или оставьте поле пустым.';

  @override
  String get errorNoSteps => 'Добавьте хотя бы один этап.';

  @override
  String get errorStepInterval => 'Для каждого этапа нужен интервал.';

  @override
  String get errorStepEnds =>
      'Этап должен заканчиваться после того, как начался.';

  @override
  String get errorOpenEnded =>
      'Без даты окончания может быть только последний этап.';

  @override
  String get errorStepsOverlap => 'Два этапа пересекаются.';

  @override
  String deleteMedicationTitle(String medication) {
    return 'Удалить лекарство «$medication»?';
  }

  @override
  String get deleteMedicationMessage =>
      'Его история доз тоже удалится. Чтобы прекратить приём, но сохранить историю, лучше выключите «Принимается сейчас».';

  @override
  String get newMedication => 'Новое лекарство';

  @override
  String editMedication(String medication) {
    return 'Изменить: $medication';
  }

  @override
  String get save => 'Сохранить';

  @override
  String forPerson(String person) {
    return 'Кому: $person';
  }

  @override
  String get fieldName => 'Название';

  @override
  String get fieldNameHint => 'например, Амоксициллин';

  @override
  String get fieldStrength => 'Дозировка';

  @override
  String get fieldStrengthHint => 'Необязательно, например 500 мг';

  @override
  String get fieldPurpose => 'Для чего';

  @override
  String get fieldPurposeHint => 'Необязательно, например от давления';

  @override
  String get fieldUsualDose => 'Обычная доза';

  @override
  String get fieldUsualDoseHint => 'например, 1 таблетка, 5 мл';

  @override
  String get fieldInstructions => 'Указания';

  @override
  String get fieldInstructionsHint => 'Необязательно, например во время еды';

  @override
  String get sectionWhen => 'Когда';

  @override
  String get sectionHowLong => 'Как долго';

  @override
  String get sectionReminders => 'Напоминания';

  @override
  String get sectionSupply => 'Запас';

  @override
  String get takingThisNow => 'Принимается сейчас';

  @override
  String get takingThisNowHint =>
      'Выключите, когда приём прекращён. История сохранится, а напоминания прекратятся.';

  @override
  String get deleteMedication => 'Удалить лекарство';

  @override
  String get addMedication => 'Добавить лекарство';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get kindInterval => 'Раз в несколько часов';

  @override
  String get kindFixedTimes => 'В заданное время';

  @override
  String get kindAsNeeded => 'По необходимости';

  @override
  String get kindTaper => 'Постепенное снижение';

  @override
  String get kindOnce => 'Однократно';

  @override
  String get every => 'Раз в';

  @override
  String get intervalHint => 'Отсчитывается от последней данной дозы.';

  @override
  String get atLeastApart => 'Минимальный промежуток между дозами';

  @override
  String get asNeededHint =>
      'Здесь не бывает «Пора дать»: Nexpill показывает, когда можно дать снова.';

  @override
  String get addTime => 'Добавить время';

  @override
  String get fixedTimesHint => 'Каждый день, по часам этого телефона.';

  @override
  String get timeOfDose => 'Время дозы';

  @override
  String get onceHint =>
      'Одна доза. Как только её дали или пропустили, она завершена и остаётся в истории.';

  @override
  String get dayOfDose => 'День дозы';

  @override
  String get courseUntilStopped => 'Пока не прекратите';

  @override
  String get courseUntilDate => 'До определённой даты';

  @override
  String get courseNumberOfDoses => 'Определённое число доз';

  @override
  String get courseOngoingHint =>
      'Напоминания продолжаются, пока вы не выключите «Принимается сейчас».';

  @override
  String courseLastDayChip(String date) {
    return 'Последний день: $date';
  }

  @override
  String get courseLastDayHint =>
      'Дозы продолжаются весь этот день; напоминания прекращаются в полночь, когда он заканчивается.';

  @override
  String get dosesStillToGive => 'Сколько доз ещё дать';

  @override
  String get numberOfDoses => 'Число доз';

  @override
  String get dosesHint => 'например, 10';

  @override
  String get courseDosesHint =>
      'Напоминания прекратятся, когда будет дана последняя доза.';

  @override
  String courseDosesGivenHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Пока дано $count дозы. Напоминания прекратятся, когда будет дана последняя.',
      many:
          'Пока дано $count доз. Напоминания прекратятся, когда будет дана последняя.',
      few:
          'Пока даны $count дозы. Напоминания прекратятся, когда будет дана последняя.',
      one:
          'Пока дана $count доза. Напоминания прекратятся, когда будет дана последняя.',
    );
    return '$_temp0';
  }

  @override
  String get lastDayOfCourse => 'Последний день курса';

  @override
  String taperStepNumber(int number) {
    return 'Этап $number';
  }

  @override
  String get removeStep => 'Удалить этап';

  @override
  String stepFrom(String date) {
    return 'С $date';
  }

  @override
  String get noEndDate => 'Без даты окончания';

  @override
  String stepUntil(String date) {
    return 'До $date';
  }

  @override
  String get clearEnd => 'Убрать окончание';

  @override
  String get addStep => 'Добавить этап';

  @override
  String get taperHint =>
      'Каждый этап длится с полуночи своего первого дня до полуночи дня окончания. У последнего этапа может не быть окончания.';

  @override
  String get remindMe => 'Напоминать';

  @override
  String get remindAsNeededHint => 'Когда можно дать снова.';

  @override
  String get remindHint =>
      'Когда пора дать дозу, и ещё раз, пока она просрочена.';

  @override
  String get headsUp => 'Предупредить заранее';

  @override
  String get none => 'Нет';

  @override
  String minutesShort(int count) {
    return '$count мин';
  }

  @override
  String get repeatWhileOverdue => 'Повторять, пока просрочено';

  @override
  String everyDuration(String duration) {
    return 'раз в $duration';
  }

  @override
  String get ringLikeAlarm => 'Звонить как будильник';

  @override
  String get ringLikeAlarmHint =>
      'Звук будильника повторяется, пока вы не отметите дозу как данную или не отложите напоминание.';

  @override
  String get trackSupply => 'Следить за остатком';

  @override
  String get trackSupplyHint => 'Уменьшается с каждой записанной дозой.';

  @override
  String get startingAmount => 'Начальное количество';

  @override
  String get unit => 'Единица';

  @override
  String get unitHint => 'табл.';

  @override
  String get eachDoseUses => 'Расход на одну дозу';

  @override
  String get warnAt => 'Предупредить при остатке';

  @override
  String get everyone => 'Все';

  @override
  String get managePeople => 'Управление людьми';

  @override
  String get settings => 'Настройки';

  @override
  String get addSomeone => 'Добавить человека';

  @override
  String get noMedicationsYet => 'Лекарств пока нет';

  @override
  String get nothingToGiveNow => 'Сейчас давать нечего';

  @override
  String moreDueNow(int count) {
    return '+ ещё $count: пора дать';
  }

  @override
  String get remindersOffShort => 'Напоминания выключены';

  @override
  String get errorEnterName => 'Введите имя.';

  @override
  String get errorNameTaken => 'Это имя уже есть.';

  @override
  String get whoAreYouCaringFor => 'О ком вы заботитесь?';

  @override
  String get rename => 'Переименовать';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get nameHint => 'Достаточно имени или прозвища';

  @override
  String get thisIsMe => 'Это я';

  @override
  String get forYourOwnMedications => 'Для ваших собственных лекарств';

  @override
  String get add => 'Добавить';

  @override
  String get deleteYourMedicationsTitle => 'Удалить ваши лекарства?';

  @override
  String deletePersonTitle(String name) {
    return 'Удалить: $name?';
  }

  @override
  String deleteYourMedicationsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ваши лекарства ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      many:
          'Ваши лекарства ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      few:
          'Ваши лекарства ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      one:
          'Ваши лекарства ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Лекарства этого человека ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      many:
          'Лекарства этого человека ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      few:
          'Лекарства этого человека ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
      one:
          'Лекарства этого человека ($count) и вся история доз тоже удалятся, и вернуть их можно будет только из резервной копии.',
    );
    return '$_temp0';
  }

  @override
  String get people => 'Люди';

  @override
  String tapToSeeThem(String count) {
    return '$count · нажмите, чтобы посмотреть';
  }

  @override
  String get addYourName => 'Добавить ваше имя';

  @override
  String get asSetForEach => 'Как настроено для каждого лекарства';

  @override
  String allOffFor(String person) {
    return 'Кому: $person — все выключены';
  }

  @override
  String medicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лекарства',
      many: '$count лекарств',
      few: '$count лекарства',
      one: '$count лекарство',
    );
    return '$_temp0';
  }

  @override
  String doseLogged(String medication, String when) {
    return '$medication: записано, $when';
  }

  @override
  String get undo => 'Отменить';

  @override
  String skippedInARow(String medication, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$medication: пропущено $count раза подряд',
      many: '$medication: пропущено $count раз подряд',
      few: '$medication: пропущено $count раза подряд',
      one: '$medication: пропущено $count раз подряд',
    );
    return '$_temp0';
  }

  @override
  String medicationSkipped(String medication, String skipped) {
    return '$medication: $skipped';
  }

  @override
  String remindersOffFor(String medication) {
    return '$medication: напоминания выключены. Снова включить их можно в разделе «Изменить».';
  }

  @override
  String medicationStopped(String medication) {
    return '$medication: приём прекращён. История сохранена.';
  }

  @override
  String get remindersAreOff => 'Напоминания выключены';

  @override
  String get allowNotificationsHint =>
      'Разрешите уведомления, чтобы напоминания до вас доходили.';

  @override
  String get allow => 'Разрешить';

  @override
  String remindersAreOffFor(String person) {
    return 'Кому: $person — напоминания выключены.';
  }

  @override
  String get addYourFirst =>
      'Добавьте первое лекарство, и Nexpill будет следить, когда можно дать каждую дозу.';

  @override
  String addPersonsFirst(String name) {
    return '$name: добавьте первое лекарство, и Nexpill будет следить, когда можно дать каждую дозу.';
  }

  @override
  String get allEndedForYou =>
      'Все ваши лекарства завершены или прекращены. Они ниже, вместе с историей.';

  @override
  String allEndedForPerson(String name) {
    return '$name: все лекарства завершены или прекращены. Они ниже, вместе с историей.';
  }

  @override
  String get addAMedication => 'Добавить лекарство';

  @override
  String get addAnotherMedication => 'Добавить ещё лекарство';

  @override
  String addMedicationFor(String name) {
    return 'Добавить лекарство. Кому: $name';
  }

  @override
  String endedStopped(int count) {
    return 'Прекращённые ($count)';
  }

  @override
  String endedFinished(int count) {
    return 'Завершённые ($count)';
  }

  @override
  String endedBoth(int count) {
    return 'Завершённые и прекращённые ($count)';
  }

  @override
  String get resume => 'Возобновить';

  @override
  String get logoLabel => 'Логотип Nexpill';

  @override
  String get welcomeWhat =>
      'Отмечает, когда была дана каждая доза и когда можно дать следующую, и вовремя напоминает.';

  @override
  String get welcomePrivate =>
      'Всё остаётся на этом телефоне. Без аккаунта, без интернета.';

  @override
  String get whoAreTheMedicationsFor => 'Для кого лекарства?';

  @override
  String get me => 'Для меня';

  @override
  String get someoneICareFor => 'Для того, о ком я забочусь';

  @override
  String get addMoreLater => 'Других людей можно добавить позже.';

  @override
  String noBrowser(String website) {
    return 'Нет браузера, чтобы открыть ссылку. Откройте $website вручную.';
  }

  @override
  String get backupSaved => 'Резервная копия сохранена';

  @override
  String get couldNotOpen => 'Не удалось открыть этот файл.';

  @override
  String get cantRestore => 'Не удаётся восстановить данные из этого файла';

  @override
  String get ok => 'ОК';

  @override
  String get restoreTitle => 'Заменить всё данными из этой резервной копии?';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человека',
      many: '$count человек',
      few: '$count человека',
      one: '$count человек',
    );
    return '$_temp0';
  }

  @override
  String dosesLoggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записанной дозы',
      many: '$count записанных доз',
      few: '$count записанные дозы',
      one: '$count записанная доза',
    );
    return '$_temp0';
  }

  @override
  String restoreMessage(String people, String medications, String doses) {
    return 'В ней: $people, $medications и $doses. Всё, что сейчас есть на этом телефоне, будет заменено.';
  }

  @override
  String get replace => 'Заменить';

  @override
  String get restored => 'Восстановлено';

  @override
  String get summaryFor => 'Чья сводка?';

  @override
  String get summarySaved => 'Сводка сохранена';

  @override
  String get yourNameOnSummary => 'Ваше имя в сводке';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get deleteAllTitle => 'Удалить все данные?';

  @override
  String get deleteAllMessage =>
      'Все люди, лекарства и дозы на этом телефоне и все напоминания. Это нельзя отменить; если данные могут ещё понадобиться, сначала сохраните резервную копию.';

  @override
  String get deleteEverything => 'Удалить всё';

  @override
  String get notificationsOff => 'Уведомления выключены';

  @override
  String get notificationsOn => 'Уведомления включены';

  @override
  String get notificationsOffHint =>
      'Напоминания не появятся, пока уведомления не разрешены.';

  @override
  String get notificationsOnHint =>
      'Напоминания будут появляться на этом телефоне.';

  @override
  String get mayBeLate => 'Напоминания могут опаздывать';

  @override
  String get mayBeLateHint =>
      'Android отключил для Nexpill точные будильники. Снова включите «Будильники и напоминания» в настройках телефона для этого приложения.';

  @override
  String get sendTest => 'Отправить тестовое напоминание';

  @override
  String get sendTestHint => 'Придёт через несколько секунд.';

  @override
  String get testOnItsWay => 'Тестовое напоминание уже в пути';

  @override
  String get peopleYouCareFor => 'Люди, о которых вы заботитесь';

  @override
  String onThisPhone(int count) {
    return 'На этом телефоне: $count';
  }

  @override
  String get yourData => 'Ваши данные';

  @override
  String get backUp => 'Сохранить резервную копию в файл';

  @override
  String get backUpHint => 'Все данные, в выбранное вами место.';

  @override
  String get restore => 'Восстановить из резервной копии';

  @override
  String get restoreHint => 'Заменяет то, что есть на этом телефоне.';

  @override
  String get medicationSummary => 'Сводка по лекарствам';

  @override
  String get medicationSummaryHint =>
      'Простой текст — для врача или при передаче ухода.';

  @override
  String get deleteAllData => 'Удалить все данные';

  @override
  String get about => 'О приложении';

  @override
  String get aboutNexpill => 'О Nexpill';

  @override
  String get aboutNexpillHint =>
      'Где хранятся ваши данные и почему это бесплатно';

  @override
  String get website => 'Сайт';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get sendFeedbackHint => 'Форма на сайте, в вашем браузере.';

  @override
  String get version => 'Версия';

  @override
  String get language => 'Язык';

  @override
  String get sameAsPhone => 'Как на телефоне';

  @override
  String sameAsPhoneNow(String language) {
    return 'Как на телефоне: $language';
  }

  @override
  String get aboutStaysTitle => 'Всё остаётся на вашем телефоне';

  @override
  String get aboutStaysBody =>
      'Всё, что вы записываете, хранится в базе данных на этом устройстве. Нет ни аккаунта, ни сервера. Данные попадают куда-то ещё, только если вы сами их перенесёте — в виде резервной копии или экспорта.';

  @override
  String get aboutCannotSeeTitle => 'Мы не можем их видеть';

  @override
  String get aboutCannotSeeBody =>
      'У Nexpill вообще нет разрешения на доступ к интернету. Android это гарантирует, и вы можете проверить это в списке разрешений приложения.';

  @override
  String get aboutRemindersTitle => 'Напоминания приходят от самого телефона';

  @override
  String get aboutRemindersBody =>
      'Каждое напоминание — это будильник, который хранит сам телефон, поэтому оно приходит вовремя без сети, в режиме полёта и после перезагрузки.';

  @override
  String get aboutPermissionsTitle => 'Для чего нужны разрешения';

  @override
  String get aboutPermissionsBody =>
      'Уведомления — для напоминаний. Точные будильники — чтобы напоминания приходили минута в минуту. Запуск после перезагрузки — чтобы снова их назначить. Вибрация. Это весь список.';

  @override
  String get aboutFreeTitle => 'Бесплатно, навсегда';

  @override
  String get aboutFreeBody =>
      'Nexpill написал человек, который сам ухаживает за близким, — для таких же людей. Приложение всегда будет бесплатным и с открытым исходным кодом: без платы, без премиум-версии, без рекламы.';

  @override
  String get aboutCheckTitle => 'Нашу работу можно проверить';

  @override
  String get aboutCheckBody =>
      'Nexpill — программа с открытым исходным кодом под лицензией GNU General Public License. Любой может точно прочитать, что она делает.';

  @override
  String get aboutHeadline => 'Ваши записи остаются у вас.';

  @override
  String get aboutIntro =>
      'Nexpill отмечает, когда была дана каждая доза и когда можно дать следующую, и вовремя напоминает. Приложение не даёт медицинских советов.';

  @override
  String get aboutTradeOff =>
      'Один компромисс, о котором стоит знать: копии в облаке нет, поэтому если телефон потеряется или будет сброшен, история пропадёт. Время от времени сохраняйте резервную копию в «Настройках» и храните её не только на этом телефоне.';

  @override
  String versionNumber(String version) {
    return 'Версия $version';
  }
}
