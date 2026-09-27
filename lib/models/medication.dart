import 'package:nexpill/domain/dates.dart';

/// A medication one patient takes, and how its doses are timed.
class Medication {
  const Medication({
    required this.id,
    required this.patientId,
    required this.name,
    required this.defaultDoseText,
    required this.schedule,
    required this.reminders,
    this.strengthText,
    this.instructions,
    this.active = true,
    this.inventoryEnabled = false,
    this.initialQuantity,
    this.doseAmount,
    this.doseUnit,
    this.lowSupplyThreshold,
  });

  final String id;
  final String patientId;
  final String name;
  final String? strengthText;
  final String? instructions;

  /// Inactive medications stay in history but never remind.
  final bool active;
  final String defaultDoseText;
  final MedicationSchedule schedule;

  /// Always set: a new medication starts from [ReminderSettings.defaultsFor],
  /// so what's stored is what the caregiver saw in the form.
  final ReminderSettings reminders;

  final bool inventoryEnabled;
  final double? initialQuantity;

  /// How much of [initialQuantity] one dose uses, in [doseUnit].
  final double? doseAmount;
  final String? doseUnit;
  final double? lowSupplyThreshold;

  Medication copyWith({
    String? name,
    String? strengthText,
    String? instructions,
    bool? active,
    String? defaultDoseText,
    MedicationSchedule? schedule,
    ReminderSettings? reminders,
    bool? inventoryEnabled,
    double? initialQuantity,
    double? doseAmount,
    String? doseUnit,
    double? lowSupplyThreshold,
  }) =>
      Medication(
        id: id,
        patientId: patientId,
        name: name ?? this.name,
        strengthText: strengthText ?? this.strengthText,
        instructions: instructions ?? this.instructions,
        active: active ?? this.active,
        defaultDoseText: defaultDoseText ?? this.defaultDoseText,
        schedule: schedule ?? this.schedule,
        reminders: reminders ?? this.reminders,
        inventoryEnabled: inventoryEnabled ?? this.inventoryEnabled,
        initialQuantity: initialQuantity ?? this.initialQuantity,
        doseAmount: doseAmount ?? this.doseAmount,
        doseUnit: doseUnit ?? this.doseUnit,
        lowSupplyThreshold: lowSupplyThreshold ?? this.lowSupplyThreshold,
      );

  /// The `medications` row. Taper steps live in their own table; see
  /// [TaperRule.toRow].
  Map<String, Object?> toRow() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'strength_text': strengthText,
        'instructions': instructions,
        'active': active ? 1 : 0,
        'default_dose_text': defaultDoseText,
        'schedule_type': schedule.typeName,
        'interval_minutes': switch (schedule) {
          IntervalSchedule(:final intervalMinutes) => intervalMinutes,
          PrnSchedule(:final minimumIntervalMinutes) => minimumIntervalMinutes,
          _ => null,
        },
        'times_of_day': switch (schedule) {
          FixedTimesSchedule(:final times) => times.join(','),
          _ => null,
        },
        'reminders_enabled': reminders.enabled ? 1 : 0,
        'early_reminder_minutes': reminders.earlyMinutes,
        'overdue_repeat_minutes': reminders.overdueRepeatMinutes,
        'alarm_enabled': reminders.alarm ? 1 : 0,
        'inventory_enabled': inventoryEnabled ? 1 : 0,
        'initial_quantity': initialQuantity,
        'dose_amount': doseAmount,
        'dose_unit': doseUnit,
        'low_supply_threshold': lowSupplyThreshold,
      };

  factory Medication.fromRow(
    Map<String, Object?> row, {
    List<TaperRule> taperRules = const [],
  }) {
    final type = row['schedule_type'] as String;
    final minutes = row['interval_minutes'] as int?;
    return Medication(
      id: row['id'] as String,
      patientId: row['patient_id'] as String,
      name: row['name'] as String,
      strengthText: row['strength_text'] as String?,
      instructions: row['instructions'] as String?,
      active: row['active'] == 1,
      defaultDoseText: row['default_dose_text'] as String,
      schedule: switch (type) {
        IntervalSchedule.name => IntervalSchedule(minutes!),
        PrnSchedule.name => PrnSchedule(minutes!),
        FixedTimesSchedule.name => FixedTimesSchedule([
            for (final t in (row['times_of_day'] as String).split(','))
              if (t.isNotEmpty) ClockTime.tryParse(t)!,
          ]),
        TaperSchedule.name => TaperSchedule(taperRules),
        _ => throw StateError('unknown schedule type $type'),
      },
      reminders: ReminderSettings(
        enabled: row['reminders_enabled'] == 1,
        earlyMinutes: row['early_reminder_minutes'] as int,
        overdueRepeatMinutes: row['overdue_repeat_minutes'] as int,
        alarm: row['alarm_enabled'] == 1,
      ),
      inventoryEnabled: row['inventory_enabled'] == 1,
      initialQuantity: (row['initial_quantity'] as num?)?.toDouble(),
      doseAmount: (row['dose_amount'] as num?)?.toDouble(),
      doseUnit: row['dose_unit'] as String?,
      lowSupplyThreshold: (row['low_supply_threshold'] as num?)?.toDouble(),
    );
  }
}

