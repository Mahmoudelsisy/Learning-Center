class StudentProfile {
  final String uid;
  final String parentId;
  final int totalStars;
  final String groupId;
  final String paymentType; // monthly, session
  final double basePrice;

  StudentProfile({
    required this.uid,
    required this.parentId,
    this.totalStars = 0,
    required this.groupId,
    required this.paymentType,
    required this.basePrice,
  });

  factory StudentProfile.fromMap(Map<dynamic, dynamic> map, String uid) {
    return StudentProfile(
      uid: uid,
      parentId: map['parent_id'] ?? '',
      totalStars: map['total_stars'] ?? 0,
      groupId: map['group_id'] ?? '',
      paymentType: map['payment_type'] ?? 'monthly',
      basePrice: (map['base_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent_id': parentId,
      'total_stars': totalStars,
      'group_id': groupId,
      'payment_type': paymentType,
      'base_price': basePrice,
    };
  }
}
