class RegisterResponse {
  final bool success;
  final int? userId;
  final String message;

  const RegisterResponse({required this.success, this.userId, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> j) => RegisterResponse(
        success: j['success'] == true,
        userId: j['user_id'] is String
            ? int.tryParse(j['user_id'])
            : j['user_id'] as int?,
        message: j['message'] ?? '',
      );
}