import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/New%20Model/abs_sbog.dart';
import 'package:snow_app/Data/models/New%20Model/sbog_model.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySbog {
  final ApiClient _api = ApiClient.create();

  /// Fetch SBOG records with optional filters
  Future<SbogAbResponse> fetchSbogRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? q,
    int? businessId,
  }) async {
    const endpoint = '/referrals/received-referrals';

    Map<String, dynamic> query = {};

    if (startDate != null) query['start_date'] = _formatDate(startDate);
    if (endDate != null) query['end_date'] = _formatDate(endDate);
    if (q != null && q.isNotEmpty) query['q'] = q;
    if (businessId != null) query['business_id'] = businessId.toString();

    try {
      print("🌐 GET Request → $endpoint with $query");
      final (res, code) = await _api.get(endpoint, query: query);

      print("📥 Response Code: $code");
      print("📦 Response Data: ${res.data}");

      if (code == 200) {
        return SbogAbResponse.fromJson(res.data);
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in fetchSbogRecords: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Record a new SBOG (POST)
  Future<Map<String, dynamic>> recordSbog(Map<String, dynamic> body) async {
    const endpoint = '/referrals/create-sbog';

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
      print("❌ Network/Server Error in recordSbog: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
  }

  String _extractError(Response res) {
    final data = res.data;
    if (data is Map && data['message'] != null) return data['message'];
    return 'Something went wrong (${res.statusCode})';
  }
}
