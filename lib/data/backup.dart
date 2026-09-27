import 'dart:convert';

import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// The backup file format. See docs/backup-format.md, which is the contract;
/// this file is one implementation of it.
///
/// Plain, documented JSON on purpose: a backup should be readable in a text
/// editor and importable by some other app one day, so nobody is locked in.
const backupFormatVersion = 1;

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

  final json = {
    'nexpillBackup': backupFormatVersion,
    'exportedAt': _instant(exportedAt),
    'patients': [
      for (final p in care.patients)
        {
          'id': p.id,
          'name': p.displayName,
          'notes': ?p.notes,
          'notificationsEnabled': p.notificationsEnabled,
          'medications': [
            for (final m in medsByPatient[p.id] ?? const <Medication>[])
              _encodeMedication(m, dosesByMed[m.id] ?? const []),
          ],
        },
    ],
  };
  return const JsonEncoder.withIndent('  ').convert(json);
}

Map<String, Object?> _encodeMedication(Medication m, List<DoseEvent> doses) {
  final ordered = [...doses]..sort((a, b) => a.givenAt.compareTo(b.givenAt));
  return {
    'id': m.id,
    'name': m.name,
    'strength': ?m.strengthText,
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
    'doses': [
      for (final d in ordered)
        {
          'id': d.id,
          'givenAt': _instant(d.givenAt),
          'dose': ?d.doseText,
          'givenBy': ?d.givenBy,
          'notes': ?d.notes,
          'corrects': ?d.supersedesId,
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
    throw const BackupFormatException("This file isn't a Nexpill backup.");
  }
  final root = _Reader(json, 'The file');
  final version = root.value<Object?>('nexpillBackup');
  if (version == null) {
    throw const BackupFormatException("This file isn't a Nexpill backup.");
  }
  if (version is! int || version > backupFormatVersion || version < 1) {
    throw const BackupFormatException(
        'This backup is from a newer version of Nexpill. Update the app, '
        'then try again.');
  }

  final ids = <String>{};
  final patients = <Patient>[];
  final medications = <Medication>[];
  final doses = <DoseEvent>[];

  for (final p in root.list('patients')) {
    final patientId = p.id(ids);
    final name = p.string('name');
    patients.add(Patient(
      id: patientId,
      displayName: name,
      notes: p.optionalString('notes'),
      notificationsEnabled: p.optionalBool('notificationsEnabled') ?? true,
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
        );
        doses.add(dose);
      }
      _checkCorrections(
          doses.where((d) => d.medicationId == medId), m.string('name'));
    }
  }

  return CareSnapshot(
      patients: patients, medications: medications, doses: doses);
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
        throw BackupFormatException('A dose of $medicationName corrects one '
            'that isn\'t in its history.');
      }
      if (!seen.add(target.id)) {
        throw BackupFormatException(
            'Corrections to $medicationName\'s doses go round in a circle.');
      }
      c = target;
    }
  }
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
            throw BackupFormatException('${s.where} has a time that isn\'t '
                'HH:mm: $t.'),
      ]),
    'taper' => TaperSchedule([
        for (final step in s.nonEmpty(s.list('steps'), 'steps'))
          TaperRule(
            startDate: step.date('from'),
            endDate: step.optionalDate('until'),
            intervalMinutes: step.minutes('everyMinutes'),
          ),
      ]),
    final type => throw BackupFormatException(
        '${s.where} has an unknown schedule type "$type".'),
  };
}

/// Typed access to one JSON object, with errors that say where the problem
/// is.
class _Reader {
  _Reader(Object? json, this.where) {
    if (json is! Map<String, Object?>) {
      throw BackupFormatException('$where isn\'t in the expected form.');
    }
    _json = json;
  }

  final String where;
  late final Map<String, Object?> _json;

  T value<T>(String key) {
    final v = _json[key];
    if (v is! T) {
      throw BackupFormatException('$where is missing "$key" or it is the '
          'wrong kind of value.');
    }
    return v;
  }

  String string(String key) {
    final v = value<String>(key);
    if (v.trim().isEmpty) {
      throw BackupFormatException('$where has an empty "$key".');
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

  int minutes(String key, {bool allowZero = false}) {
    final v = value<int>(key);
    if (v < (allowZero ? 0 : 1) || v > 60 * 24 * 365) {
      throw BackupFormatException('$where has an impossible "$key": $v.');
    }
    return v;
  }

  DateTime date(String key) =>
      tryParseIsoDate(value<String>(key)) ??
      (throw BackupFormatException(
          '$where has a "$key" that isn\'t a YYYY-MM-DD date.'));

  DateTime? optionalDate(String key) => _json[key] == null ? null : date(key);

  /// An ISO 8601 instant, which must say its offset: a bare local time would
  /// mean different moments on different phones.
  DateTime instant(String key) {
    final s = value<String>(key);
    final parsed = DateTime.tryParse(s);
    final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s);
    if (parsed == null || !hasOffset) {
      throw BackupFormatException('$where has a "$key" that isn\'t a date '
          'and time with a time zone.');
    }
    return parsed.toUtc();
  }

  /// A new record id, which must be unique across the whole file.
  String id(Set<String> seen) {
    final id = string('id');
    if (!seen.add(id)) {
      throw BackupFormatException('The id "$id" appears more than once.');
    }
    return id;
  }

  List<T> nonEmpty<T>(List<T> items, String key) => items.isEmpty
      ? throw BackupFormatException('$where has no "$key".')
      : items;

  _Reader object(String key) => _Reader(_json[key], '$where, "$key"');

  List<_Reader> list(String key) {
    final items = value<List<Object?>>(key);
    return [
      for (final (i, item) in items.indexed)
        _Reader(item, _describe(key, i, item)),
    ];
  }

  String _describe(String key, int i, Object? item) {
    final name = item is Map ? item['name'] : null;
    return name is String ? '"$name"' : '$where, $key ${i + 1}';
  }
}
