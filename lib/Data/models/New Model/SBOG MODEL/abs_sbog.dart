class SbogListResponse {
  final bool success;
  final int count;
  final List<SbogItem> data;

  SbogListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SbogListResponse.fromJson(Map<String, dynamic> json) {
    return SbogListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((item) => SbogItem.fromJson(item))
          .toList(),
    );
  }
}

class SbogItem {
  final String id;
  final String userId;
  final String toBusinessId;
  final String give;
  final String telephone;
  final String email;
  final String comment;
  final String createdAt;

  SbogItem({
    required this.id,
    required this.userId,
    required this.toBusinessId,
    required this.give,
    required this.telephone,
    required this.email,
    required this.comment,
    required this.createdAt,
  });

  factory SbogItem.fromJson(Map<String, dynamic> json) {
    return SbogItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      toBusinessId: json['to_business_id'].toString(),
      give: json['give'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
