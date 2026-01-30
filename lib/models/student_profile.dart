class StudentProfile {
  final String uid;
  final String parentId;
  final int totalStars;
  final List<String> groupIds;
  final String paymentType; // monthly, session
  final double basePrice;
  final List<String> tags;

  StudentProfile({
    required this.uid,
    required this.parentId,
    this.totalStars = 0,
    required this.groupIds,
    required this.paymentType,
    required this.basePrice,
    this.tags = const [],
  });

  factory StudentProfile.fromMap(Map<dynamic, dynamic> map, String uid) {
    return StudentProfile(
      uid: uid,
      parentId: map['parent_id'] ?? '',
      totalStars: map['total_stars'] ?? 0,
      groupIds: List<String>.from(map['group_ids'] ?? (map['group_id'] != null ? [map['group_id']] : [])),
      paymentType: map['payment_type'] ?? 'monthly',
      basePrice: (map['base_price'] ?? 0).toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent_id': parentId,
      'total_stars': totalStars,
      'group_ids': groupIds,
      'payment_type': paymentType,
      'base_price': basePrice,
      'tags': tags,
    };
  }
}
