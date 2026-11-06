import 'dart:convert';

import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/refill.dart';

// Writing a backup, apart from reading one (backup.dart) because reading has
// messages to translate, which needs Flutter. This half stays free of it, so
// tool/sample_history.dart can run under plain `dart run`.

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
