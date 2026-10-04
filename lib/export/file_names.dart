import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/patient.dart';

/// Suggested names for the files Nexpill offers to save. (The backup's is
/// [backupFileName], beside its format.)

/// "nexpill-alex-rivera-summary-2026-06-10.txt"
String patientSummaryFileName(Patient patient, DateTime day) =>
    _fileName(patient, 'summary', day, 'txt');

/// "nexpill-alex-rivera-doses-2026-06-10.csv"
String doseHistoryFileName(Patient patient, DateTime day) =>
    _fileName(patient, 'doses', day, 'csv');

String _fileName(Patient patient, String what, DateTime day, String extension) {
  // Only plain letters and digits; a name with none of those is left out.
  final name = patient.displayName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '${['nexpill', if (name.isNotEmpty) name, what, isoDate(day)].join('-')}'
      '.$extension';
}
