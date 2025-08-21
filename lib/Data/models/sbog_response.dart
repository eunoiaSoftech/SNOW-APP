class CreateSbogResponse {
  final bool success;
  final String message;
  final int leadId;

  CreateSbogResponse({
    required this.success,
    required this.message,
    required this.leadId,
  });

  factory CreateSbogResponse.fromJson(Map<String, dynamic> json) {
    return CreateSbogResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      leadId: json['lead_id'] ?? 0,
    );
  }
}