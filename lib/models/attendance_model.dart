enum AttendanceStatus { present, absent, late }

class AttendanceModel {
  final String studentId;
  final AttendanceStatus status;
  final String notes;
  final DateTime timestamp;

  AttendanceModel({
    required this.studentId,
    required this.status,
    this.notes = '',
    required this.timestamp,
  });

  factory AttendanceModel.fromMap(Map<dynamic, dynamic> map, String studentId) {
    return AttendanceModel(
      studentId: studentId,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'present'),
        orElse: () => AttendanceStatus.present,
      ),
      notes: map['notes'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'notes': notes,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
