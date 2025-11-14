class SborListResponse {
  final bool success;
  final int count;
  final List<SborRecord> data;

  SborListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SborListResponse.fromJson(Map<String, dynamic> json) {
    return SborListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SborRecord.fromJson(e))
          .toList(),
    );
  }
}

class SborRecord {
  final int id;
  final int userId;
  final int fromBusinessId;
  final int giverUserId;
  final String amount;
  final String comment;

  SborRecord({
    required this.id,
    required this.userId,
    required this.fromBusinessId,
    required this.giverUserId,
    required this.amount,
    required this.comment,
  });

  factory SborRecord.fromJson(Map<String, dynamic> json) {
    return SborRecord(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fromBusinessId: json['from_business_id'] ?? 0,
      giverUserId: json['giver_user_id'] ?? 0,
      amount: json['amount'] ?? "0",
      comment: json['comment'] ?? "",
    );
  }
}
