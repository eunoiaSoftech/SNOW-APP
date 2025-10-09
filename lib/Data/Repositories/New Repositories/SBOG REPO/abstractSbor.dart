import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/New Model/abs_sbor.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySbor {
  final ApiClient _api = ApiClient.create();

  /// Fetch SBOR abstract records with optional filters
  Future<SborAbResponse> fetchSborRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? q,
    String filter = "creator",
  }) async {
    const endpoint = '/referrals/abstract-sbor';

    Map<String, dynamic> query = {};

    if (startDate != null) query['start_date'] = _formatDate(startDate);
    if (endDate != null) query['end_date'] = _formatDate(endDate);
    if (q != null && q.isNotEmpty) query['q'] = q;
    if (filter.isNotEmpty) query['filter'] = filter;

    try {
      print("🌐 GET Request → $endpoint with $query");
      final (res, code) = await _api.get(endpoint, query: query);

      print("📥 Response Code: $code");
      print("📦 Response Data: ${res.data}");

      if (code == 200) {
        return SborAbResponse.fromJson(res.data);
      } else {
        throw Exception(_extractError(res));
      }
    } catch (e) {
      print("❌ Network/Server Error in fetchSborRecords: $e");
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Utility: format date as yyyy-MM-dd
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Utility: extract readable error message
  String _extractError(Response res) {
    final data = res.data;
    if (data is Map && data['message'] != null) return data['message'];
    return 'Something went wrong (${res.statusCode})';
  }
}
