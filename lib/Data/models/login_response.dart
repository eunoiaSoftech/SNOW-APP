import 'package:snow_app/Data/models/user.dart';

class LoginResponse {
  final bool success;
  final String token;
  final User user;

  const LoginResponse({required this.success, required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        success: j['success'] == true,
        token: j['token'] ?? '',
        user: User.fromJson(j['user'] ?? const {}),
      );
}