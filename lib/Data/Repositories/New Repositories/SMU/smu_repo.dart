import 'package:snow_app/Data/models/New%20Model/SMU%20MODEL/smu_model.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySmu {
  final ApiClient _api = ApiClient.create();

  /// 🔹 LIST SMU  
  Future<SmuListResponse> fetchSmuRecords({
    bool filterForMe = false,
    bool showOnlyMy = false,
  }) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "smu/list",
      "filter_for_me": filterForMe.toString(),
      "show_only_my": showOnlyMy.toString(),
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200) {
        return SmuListResponse.fromJson(res.data);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  /// 🔹 CREATE SMU
  Future<Map<String, dynamic>> createSmu(Map<String, dynamic> body) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "smu/create",
    };

    try {
      final (res, code) = await _api.post(
        endpoint,
        query: query,
        body: body,
      );

      if (code == 200 || code == 201) {
        return res.data;
      } else {
        throw Exception("Failed: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
