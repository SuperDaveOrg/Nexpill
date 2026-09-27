import 'package:nexpill/domain/dates.dart';
import 'package:nexpill/models/dose_event.dart';
import 'package:nexpill/models/medication.dart';

/// Reads medications and doses in the PWA's JSON shape, as recorded in
/// test/fixtures/engine_golden.json. Test-only: the app's own storage and
/// backup format are its own.

Medication medicationFromPwa(Map<String, dynamic> json) {
  final reminders = json['reminderSettings'] as Map<String, dynamic>?;
  final schedule = _scheduleFromPwa(json['schedule'] as Map<String, dynamic>);
  return Medication(
    id: json['id'] as String,
    patientId: json['patientId'] as String,
    name: json['name'] as String,
    strengthText: json['strengthText'] as String?,
    instructions: json['instructions'] as String?,
    active: json['active'] as bool,
    defaultDoseText: json['defaultDoseText'] as String,
    schedule: schedule,
    // Unset settings get the defaults a new medication gets
    // (port-from-pwa.md, 3).
    reminders: reminders == null
        ? ReminderSettings.defaultsFor(schedule)
        : ReminderSettings(
            enabled: reminders['enabled'] as bool,
            earlyMinutes: reminders['earlyReminderMinutes'] as int? ?? 0,
            alarm: reminders['alarmEnabled'] as bool? ?? false,
            overdueRepeatMinutes:
                json['overdueReminderIntervalMinutes'] as int? ??
                    ReminderSettings.defaultOverdueRepeatMinutes,
          ),
    inventoryEnabled: json['inventoryEnabled'] as bool? ?? false,
    initialQuantity: (json['initialQuantity'] as num?)?.toDouble(),
    doseAmount: (json['doseAmount'] as num?)?.toDouble(),
    doseUnit: json['doseUnit'] as String?,
    lowSupplyThreshold: (json['lowSupplyThreshold'] as num?)?.toDouble(),
  );
}

MedicationSchedule _scheduleFromPwa(Map<String, dynamic> json) {
  return switch (json['type']) {
    'interval' => IntervalSchedule(json['intervalMinutes'] as int),
    'prn' => PrnSchedule(json['minimumIntervalMinutes'] as int),
    'fixed_times' => FixedTimesSchedule([
        for (final t in json['timesOfDay'] as List) ClockTime.tryParse(t)!,
      ]),
    'taper' => TaperSchedule([
        for (final r in (json['rules'] as List).cast<Map<String, dynamic>>())
          TaperRule(
            startDate: tryParseIsoDate(r['startDate'] as String)!,
            endDate: r['endDate'] == null
                ? null
                : tryParseIsoDate(r['endDate'] as String)!,
            intervalMinutes: r['intervalMinutes'] as int,
          ),
      ]),
    final type => throw FormatException('unknown schedule type $type'),
  };
}

DoseEvent doseFromPwa(Map<String, dynamic> json) {
  return DoseEvent(
    id: json['id'] as String,
    medicationId: json['medicationId'] as String,
    givenAt: DateTime.parse(json['timestampGiven'] as String),
    doseText: json['doseText'] as String?,
    givenBy: json['givenBy'] as String?,
    notes: json['notes'] as String?,
    supersedesId: json['corrected'] == true
        ? json['supersedesDoseEventId'] as String
        : null,
  );
}
