/// One dose given, as logged.
///
/// Dose history is an audit trail. A dose logged at the wrong time or with
/// the wrong details is fixed by logging a *correction* — a new event that
/// names the one it replaces in [supersedesId]. The replaced event stays in
/// history but no longer counts for timing or inventory. Deleting is only
/// for an entry that should never have been logged at all.
class DoseEvent {
  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.givenAt,
    this.doseText,
    this.givenBy,
    this.notes,
    this.supersedesId,
  });

  final String id;
  final String medicationId;

  /// The instant the dose was given.
  final DateTime givenAt;

  final String? doseText;

  /// Who gave it, when more than one person is caring for the patient.
  final String? givenBy;
  final String? notes;

  /// The event this one corrects, or null for an ordinary dose.
  final String? supersedesId;

  bool get isCorrection => supersedesId != null;

  /// Stored as UTC milliseconds, which sort correctly as plain integers.
  Map<String, Object?> toRow() => {
        'id': id,
        'medication_id': medicationId,
        'given_at': givenAt.toUtc().millisecondsSinceEpoch,
        'dose_text': doseText,
        'given_by': givenBy,
        'notes': notes,
        'supersedes_id': supersedesId,
      };

  factory DoseEvent.fromRow(Map<String, Object?> row) => DoseEvent(
        id: row['id'] as String,
        medicationId: row['medication_id'] as String,
        givenAt: DateTime.fromMillisecondsSinceEpoch(row['given_at'] as int,
            isUtc: true),
        doseText: row['dose_text'] as String?,
        givenBy: row['given_by'] as String?,
        notes: row['notes'] as String?,
        supersedesId: row['supersedes_id'] as String?,
      );
}
