class TrainingRecord {
  final int id;
  final String title;
  final String description;
  final String mode;
  final String locationDetail;
  final DateTime? trainingDate;

  final String trainingOf;
  final String trainingBy;
  final String trainerName;
  final String city;
  final String paymentAmount;

  TrainingRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.mode,
    required this.locationDetail,
    required this.trainingDate,
    required this.trainingOf,
    required this.trainingBy,
    required this.trainerName,
    required this.city,
    required this.paymentAmount,
  });

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"] ?? "",
      description: json["description"] ?? "",

      // normalize mode
      mode: (json["mode"] ?? "").toString().toLowerCase(),

      locationDetail: json["location_detail"] ?? "",

      // 🔥 FIX DATE FORMAT (NOT ISO)
      trainingDate: json["training_date"] != null
          ? DateTime.tryParse(
              json["training_date"].toString().replaceAll(" ", "T"))
          : null,

      trainingOf: json["training_of"] ?? "",
      trainingBy: json["training_by"] ?? "",
      trainerName: json["trainer_name"] ?? "",
      city: json["city"] ?? "",
      paymentAmount: json["payment_amount"]?.toString() ?? "0",
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
