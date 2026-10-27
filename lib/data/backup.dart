import 'dart:convert';

import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/models/refill.dart';

/// The backup file format. See docs/backup-format.md, which is the contract;
/// this file is one implementation of it.
///
/// Plain, documented JSON on purpose: a backup should be readable in a text
/// editor and importable by some other app one day, so nobody is locked in.
///
/// Version 2 added `course`, version 3 skipped doses, version 4 the phone's
/// owner, who may have no name, version 5 the single-dose schedule, version 6
/// refills. Files of every earlier version still restore.
const backupFormatVersion = 6;

/// A file that can't be restored, with a reason fit to show the user.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// The suggested file name for a backup taken on [day].
String backupFileName(DateTime day) => 'nexpill-backup-${isoDate(day)}.json';

String encodeBackup(CareSnapshot care, {required DateTime exportedAt}) {
  final medsByPatient = <String, List<Medication>>{};
  for (final m in care.medications) {
    medsByPatient.putIfAbsent(m.patientId, () => []).add(m);
  }
  final dosesByMed = <String, List<DoseEvent>>{};
  for (final d in care.doses) {
    dosesByMed.putIfAbsent(d.medicationId, () => []).add(d);
  }
  final refillsByMed = <String, List<Refill>>{};
  for (final r in care.refills) {
    refillsByMed.putIfAbsent(r.medicationId, () => []).add(r);
  }

  final json = {
    'nexpillBackup': backupFormatVersion,
    'exportedAt': _instant(exportedAt),
    'patients': [
      for (final p in care.patients)
        {
          'id': p.id,
          'name': ?(p.hasName ? p.displayName : null),
          if (p.isSelf) 'self': true,
          'notes': ?p.notes,
          'notificationsEnabled': p.notificationsEnabled,
          'medications': [
            for (final m in medsByPatient[p.id] ?? const <Medication>[])
              _encodeMedication(m, dosesByMed[m.id] ?? const [],
                  refillsByMed[m.id] ?? const []),
          ],
        },
    ],
  };
  return const JsonEncoder.withIndent('  ').convert(json);
}

Map<String, Object?> _encodeMedication(
    Medication m, List<DoseEvent> doses, List<Refill> refills) {
  final ordered = [...doses]..sort((a, b) => a.givenAt.compareTo(b.givenAt));
  final refillsInOrder = [...refills]
    ..sort((a, b) => a.refilledAt.compareTo(b.refilledAt));
  return {
    'id': m.id,
    'name': m.name,
    'strength': ?m.strengthText,
    'purpose': ?m.purpose,
    'instructions': ?m.instructions,
    'active': m.active,
    'defaultDose': m.defaultDoseText,
    'schedule': switch (m.schedule) {
      IntervalSchedule(:final intervalMinutes) => {
          'type': 'interval',
          'everyMinutes': intervalMinutes,
        },
      FixedTimesSchedule(:final times) => {
          'type': 'fixedTimes',
          'times': [for (final t in times) t.toString()],
        },
      PrnSchedule(:final minimumIntervalMinutes) => {
          'type': 'asNeeded',
          'minimumMinutes': minimumIntervalMinutes,
        },
      TaperSchedule(:final rules) => {
          'type': 'taper',
          'steps': [
            for (final r in rules)
              {
                'from': isoDate(r.startDate),
                if (r.endDate != null) 'until': isoDate(r.endDate!),
                'everyMinutes': r.intervalMinutes,
              },
          ],
        },
      OnceSchedule(:final at) => {
          'type': 'once',
          'at': _instant(at),
        },
    },
    'reminders': {
      'enabled': m.reminders.enabled,
      'earlyMinutes': m.reminders.earlyMinutes,
      'overdueRepeatMinutes': m.reminders.overdueRepeatMinutes,
      'alarm': m.reminders.alarm,
    },
    'inventory': {
      'enabled': m.inventoryEnabled,
      'startingQuantity': ?_number(m.initialQuantity),
      'perDose': ?_number(m.doseAmount),
      'unit': ?m.doseUnit,
      'lowAt': ?_number(m.lowSupplyThreshold),
    },
    'course': ?switch (m.course) {
      EndsAfterDay(:final lastDay) => {'lastDay': isoDate(lastDay)},
      EndsAfterDoses(:final doses) => {'doses': doses},
      null => null,
    },
    'doses': [
      for (final d in ordered)
        {
          'id': d.id,
          'givenAt': _instant(d.givenAt),
          'dose': ?d.doseText,
          'givenBy': ?d.givenBy,
          'notes': ?d.notes,
          'corrects': ?d.supersedesId,
          if (d.skipped) 'skipped': true,
        },
    ],
    if (refillsInOrder.isNotEmpty)
      'refills': [
        for (final r in refillsInOrder)
          {
            'id': r.id,
            'at': _instant(r.refilledAt),
            'amount': _number(r.amount),
          },
      ],
  };
}

