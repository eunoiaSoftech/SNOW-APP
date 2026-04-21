import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/Data/models/register_response.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';


class BaseSignupRepository {
  final ApiClient _api = ApiClient.create();

  static Uri get _base =>
      Uri.parse(dotenv.env['BASE_URL'] ?? '');

  Future<Result<RegisterResponse>> register({
    required Map<String, dynamic> body,
    required File aadhar,
    required File photo,
  }) async {
    try {
      final uri = _base.replace(
        queryParameters: {'endpoint': 'user/register'},
      );

      final formData = FormData();

      // fields
      body.forEach((k, v) {
        formData.fields.add(MapEntry(k, v.toString()));
      });

      // files
      formData.files.addAll([
        MapEntry(
          'aadhar_file',
          await MultipartFile.fromFile(aadhar.path),
        ),
        MapEntry(
          'user_photo',
          await MultipartFile.fromFile(photo.path),
        ),
      ]);

      print("🚀 API HIT => $body");

      final (res, code) = await _api.postUri(uri, body: formData);

      print("📡 RESPONSE => ${res.data}");

      if (code == 200 || code == 201) {
        return Ok(RegisterResponse.fromJson(res.data));
      }

      return Err(res.data.toString(), code: code);
    } catch (e) {
      print("❌ ERROR => $e");
      return Err(e.toString());
    }
  }
}