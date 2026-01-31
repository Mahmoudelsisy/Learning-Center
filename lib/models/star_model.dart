class StarModel {
  final String id;
  final String studentId;
  final int amount;
  final String reason;
  final DateTime timestamp;

  StarModel({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.reason,
    required this.timestamp,
  });

  factory StarModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return StarModel(
      id: id,
      studentId: map['student_id'] ?? '',
      amount: map['amount'] ?? 0,
      reason: map['reason'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
