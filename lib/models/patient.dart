/// Someone whose medications are being tracked.
class Patient {
  const Patient({
    required this.id,
    required this.displayName,
    this.notes,
    this.notificationsEnabled = true,
    this.isSelf = false,
  });

  final String id;

  /// Empty only for [isSelf], who needn't give a name.
  final String displayName;
  final String? notes;

  /// Off silences every reminder for this patient, whatever each medication
  /// says.
  final bool notificationsEnabled;

  /// The phone's owner, tracking their own medications: "you" rather than a
  /// name. At most one patient is.
  final bool isSelf;

  /// Whether there's a name to show. Everyone else always has one.
  bool get hasName => displayName.isNotEmpty;

  Patient copyWith({
    String? displayName,
    String? notes,
    bool? notificationsEnabled,
    bool? isSelf,
  }) =>
      Patient(
        id: id,
        displayName: displayName ?? this.displayName,
        notes: notes ?? this.notes,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        isSelf: isSelf ?? this.isSelf,
      );

  Map<String, Object?> toRow() => {
        'id': id,
        'display_name': displayName,
        'notes': notes,
        'notifications_enabled': notificationsEnabled ? 1 : 0,
        'is_self': isSelf ? 1 : 0,
      };

  factory Patient.fromRow(Map<String, Object?> row) => Patient(
        id: row['id'] as String,
        displayName: row['display_name'] as String,
        notes: row['notes'] as String?,
        notificationsEnabled: row['notifications_enabled'] == 1,
        isSelf: row['is_self'] == 1,
      );
}
