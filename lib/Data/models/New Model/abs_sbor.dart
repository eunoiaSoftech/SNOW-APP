class SborAbResponse {
  final bool success;
  final int? count;
  final List<SborAbsRecord> records;

  SborAbResponse({
    required this.success,
    this.count,
    required this.records,
  });

  factory SborAbResponse.fromJson(Map<String, dynamic> json) {
    return SborAbResponse(
      success: json['success'] ?? false,
      count: json['count'],
      records: (json['records'] as List<dynamic>? ?? [])
          .map((item) => SborAbsRecord.fromJson(item))
          .toList(),
    );
  }
}

class SborAbsRecord {
  final String id;
  final String toMember;
  final String referral;
  final String telephone;
  final String email;
  final String level;
  final String comments;
  final String createdAt;

  SborAbsRecord({
    required this.id,
    required this.toMember,
    required this.referral,
    required this.telephone,
    required this.email,
    required this.level,
    required this.comments,
    required this.createdAt,
  });

  factory SborAbsRecord.fromJson(Map<String, dynamic> json) {
    return SborAbsRecord(
      id: json['id']?.toString() ?? '',
      toMember: json['to_member'] ?? '',
      referral: json['referral'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] ?? '',
      comments: json['comments'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
