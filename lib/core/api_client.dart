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
        validateStatus: (status) => true, // We'll handle all
      ),
    );
    final storage = SecureStorageService();

    // ✅ Bypass SSL certificate errors in dev
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

    // Attach token automatically and add logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request details
          print('🚀 API REQUEST:');
          print('📍 URL: ${options.baseUrl}${options.path}');
          print('🔧 Method: ${options.method}');
          print('📋 Headers: ${jsonEncode(options.headers)}');
          if (options.queryParameters.isNotEmpty) {
            print(
              '🔍 Query Parameters: ${jsonEncode(options.queryParameters)}',
            );
          }
          if (options.data != null) {
            print('📦 Request Body: ${jsonEncode(options.data)}');
          }
          print('⏰ Request Time: ${DateTime.now()}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response details
          print('✅ API RESPONSE:');
          print(
            '📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
          );
          print('📊 Status Code: ${response.statusCode}');
          print('📋 Response Headers: ${jsonEncode(response.headers.map)}');
          print('📦 Response Data: ${jsonEncode(response.data)}');
          print('⏰ Response Time: ${DateTime.now()}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          handler.next(response);
        },
        onError: (error, handler) {
          // Log error details
          print('❌ API ERROR:');
          print(
            '📍 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          print('📊 Status Code: ${error.response?.statusCode}');
          print('💥 Error Message: ${error.message}');
          if (error.response != null) {
            print(
              '📋 Error Headers: ${jsonEncode(error.response!.headers.map)}',
            );
            print('📦 Error Data: ${jsonEncode(error.response!.data)}');
          }
          print('⏰ Error Time: ${DateTime.now()}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          handler.next(error);
        },
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

  Future<(Response, int)> post(String path, {Object? body}) async {
    final res = await dio.post(path, data: body);
    return (res, res.statusCode ?? 0);
  }
}
