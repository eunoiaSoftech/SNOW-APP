// lib/Data/models/New Model/SBOL MODEL/sbol_model.dart

class SbolRequest {
  final String toBusinessId;
  final String referral;
  final String telephone;
  final String email;
  final int level;
  final String comment;

  SbolRequest({
    required this.toBusinessId,
    required this.referral,
    required this.telephone,
    required this.email,
    required this.level,
    required this.comment,
  });

  /// To send to API (create)
  Map<String, dynamic> toJson() {
    // ensure to_business_id is an integer in JSON
    int id = int.tryParse(toBusinessId) ?? 0;
    return {
      "to_business_id": id,
      "referral": referral,
      "telephone": telephone,
      "email": email,
      "level": level,
      "comment": comment,
    };
  }

  /// Optional: parse a single item into SbolRequest (if you need it)
  factory SbolRequest.fromJson(Map<String, dynamic> json) {
    return SbolRequest(
      toBusinessId: (json['to_business_id'] ?? '').toString(),
      referral: json['referral'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] is int ? json['level'] : int.tryParse('${json['level']}') ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}

class SbolItem {
  final int id;
  final int toBusinessId;
  final String referral;
  final String telephone;
  final String email;
  final int level;
  final String comment;

  SbolItem({
    required this.id,
    required this.toBusinessId,
    required this.referral,
    required this.telephone,
    required this.email,
    required this.level,
    required this.comment,
  });

  factory SbolItem.fromJson(Map<String, dynamic> json) {
    return SbolItem(
      id: json['id'] ?? 0,
      toBusinessId: json['to_business_id'] ?? 0,
      referral: json['referral'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }
}

class SbolListResponse {
  final bool success;
  final int count;
  final List<SbolItem> data;

  SbolListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SbolListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .map((e) => SbolItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SbolListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? list.length,
      data: list,
    );
  }
}
