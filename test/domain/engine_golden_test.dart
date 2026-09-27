import 'dart:convert';
import 'dart:io';

import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/scheduling.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pwa_json.dart';

/// Checks the Dart engine against answers recorded from the PWA's TypeScript
/// engine (tool/engine_golden/). A failure here means the port behaves
/// differently from the app it replaced. Deliberate changes since the PWA are
/// listed in docs/port-from-pwa.md and handled in [_changedSincePwa] and
/// [_expectedNow] — nowhere else.
///
/// Instants are compared in UTC. Fixed-time schedules are recorded as local
/// wall-clock times, so this passes in any time zone.
void main() {
  final golden = jsonDecode(
          File('test/fixtures/engine_golden.json').readAsStringSync())
      as Map<String, dynamic>;

  final medications = {
    for (final MapEntry(:key, :value)
        in (golden['medications'] as Map<String, dynamic>).entries)
      key: medicationFromPwa(value as Map<String, dynamic>),
  };
  final histories = (golden['histories'] as Map<String, dynamic>)
      .map((name, events) => MapEntry(name, events as List));

  List<DoseEvent> history(String name, String medicationId) => [
        for (final e in histories[name]!.cast<Map<String, dynamic>>())
          doseFromPwa({
            ...e,
            if (e['medicationId'] == r'$med') 'medicationId': medicationId,
          }),
      ];

  final cases = (golden['cases'] as List).cast<Map<String, dynamic>>();

  test('fixture is present and substantial', () {
    expect(cases.length, greaterThan(2000));
  });

  group('status matches the PWA', () {
    for (final c in cases.where((c) => c['kind'] == 'status')) {
      final medication = medications[c['medication']]!;
      final now = c['now'] as String;
      final doses = history(c['history'] as String, medication.id);
      test('${medication.id} / ${c['history']} @ $now', () {
        final status =
            computeMedicationStatus(medication, doses, DateTime.parse(now));
        expect(
          _statusAsPwa(status, medication),
          _expectedNow(c['expect'] as Map<String, dynamic>, medication,
              DateTime.parse(now),
              remindersWereUnset: (golden['medications']
                      as Map<String, dynamic>)[medication.id]
                  ['reminderSettings'] == null),
        );
      }, skip: _changedSincePwa(medication, doses));
    }
  });

  group('inventory matches the PWA', () {
    for (final c in cases.where((c) => c['kind'] == 'inventory')) {
      final medication = medications[c['medication']]!;
      test('${medication.id} / ${c['history']}', () {
        final inventory = computeInventoryStatus(
          medication,
          history(c['history'] as String, medication.id),
        );
        expect(_inventoryAsPwa(inventory), _numbersAsDoubles(c['expect']));
      });
    }
  });
}

/// Why the PWA's answer no longer applies to this case, or null if it does.
String? _changedSincePwa(Medication medication, List<DoseEvent> doses) {
  // Change 1: fixed-time doses now count. Without doses nothing changed.
  if (medication.schedule is FixedTimesSchedule && doses.isNotEmpty) {
    return 'fixed-time doses now count (port-from-pwa.md, 1)';
  }
  // Change 2: taper steps begin at local midnight, which is where the PWA's
  // UTC midnight was only when the phone is on UTC.
  if (medication.schedule is TaperSchedule &&
      DateTime(2026, 6, 1).timeZoneOffset != Duration.zero) {
    return 'taper steps now start at local midnight; checked in UTC only '
        '(port-from-pwa.md, 2)';
  }
  return null;
}

/// The PWA's answer, updated for changes that alter it predictably.
Map<String, dynamic> _expectedNow(
  Map<String, dynamic> pwa,
  Medication medication,
  DateTime now, {
  required bool remindersWereUnset,
}) {
  // Change 3: unset reminder settings are now the defaults — on, with no
  // early heads-up, for anything but as-needed — so the first reminder is
  // at the due time rather than absent.
  if (remindersWereUnset && medication.schedule is! PrnSchedule) {
    pwa = {...pwa, 'reminderAt': pwa['nextEligibleAt']};
  }
  // Change 4: tapers are "missed" by the same rule as intervals.
  if (medication.schedule case TaperSchedule(:final rules)
      when pwa['label'] == 'overdue') {
    final interval = activeTaperRule(rules, now)!.intervalMinutes;
    if ((pwa['overdueByMinutes'] as int) >= (interval * 0.5).ceil()) {
      return {...pwa, 'label': 'missed'};
    }
  }
  return pwa;
}

Map<String, Object> _statusAsPwa(MedicationStatus status, Medication med) {
  final s = status.schedule;
  final local = med.schedule is FixedTimesSchedule;
  String time(DateTime d) => local ? _wallClock(d) : _utc(d);
  return {
    'label': _pwaLabels[status.label]!,
    'eligibleNow': s.eligibleNow,
    if (s.lastGivenAt case final t?) 'lastGivenAt': _utc(t),
    'nextEligibleAt': time(s.nextEligibleAt),
    if (s.reminderAt case final t?) 'reminderAt': time(t),
    'minutesUntilEligible': status.minutesUntilEligible,
    'tooEarlyByMinutes': ?s.tooEarlyByMinutes,
    'overdueByMinutes': ?s.overdueByMinutes,
  };
}

const _pwaLabels = {
  MedicationStatusLabel.neverTaken: 'never_taken',
  MedicationStatusLabel.tooEarly: 'too_early',
  MedicationStatusLabel.dueSoon: 'due_soon',
  MedicationStatusLabel.eligibleNow: 'eligible_now',
  MedicationStatusLabel.overdue: 'overdue',
  MedicationStatusLabel.missed: 'missed',
  MedicationStatusLabel.availablePrn: 'available_prn',
};

Map<String, Object> _inventoryAsPwa(InventoryStatus i) => {
      'inventoryEnabled': i.enabled,
      'configured': i.configured,
      if (i.level case final level?)
        'statusLabel': switch (level) {
          InventoryLevel.ok => 'inventory_ok',
          InventoryLevel.low => 'low_supply',
          InventoryLevel.out => 'out_of_stock',
        },
      'remainingQuantity': ?i.remaining,
      'quantityUsed': i.used,
      'effectiveDoseCount': i.effectiveDoseCount,
      'lowSupplyThreshold': ?i.lowSupplyThreshold,
    };

/// JSON can't tell 3 from 3.0; the Dart side uses doubles for quantities.
Map<String, Object?> _numbersAsDoubles(Object? expected) => {
      for (final MapEntry(:key, :value)
          in (expected as Map<String, dynamic>).entries)
        key: value is num && key != 'effectiveDoseCount'
            ? value.toDouble()
            : value,
    };

String _utc(DateTime d) => d.toUtc().toIso8601String();

String _wallClock(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}'
      'T${two(l.hour)}:${two(l.minute)}:${two(l.second)}'
      '.${l.millisecond.toString().padLeft(3, '0')}';
}
