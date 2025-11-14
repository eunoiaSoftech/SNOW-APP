import 'package:snow_app/Data/models/New%20Model/SBOR%20MODEL/sbor_model.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySbor {
  final ApiClient _api = ApiClient.create();

  Future<Map<String, dynamic>> createSbor(Map<String, dynamic> body) async {
    const endpoint = "router.php";


    final query = {"endpoint": "sbor/create"};



    try {
      final (res, code) = await _api.post(endpoint, body: body, query: query);

      if (code == 200 || code == 201) {
        return res.data;
      } else {
        throw Exception("Failed: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  /// 🔹 LIST SBOR
  Future<SborListResponse> fetchSborRecords() async {
    const endpoint = "router.php";

    final query = {"endpoint": "sbor/list", "show_only_my": "true"};

    final (res, code) = await _api.get(endpoint, query: query);

    if (code == 200) {
      return SborListResponse.fromJson(res.data);
    } else {
      throw Exception("Error: ${res.data}");
    }
  }
}
