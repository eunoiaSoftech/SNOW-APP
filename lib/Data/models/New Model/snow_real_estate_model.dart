// snow_real_estate_model.dart
class SnowRegisterResponse {
  final bool success;
  final String message;
  final int? userId;
  final String? status;

  SnowRegisterResponse({
    required this.success,
    required this.message,
    this.userId,
    this.status,
  });

  factory SnowRegisterResponse.fromJson(Map<String, dynamic> json) {
    return SnowRegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'],
      status: json['status'],
    );
  }
}
