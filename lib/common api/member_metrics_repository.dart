import 'package:snow_app/Data/models/New%20Model/APP%20SETTING/member_metrics_model.dart';
import 'package:snow_app/core/api_client.dart';

class MemberMetricsRepository {
  final ApiClient _api = ApiClient.create();

  Future<List<MemberMetrics>> fetchMetrics({
    required String period,
    int page = 1,          // ✅ dynamic
    int perPage = 20,     // ✅ dynamic
  }) async {
    const endpoint = "/";

    final query = {
      "endpoint": "admin/business-metrics",
      "period": period,
      "page": page.toString(),
      "per_page": perPage.toString(),
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200) {
        final data = res.data;

        if (data is Map<String, dynamic>) {
          final rawList = data['data'];

          if (rawList is List) {
            return rawList
                .map((e) =>
                    MemberMetrics.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }

        return [];
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}