import 'package:intl/intl.dart';

import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/dose_event.dart';

/// Dose history as CSV (RFC 4180), for a spreadsheet or a doctor.
///
/// Every entry is included, newest first — corrections and the entries they
/// replaced alike — with a column saying which ones count, so the file is
/// the full audit trail rather than a tidied summary. A skipped dose's time
/// is when it was due.
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

  final doses = [...care.doses]..sort(_newestFirst);
  for (final d in doses) {
    final medication = care.medication(d.medicationId);
    if (medication == null) continue;
    if (patientId != null && medication.patientId != patientId) continue;
    rows.add([
      local.format(d.givenAt.toLocal()),
      d.givenAt.toUtc().toIso8601String(),
      switch (care.patient(medication.patientId)) {
        final p? => personName(p),
        null => '',
      },
      medication.name,
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
