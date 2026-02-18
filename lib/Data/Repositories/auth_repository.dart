// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:snow_app/Data/models/login_response.dart';
// import 'package:snow_app/Data/models/register_response.dart';
// import '../../core/api_client.dart';
// import '../../core/result.dart';

// class AuthRepository {
//   AuthRepository();

//   final ApiClient _api = ApiClient.create();
//   static Uri get _routerBase =>
//       Uri.parse(dotenv.env['BASE_URL'] ?? '');

//   // Future<Result<RegisterResponse>> signup(Map<String, dynamic> body) async {
//   //   final uri = _routerBase.replace(queryParameters: {'endpoint': 'user/register'});
//   //   final (res, code) = await _api.postUri(uri, body: body);
//   //   if (code == 201 || code == 200 || code == 202) {
//   //     return Ok(RegisterResponse.fromJson(res.data as Map<String, dynamic>));
//   //   }
//   //   final msg = _extractError(res);
//   //   return Err(msg, code: code);
//   // }
//   Future<Result<RegisterResponse>> signup({
//     required Map<String, dynamic> body,
//     File? aadharFile,
//   }) async {
//     final uri = _routerBase.replace(
//       queryParameters: {'endpoint': 'user/register'},
//     );

//     const int maxAadharSize = 2 * 1024 * 1024; // 2 MB

//     final formData = FormData();

//     Future<void> validateAadharFile(File file) async {
//       final size = await file.length();
//       if (size > maxAadharSize) {
//         throw Exception('Aadhaar image must be under 2MB');
//       }
//     }

//     // Add text fields
//     body.forEach((key, value) {
//       if (value != null) {
//         formData.fields.add(MapEntry(key, value.toString()));
//       }
//     });

//     // Add Aadhaar file
//     if (aadharFile != null) {
//       await validateAadharFile(aadharFile);

//       formData.files.add(
//         MapEntry(
//           'aadhar_file',
//           await MultipartFile.fromFile(aadharFile.path, filename: 'aadhar.jpg'),
//         ),
//       );
//     }

//     final (res, code) = await _api.postUri(uri, body: formData);

//     if (code == 200 || code == 201 || code == 202) {
//       return Ok(RegisterResponse.fromJson(res.data));
//     }

//     return Err(_extractError(res), code: code);
//   }

//   Future<Result<LoginResponse>> login({
//     required String email,
//     required String password,
//   }) async {
//     final uri = _routerBase.replace(
//       queryParameters: {'endpoint': 'auth/login'},
//     );

//     final (res, code) = await _api.postUri(
//       uri,
//       body: {'email': email, 'password': password},
//     );

//     if (code == 200) {
//       final lr = LoginResponse.fromJson(res.data);
//       await _api.storage.saveToken(lr.token);
//       return Ok(lr);
//     }

//     final msg = _extractError(res);
//     return Err(msg, code: code);
//   }

//   Future<Result<void>> requestPasswordOtp(String email) async {
//     final uri = _routerBase.replace(
//       queryParameters: {'endpoint': 'auth/forgot-password'},
//     );
//     final (res, code) = await _api.postUri(uri, body: {'email': email});
//     if (code == 200) {
//       return const Ok(null);
//     }
//     final msg = _extractError(res);
//     return Err(msg, code: code);
//   }

//   Future<Result<String>> verifyResetOtp({
//     required String email,
//     required String otp,
//   }) async {
//     final uri = _routerBase.replace(
//       queryParameters: {'endpoint': 'auth/verify-reset-otp'},
//     );
//     final (res, code) = await _api.postUri(
//       uri,
//       body: {'email': email, 'otp': otp},
//     );
//     if (code == 200 && res.data is Map<String, dynamic>) {
//       final token = (res.data as Map<String, dynamic>)['reset_token']
//           ?.toString();
//       if (token != null && token.isNotEmpty) {
//         return Ok(token);
//       }
//     }
//     final msg = _extractError(res);
//     return Err(msg, code: code);
//   }

//   Future<Result<void>> resetPassword({
//     required String email,
//     required String resetToken,
//     required String newPassword,
//   }) async {
//     final uri = _routerBase.replace(
//       queryParameters: {'endpoint': 'auth/reset-password'},
//     );
//     final body = {
//       'email': email,
//       'reset_token': resetToken,
//       'new_password': newPassword,
//     };
//     final (res, code) = await _api.postUri(uri, body: body);
//     if (code == 200) {
//       return const Ok(null);
//     }
//     final msg = _extractError(res);
//     return Err(msg, code: code);
//   }

//   String _extractError(Response res) {
//     final data = res.data;

//     print("❌ API Error: ${res.statusCode} - ${res.data}");

//     if (data is Map) {
//       if (data['message'] is String) return data['message'];
//       if (data['error'] is String) return data['error'];
//     }

//     return 'Something went wrong (${res.statusCode})';
//   }
// }



