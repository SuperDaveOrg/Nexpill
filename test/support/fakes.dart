import 'package:nexpill/data/care_repository.dart';
import 'package:nexpill/data/ids.dart';
import 'package:nexpill/domain/reminder_planner.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';
import 'package:nexpill/models/patient.dart';
import 'package:nexpill/services/notification_service.dart';

/// [CareRepository] in memory, for widget tests, where real database I/O
/// can't run inside the test's fake clock.
class InMemoryCareRepository implements CareRepository {
  final _patients = <String, Patient>{};
  final _medications = <String, Medication>{};
  final _doses = <String, DoseEvent>{};

  @override
  Future<CareSnapshot> snapshot() async => CareSnapshot(
        patients: [..._patients.values]
          ..sort((a, b) => a.displayName.compareTo(b.displayName)),
        medications: [..._medications.values]
          ..sort((a, b) => a.name.compareTo(b.name)),
        doses: [..._doses.values]..sort((a, b) => b.givenAt.compareTo(a.givenAt)),
      );

  @override
  Future<List<Patient>> patients() async => (await snapshot()).patients;

  @override
  Future<void> savePatient(Patient p) async => _patients[p.id] = p;

  @override
  Future<void> deletePatient(String id) async {
    _patients.remove(id);
    for (final m in [..._medications.values.where((m) => m.patientId == id)]) {
      await deleteMedication(m.id);
    }
  }

  @override
  Future<List<Medication>> medications({String? patientId}) async => [
        for (final m in (await snapshot()).medications)
          if (patientId == null || m.patientId == patientId) m,
      ];

  @override
  Future<Medication?> medication(String id) async => _medications[id];

  @override
  Future<void> saveMedication(Medication m) async => _medications[m.id] = m;

  @override
  Future<void> setMedicationActive(String id, bool active) async =>
      _medications[id] = _medications[id]!.copyWith(active: active);

  @override
  Future<void> deleteMedication(String id) async {
    _medications.remove(id);
    _doses.removeWhere((_, d) => d.medicationId == id);
  }

  @override
  Future<List<DoseEvent>> doses({String? medicationId, String? patientId}) async => [
        for (final d in (await snapshot()).doses)
          if (medicationId == null || d.medicationId == medicationId)
            if (patientId == null ||
                _medications[d.medicationId]?.patientId == patientId)
              d,
      ];

  @override
  Future<DoseEvent?> dose(String id) async => _doses[id];

  @override
  Future<DoseEvent> logDose(String medicationId,
      {DateTime? givenAt, String? doseText, String? givenBy, String? notes}) async {
    final d = DoseEvent(
      id: newId(),
      medicationId: medicationId,
      givenAt: (givenAt ?? DateTime.now()).toUtc(),
      doseText: doseText,
      givenBy: givenBy,
      notes: notes,
    );
    return _doses[d.id] = d;
  }

  @override
  Future<DoseEvent> correctDose(DoseEvent original,
      {DateTime? givenAt, String? doseText, String? givenBy, String? notes}) async {
    final d = DoseEvent(
      id: newId(),
      medicationId: original.medicationId,
      givenAt: (givenAt ?? original.givenAt).toUtc(),
      doseText: doseText ?? original.doseText,
      givenBy: givenBy ?? original.givenBy,
      notes: notes ?? original.notes,
      supersedesId: original.id,
    );
    return _doses[d.id] = d;
  }

  @override
  Future<void> deleteDose(String id) async {
    _doses.remove(id);
    _doses.removeWhere((_, d) => d.supersedesId == id);
  }

  @override
  Future<void> replaceAll(CareSnapshot s) async {
    await deleteAllData();
    for (final p in s.patients) {
      _patients[p.id] = p;
    }
    for (final m in s.medications) {
      _medications[m.id] = m;
    }
    for (final d in s.doses) {
      _doses[d.id] = d;
    }
  }

  @override
  Future<void> deleteAllData() async {
    _patients.clear();
    _medications.clear();
    _doses.clear();
  }
}

/// A [NotificationService] that remembers the last plan instead of talking
/// to Android.
class FakeNotifications extends NotificationService {
  ReminderPlan? lastPlan;
  bool allowed = true;

  @override
  Future<void> apply(ReminderPlan plan, CareSnapshot care) async => lastPlan = plan;

  @override
  Future<bool> notificationsAllowed() async => allowed;

  @override
  Future<bool> exactAlarmsAllowed() async => true;

  @override
  Future<bool> requestPermission() async => allowed = true;

  @override
  Future<void> cancelAll() async {}
}
