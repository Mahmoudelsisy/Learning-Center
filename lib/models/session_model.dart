class SessionModel {
  final String id;
  final String title;
  final DateTime date;
  final String teacherId;
  final String groupId;
  final String notes;
  final bool isClosed;

  SessionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.teacherId,
    required this.groupId,
    this.notes = '',
    this.isClosed = false,
  });

  factory SessionModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return SessionModel(
      id: id,
      title: map['title'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      teacherId: map['teacher_id'] ?? '',
      groupId: map['group_id'] ?? '',
      notes: map['notes'] ?? '',
      isClosed: map['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'teacher_id': teacherId,
      'group_id': groupId,
      'notes': notes,
      'is_closed': isClosed,
    };
  }
}
