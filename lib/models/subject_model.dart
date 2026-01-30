class SubjectModel {
  final String id;
  final String name;

  SubjectModel({
    required this.id,
    required this.name,
  });

  factory SubjectModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return SubjectModel(
      id: id,
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
