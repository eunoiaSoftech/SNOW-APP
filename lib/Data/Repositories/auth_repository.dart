import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/login_response.dart';
import 'package:snow_app/Data/models/register_response.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';

class AuthRepository {
  AuthRepository();

  final ApiClient _api = ApiClient.create();
  static final Uri _routerBase =
      Uri.parse('https://mediumvioletred-chough-398772.hostingersite.com/api/v1/router.php');

  Future<Result<RegisterResponse>> signup(Map<String, dynamic> body) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'user/register'});
    final (res, code) = await _api.postUri(uri, body: body);
    if (code == 201 || code == 200 || code == 202) {
      return Ok(RegisterResponse.fromJson(res.data as Map<String, dynamic>));
    }
    final msg = _extractError(res);
    return Err(msg, code: code);
  }

Future<Result<LoginResponse>> login({
  required String email,
  required String password,
}) async {
  final uri = _routerBase.replace(queryParameters: {
    'endpoint': 'auth/login',
  });

  final (res, code) = await _api.postUri(
    uri,
    body: {'email': email, 'password': password},
  );

  if (code == 200) {
    final lr = LoginResponse.fromJson(res.data);
    await _api.storage.saveToken(lr.token);
    return Ok(lr);
  }

  final msg = _extractError(res);
  return Err(msg, code: code);
}


  Future<Result<void>> requestPasswordOtp(String email) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'auth/forgot-password'});
    final (res, code) = await _api.postUri(uri, body: {'email': email});
    if (code == 200) {
      return const Ok(null);
    }
    final msg = _extractError(res);
    return Err(msg, code: code);
  }

  Future<Result<String>> verifyResetOtp({required String email, required String otp}) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'auth/verify-reset-otp'});
    final (res, code) = await _api.postUri(uri, body: {'email': email, 'otp': otp});
    if (code == 200 && res.data is Map<String, dynamic>) {
      final token = (res.data as Map<String, dynamic>)['reset_token']?.toString();
      if (token != null && token.isNotEmpty) {
        return Ok(token);
      }
    }
    final msg = _extractError(res);
    return Err(msg, code: code);
  }

  Future<Result<void>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'auth/reset-password'});
    final body = {
      'email': email,
      'reset_token': resetToken,
      'new_password': newPassword,
    };
    final (res, code) = await _api.postUri(uri, body: body);
    if (code == 200) {
      return const Ok(null);
    }
    final msg = _extractError(res);
    return Err(msg, code: code);
  }

  String _extractError(Response res) {
    final data = res.data;

    print("❌ API Error: ${res.statusCode} - ${res.data}");

    if (data is Map) {
      if (data['message'] is String) return data['message'];
      if (data['error'] is String) return data['error'];
    }

    return 'Something went wrong (${res.statusCode})';
  }
}
