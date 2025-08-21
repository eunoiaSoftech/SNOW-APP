class RecordSfgResponse {
  final bool success;
  final String message;

  RecordSfgResponse({
    required this.success,
    required this.message,
  });

  factory RecordSfgResponse.fromJson(Map<String, dynamic> json) {
    return RecordSfgResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}