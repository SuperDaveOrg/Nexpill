import 'package:intl/intl.dart';

import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/care_snapshot.dart';

/// Dose history as CSV (RFC 4180), for a spreadsheet or a doctor.
///
/// Every entry is included, newest first — corrections and the entries they
/// replaced alike — with a column saying which ones count, so the file is
/// the full audit trail rather than a tidied summary. A skipped dose's time
/// is when it was due. Refills are rows too, saying how much was added.
String doseHistoryCsv(CareSnapshot care, {String? patientId}) {
  final replaced = {for (final d in care.doses) ?d.supersedesId};
  // Machine-readable in any language.
  final local = DateFormat('yyyy-MM-dd HH:mm', 'en_US');

  final rows = <List<String>>[
    [
      strings.csvGivenAt,
      strings.csvGivenAtUtc,
      strings.csvPatient,
      strings.csvMedication,
      strings.csvDose,
      strings.csvGivenBy,
      strings.csvNotes,
      strings.csvStatus,
      strings.csvCorrects,
      strings.csvEntry,
    ],
  ];

  // Each row with what it's sorted by: newest first, then by entry.
  final entries = <(DateTime, String, List<String>)>[];
  List<String>? start(String medicationId, DateTime at) {
    final medication = care.medication(medicationId);
    if (medication == null) return null;
    if (patientId != null && medication.patientId != patientId) return null;
    return [
      local.format(at.toLocal()),
      at.toUtc().toIso8601String(),
      switch (care.patient(medication.patientId)) {
        final p? => personName(p),
        null => '',
      },
      medication.name,
    ];
  }

  for (final d in care.doses) {
    final row = start(d.medicationId, d.givenAt);
    if (row == null) continue;
    final medication = care.medication(d.medicationId)!;
    entries.add((d.givenAt, d.id, [
      ...row,
      d.skipped ? '' : d.doseText ?? medication.defaultDoseText,
      d.givenBy ?? '',
      d.notes ?? '',
      replaced.contains(d.id)
          ? strings.csvReplaced
          : d.skipped
              ? strings.csvSkipped
              : d.isCorrection
                  ? strings.csvCorrection
                  : strings.csvGiven,
      d.supersedesId ?? '',
      d.id,
    ]));
  }
  for (final r in care.refills) {
    final row = start(r.medicationId, r.refilledAt);
    if (row == null) continue;
    final unit = care.medication(r.medicationId)!.doseUnit;
    entries.add((r.refilledAt, r.id, [
      ...row,
      '+${amountText(r.amount, unit)}',
      '',
      '',
      strings.csvRefill,
      '',
      r.id,
    ]));
  }

  entries.sort((a, b) {
    final byTime = b.$1.compareTo(a.$1);
    return byTime != 0 ? byTime : b.$2.compareTo(a.$2);
  });
  rows.addAll([for (final (_, _, row) in entries) row]);
  return '${rows.map((r) => r.map(_field).join(',')).join('\r\n')}\r\n';
}

String _field(String value) =>
    value.contains(RegExp(r'[",\r\n]'))
        ? '"${value.replaceAll('"', '""')}"'
        : value;
