import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snow_app/Data/models/New Model/locations.dart';
import 'package:snow_app/core/api_client.dart';

class LocationRepository {
  final ApiClient _api = ApiClient.create();

  static const String _endpoint = '/api/v1/auth/location-data';

  Future<LocationResponse> fetchLocations() async {
    try {
      print("🌐 GET Request → $_endpoint");

      final response = await _api.get(_endpoint) as (http.Response, int);
      final (http.Response res, int code) = response;

      print("📥 Response Code: $code");
      print("📦 Raw Response Body: ${res.body}");

      if (code == 200) {
        final decoded = jsonDecode(res.body);
        return LocationResponse.fromJson(decoded);
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in fetchLocations: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  String _extractError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
    } catch (_) {}
    return 'Something went wrong (${res.statusCode})';
  }
}
