import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/core/api_client.dart';

class AppreciationTestimonialRepository {
  final ApiClient _api = ApiClient.create();

  static Uri get _base => Uri.parse(dotenv.env['BASE_URL'] ?? '');

  // ================================
  // ✅ UPLOAD IMAGE (CORRECT FOR YOUR SETUP)
  // ================================
  Future<String> uploadImage(File file) async {
    try {
      final base = dotenv.env['BASE_URL']!;

      // ✅ CORRECT ENDPOINT
      final uri = Uri.parse(
        base,
      ).replace(queryParameters: {"endpoint": "upload/images"});

      final formData = FormData.fromMap({
        // ✅ IMPORTANT: images[] (ARRAY FORMAT)
        "images[]": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final (res, code) = await _api.postUri(uri, body: formData);

      print("UPLOAD URL => $uri");
      print("UPLOAD RESPONSE => ${res.data}");

      if (code == 200 || code == 201) {
        final data = res.data;

        // ✅ CORRECT RESPONSE PARSING
        if (data["files"] != null &&
            data["files"] is List &&
            data["files"].isNotEmpty) {
          return data["files"][0]["url"];
        }

        throw Exception("Upload failed: No file returned");
      }

      throw Exception(res.data.toString());
    } catch (e) {
      throw Exception("Upload error: $e");
    }
  }

  // ================================
  // CREATE APPRECIATION
  // ================================
  Future<String> createAppreciation({
    required int memberUserId,
    required String description,
    required String photo,
  }) async {
    final (res, code) = await _api.post(
      "/",
      query: {"endpoint": "appreciation/create"},
      body: {
        "member_user_id": memberUserId,
        "description": description,
        "photo": photo,
      },
    );

    if (code == 200 || code == 201) {
      return res.data['message'] ?? "Created";
    }

    throw Exception(res.data['error'] ?? "Failed");
  }

  // ================================
  // CREATE TESTIMONIAL
  // ================================
  Future<String> createTestimonial({
    required int memberUserId,
    required String description,
    required String link,
    required String photo,
  }) async {
    final (res, code) = await _api.post(
      "/",
      query: {"endpoint": "testimonial/create"},
      body: {
        "member_user_id": memberUserId,
        "description": description,
        "link": link,
        "photo": photo,
      },
    );

    if (code == 200 || code == 201) {
      return res.data['message'] ?? "Created";
    }

    throw Exception(res.data['error'] ?? "Failed");
  }
  // ================================
// GET TESTIMONIAL LIST
// ================================
Future<List<dynamic>> getTestimonials() async {
  final (res, code) = await _api.get(
    "/",
    query: {"endpoint": "testimonial/list"},
  );

  if (code == 200 && res.data["success"] == true) {
    return res.data["data"] ?? [];
  }

  throw Exception("Failed to load testimonials");
}

// ================================
// GET APPRECIATION LIST
// ================================
Future<List<dynamic>> getAppreciations() async {
  final (res, code) = await _api.get(
    "/",
    query: {"endpoint": "appreciation/list"},
  );

  if (code == 200 && res.data["success"] == true) {
    return res.data["data"] ?? [];
  }

  throw Exception("Failed to load appreciations");
}
}
