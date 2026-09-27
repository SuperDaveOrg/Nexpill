import 'package:nexpill/domain/inventory.dart';
import 'package:nexpill/domain/status.dart';
import 'package:nexpill/domain/wording.dart';
import 'package:nexpill/models/care_snapshot.dart';
import 'package:nexpill/models/patient.dart';

/// A plain-text summary of one patient's active medications, for a doctor's
/// visit or a handover to another caregiver.
String patientSummary(CareSnapshot care, Patient patient, {required DateTime now}) {
  final medications = [
    for (final m in care.medications)
      if (m.patientId == patient.id && m.active) m,
  ];

  final lines = <String>[
    'Medication summary for ${patient.displayName}',
    'As of ${dateTimeText(now)}. Active medications only.',
    'From Nexpill, a timing tracker. Not medical advice.',
    '',
  ];

  if (medications.isEmpty) lines.add('No active medications.');

  for (final (i, m) in medications.indexed) {
    final status = computeMedicationStatus(m, care.doses, now);
    final last = status.schedule.lastGivenAt;
    final inventory = computeInventoryStatus(m, care.doses);
    lines.addAll([
      '${i + 1}. ${m.name}${m.strengthText == null ? '' : ' (${m.strengthText})'}',
      '   Dose: ${m.defaultDoseText}',
      '   Schedule: ${scheduleText(m.schedule)}',
      if (m.instructions != null) '   Instructions: ${m.instructions}',
      '   Last given: ${last == null ? 'Not yet' : dateTimeText(last)}',
      if (last != null) '   Status: ${statusText(status)}',
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
