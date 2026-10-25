import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/l10n/app_localizations.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/ui/language.dart';

/// Every language says everything English does, with the same blanks to
/// fill, and is offered everywhere Nexpill lists its languages.
void main() {
  Map<String, dynamic> arb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
  final english = arb('en');
  final keys = {for (final k in english.keys) if (!k.startsWith('@')) k};
  final codes = [
    for (final l in AppLocalizations.supportedLocales) l.languageCode,
  ];

  /// The names filled in: "{count}", "{count, plural, ...}" and so on.
  Set<String> blanks(String message) =>
      {for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m[1]!};

  for (final code in codes.where((c) => c != 'en')) {
    group(code, () {
      final translated = arb(code);

      test('has every message, and nothing English lacks', () {
        final theirs = {
          for (final k in translated.keys) if (!k.startsWith('@')) k,
        };
        expect(keys.difference(theirs), isEmpty, reason: 'untranslated');
        expect(theirs.difference(keys), isEmpty, reason: 'not in English');
      });

      test('fills in the same blanks', () {
        for (final k in keys) {
          expect(blanks(translated[k] as String), blanks(english[k] as String),
              reason: k);
        }
      });
    });
  }

  // Each language's plural rule decides which form a count gets, and they
  // differ: French puts 0 with 1, Russian puts 21 with 1. A form written
  // for exactly one ("1 dose left", "its only dose") would then say the
  // wrong number, so any count but 1 must show its own number.
  test('every plural shows the right number, in every language', () {
    const counts = [0, 1, 2, 3, 5, 11, 21, 22, 25, 101];
    final wrong = <String>[];
    for (final code in codes) {
      final messages = arb(code);
      for (final k in keys) {
        final plural = _plural(messages[k] as String);
        if (plural == null) continue;
        final (name, forms) = plural;
        for (final n in counts.where((n) => n != 1)) {
          // As the generated code picks: "=1" and "one" are the same slot,
          // the later one written winning.
          final form = Intl.pluralLogic(n,
              zero: forms['=0'] ?? forms['zero'],
              one: forms['one'] ?? forms['=1'],
              two: forms['=2'] ?? forms['two'],
              few: forms['few'],
              many: forms['many'],
              other: forms['other']!,
              locale: code);
          if (!form.contains('{$name}')) wrong.add('$code $k($n): $form');
        }
      }
    }
    expect(wrong, isEmpty);
  });

  test('each language is named in Settings and offered to Android', () {
    expect(languageNames.keys.toSet(), codes.toSet());
    final config = File('android/app/src/main/res/xml/locales_config.xml')
        .readAsStringSync();
    // By language: Android lists Portuguese as pt-PT, which is what it is.
    final offered = {
      for (final m in RegExp(r'android:name="([\w-]+)"').allMatches(config))
        m[1]!.split('-').first,
    };
    expect(offered, codes.toSet());
  });

  test('the phone\'s language if Nexpill speaks it, else English', () {
    expect(resolveLanguage(null, const [Locale('es', 'MX')]), const Locale('es'));
    expect(resolveLanguage(null, const [Locale('ja'), Locale('ru')]),
        const Locale('ru'));
    expect(resolveLanguage(null, const [Locale('ja')]), const Locale('en'));
    expect(resolveLanguage(null, const [Locale('pt', 'BR')]), const Locale('pt'));
    expect(resolveLanguage('es', const [Locale('en')]), const Locale('es'));
  });

  group('in Spanish', () {
    setUp(() => useLanguage(const Locale('es')));
    tearDown(() async {
      await useLanguage(const Locale('en'));
      use24HourClock = false;
    });

    test('durations, schedules and lists', () {
      expect(durationText(90), '1 hora y 30 minutos');
      expect(durationText(480), '8 horas');
      expect(scheduleText(const IntervalSchedule(480)), 'Cada 8 horas');
      use24HourClock = true;
      expect(
          scheduleText(const FixedTimesSchedule(
              [ClockTime(20, 0), ClockTime(8, 0), ClockTime(14, 0)])),
          'A las 8:00, 14:00 y 20:00');
    });

    test('a 12-hour phone gets 12 hours, though Spanish usually uses 24', () {
      use24HourClock = false;
      expect(clockText(DateTime(2026, 6, 10, 16, 30)), matches(RegExp(r'^4:30\s')));
      use24HourClock = true;
      expect(clockText(DateTime(2026, 6, 10, 16, 30)), '16:30');
    });

    test('today, tomorrow and other days, with dates in Spanish', () {
      use24HourClock = true;
      final now = DateTime(2026, 6, 10, 12);
      expect(whenText(DateTime(2026, 6, 10, 16, 30), now), 'hoy a las 16:30');
      expect(whenText(DateTime(2026, 6, 11, 8), now), 'mañana a las 8:00');
      expect(whenText(DateTime(2026, 6, 14, 8), now), 'el 14 jun a las 8:00');
      expect(dayHeading(DateTime(2026, 6, 9), now), 'Ayer');
    });

    test('plurals', () {
      expect(strings.courseDosesLeft(1), 'queda 1 dosis');
      expect(strings.courseDosesLeft(3), 'quedan 3 dosis');
      expect(strings.medicationCount(1), '1 medicamento');
      expect(strings.medicationCount(2), '2 medicamentos');
    });

    test('a card, overdue', () {
      use24HourClock = true;
      final m = Medication(
        id: 'm',
        patientId: 'p',
        name: 'Amoxicilina',
        defaultDoseText: '1',
        schedule: const IntervalSchedule(480),
        reminders: const ReminderSettings(enabled: true),
      );
      final now = DateTime(2026, 6, 10, 14, 5);
      final status = computeMedicationStatus(
          m, [DoseEvent(id: 'd', medicationId: 'm', givenAt: DateTime(2026, 6, 10, 6))],
          now);
      expect(cardText(status, m, now),
          ('Con 5 min de retraso', 'tocaba hoy a las 14:00'));
    });
  });
}

/// A message that is one plural, "{count, plural, =1{…} other{…}}", as its
/// count's name and each form by selector. Null for anything else.
(String, Map<String, String>)? _plural(String message) {
  final head = RegExp(r'^\{(\w+), plural,').firstMatch(message);
  if (head == null || !message.endsWith('}')) return null;
  final forms = <String, String>{};
  final body = message.substring(head.end, message.length - 1);
  var i = 0;
  while (i < body.length) {
    final selector = RegExp(r'\s*(=\d+|\w+)\{').matchAsPrefix(body, i);
    if (selector == null) break;
    var depth = 1, j = selector.end;
    for (; depth > 0; j++) {
      if (body[j] == '{') depth++;
      if (body[j] == '}') depth--;
    }
    forms[selector[1]!] = body.substring(selector.end, j - 1);
    i = j;
  }
  return (head[1]!, forms);
}
