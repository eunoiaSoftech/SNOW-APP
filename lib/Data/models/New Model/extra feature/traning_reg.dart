class TrainingRecord {
  final int id;
  final String title;
  final String description;
  final String mode;
  final String locationDetail;
  final DateTime? trainingDate;

  TrainingRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.mode,
    required this.locationDetail,
    required this.trainingDate,
  });

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      mode: json["mode"] ?? "",
      locationDetail: json["location_detail"] ?? "",
      trainingDate: json["training_date"] != null
          ? DateTime.tryParse(json["training_date"])
          : null,
    );
  }
}
class TrainingListResponse {
  final bool success;
  final int count;
  final List<TrainingRecord> data;

  TrainingListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory TrainingListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingListResponse(
      success: json["success"] ?? false,
      count: json["count"] ?? 0,
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => TrainingRecord.fromJson(e))
          .toList(),
    );
  }
}
