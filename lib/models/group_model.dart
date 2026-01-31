class GroupModel {
  final String id;
  final String name;
  final String schedule;
  final List<String> subjectIds;

  GroupModel({
    required this.id,
    required this.name,
    required this.schedule,
    this.subjectIds = const [],
  });

  factory GroupModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      schedule: map['schedule'] ?? '',
      subjectIds: List<String>.from(map['subject_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'schedule': schedule,
      'subject_ids': subjectIds,
    };
  }
}
