/// Someone whose medications are being tracked.
class Patient {
  const Patient({
    required this.id,
    required this.displayName,
    this.notes,
    this.notificationsEnabled = true,
  });

  final String id;
  final String displayName;
  final String? notes;

  /// Off silences every reminder for this patient, whatever each medication
  /// says.
  final bool notificationsEnabled;

  Patient copyWith({
    String? displayName,
    String? notes,
    bool? notificationsEnabled,
  }) =>
      Patient(
        id: id,
        displayName: displayName ?? this.displayName,
        notes: notes ?? this.notes,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'display_name': displayName,
        'notes': notes,
        'notifications_enabled': notificationsEnabled ? 1 : 0,
      };

  factory Patient.fromRow(Map<String, Object?> row) => Patient(
        id: row['id'] as String,
        displayName: row['display_name'] as String,
        notes: row['notes'] as String?,
        notificationsEnabled: row['notifications_enabled'] == 1,
      );
}
