import 'package:snow_app/Data/models/New%20Model/SBOL%20MODEL/sbol_model.dart';
import 'package:snow_app/core/api_client.dart';

class ReferralsRepositorySbol {
  final ApiClient _api = ApiClient.create();

  /// ✅ LIST SBOL (correct Postman endpoint)
  Future<SbolListResponse> fetchSbolRecords(int businessId) async {
    const endpoint = "router.php"; 

    final query = {
      "endpoint": "sbol/list",
      "business_id": businessId.toString(),
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200) {
        return SbolListResponse.fromJson(res.data);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  /// ✅ CREATE SBOL (correct Postman endpoint)
  Future<Map<String, dynamic>> recordSbol(Map<String, dynamic> body) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "sbol/create",
    };

    try {
      final (res, code) = await _api.post(
        endpoint,
        body: body,
        query: query,
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
