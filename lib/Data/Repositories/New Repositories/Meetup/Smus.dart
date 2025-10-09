import 'package:dio/dio.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/Data/models/New Model/record_smus_response.dart';

class ReferralsRepositorysums {
  final ApiClient _api = ApiClient.create();

  /// 🧾 Fetch all SMU records
  Future<SmusResponse> fetchSmusRecords({bool showOnlyMy = false}) async {
    final endpoint = '/referrals/abstract-smus';
    try {
      print("🌐 GET Request → $endpoint");
      final (res, code) = await _api.get(endpoint, query: {
        'show_only_my': showOnlyMy.toString(),
      });
      print("📥 Response Code: $code");
      print("📦 Response Data: ${res.data}");

      if (code == 200) {
        return SmusResponse.fromJson(res.data);
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in fetchSmusRecords: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// 🧾 Record a new SMU (POST)
  Future<Map<String, dynamic>> recordSmus(Map<String, dynamic> body) async {
    final endpoint = '/referrals/record-smus';
    try {
      print("🌐 POST Request → $endpoint");
      print("📤 Body: $body");

      final (res, code) = await _api.post(endpoint, body: body);

      print("📥 Response Code: $code");
      print("📦 Response Body: ${res.data}");

      if (code == 200 || code == 201) {
        return res.data;
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in recordSmus: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  String _extractError(Response res) {
    final data = res.data;
    if (data is Map && data['message'] != null) return data['message'];
    return 'Something went wrong (${res.statusCode})';
  }
}