/// Whole quantities as integers, so the file reads "30", not "30.0".
num? _number(double? q) =>
    q == null ? null : (q == q.roundToDouble() ? q.toInt() : q);

String _instant(DateTime d) =>
    DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch, isUtc: true)
        .toIso8601String();

/// Reads a backup, checking all of it before returning anything: a file
/// that is wrong anywhere is refused whole, never half-restored.
CareSnapshot decodeBackup(String text) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    throw BackupFormatException(strings.backupNotNexpill);
  }
  final root = _Reader(json, strings.backupWhereFile);
  final version = root.value<Object?>('nexpillBackup');
  if (version == null) {
    throw BackupFormatException(strings.backupNotNexpill);
  }
  if (version is! int || version > backupFormatVersion || version < 1) {
    throw BackupFormatException(strings.backupTooNew);
  }

  final ids = <String>{};
  final patients = <Patient>[];
  final medications = <Medication>[];
  final doses = <DoseEvent>[];
  final refills = <Refill>[];

  for (final p in root.list('patients')) {
    final patientId = p.id(ids);
    final isSelf = p.optionalBool('self') ?? false;
    if (isSelf && patients.any((other) => other.isSelf)) {
      throw BackupFormatException(strings.backupTwoOfYou);
    }
    // Only the phone's owner may have no name.
    final name =
        isSelf ? (p.optionalString('name') ?? '').trim() : p.string('name');
    patients.add(Patient(
      id: patientId,
      displayName: name,
      notes: p.optionalString('notes'),
      notificationsEnabled: p.optionalBool('notificationsEnabled') ?? true,
      isSelf: isSelf,
    ));

    for (final m in p.list('medications')) {
      final medId = m.id(ids);
      final schedule = _decodeSchedule(m.object('schedule'));
      final reminders = m.object('reminders');
      final inventory = m.object('inventory');
      medications.add(Medication(
        id: medId,
        patientId: patientId,
        name: m.string('name'),
        strengthText: m.optionalString('strength'),
        purpose: m.optionalString('purpose'),
        instructions: m.optionalString('instructions'),
        active: m.optionalBool('active') ?? true,
        defaultDoseText: m.string('defaultDose'),
        schedule: schedule,
        reminders: ReminderSettings(
          enabled: reminders.boolean('enabled'),
          earlyMinutes: reminders.minutes('earlyMinutes', allowZero: true),
          overdueRepeatMinutes: reminders.minutes('overdueRepeatMinutes'),
          alarm: reminders.optionalBool('alarm') ?? false,
        ),
        inventoryEnabled: inventory.boolean('enabled'),
        initialQuantity: inventory.optionalNumber('startingQuantity'),
        doseAmount: inventory.optionalNumber('perDose'),
        doseUnit: inventory.optionalString('unit'),
        lowSupplyThreshold: inventory.optionalNumber('lowAt'),
        course: _decodeCourse(m),
      ));

      for (final d in m.list('doses')) {
        final dose = DoseEvent(
          id: d.id(ids),
          medicationId: medId,
          givenAt: d.instant('givenAt'),
          doseText: d.optionalString('dose'),
          givenBy: d.optionalString('givenBy'),
          notes: d.optionalString('notes'),
          supersedesId: d.optionalString('corrects'),
          skipped: d.optionalBool('skipped') ?? false,
        );
        doses.add(dose);
      }
      _checkCorrections(
          doses.where((d) => d.medicationId == medId), m.string('name'));

      for (final r in m.optionalList('refills')) {
        refills.add(Refill(
          id: r.id(ids),
          medicationId: medId,
          refilledAt: r.instant('at'),
          amount: r.positiveNumber('amount'),
        ));
      }
    }
  }

  return CareSnapshot(
      patients: patients,
      medications: medications,
      doses: doses,
      refills: refills);
}

/// Every correction must replace a dose of the same medication, and
/// following corrections back must end at an original dose.
void _checkCorrections(Iterable<DoseEvent> doses, String medicationName) {
  final byId = {for (final d in doses) d.id: d};
  for (final d in byId.values) {
    final seen = <String>{d.id};
    for (var c = d; c.supersedesId != null;) {
      final target = byId[c.supersedesId];
      if (target == null) {
        throw BackupFormatException(
            strings.backupCorrectsMissing(medicationName));
      }
      if (!seen.add(target.id)) {
        throw BackupFormatException(
            strings.backupCorrectionsCircle(medicationName));
      }
      c = target;
    }
  }
}