import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/Data/models/login_response.dart';
import 'package:snow_app/Data/models/register_response.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';

class AuthRepository {
  AuthRepository();

  final ApiClient _api = ApiClient.create();

  static Uri get _routerBase =>
      Uri.parse(dotenv.env['BASE_URL'] ?? '');

  // ==============================
  // SIGNUP
  // ==============================
  Future<Result<RegisterResponse>> signup({
    required Map<String, dynamic> body,
    File? aadharFile,
  }) async {
    try {
      final uri = _routerBase.replace(
        queryParameters: {'endpoint': 'user/register'},
      );

      const int maxAadharSize = 2 * 1024 * 1024; // 2MB
      final formData = FormData();

      // Add text fields
      body.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add Aadhaar file
      if (aadharFile != null) {
        final size = await aadharFile.length();
        if (size > maxAadharSize) {
          return const Err('Aadhaar image must be under 2MB');
        }

        formData.files.add(
          MapEntry(
            'aadhar_file',
            await MultipartFile.fromFile(
              aadharFile.path,
              filename: 'aadhar.jpg',
            ),
          ),
        );
      }

      final (res, code) = await _api.postUri(uri, body: formData);

      if (code == 200 || code == 201 || code == 202) {
        return Ok(RegisterResponse.fromJson(res.data));
      }

      return Err(_extractError(res), code: code);
    } on DioException catch (e) {
return Err(
  _extractDioError(e),
  code: e.response?.statusCode ?? 0,
);
    } catch (e) {
      return Err(e.toString());
    }
  }

  // ==============================
  // LOGIN
  // ==============================
  Future<Result<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = _routerBase.replace(
        queryParameters: {'endpoint': 'auth/login'},
      );

      final (res, code) = await _api.postUri(
        uri,
        body: {'email': email, 'password': password},
      );

      if (code == 200) {
        final lr = LoginResponse.fromJson(res.data);
        await _api.storage.saveToken(lr.token);
        return Ok(lr);
      }

      return Err(_extractError(res), code: code);
    } on DioException catch (e) {
return Err(
  _extractDioError(e),
  code: e.response?.statusCode ?? 0,
);
    } catch (e) {
      return Err(e.toString());
    }
  }

  // ==============================
  // FORGOT PASSWORD
  // ==============================
  Future<Result<void>> requestPasswordOtp(String email) async {
    try {
      final uri = _routerBase.replace(
        queryParameters: {'endpoint': 'auth/forgot-password'},
      );

      final (res, code) =
          await _api.postUri(uri, body: {'email': email});

      if (code == 200) {
        return const Ok(null);
      }

      return Err(_extractError(res), code: code);
    } on DioException catch (e) {
return Err(
  _extractDioError(e),
  code: e.response?.statusCode ?? 0,
);
    }
  }

  Future<Result<String>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final uri = _routerBase.replace(
        queryParameters: {'endpoint': 'auth/verify-reset-otp'},
      );

      final (res, code) = await _api.postUri(
        uri,
        body: {'email': email, 'otp': otp},
      );

      if (code == 200 && res.data is Map<String, dynamic>) {
        final token =
            (res.data as Map<String, dynamic>)['reset_token']?.toString();

        if (token != null && token.isNotEmpty) {
          return Ok(token);
        }
      }

      return Err(_extractError(res), code: code);
    } on DioException catch (e) {
return Err(
  _extractDioError(e),
  code: e.response?.statusCode ?? 0,
);
    }
  }

  Future<Result<void>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final uri = _routerBase.replace(
        queryParameters: {'endpoint': 'auth/reset-password'},
      );

      final body = {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
      };

      final (res, code) = await _api.postUri(uri, body: body);

      if (code == 200) {
        return const Ok(null);
      }

      return Err(_extractError(res), code: code);
    } on DioException catch (e) {
return Err(
  _extractDioError(e),
  code: e.response?.statusCode ?? 0,
);
    }
  }

  // ==============================
  // ERROR EXTRACTOR (IMPORTANT)
  // ==============================
  String _extractError(Response res) {
    final data = res.data;

    print("❌ API Error: ${res.statusCode} - ${res.data}");

    if (data is Map<String, dynamic>) {
      if (data['message'] is String &&
          data['message'].toString().isNotEmpty) {
        return data['message'];
      }

      if (data['error'] is String &&
          data['error'].toString().isNotEmpty) {
        return data['error'];
      }
    }

    return "Error ${res.statusCode}";
  }

  String _extractDioError(DioException e) {
    final data = e.response?.data;

    print("❌ Dio Error: ${e.response?.statusCode} - $data");

    if (data is Map<String, dynamic>) {
      if (data['message'] is String &&
          data['message'].toString().isNotEmpty) {
        return data['message'];
      }

      if (data['error'] is String &&
          data['error'].toString().isNotEmpty) {
        return data['error'];
      }
    }

    return e.message ?? "Network error occurred";
  }
}
