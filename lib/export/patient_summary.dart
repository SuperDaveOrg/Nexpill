import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/patient.dart';

/// A plain-text summary of one patient's active medications, for a doctor's
/// visit or a handover to another caregiver.
String patientSummary(CareSnapshot care, Patient patient, {required DateTime now}) {
  final medications = [
    for (final m in care.medicationsFor(patient.id))
      if (m.active) m,
  ];

  final lines = <String>[
    // The phone's owner may have no name to put here.
    patient.hasName
        ? 'Medication summary for ${patient.displayName}'
        : 'Medication summary',
    'As of ${dateTimeText(now)}. Active medications only.',
    'From Nexpill, a timing tracker. Not medical advice.',
    '',
  ];

  if (medications.isEmpty) lines.add('No active medications.');

  for (final (i, m) in medications.indexed) {
    final status = computeMedicationStatus(m, care.doses, now);
    final last = status.schedule.lastGivenAt;
    final finished = status.label == MedicationStatusLabel.finished;
    final inventory = computeInventoryStatus(m, care.doses);
    lines.addAll([
      '${i + 1}. ${m.name}${m.strengthText == null ? '' : ' (${m.strengthText})'}',
      if (m.purpose != null) '   For: ${m.purpose}',
      '   Dose: ${m.defaultDoseText}',
      '   Schedule: ${scheduleText(m.schedule)}',
      if (courseText(m, care.doses) case final course?) '   Course: $course',
      if (m.instructions != null) '   Instructions: ${m.instructions}',
      '   Last given: ${last == null ? 'Not yet' : dateTimeText(last)}',
      if (last != null || finished)
        '   Status: ${finished ? finishedText(m) : statusText(status)}',
      '   Reminders: ${remindersText(m.reminders)}',
      if (inventory.configured)
        '   Remaining: ${quantityText(inventory.remaining!)}'
            '${m.doseUnit == null ? '' : ' ${m.doseUnit}'}'
            '${inventory.level == InventoryLevel.low ? ' (running low)' : inventory.level == InventoryLevel.out ? ' (none left)' : ''}',
      '',
    ]);
  }
  return '${lines.join('\n').trimRight()}\n';
}