CourseEnd? _decodeCourse(_Reader m) {
  final c = m.optionalObject('course');
  if (c == null) return null;
  return switch ((c.optionalDate('lastDay'), c.optionalCount('doses'))) {
    (final day?, null) => EndsAfterDay(day),
    (null, final doses?) => EndsAfterDoses(doses),
    _ => throw BackupFormatException(strings.backupCourseBoth(c.where)),
  };
}

MedicationSchedule _decodeSchedule(_Reader s) {
  return switch (s.string('type')) {
    'interval' => IntervalSchedule(s.minutes('everyMinutes')),
    'asNeeded' => PrnSchedule(s.minutes('minimumMinutes')),
    'fixedTimes' => FixedTimesSchedule([
        for (final t in s.nonEmpty(s.value<List<Object?>>('times'), 'times'))
          if (t is String && ClockTime.tryParse(t) != null)
            ClockTime.tryParse(t)!
          else
            throw BackupFormatException(strings.backupBadTime(s.where, '$t')),
      ]),
    'taper' => TaperSchedule([
        for (final step in s.nonEmpty(s.list('steps'), 'steps'))
          TaperRule(
            startDate: step.date('from'),
            endDate: step.optionalDate('until'),
            intervalMinutes: step.minutes('everyMinutes'),
          ),
      ]),
    'once' => OnceSchedule(s.instant('at')),
    final type => throw BackupFormatException(
        strings.backupUnknownSchedule(s.where, type)),
  };
}

/// Typed access to one JSON object, with errors that say where the problem
/// is.
class _Reader {
  _Reader(Object? json, this.where) {
    if (json is! Map<String, Object?>) {
      throw BackupFormatException(strings.backupWrongForm(where));
    }
    _json = json;
  }

  final String where;
  late final Map<String, Object?> _json;

  T value<T>(String key) {
    final v = _json[key];
    if (v is! T) {
      throw BackupFormatException(strings.backupMissing(where, key));
    }
    return v;
  }

  String string(String key) {
    final v = value<String>(key);
    if (v.trim().isEmpty) {
      throw BackupFormatException(strings.backupEmpty(where, key));
    }
    return v;
  }

  String? optionalString(String key) =>
      _json[key] == null ? null : value<String>(key);

  bool boolean(String key) => value<bool>(key);

  bool? optionalBool(String key) =>
      _json[key] == null ? null : value<bool>(key);

  double? optionalNumber(String key) =>
      _json[key] == null ? null : value<num>(key).toDouble();

  /// A number above zero, such as an amount added.
  double positiveNumber(String key) {
    final v = value<num>(key);
    if (v <= 0) {
      throw BackupFormatException(strings.backupImpossible(where, key, '$v'));
    }
    return v.toDouble();
  }

  int minutes(String key, {bool allowZero = false}) {
    final v = value<int>(key);
    if (v < (allowZero ? 0 : 1) || v > 60 * 24 * 365) {
      throw BackupFormatException(strings.backupImpossible(where, key, '$v'));
    }
    return v;
  }

  /// A positive whole number of things, such as doses.
  int? optionalCount(String key) {
    if (_json[key] == null) return null;
    final v = value<int>(key);
    if (v < 1 || v > 100000) {
      throw BackupFormatException(strings.backupImpossible(where, key, '$v'));
    }
    return v;
  }

  DateTime date(String key) =>
      tryParseIsoDate(value<String>(key)) ??
      (throw BackupFormatException(strings.backupBadDate(where, key)));

  DateTime? optionalDate(String key) => _json[key] == null ? null : date(key);

  /// An ISO 8601 instant, which must say its offset: a bare local time would
  /// mean different moments on different phones.
  DateTime instant(String key) {
    final s = value<String>(key);
    final parsed = DateTime.tryParse(s);
    final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s);
    if (parsed == null || !hasOffset) {
      throw BackupFormatException(strings.backupBadInstant(where, key));
    }
    return parsed.toUtc();
  }

  /// A new record id, which must be unique across the whole file.
  String id(Set<String> seen) {
    final id = string('id');
    if (!seen.add(id)) {
      throw BackupFormatException(strings.backupDuplicateId(id));
    }
    return id;
  }

  List<T> nonEmpty<T>(List<T> items, String key) => items.isEmpty
      ? throw BackupFormatException(strings.backupNone(where, key))
      : items;

  _Reader object(String key) => _Reader(_json[key], '$where, "$key"');

  _Reader? optionalObject(String key) => _json[key] == null ? null : object(key);

  List<_Reader> list(String key) {
    final items = value<List<Object?>>(key);
    return [
      for (final (i, item) in items.indexed)
        _Reader(item, _describe(key, i, item)),
    ];
  }

  List<_Reader> optionalList(String key) =>
      _json[key] == null ? const [] : list(key);

  String _describe(String key, int i, Object? item) {
    final name = item is Map ? item['name'] : null;
    return name is String ? '"$name"' : strings.backupWhereItem(where, key, i + 1);
  }
}
