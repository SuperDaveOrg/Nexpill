/// More added to a medication's supply, such as a new pack from the
/// pharmacy. What's left is worked out from these and the doses given, never
/// kept as a running count. One logged by mistake, or with the wrong amount,
/// is deleted; it isn't timing, so it has no corrections.
class Refill {
  const Refill({
    required this.id,
    required this.medicationId,
    required this.refilledAt,
    required this.amount,
  });

  final String id;
  final String medicationId;
  final DateTime refilledAt;

  /// How much was added, in the medication's unit; always positive.
  final double amount;

  /// Stored as UTC milliseconds, which sort correctly as plain integers.
  Map<String, Object?> toRow() => {
        'id': id,
        'medication_id': medicationId,
        'refilled_at': refilledAt.toUtc().millisecondsSinceEpoch,
        'amount': amount,
      };

  factory Refill.fromRow(Map<String, Object?> row) => Refill(
        id: row['id'] as String,
        medicationId: row['medication_id'] as String,
        refilledAt: DateTime.fromMillisecondsSinceEpoch(
            row['refilled_at'] as int,
            isUtc: true),
        amount: (row['amount'] as num).toDouble(),
      );
}
