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
        ? strings.summaryTitleFor(patient.displayName)
        : strings.summaryTitle,
    strings.summaryAsOf(dateTimeText(now)),
    strings.summaryNotAdvice,
    '',
  ];

  if (medications.isEmpty) lines.add(strings.summaryNoActive);

  for (final (i, m) in medications.indexed) {
    final status = computeMedicationStatus(m, care.doses, now);
    final last = status.schedule.lastGivenAt;
    final finished = status.label == MedicationStatusLabel.finished;
    final inventory = computeInventoryStatus(m, care.doses, care.refills);
    final amount = amountText(inventory.remaining ?? 0, m.doseUnit);
    lines.addAll([
      '${i + 1}. ${m.name}${m.strengthText == null ? '' : ' (${m.strengthText})'}',
      for (final line in [
        if (m.purpose != null) strings.summaryPurpose(m.purpose!),
        strings.summaryDose(m.defaultDoseText),
        strings.summarySchedule(scheduleText(m.schedule)),
        if (courseText(m, care.doses) case final course?)
          strings.summaryCourse(course),
        if (m.instructions != null) strings.summaryInstructions(m.instructions!),
        strings.summaryLastGiven(
            last == null ? strings.summaryNotYet : dateTimeText(last)),
        if (last != null || finished)
          strings.summaryStatus(finished ? finishedText(m) : statusText(status)),
        strings.summaryReminders(remindersText(m.reminders)),
        if (inventory.configured)
          strings.summaryRemaining(switch (inventory.level) {
            InventoryLevel.low => strings.summaryRunningLow(amount),
            InventoryLevel.out => strings.summaryNoneLeft(amount),
            _ => amount,
          }),
      ])
        '   $line',
      '',
    ]);
  }
  return '${lines.join('\n').trimRight()}\n';
}
