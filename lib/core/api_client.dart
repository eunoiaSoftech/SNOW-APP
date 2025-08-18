import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService storage;

  ApiClient._(this.dio, this.storage);

  factory ApiClient.create() {
    final baseUrl = dotenv.env['BASE_URL'];
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => true, // We'll handle all
    ));
    final storage = SecureStorageService();

    // Attach token automatically
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    return ApiClient._(dio, storage);
  }

  /// Generic getters that return (data, statusCode)
  Future<(Response, int)> get(String path, {Map<String, dynamic>? query}) async {
    final res = await dio.get(path, queryParameters: query);
    return (res, res.statusCode ?? 0);
  }

  Future<(Response, int)> post(String path, {Object? body}) async {
    final res = await dio.post(path, data: body);
    return (res, res.statusCode ?? 0);
  }
}