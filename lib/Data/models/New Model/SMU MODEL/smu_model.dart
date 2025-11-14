class SmuListResponse {
  final bool success;
  final int count;
  final List<SmuRecord> data;

  SmuListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory SmuListResponse.fromJson(Map<String, dynamic> json) {
    return SmuListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SmuRecord.fromJson(e))
          .toList(),
    );
  }
}

class SmuRecord {
  final int id;
  final int userId;
  final String toName;
  final int opponentUserId;
  final String abstractText;
  final String date;
  final String collaborationType;
  final String followupDate;
  final String mode;

  SmuRecord({
    required this.id,
    required this.userId,
    required this.toName,
    required this.opponentUserId,
    required this.abstractText,
    required this.date,
    required this.collaborationType,
    required this.followupDate,
    required this.mode,
  });

  factory SmuRecord.fromJson(Map<String, dynamic> json) {
    return SmuRecord(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      toName: json['to_name'] ?? "",
      opponentUserId: json['opponent_user_id'] ?? 0,
      abstractText: json['abstract'] ?? "",
      date: json['date'] ?? "",
      collaborationType: json['collaboration_type'] ?? "",
      followupDate: json['followup_date'] ?? "",
      mode: json['mode'] ?? "",
    );
  }
}
