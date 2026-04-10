import 'package:snow_app/Data/models/New%20Model/SBOG%20MODEL/abs_sbog.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySbog {
  final ApiClient _api = ApiClient.create();

  /// LIST SBOG
  Future<SbogListResponse> fetchSbogRecords({
    bool filterForMe = false,
    bool showOnlyMy = false,
  }) async {
    const endpoint = "router.php";
    final query = {
      "endpoint": "sbog/list",
      "filter_for_me": filterForMe.toString(),
      "show_only_my": showOnlyMy.toString(),
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);
      if (code == 200) {
        return SbogListResponse.fromJson(res.data);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  /// CREATE SBOG
  Future<Map<String, dynamic>> recordSbog(Map<String, dynamic> body) async {
    const endpoint = "router.php";
    const query = {
      "endpoint": "sbog/create",
    };

    try {
      final (res, code) =
          await _api.post(endpoint, query: query, body: body);

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