/// Per-medication reminder preferences. There is no "unset": see
/// [defaultsFor].
class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    this.earlyMinutes = 0,
    this.overdueRepeatMinutes = defaultOverdueRepeatMinutes,
    this.alarm = false,
  });

  /// What a new medication starts with: reminders on for scheduled doses,
  /// off for as-needed ones, which have nothing to be late for.
  factory ReminderSettings.defaultsFor(MedicationSchedule schedule) =>
      ReminderSettings(enabled: schedule is! PrnSchedule);

  static const defaultOverdueRepeatMinutes = 30;

  /// The early heads-up choices offered, in minutes; 0 is none.
  static const earlyChoices = [0, 10, 15];

  final bool enabled;

  /// A heads-up this many minutes before the dose is due; 0 for none.
  final int earlyMinutes;

  /// How often an overdue reminder repeats.
  final int overdueRepeatMinutes;

  /// Ring like an alarm when due, rather than a plain notification. Offered
  /// for interval and fixed-time schedules.
  final bool alarm;

  ReminderSettings copyWith({
    bool? enabled,
    int? earlyMinutes,
    int? overdueRepeatMinutes,
    bool? alarm,
  }) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        earlyMinutes: earlyMinutes ?? this.earlyMinutes,
        overdueRepeatMinutes: overdueRepeatMinutes ?? this.overdueRepeatMinutes,
        alarm: alarm ?? this.alarm,
      );
}

/// How a medication's doses are timed.
sealed class MedicationSchedule {
  const MedicationSchedule();

  /// The name stored in the database and backups.
  String get typeName;
}

/// Every [intervalMinutes] after the last dose. Intervals like 4h 45m are
/// normal, so this is minutes rather than hours.
class IntervalSchedule extends MedicationSchedule {
  const IntervalSchedule(this.intervalMinutes);
  final int intervalMinutes;

  static const name = 'interval';
  @override
  String get typeName => name;
}

/// At the same times on the clock every day.
class FixedTimesSchedule extends MedicationSchedule {
  const FixedTimesSchedule(this.times);
  final List<ClockTime> times;

  static const name = 'fixed_times';
  @override
  String get typeName => name;
}

/// As needed, with at least [minimumIntervalMinutes] between doses. Never
/// "due" or "overdue": only available or not yet.
class PrnSchedule extends MedicationSchedule {
  const PrnSchedule(this.minimumIntervalMinutes);
  final int minimumIntervalMinutes;

  static const name = 'prn';
  @override
  String get typeName => name;
}

/// An interval that changes by date, as when a dose is stepped down.
class TaperSchedule extends MedicationSchedule {
  const TaperSchedule(this.rules);
  final List<TaperRule> rules;

  static const name = 'taper';
  @override
  String get typeName => name;
}

/// One step of a taper: [intervalMinutes] from [startDate] until the day
/// before [endDate]. Both are calendar days; an open-ended step has no end.
class TaperRule {
  const TaperRule({
    required this.startDate,
    this.endDate,
    required this.intervalMinutes,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final int intervalMinutes;

  Map<String, Object?> toRow(String medicationId, int position) => {
        'medication_id': medicationId,
        'position': position,
        'start_date': isoDate(startDate),
        'end_date': endDate == null ? null : isoDate(endDate!),
        'interval_minutes': intervalMinutes,
      };

  factory TaperRule.fromRow(Map<String, Object?> row) => TaperRule(
        startDate: tryParseIsoDate(row['start_date'] as String)!,
        endDate: row['end_date'] == null
            ? null
            : tryParseIsoDate(row['end_date'] as String)!,
        intervalMinutes: row['interval_minutes'] as int,
      );
}
