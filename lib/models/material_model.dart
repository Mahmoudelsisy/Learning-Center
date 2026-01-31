class MaterialModel {
  final String id;
  final String title;
  final String content;
  final String subjectId;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.title,
    required this.content,
    required this.subjectId,
    required this.createdAt,
  });

  factory MaterialModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return MaterialModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      subjectId: map['subject_id'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'subject_id': subjectId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
