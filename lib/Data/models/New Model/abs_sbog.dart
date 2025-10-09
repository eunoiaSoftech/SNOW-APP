class SbogAbResponse {
  final bool success;
  final int? count;
  final List<SbogAbsRecord> records;

  SbogAbResponse({
    required this.success,
    this.count,
    required this.records,
  });

  factory SbogAbResponse.fromJson(Map<String, dynamic> json) {
    return SbogAbResponse(
      success: json['success'] ?? false,
      count: json['count'],
      records: (json['records'] as List<dynamic>? ?? [])
          .map((item) => SbogAbsRecord.fromJson(item))
          .toList(),
    );
  }
}

class SbogAbsRecord {
  final String? id;
  final String? senderUserId;
  final String? sbogTo;
  final String? referral;
  final String? phone;
  final String? email;
  final String? comment;
  final String? level;
  final String? date;

  SbogAbsRecord({
    this.id,
    this.senderUserId,
    this.sbogTo,
    this.referral,
    this.phone,
    this.email,
    this.comment,
    this.level,
    this.date,
  });

  factory SbogAbsRecord.fromJson(Map<String, dynamic> json) {
    return SbogAbsRecord(
      id: json['id']?.toString(),
      senderUserId: json['sender_user_id']?.toString(),
      sbogTo: json['to_member'] ?? json['sbog_to'] ?? json['name'] ?? '',
      referral: json['referral'] ?? '',
      phone: json['telephone'] ?? json['phone'] ?? '',
      email: json['email'] ?? '',
      comment: json['comments'] ?? json['comment'] ?? '',
      level: json['level']?.toString() ?? '',
      date: json['created_at'] ?? json['date'] ?? '',
    );
  }
}
