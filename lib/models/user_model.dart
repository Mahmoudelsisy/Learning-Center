enum UserRole { admin, student, parent }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'student'),
        orElse: () => UserRole.student,
      ),
      phone: map['phone'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
