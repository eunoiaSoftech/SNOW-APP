import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage.dart';
import 'dart:convert';

class ApiClient {
  final Dio dio;
  final SecureStorageService storage;

  ApiClient._(this.dio, this.storage);

  factory ApiClient.create() {
    final baseUrl = dotenv.env['BASE_URL'];
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => true,
      ),
    );
    final storage = SecureStorageService();

    // Bypass SSL certificate errors in dev
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Logging and token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('🚀 API REQUEST: ${options.method} {options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    );

    return ApiClient._(dio, storage);
  }

  Future<(Response, int)> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await dio.get(path, queryParameters: query);
    return (res, res.statusCode ?? 0);
  }

  Future<(Response, int)> getUri(Uri uri) async {
    final res = await dio.getUri(uri);
    return (res, res.statusCode ?? 0);
  }

  Future<(Response, int)> post(
  String path, {
  Object? body,
  Map<String, dynamic>? query,
}) async {
  final res = await dio.post(
    path,
    data: body,
    queryParameters: query,
  );

  return (res, res.statusCode ?? 0);
}


  Future<(Response, int)> postUri(
    Uri uri, {
    Object? body,
  }) async {
    final res = await dio.postUri(uri, data: body);
    return (res, res.statusCode ?? 0);
  }

  /// ✅ DELETE method
  Future<(Response, int)> delete(String path, {Map<String, dynamic>? query}) async {
    final res = await dio.delete(path, queryParameters: query);
    return (res, res.statusCode ?? 0);
  }
}
