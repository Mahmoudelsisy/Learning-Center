class HomeworkModel {
  final String id;
  final String sessionId;
  final String description;
  final DateTime deadline;
  final DateTime createdAt;

  HomeworkModel({
    required this.id,
    required this.sessionId,
    required this.description,
    required this.deadline,
    required this.createdAt,
  });

  factory HomeworkModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return HomeworkModel(
      id: id,
      sessionId: map['session_id'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
