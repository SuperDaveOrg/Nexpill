import 'package:intl/intl.dart';

import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';

/// Dose history as CSV (RFC 4180), for a spreadsheet or a doctor.
///
/// Every entry is included, newest first — corrections and the entries they
/// replaced alike — with a column saying which ones count, so the file is
/// the full audit trail rather than a tidied summary.
String doseHistoryCsv(CareSnapshot care, {String? patientId}) {
  final replaced = {for (final d in care.doses) ?d.supersedesId};
  final local = DateFormat('yyyy-MM-dd HH:mm');

  final rows = <List<String>>[
    [
      'Given at',
      'Given at (UTC)',
      'Patient',
      'Medication',
      'Dose',
      'Given by',
      'Notes',
      'Status',
      'Corrects entry',
      'Entry',
    ],
  ];

  final doses = [...care.doses]..sort(_newestFirst);
  for (final d in doses) {
    final medication = care.medication(d.medicationId);
    if (medication == null) continue;
    if (patientId != null && medication.patientId != patientId) continue;
    rows.add([
      local.format(d.givenAt.toLocal()),
      d.givenAt.toUtc().toIso8601String(),
      care.patient(medication.patientId)?.displayName ?? '',
      medication.name,
      d.doseText ?? medication.defaultDoseText,
      d.givenBy ?? '',
      d.notes ?? '',
      replaced.contains(d.id)
          ? 'Replaced by a correction'
          : d.isCorrection
              ? 'Correction'
              : 'Given',
      d.supersedesId ?? '',
      d.id,
    ]);
  }
  return '${rows.map((r) => r.map(_field).join(',')).join('\r\n')}\r\n';
}

int _newestFirst(DoseEvent a, DoseEvent b) {
  final byTime = b.givenAt.compareTo(a.givenAt);
  return byTime != 0 ? byTime : b.id.compareTo(a.id);
}

String _field(String value) =>
    value.contains(RegExp(r'[",\r\n]'))
        ? '"${value.replaceAll('"', '""')}"'
        : value;
