import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/New Model/snow_real_estate_model.dart';
import 'package:snow_app/core/api_client.dart';

/// Repository to handle Real Estate registration only.
/// Updated to work with a router-style backend that expects the route
/// as a QUERY parameter (e.g. `router.php?endpoint=user/register`).
class SnowRealEstateRepository {
  final ApiClient _api = ApiClient.create();

  /// Register a real estate user.
  /// This implementation sends the target route as a query parameter
  /// named `endpoint` because your backend exposes a single router.php
  /// entrypoint (example base URL: https://.../api/v1/router.php).
  ///
  // Future<SnowRegisterResponse> registerRealEstate({
  //   required String fullName,
  //   required String email,
  //   required String password,
  //   required String businessName,
  //   required String businessCategory,
  //   required int country,
  //   required int zone,
  //   required int state,
  //   required int city,
  //   required String contact,
  //   String? website,
  // }) async {
  //   // NOTE: when using router.php entrypoint, the actual path is sent via the
  //   // `endpoint` query param. We'll call the ApiClient with an empty path and
  //   // supply the endpoint as `query` so final URL becomes:
  //   // https://.../api/v1/router.php?endpoint=user/register
  //   const routerEndpoint = 'user/register';

  //   final body = {
  //     'user_type': 'real_estate',
  //     'full_name': fullName,
  //     'email': email,
  //     'password': password,
  //     'business_name': businessName,
  //     'business_category': businessCategory,
  //     'country': country,
  //     'zone': zone,
  //     'state': state,
  //     'city': city,
  //     'contact': contact,
  //     'website': website ?? ''
  //   };

  //   try {
  //     print('🌐 POST → router.php?endpoint=$routerEndpoint');
  //     print('   body: $body');

  //     // Use ApiClient.post with query param `endpoint` and named `body:`
  //     // ApiClient.create() baseUrl should be: https://mediumvioletred-chough-398772.hostingersite.com/api/v1/router.php
  //     final (res, code) = await _api.post('', body: body, query: {'endpoint': routerEndpoint});

  //     print('📥 Response Code: $code');
  //     print('📦 Response Data: ${res.data}');

  //     if (code == 200 || code == 201) {
  //       final data = res.data is Map ? Map<String, dynamic>.from(res.data) : {'data': res.data};
  //       return SnowRegisterResponse.fromJson(data);
  //     }

  //     throw Exception(_extractError(res, code));
  //   } on DioError catch (dioErr) {
  //     final status = dioErr.response?.statusCode;
  //     final respData = dioErr.response?.data;
  //     print('❌ DioError: status=$status, data=$respData, message=${dioErr.message}');

  //     // Friendly error showing router hint
  //     throw Exception('Register failed: ${dioErr.message} (status: $status, response: $respData)');
  //   } catch (e) {
  //     print('❌ Unexpected error: $e');
  //     rethrow;
  //   }
  // }

  Future<SnowRegisterResponse> registerRealEstate({
    required String fullName,
    required String email,
    required String password,
    required String businessName,
    required String businessCategory,
    required int country,
    required int zone,
    required int state,
    required int city,
    required String contact,
    String? website,
    File? aadharFile,
  }) async {
    const routerEndpoint = 'user/register';
    const int maxAadharSize = 2 * 1024 * 1024; // 2 MB

    Future<File> validateAadharFile(File file) async {
      final size = await file.length();
      if (size > maxAadharSize) {
        throw Exception('Aadhaar image must be under 2MB');
      }
      return file;
    }

    final formData = FormData.fromMap({
      'user_type': 'real_estate',
      'full_name': fullName,
      'email': email,
      'password': password,
      'business_name': businessName,
      'business_category': businessCategory,
      'country': country,
      'zone': zone,
      'state': state,
      'city': city,
      'contact': contact,
      'website': website ?? '',
    });

    if (aadharFile != null) {
      await validateAadharFile(aadharFile);

      formData.files.add(
        MapEntry(
          'aadhar_file',
          await MultipartFile.fromFile(aadharFile.path, filename: 'aadhar.jpg'),
        ),
      );
    }

   final (res, code) = await _api.post(
  '',
  body: formData,
  query: {'endpoint': routerEndpoint},
);


    if (code == 200 || code == 201) {
      return SnowRegisterResponse.fromJson(Map<String, dynamic>.from(res.data));
    }

    throw Exception(_extractError(res, code));
  }

  /// Utility: extract readable error message
  String _extractError(Response res, int? code) {
    try {
      final data = res.data;
      if (data is Map && (data['message'] != null || data['error'] != null)) {
        return (data['message'] ?? data['error']).toString();
      }
    } catch (_) {}

    return 'Something went wrong (${code ?? res.statusCode ?? 'unknown'})';
  }
}
