class SfgItem {
  final int id;
  final int userId;
  final int opponentUserId;
  final String amount;
  final String comment;
  final String createdAt;

  SfgItem({
    required this.id,
    required this.userId,
    required this.opponentUserId,
    required this.amount,
    required this.comment,
    required this.createdAt,
  });

  factory SfgItem.fromJson(Map<String, dynamic> json) {
    return SfgItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      opponentUserId: json['opponent_user_id'] ?? 0,
      amount: json['amount']?.toString() ?? "",
      comment: json['comment'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}

class SfgListResponse {
  final bool success;
  final int count;
  final List<SfgItem> data;

  SfgListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SfgListResponse.fromJson(Map<String, dynamic> json) {
    return SfgListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SfgItem.fromJson(e))
          .toList(),
    );
  }
}
