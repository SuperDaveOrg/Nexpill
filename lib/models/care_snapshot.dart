import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';

/// Everything the phone knows, in one read: what timing and reminders are
/// worked out from.
class CareSnapshot {
  const CareSnapshot({
    required this.patients,
    required this.medications,
    required this.doses,
  });

  final List<Patient> patients;
  final List<Medication> medications;
  final List<DoseEvent> doses;

  Patient? patient(String id) =>
      patients.where((p) => p.id == id).firstOrNull;

  Medication? medication(String id) =>
      medications.where((m) => m.id == id).firstOrNull;
}
