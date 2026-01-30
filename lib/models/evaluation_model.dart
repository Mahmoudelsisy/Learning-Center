class EvaluationModel {
  final String id;
  final String studentId;
  final DateTime date;
  final int academicScore;
  final int behavioralScore;
  final String notes;
  final String type; // weekly, monthly

  EvaluationModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.academicScore,
    required this.behavioralScore,
    this.notes = '',
    this.type = 'weekly',
  });

  factory EvaluationModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return EvaluationModel(
      id: id,
      studentId: map['student_id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      academicScore: map['academic_score'] ?? 0,
      behavioralScore: map['behavioral_score'] ?? 0,
      notes: map['notes'] ?? '',
      type: map['type'] ?? 'weekly',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'date': date.millisecondsSinceEpoch,
      'academic_score': academicScore,
      'behavioral_score': behavioralScore,
      'notes': notes,
      'type': type,
    };
  }
}
