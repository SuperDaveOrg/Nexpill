import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/models/refill.dart';

/// Everything the phone knows, in one read: what timing and reminders are
/// worked out from.
class CareSnapshot {
  const CareSnapshot({
    required this.patients,
    required this.medications,
    required this.doses,
    this.refills = const [],
  });

  final List<Patient> patients;
  final List<Medication> medications;
  final List<DoseEvent> doses;
  final List<Refill> refills;

  Patient? patient(String id) =>
      patients.where((p) => p.id == id).firstOrNull;

  Medication? medication(String id) =>
      medications.where((m) => m.id == id).firstOrNull;

  /// [patientId]'s medications, stopped ones included.
  List<Medication> medicationsFor(String patientId) =>
      [for (final m in medications) if (m.patientId == patientId) m];
}
