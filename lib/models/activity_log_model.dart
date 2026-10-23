// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Activity Log Model
// Tracks 'CALL' and 'SMS' interactions for the Settings notification log.
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single logged user interaction (phone call or bulk SMS).
class ActivityLog {
  final int? id;
  final String actionType;    // 'CALL' or 'SMS'
  final String studentNames;  // Comma-separated display names
  final String details;       // Human-readable description shown in the log
  final String timestamp;     // ISO8601 datetime string

  const ActivityLog({
    this.id,
    required this.actionType,
    required this.studentNames,
    required this.details,
    required this.timestamp,
  });

  /// Creates an [ActivityLog] from a SQLite row map.
  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id:           map['id'] as int?,
      actionType:   map['action_type'] as String,
      studentNames: map['student_names'] as String,
      details:      map['details'] as String,
      timestamp:    map['timestamp'] as String,
    );
  }

  /// Converts this log to a SQLite row map.
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'action_type':   actionType,
    'student_names': studentNames,
    'details':       details,
    'timestamp':     timestamp,
  };

  /// Returns a [DateTime] parsed from [timestamp].
  DateTime get dateTime => DateTime.tryParse(timestamp) ?? DateTime.now();

  @override
  String toString() => 'ActivityLog($actionType @ $timestamp)';
}
