class AwardListResponse {
  final bool success;
  final int count;
  final List<Award> data;

  AwardListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory AwardListResponse.fromJson(Map<String, dynamic> json) {
    return AwardListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Award.fromJson(e))
          .toList(),
    );
  }
}
class Award {
  final int id;
  final int createdBy;
  final String title;
  final String? description;
  final DateTime? createdAt;

  Award({
    required this.id,
    required this.createdBy,
    required this.title,
    this.description,
    this.createdAt,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: int.tryParse(json['id'].toString()) ?? 0,
      createdBy: int.tryParse(json['created_by'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

