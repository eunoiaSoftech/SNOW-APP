import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _jwtKey = 'jwt_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _jwtKey, value: token);

  Future<String?> get token => _storage.read(key: _jwtKey);

  Future<void> clearToken() => _storage.delete(key: _jwtKey);
}