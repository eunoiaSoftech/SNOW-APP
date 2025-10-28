import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/New Model/locations.dart';
import 'package:snow_app/core/api_client.dart';

class LocationRepository {
  final ApiClient _api = ApiClient.create();

  static const String _endpoint = '/auth/location-data';

  Future<LocationResponse> fetchLocations() async {
    try {
      print("🌐 GET Request → $_endpoint");

      // ✅ Correctly unpack the tuple
      final (Response res, int code) = await _api.get(_endpoint);

      print("📥 Response Code: $code");
      print("📦 Raw Response Body: ${res.data}");

      if (code == 200) {
        final decoded = res.data is Map ? res.data : jsonDecode(res.data);
        return LocationResponse.fromJson(decoded);
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in fetchLocations: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  String _extractError(Response res) {
    try {
      final data = res.data is Map ? res.data : jsonDecode(res.data);
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
    } catch (_) {}
    return 'Something went wrong (${res.statusCode})';
  }
}
