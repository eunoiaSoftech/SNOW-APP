class RecordSfgPostResponse {
  final bool success;
  final String message;
  final int recordId;

  RecordSfgPostResponse({
    required this.success,
    required this.message,
    required this.recordId,
  });

  factory RecordSfgPostResponse.fromJson(Map<String, dynamic> json) {
    return RecordSfgPostResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      recordId: json['record_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "record_id": recordId,
      };
}
