import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/login_response.dart';
import 'package:snow_app/Data/models/register_response.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';

class AuthRepository {
  final ApiClient _api = ApiClient.create();

  Future<Result<RegisterResponse>> signup(Map<String, dynamic> body) async {
    final (res, code) = await _api.post('/auth/register', body: body);
    if (code == 201 || code == 200) {
      return Ok(RegisterResponse.fromJson(res.data));
    }
    final msg = _extractError(res);
    return Err(msg, code: code);
  }

  Future<Result<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    final (res, code) = await _api.post(
      '/auth/login',
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

  String _extractError(Response res) {
    final data = res.data;

    print("❌ API Error: ${res.statusCode} - ${res.data}");

    if (data is Map) {
      if (data['message'] is String) return data['message'];
      if (data['error'] is String)
        return data['error']; 
    }

    return 'Something went wrong (${res.statusCode})';
  }
}
